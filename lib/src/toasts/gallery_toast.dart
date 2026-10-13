import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../core/gallery_theme.dart';

enum UiGalleryToastPreset { signal, ribbon, action }

enum UiGalleryToastKind { info, success, warning, error }

enum UiGalleryToastPosition { top, bottom }

enum UiGalleryToastDuplicates { ignore, replace, allow }

enum UiGalleryToastScope { route, overlay }

/// A handle never retains the caller's BuildContext. Safe after route disposal.
class UiGalleryToastHandle {
  UiGalleryToastHandle._(this._dismiss, this.closed);
  final VoidCallback _dismiss;
  final Future<void> closed;
  void dismiss() => _dismiss();
}

abstract final class UiGalleryToast {
  static final Expando<_ToastQueue> _routes = Expando('UiGallery route toasts');
  static final Expando<_ToastQueue> _overlays = Expando(
    'UiGallery overlay toasts',
  );

  /// FIFO queue. [maxVisible] applies to this route/overlay queue, including
  /// entries exiting. Duplicate identity defaults to message + status.
  ///
  /// Route-scoped toasts are cleared on pop, removal and replacement. Overlay
  /// scope lasts until dismissal, timeout or disposal of the selected overlay.
  /// With accessible navigation, actionable notifications do not expire.
  static UiGalleryToastHandle show(
    BuildContext context, {
    required String message,
    UiGalleryToastPreset preset = UiGalleryToastPreset.signal,
    UiGalleryToastKind kind = UiGalleryToastKind.info,
    UiGalleryToastPosition position = UiGalleryToastPosition.bottom,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    bool showProgress = false,
    int maxVisible = 2,
    String? duplicateKey,
    UiGalleryToastDuplicates duplicates = UiGalleryToastDuplicates.ignore,
    UiGalleryToastScope scope = UiGalleryToastScope.route,
    bool rootOverlay = false,
    UiGalleryTheme? appearance,
  }) {
    if (!context.mounted) {
      throw StateError('Cannot show a toast from an unmounted context.');
    }
    if (maxVisible < 1) {
      throw ArgumentError.value(
        maxVisible,
        'maxVisible',
        'Must be at least one',
      );
    }
    if (duration.isNegative) {
      throw ArgumentError.value(duration, 'duration');
    }
    if ((actionLabel == null) != (onAction == null)) {
      throw ArgumentError('Provide both actionLabel and onAction.');
    }
    final overlay = Overlay.of(context, rootOverlay: rootOverlay);
    final route = scope == UiGalleryToastScope.route
        ? ModalRoute.of(context)
        : null;
    if (scope == UiGalleryToastScope.route && route == null) {
      throw StateError(
        'Route-scoped toasts need a context inside a ModalRoute.',
      );
    }
    var queue = route == null ? _overlays[overlay] : _routes[route];
    if (queue == null || queue.disposed) {
      queue = _ToastQueue(overlay, route);
      if (route == null) {
        _overlays[overlay] = queue;
      } else {
        _routes[route] = queue;
      }
    }
    final item = _ToastItem(
      message: message,
      preset: preset,
      kind: kind,
      position: position,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      showProgress: showProgress,
      appearance: appearance,
      identity: duplicateKey ?? '${kind.name}:$message',
      themes: InheritedTheme.capture(from: context, to: overlay.context),
    );
    return queue.add(item, maxVisible, duplicates);
  }

  static UiGalleryToastHandle success(
    BuildContext context, {
    required String message,
    UiGalleryToastPreset preset = UiGalleryToastPreset.signal,
    Duration duration = const Duration(seconds: 4),
  }) => show(
    context,
    message: message,
    kind: UiGalleryToastKind.success,
    preset: preset,
    duration: duration,
  );

  static UiGalleryToastHandle error(
    BuildContext context, {
    required String message,
    UiGalleryToastPreset preset = UiGalleryToastPreset.ribbon,
    Duration duration = const Duration(seconds: 6),
  }) => show(
    context,
    message: message,
    kind: UiGalleryToastKind.error,
    preset: preset,
    duration: duration,
  );

  static UiGalleryToastHandle warning(
    BuildContext context, {
    required String message,
    UiGalleryToastPreset preset = UiGalleryToastPreset.ribbon,
    Duration duration = const Duration(seconds: 6),
  }) => show(
    context,
    message: message,
    kind: UiGalleryToastKind.warning,
    preset: preset,
    duration: duration,
  );
}

// Backwards-compatible aliases
typedef NovaToast = UiGalleryToast;
typedef NovaToastPreset = UiGalleryToastPreset;
typedef NovaToastKind = UiGalleryToastKind;
typedef NovaToastPosition = UiGalleryToastPosition;
typedef NovaToastDuplicates = UiGalleryToastDuplicates;
typedef NovaToastScope = UiGalleryToastScope;
typedef NovaToastHandle = UiGalleryToastHandle;

class _ToastItem {
  _ToastItem({
    required this.message,
    required this.preset,
    required this.kind,
    required this.position,
    required this.duration,
    required this.showProgress,
    required this.identity,
    required this.themes,
    this.actionLabel,
    this.onAction,
    this.appearance,
  });
  final String message;
  final String identity;
  final UiGalleryToastPreset preset;
  final UiGalleryToastKind kind;
  final UiGalleryToastPosition position;
  final Duration duration;
  final bool showProgress;
  final CapturedThemes themes;
  final String? actionLabel;
  final VoidCallback? onAction;
  final UiGalleryTheme? appearance;
  final Completer<void> completion = Completer<void>();
  late UiGalleryToastHandle handle;
  bool dismissing = false;
}

class _ToastQueue extends ChangeNotifier {
  _ToastQueue(this.overlay, this.route) {
    route?.popped.then((_) => dispose());
    route?.completed.then((_) => dispose());
  }
  final OverlayState overlay;
  final ModalRoute<dynamic>? route;
  final Queue<_ToastItem> pending = Queue();
  final List<_ToastItem> visible = [];
  OverlayEntry? entry;
  int limit = 2;
  bool disposed = false;

  UiGalleryToastHandle add(
    _ToastItem item,
    int maxVisible,
    UiGalleryToastDuplicates policy,
  ) {
    final matching = [
      ...visible,
      ...pending,
    ].where((e) => e.identity == item.identity);
    if (matching.isNotEmpty && policy == UiGalleryToastDuplicates.ignore) {
      return matching.first.handle;
    }
    if (policy == UiGalleryToastDuplicates.replace) {
      for (final old in matching.toList()) {
        _remove(old);
      }
    }
    limit = maxVisible;
    item.handle = UiGalleryToastHandle._(
      () => dismiss(item),
      item.completion.future,
    );
    pending.add(item);
    _advance();
    return item.handle;
  }

  void _advance() {
    if (disposed) return;
    while (visible.length < limit && pending.isNotEmpty) {
      visible.add(pending.removeFirst());
    }
    if (visible.isNotEmpty && entry == null) {
      late final OverlayEntry newEntry;
      newEntry = OverlayEntry(
        maintainState: true,
        builder: (_) => _ToastHost(queue: this, owner: newEntry),
      );
      entry = newEntry;
      overlay.insert(newEntry);
    } else if (visible.isEmpty && pending.isEmpty) {
      _removeEntry();
    }
    notifyListeners();
  }

  void dismiss(_ToastItem item) {
    if (disposed || item.dismissing || item.completion.isCompleted) return;
    if (pending.remove(item)) {
      item.completion.complete();
      _advance();
    } else {
      item.dismissing = true;
      notifyListeners();
    }
  }

  void _remove(_ToastItem item) {
    visible.remove(item);
    pending.remove(item);
    if (!item.completion.isCompleted) item.completion.complete();
  }

  void finish(_ToastItem item) {
    if (disposed) return;
    _remove(item);
    _advance();
  }

  void _removeEntry() {
    final previous = entry;
    entry = null;
    previous?.remove();
    previous?.dispose();
  }

  void hostDisposed(OverlayEntry owner) {
    if (identical(entry, owner)) dispose();
  }

  @override
  void dispose() {
    if (disposed) return;
    disposed = true;
    for (final item in [...visible, ...pending]) {
      if (!item.completion.isCompleted) item.completion.complete();
    }
    visible.clear();
    pending.clear();
    _removeEntry();
    super.dispose();
  }
}

class _ToastHost extends StatefulWidget {
  const _ToastHost({required this.queue, required this.owner});
  final _ToastQueue queue;
  final OverlayEntry owner;
  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost> {
  @override
  void dispose() {
    widget.queue.hostDisposed(widget.owner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      widget.queue,
      widget.queue.route?.animation,
      widget.queue.route?.secondaryAnimation,
    ]),
    builder: (context, _) {
      final queue = widget.queue;
      return Positioned.fill(
        child: Offstage(
          offstage: queue.route != null && !queue.route!.isCurrent,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Stack(
                children: [
                  for (final position in UiGalleryToastPosition.values)
                    Align(
                      alignment: position == UiGalleryToastPosition.top
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final item in queue.visible.where(
                                  (i) => i.position == position,
                                ))
                                  item.themes.wrap(
                                    _ToastTile(
                                      key: ObjectKey(item),
                                      item: item,
                                      queue: queue,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ToastTile extends StatefulWidget {
  const _ToastTile({super.key, required this.item, required this.queue});
  final _ToastItem item;
  final _ToastQueue queue;
  @override
  State<_ToastTile> createState() => _ToastTileState();
}

class _ToastTileState extends State<_ToastTile> with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(vsync: this);
  late final AnimationController _timeout = AnimationController(vsync: this);
  Timer? _timer;
  bool _started = false;
  bool _closing = false;
  bool _acted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = UiGalleryStyle.of(context, widget.item.appearance);
    _entrance.duration = s.duration(UiGalleryTokens.exit);
    if (!_started) {
      _started = true;
      _entrance.forward();
    }
    // Re-evaluate accessibility while visible without restarting normal timeouts.
    if (s.media.accessibleNavigation && widget.item.onAction != null) {
      _timer?.cancel();
      _timer = null;
      _timeout.stop();
    } else if (_timer == null && !_closing) {
      var duration = widget.item.duration;
      if (s.media.accessibleNavigation &&
          duration < const Duration(seconds: 8)) {
        duration = const Duration(seconds: 8);
      }
      if (duration > Duration.zero) {
        _timer = Timer(duration, () => widget.queue.dismiss(widget.item));
        if (widget.item.showProgress && !s.reduceMotion) {
          _timeout.duration = duration;
          _timeout.forward(from: 0);
        }
      }
    }
    if (s.reduceMotion) {
      _timeout.stop();
      _entrance.value = 1;
    }
    if (widget.item.dismissing) _close();
  }

  @override
  void didUpdateWidget(_ToastTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.dismissing) _close();
  }

  void _close() {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    _timeout.stop();
    _entrance.reverse().whenCompleteOrCancel(() {
      if (mounted) widget.queue.finish(widget.item);
    });
  }

  void _action() {
    if (_acted || _closing) return;
    _acted = true;
    try {
      widget.item.onAction?.call();
    } finally {
      widget.queue.dismiss(widget.item);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entrance.dispose();
    _timeout.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final s = UiGalleryStyle.of(context, item.appearance);
    final ribbon = item.preset == UiGalleryToastPreset.ribbon;
    final color = switch (item.kind) {
      UiGalleryToastKind.error => s.theme.colorScheme.error,
      UiGalleryToastKind.warning => s.theme.colorScheme.tertiary,
      _ => s.accent,
    };
    final icon = switch (item.kind) {
      UiGalleryToastKind.info => Icons.info_outline_rounded,
      UiGalleryToastKind.success => Icons.check_rounded,
      UiGalleryToastKind.warning => Icons.priority_high_rounded,
      UiGalleryToastKind.error => Icons.close_rounded,
    };
    final radius = BorderRadius.circular(
      ribbon
          ? 8
          : item.preset == UiGalleryToastPreset.signal
          ? 32
          : 20,
    );
    final measure = TextPainter(
      text: TextSpan(text: item.message, style: s.theme.textTheme.bodyMedium),
      textDirection: Directionality.of(context),
      textScaler: s.media.textScaler,
    )..layout();
    final messageWidth = measure.width;
    measure.dispose();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = ribbon || item.actionLabel != null
            ? constraints.maxWidth
            : (messageWidth + 108).clamp(0.0, constraints.maxWidth);
        return SizedBox(
          width: width,
          child: AnimatedBuilder(
            animation: _entrance,
            builder: (context, child) {
              final t = UiGalleryTokens.curve.transform(_entrance.value);
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    (1 - t) *
                        (item.position == UiGalleryToastPosition.top
                            ? -24
                            : 24),
                  ),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Semantics(
                container: true,
                liveRegion: true,
                child: Material(
                  color: s.surface,
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: .18),
                  shape: RoundedRectangleBorder(
                    borderRadius: radius,
                    side: BorderSide(color: s.line),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: ribbon
                            ? BoxDecoration(
                                border: BorderDirectional(
                                  start: BorderSide(color: color, width: 4),
                                ),
                              )
                            : null,
                        padding: const EdgeInsetsDirectional.only(
                          start: 16,
                          end: 4,
                          top: 4,
                          bottom: 4,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked =
                                item.actionLabel != null &&
                                (constraints.maxWidth < 380 ||
                                    s.media.textScaler.scale(1) > 1.3);
                            final close = IconButton(
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip,
                              onPressed: () => widget.queue.dismiss(item),
                              icon: Icon(Icons.close, size: 16, color: s.muted),
                            );
                            final action = item.actionLabel == null
                                ? null
                                : TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: color,
                                      minimumSize: const Size(48, 48),
                                    ),
                                    onPressed: _closing ? null : _action,
                                    child: Text(item.actionLabel!),
                                  );
                            final message = Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, color: color, size: 20),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      item.message,
                                      style: s.theme.textTheme.bodyMedium
                                          ?.copyWith(color: s.content),
                                    ),
                                  ),
                                ),
                                if (!stacked && action != null)
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 8,
                                    ),
                                    child: action,
                                  ),
                                if (!stacked) close,
                              ],
                            );
                            return stacked
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      message,
                                      Wrap(
                                        alignment: WrapAlignment.end,
                                        children: [action!, close],
                                      ),
                                    ],
                                  )
                                : message;
                          },
                        ),
                      ),
                      if (item.showProgress &&
                          !s.reduceMotion &&
                          item.duration > Duration.zero &&
                          !(s.media.accessibleNavigation &&
                              item.onAction != null))
                        AnimatedBuilder(
                          animation: _timeout,
                          builder: (context, _) => ExcludeSemantics(
                            child: LinearProgressIndicator(
                              value: 1 - _timeout.value,
                              minHeight: 2,
                              color: color,
                              backgroundColor: s.line,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
