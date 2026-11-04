import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueListenable;

import '../core/gallery_theme.dart';
import '../core/gallery_style.dart';
import '../core/gallery_signature.dart';
import '../core/gallery_shape.dart';

enum UiGalleryToastPreset {
  signal,
  ribbon,
  action,
  stackTag,
  inlinePulse,
  beacon,
  ribbonActionBar,
  dock,
  snapNotice,
  miniConsole,
  progressCard;

  static const signalPill = signal;
  static const edgeRibbon = ribbon;
  static const actionCapsule = action;
  static const beaconToast = beacon;
  static const dockToast = dock;
}

enum UiGalleryToastKind { info, success, warning, error }

enum UiGalleryToastPosition { top, bottom }

enum UiGalleryToastDuplicates { ignore, replace, allow }

enum UiGalleryToastScope { route, overlay }

/// A handle never retains the caller's BuildContext. Safe after route disposal.
class UiGalleryToastHandle {
  UiGalleryToastHandle._(this._dismiss, this.closed) {
    closed.then((_) => _dismiss = null);
  }
  VoidCallback? _dismiss;
  final Future<void> closed;
  void dismiss() => _dismiss?.call();
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
    ValueListenable<double>? progressValue,
    String Function(double value)? progressLabelBuilder,
    int maxVisible = 2,
    String? duplicateKey,
    UiGalleryToastDuplicates duplicates = UiGalleryToastDuplicates.ignore,
    UiGalleryToastScope scope = UiGalleryToastScope.route,
    bool rootOverlay = false,
    UiGalleryTheme? appearance,
    UiGallerySurfaceStyle? style,
    UiGalleryMotion? motion,
    Widget? icon,
    Widget? leading,
    Widget? trailing,
    String? title,
    String? semanticLabel,
    EdgeInsetsGeometry? margin,
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
      progressValue: progressValue,
      progressLabelBuilder: progressLabelBuilder,
      appearance: appearance,
      style: style,
      motion: motion,
      icon: icon,
      leading: leading,
      trailing: trailing,
      title: title,
      semanticLabel: semanticLabel,
      margin: margin,
      focusParent:
          (preset == UiGalleryToastPreset.ribbonActionBar ||
                  preset == UiGalleryToastPreset.action) &&
              scope == UiGalleryToastScope.route
          ? FocusScope.of(context)
          : null,
      identity: duplicateKey ?? '${kind.name}:$message',
      themes: InheritedTheme.capture(from: context, to: overlay.context),
    );
    return queue.add(item, maxVisible, duplicates);
  }

  /// Displays caller-owned task progress until explicitly dismissed.
  static UiGalleryToastHandle progress(
    BuildContext context, {
    required String message,
    required ValueListenable<double> progress,
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
    String Function(double value)? progressLabelBuilder,
    UiGallerySurfaceStyle? style,
    UiGalleryMotion? motion,
    UiGalleryTheme? appearance,
    String? duplicateKey,
  }) => show(
    context,
    message: message,
    title: title,
    preset: UiGalleryToastPreset.progressCard,
    duration: Duration.zero,
    progressValue: progress,
    progressLabelBuilder: progressLabelBuilder,
    actionLabel: actionLabel,
    onAction: onAction,
    style: style,
    motion: motion,
    appearance: appearance,
    duplicateKey: duplicateKey,
    duplicates: UiGalleryToastDuplicates.allow,
  );

  static UiGalleryToastHandle success(
    BuildContext context, {
    required String message,
    UiGalleryToastPreset preset = UiGalleryToastPreset.signal,
    Duration duration = const Duration(seconds: 4),
    UiGallerySurfaceStyle? style,
    UiGalleryMotion? motion,
    UiGalleryTheme? appearance,
  }) => show(
    context,
    message: message,
    kind: UiGalleryToastKind.success,
    preset: preset,
    duration: duration,
    style: style,
    motion: motion,
    appearance: appearance,
  );

  static UiGalleryToastHandle error(
    BuildContext context, {
    required String message,
    UiGalleryToastPreset preset = UiGalleryToastPreset.ribbon,
    Duration duration = const Duration(seconds: 6),
    UiGallerySurfaceStyle? style,
    UiGalleryMotion? motion,
    UiGalleryTheme? appearance,
  }) => show(
    context,
    message: message,
    kind: UiGalleryToastKind.error,
    preset: preset,
    duration: duration,
    style: style,
    motion: motion,
    appearance: appearance,
  );

  static UiGalleryToastHandle warning(
    BuildContext context, {
    required String message,
    UiGalleryToastPreset preset = UiGalleryToastPreset.ribbon,
    Duration duration = const Duration(seconds: 6),
    UiGallerySurfaceStyle? style,
    UiGalleryMotion? motion,
    UiGalleryTheme? appearance,
  }) => show(
    context,
    message: message,
    kind: UiGalleryToastKind.warning,
    preset: preset,
    duration: duration,
    style: style,
    motion: motion,
    appearance: appearance,
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
    this.progressValue,
    this.progressLabelBuilder,
    required this.identity,
    required this.themes,
    this.actionLabel,
    this.onAction,
    this.appearance,
    this.style,
    this.motion,
    this.icon,
    this.leading,
    this.trailing,
    this.title,
    this.semanticLabel,
    this.margin,
    this.focusParent,
  });
  final FocusNode? focusParent;
  final String message;
  final String identity;
  final UiGalleryToastPreset preset;
  final UiGalleryToastKind kind;
  final UiGalleryToastPosition position;
  final Duration duration;
  final bool showProgress;
  final ValueListenable<double>? progressValue;
  final String Function(double value)? progressLabelBuilder;
  final CapturedThemes themes;
  final String? actionLabel;
  final VoidCallback? onAction;
  final UiGalleryTheme? appearance;
  final UiGallerySurfaceStyle? style;
  final UiGalleryMotion? motion;
  final Widget? icon, leading, trailing;
  final String? title, semanticLabel;
  final EdgeInsetsGeometry? margin;
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
    while (visible.length > limit) {
      pending.addFirst(visible.removeLast());
    }
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
                        padding: const EdgeInsets.all(UiGalleryTokens.space3),
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
    final s = UiGalleryStyle.of(
      context,
      widget.item.appearance,
      widget.item.style,
      widget.item.motion,
      UiGallerySurface.toast,
    );
    _entrance.duration = s.duration(s.motion.entrance);
    _entrance.reverseDuration = s.duration(s.motion.exit);
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
          duration > Duration.zero &&
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
    final s = UiGalleryStyle.of(
      context,
      item.appearance,
      item.style,
      item.motion,
      UiGallerySurface.toast,
    );
    final p = item.preset;
    final color = switch (item.kind) {
      UiGalleryToastKind.error => s.theme.colorScheme.error,
      UiGalleryToastKind.warning => s.theme.colorScheme.tertiary,
      _ => s.accent,
    };
    final rawMark =
        item.icon ??
        Icon(
          switch (item.kind) {
            UiGalleryToastKind.info => Icons.info_outline_rounded,
            UiGalleryToastKind.success => Icons.check_rounded,
            UiGalleryToastKind.warning => Icons.priority_high_rounded,
            UiGalleryToastKind.error => Icons.close_rounded,
          },
          color: color,
          size: 20,
        );
    final mark = GalleryFamilyMark(style: s, child: rawMark);
    final messageStyle = s.body(
      s.theme.textTheme.bodyMedium?.copyWith(
        color: s.content,
        fontFamily: p == UiGalleryToastPreset.miniConsole ? 'monospace' : null,
      ),
      monospace: p == UiGalleryToastPreset.miniConsole,
    );
    final message = Text(item.message, style: messageStyle);
    final close = IconButton(
      constraints: p == UiGalleryToastPreset.action && s.signatureEnabled
          ? const BoxConstraints(
              minWidth: UiGalleryTokens.touchTarget,
              minHeight: UiGalleryTokens.touchTarget,
            )
          : null,
      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
      onPressed: () => widget.queue.dismiss(item),
      icon: Icon(Icons.close, size: UiGalleryTokens.iconSmall, color: s.muted),
    );
    final action = item.actionLabel == null
        ? null
        : TextButton(
            style: TextButton.styleFrom(
              foregroundColor: color,
              minimumSize: const Size(
                UiGalleryTokens.touchTarget,
                UiGalleryTokens.touchTarget,
              ),
            ),
            onPressed: _closing ? null : _action,
            child: Text(item.actionLabel!),
          );
    final shape = s.shape(switch (p) {
      UiGalleryToastPreset.stackTag => BeveledRectangleBorder(
        borderRadius: const BorderRadiusDirectional.only(
          topEnd: Radius.circular(UiGalleryTokens.tagBevel),
        ),
        side: BorderSide(color: s.line),
      ),
      UiGalleryToastPreset.ribbonActionBar => RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(UiGalleryTokens.radiusMedium),
        ),
        side: BorderSide(color: s.line),
      ),
      UiGalleryToastPreset.signal => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiGalleryTokens.radiusCapsule),
        side: BorderSide(color: s.line),
      ),
      UiGalleryToastPreset.inlinePulse ||
      UiGalleryToastPreset.dock ||
      UiGalleryToastPreset.miniConsole => RoundedRectangleBorder(
        side: BorderSide(color: s.line),
      ),
      _ => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          p == UiGalleryToastPreset.ribbon ||
                  p == UiGalleryToastPreset.ribbonActionBar
              ? UiGalleryTokens.radiusSmall
              : UiGalleryTokens.radiusAction,
        ),
        side: BorderSide(color: s.line),
      ),
    }, preserveRadius: p == UiGalleryToastPreset.signal);
    final measure = TextPainter(
      text: TextSpan(text: item.message, style: messageStyle),
      textDirection: Directionality.of(context),
      textScaler: s.media.textScaler,
    )..layout();
    final messageWidth = measure.width;
    measure.dispose();
    final tile = LayoutBuilder(
      builder: (context, constraints) {
        final available = (s.visual.maxWidth ?? constraints.maxWidth).clamp(
          0.0,
          constraints.maxWidth,
        );
        final width = p == UiGalleryToastPreset.signal && action == null
            ? (messageWidth + 108).clamp(0.0, available)
            : p == UiGalleryToastPreset.snapNotice
            ? available.clamp(0.0, 260.0)
            : available;
        final stacked =
            action != null &&
            (width < UiGalleryTokens.choiceBreakpoint ||
                s.media.textScaler.scale(1) > 1.3);
        Widget line({
          bool actionFirst = false,
          bool omitMark = false,
          bool omitClose = false,
          bool omitAction = false,
        }) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.leading != null) ...[
              Flexible(child: item.leading!),
              const SizedBox(width: UiGalleryTokens.gapInline),
            ] else if (!omitMark) ...[
              mark,
              const SizedBox(width: UiGalleryTokens.gapInline),
            ],
            if (!omitAction && actionFirst && !stacked && action != null) ...[
              action,
              const SizedBox(width: UiGalleryTokens.space2),
            ],
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: UiGalleryTokens.space3,
                ),
                child: message,
              ),
            ),
            if (!omitAction && !actionFirst && !stacked && action != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: UiGalleryTokens.space2,
                ),
                child: action,
              ),
            if (!stacked && !omitClose) close,
            if (item.trailing != null) Flexible(child: item.trailing!),
          ],
        );
        Widget content;
        switch (p) {
          case UiGalleryToastPreset.action
              when s.signatureEnabled && action != null:
            final textFirst =
                s.media.textScaler.scale(1) > 1.3 ||
                messageWidth > width - UiGalleryTokens.space4 * 2;
            final recoveryBelow = stacked || textFirst;
            final status = item.leading ?? rawMark;
            final controls = textFirst
                ? s.media.textScaler.scale(1) > 1.3
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            action,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: status),
                                if (item.trailing != null) ...[
                                  const SizedBox(width: UiGalleryTokens.space2),
                                  Flexible(child: item.trailing!),
                                ],
                                close,
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (item.leading != null)
                              Flexible(child: status)
                            else
                              status,
                            const SizedBox(width: UiGalleryTokens.space2),
                            Expanded(child: action),
                            close,
                            if (item.trailing != null)
                              Flexible(child: item.trailing!),
                          ],
                        )
                : Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [action, close],
                  );
            final recovery = Container(
              padding: const EdgeInsets.all(UiGalleryTokens.space1),
              decoration: BoxDecoration(
                color: s.tinted,
                border: recoveryBelow
                    ? Border(top: BorderSide(color: s.line))
                    : BorderDirectional(start: BorderSide(color: s.line)),
              ),
              child: controls,
            );
            content = recoveryBelow
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (textFirst)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: UiGalleryTokens.space3,
                          ),
                          child: message,
                        )
                      else
                        line(omitAction: true, omitClose: true),
                      recovery,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: line(omitAction: true, omitClose: true)),
                      recovery,
                    ],
                  );
          case UiGalleryToastPreset.progressCard:
            content = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    item.leading ?? mark,
                    const SizedBox(width: UiGalleryTokens.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.title != null)
                            Text(
                              item.title!,
                              style:
                                  s.visual.titleStyle ??
                                  s.theme.textTheme.titleSmall,
                            ),
                          message,
                        ],
                      ),
                    ),
                    close,
                    if (item.trailing != null) Flexible(child: item.trailing!),
                  ],
                ),
                if (action != null)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: action,
                  ),
                if (item.progressValue != null)
                  ValueListenableBuilder<double>(
                    valueListenable: item.progressValue!,
                    builder: (context, value, _) {
                      final fraction = value.isFinite
                          ? value.clamp(0.0, 1.0)
                          : 0.0;
                      final label =
                          item.progressLabelBuilder?.call(fraction) ??
                          '${MaterialLocalizations.of(context).formatDecimal((fraction * 100).round())}%';
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: UiGalleryTokens.space3,
                          top: UiGalleryTokens.space2,
                          bottom: UiGalleryTokens.space3,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Semantics(
                              label: label,
                              child: ExcludeSemantics(
                                child: LinearProgressIndicator(
                                  value: fraction,
                                  minHeight: 4,
                                  color: color,
                                  backgroundColor: s.line,
                                ),
                              ),
                            ),
                            const SizedBox(height: UiGalleryTokens.gapCompact),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: ExcludeSemantics(
                                child: Text(
                                  label,
                                  style:
                                      s.visual.messageStyle ??
                                      s.theme.textTheme.labelSmall,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            );
          case UiGalleryToastPreset.stackTag:
            content = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiGalleryTokens.space3,
                      vertical: UiGalleryTokens.space1,
                    ),
                    color: s.tinted,
                    child: Text(
                      item.title ?? item.kind.name.toUpperCase(),
                      style:
                          s.visual.titleStyle ??
                          s.theme.textTheme.labelSmall?.copyWith(color: color),
                    ),
                  ),
                ),
                line(),
              ],
            );
          case UiGalleryToastPreset.beacon:
            content = Row(
              children: [
                Container(
                  width: UiGalleryTokens.touchTarget,
                  height: UiGalleryTokens.touchTarget,
                  decoration: BoxDecoration(
                    color: s.tinted,
                    shape: BoxShape.circle,
                    border: Border.all(color: s.line),
                  ),
                  child: Center(child: mark),
                ),
                const SizedBox(width: UiGalleryTokens.space3),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (item.title != null)
                        Text(
                          item.title!,
                          style:
                              s.visual.titleStyle ??
                              s.theme.textTheme.titleSmall,
                        ),
                      line(omitMark: true),
                    ],
                  ),
                ),
              ],
            );
          case UiGalleryToastPreset.ribbonActionBar:
            final command = Container(
              constraints: const BoxConstraints(
                minHeight: UiGalleryTokens.touchTarget,
              ),
              padding: const EdgeInsets.all(UiGalleryTokens.space2),
              color: s.theme.colorScheme.primaryContainer,
              child: action == null
                  ? Center(child: item.leading ?? mark)
                  : TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: s.theme.colorScheme.onPrimaryContainer,
                        minimumSize: const Size(
                          UiGalleryTokens.touchTarget,
                          UiGalleryTokens.touchTarget,
                        ),
                      ),
                      onPressed: _closing ? null : _action,
                      child: Text(
                        item.actionLabel!,
                        textAlign: TextAlign.center,
                      ),
                    ),
            );
            final narrative = Padding(
              padding: const EdgeInsets.all(UiGalleryTokens.space3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.title != null) ...[
                    Text(
                      item.title!,
                      style: s.heading(
                        s.theme.textTheme.labelSmall?.copyWith(color: s.muted),
                      ),
                    ),
                    const SizedBox(height: UiGalleryTokens.space1),
                  ],
                  message,
                  if (item.leading != null && action != null) item.leading!,
                  if (item.trailing != null) item.trailing!,
                ],
              ),
            );
            content = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(height: UiGalleryTokens.baselineHeight, color: color),
                if (stacked)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      command,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: narrative),
                          close,
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: UiGalleryTokens.ribbonActionWidth,
                        child: command,
                      ),
                      Expanded(child: narrative),
                      close,
                    ],
                  ),
              ],
            );
          case UiGalleryToastPreset.dock:
            content = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                line(omitClose: true, omitAction: true),
                Divider(height: UiGalleryTokens.lineWidth, color: s.line),
                Container(
                  color: s.tinted,
                  padding: const EdgeInsetsDirectional.only(
                    start: UiGalleryTokens.space3,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title ?? item.kind.name,
                          style:
                              s.visual.titleStyle ??
                              s.theme.textTheme.labelSmall?.copyWith(
                                color: s.muted,
                              ),
                        ),
                      ),
                      if (action != null) Flexible(child: action),
                      close,
                    ],
                  ),
                ),
              ],
            );
          case UiGalleryToastPreset.snapNotice:
            content = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [mark, const Spacer(), close]),
                message,
                if (item.leading != null) item.leading!,
                if (item.trailing != null) item.trailing!,
              ],
            );
          case UiGalleryToastPreset.miniConsole:
            content = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title ?? item.kind.name.toUpperCase(),
                        style: s.heading(
                          s.theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                            letterSpacing: 1.4,
                            color: color,
                          ),
                          monospace: true,
                        ),
                      ),
                    ),
                    close,
                  ],
                ),
                Divider(height: UiGalleryTokens.lineWidth, color: s.line),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: UiGalleryTokens.space3,
                  ),
                  child: line(omitMark: true, omitClose: true),
                ),
              ],
            );
          default:
            content = line();
        }
        if (stacked &&
            p != UiGalleryToastPreset.dock &&
            p != UiGalleryToastPreset.progressCard &&
            p != UiGalleryToastPreset.ribbonActionBar &&
            !(p == UiGalleryToastPreset.action && s.signatureEnabled)) {
          content = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              content,
              Wrap(alignment: WrapAlignment.end, children: [action, close]),
            ],
          );
        }
        if (p == UiGalleryToastPreset.ribbon) {
          content = Container(
            decoration: BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(color: color, width: UiGalleryTokens.space1),
              ),
            ),
            padding: const EdgeInsetsDirectional.only(
              start: UiGalleryTokens.space3,
            ),
            child: content,
          );
        }
        final showProgress =
            item.showProgress &&
            !s.reduceMotion &&
            item.duration > Duration.zero &&
            !(s.media.accessibleNavigation && item.onAction != null);
        final surface = Semantics(
          container: true,
          liveRegion: true,
          label: item.semanticLabel,
          child: Material(
            color: s.surface,
            elevation: s.elevation(
              p == UiGalleryToastPreset.inlinePulse ||
                      p == UiGalleryToastPreset.miniConsole
                  ? 0
                  : 8,
            ),
            shadowColor: s.shadowFor(.18),
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: s.visual.gradient),
              child: Padding(
                padding:
                    (p == UiGalleryToastPreset.ribbonActionBar
                            ? EdgeInsets.zero
                            : s.visual.padding ??
                                  const EdgeInsetsDirectional.only(
                                    start: UiGalleryTokens.space4,
                                    end: UiGalleryTokens.space1,
                                    top: UiGalleryTokens.space1,
                                    bottom: UiGalleryTokens.space1,
                                  ))
                        .add(galleryCurveInsets(shape)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    content,
                    if (p == UiGalleryToastPreset.inlinePulse)
                      Container(
                        height: UiGalleryTokens.baselineHeight,
                        color: color,
                      ),
                    if (showProgress)
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
        );
        return Align(
          alignment:
              p == UiGalleryToastPreset.snapNotice ||
                  p == UiGalleryToastPreset.stackTag
              ? AlignmentDirectional.centerStart
              : Alignment.center,
          child: SizedBox(
            width: width,
            child: AnimatedBuilder(
              animation: _entrance,
              child: Padding(
                padding:
                    item.margin ??
                    const EdgeInsets.only(bottom: UiGalleryTokens.space2),
                child: surface,
              ),
              builder: (context, child) {
                final t = s.curve.transform(_entrance.value).clamp(0.0, 1.0);
                final fromSide =
                    p == UiGalleryToastPreset.stackTag ||
                    p == UiGalleryToastPreset.snapNotice;
                final direction =
                    Directionality.of(context) == TextDirection.rtl
                    ? 1.0
                    : -1.0;
                final shift =
                    p == UiGalleryToastPreset.inlinePulse ||
                        p == UiGalleryToastPreset.miniConsole
                    ? Offset.zero
                    : fromSide
                    ? Offset(
                        (1 - t) * UiGalleryTokens.sideDistance * direction,
                        0,
                      )
                    : Offset(
                        0,
                        (1 - t) *
                            (item.position == UiGalleryToastPosition.top
                                ? -24
                                : p == UiGalleryToastPreset.ribbonActionBar
                                ? UiGalleryTokens.space2
                                : 24),
                      );
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: shift,
                    child: Transform.scale(
                      scale: p == UiGalleryToastPreset.beacon
                          ? UiGalleryTokens.beaconRevealScale +
                                (1 - UiGalleryTokens.beaconRevealScale) * t
                          : 1,
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
    return item.focusParent == null
        ? tile
        : Focus(
            parentNode: item.focusParent,
            canRequestFocus: false,
            includeSemantics: false,
            child: tile,
          );
  }
}
