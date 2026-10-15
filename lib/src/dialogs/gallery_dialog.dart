import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/gallery_theme.dart';
import '../core/gallery_style.dart';
import '../core/gallery_shape.dart';

enum UiGalleryDialogPreset {
  halo,
  split,
  timeline,
  spotlight,
  orbitConfirm,
  sideBySideChoice,
  alertCapsule,
  milestone,
  panelDecision,
  statusBeacon,
  commandPalette;

  static const haloFocus = halo;
  static const splitDecision = split;
  static const timelineDialog = timeline;
  static const spotlightResult = spotlight;
  static const compactAlertCapsule = alertCapsule;
  static const milestoneDialog = milestone;
}

enum UiGalleryActionLayout { wrap, stacked, sideBySide }

enum UiGalleryResult { success, warning, failure }

/// A typed route result. Labels are supplied by the application for localization.
@immutable
class UiGalleryDialogAction<T> {
  const UiGalleryDialogAction({
    required this.label,
    required this.value,
    this.primary = false,
    this.destructive = false,
    this.description,
    this.icon,
    this.enabled = true,
  });
  final String label;
  final T value;
  final bool primary;
  final bool destructive;
  final String? description;
  final Widget? icon;
  final bool enabled;
}

abstract final class UiGalleryDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? child,
    WidgetBuilder? builder,
    List<UiGalleryDialogAction<T>> actions = const [],
    UiGalleryDialogPreset preset = UiGalleryDialogPreset.halo,
    UiGalleryResult result = UiGalleryResult.success,
    UiGalleryTheme? appearance,
    UiGallerySurfaceStyle? style,
    UiGalleryMotion? motion,
    Widget? icon,
    Color? barrierColor,
    String? semanticLabel,
    String? eyebrow,
    AlignmentGeometry alignment = Alignment.center,
    UiGalleryActionLayout? actionLayout,
    bool barrierDismissible = false,
    bool useRootNavigator = true,
    bool? requestFocus,
    RouteSettings? routeSettings,
  }) {
    assert(child == null || builder == null, 'Use either child or builder.');
    final s = UiGalleryStyle.of(
      context,
      appearance,
      style,
      motion,
      UiGallerySurface.dialog,
    );
    final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
    return navigator.push<T>(
      _GalleryDialogRoute<T>(
        context: context,
        preset: preset,
        duration: s.duration(s.motion.entrance),
        reverseDuration: s.duration(s.motion.exit),
        curve: s.curve,
        barrierColor: barrierColor ?? Colors.black54,
        themes: InheritedTheme.capture(from: context, to: navigator.context),
        barrierDismissible: barrierDismissible,
        requestFocus: requestFocus,
        settings: routeSettings,
        builder: (context) => _DialogSurface<T>(
          title: title,
          message: message,
          preset: preset,
          result: result,
          appearance: appearance,
          actions: actions,
          style: style,
          motion: motion,
          icon: icon,
          semanticLabel: semanticLabel,
          eyebrow: eyebrow,
          alignment: alignment,
          actionLayout: actionLayout,
          child: builder?.call(context) ?? child,
        ),
      ),
    );
  }

  /// Returns true for confirmation, false for cancellation, null for route pop.
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? message,
    UiGalleryDialogPreset preset = UiGalleryDialogPreset.halo,
    String? confirmLabel,
    String? cancelLabel,
    bool destructive = false,
    bool barrierDismissible = false,
    bool useRootNavigator = true,
    UiGalleryTheme? appearance,
    UiGallerySurfaceStyle? style,
    UiGalleryMotion? motion,
    Widget? icon,
    Color? barrierColor,
    String? semanticLabel,
    String? eyebrow,
    AlignmentGeometry alignment = Alignment.center,
    UiGalleryActionLayout? actionLayout,
  }) {
    final labels = MaterialLocalizations.of(context);
    return show<bool>(
      context: context,
      title: title,
      message: message,
      preset: preset,
      appearance: appearance,
      style: style,
      motion: motion,
      icon: icon,
      barrierColor: barrierColor,
      semanticLabel: semanticLabel,
      eyebrow: eyebrow,
      alignment: alignment,
      actionLayout: actionLayout,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      actions: [
        UiGalleryDialogAction(
          label: cancelLabel ?? labels.cancelButtonLabel,
          value: false,
        ),
        UiGalleryDialogAction(
          label: confirmLabel ?? labels.okButtonLabel,
          value: true,
          primary: true,
          destructive: destructive,
        ),
      ],
    );
  }

  /// The caller owns and disposes [progress]; this dialog only listens to it.
  static Future<T?> timeline<T>({
    required BuildContext context,
    required String title,
    required ValueListenable<UiGalleryTimelineState> progress,
    UiGalleryDialogPreset preset = UiGalleryDialogPreset.timeline,
    List<UiGalleryDialogAction<T>> actions = const [],
    bool barrierDismissible = false,
    bool useRootNavigator = true,
    UiGallerySurfaceStyle? style,
    UiGalleryMotion? motion,
    UiGalleryTheme? appearance,
    String? semanticLabel,
    String? eyebrow,
  }) => show<T>(
    context: context,
    title: title,
    preset: preset,
    actions: actions,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    style: style,
    motion: motion,
    appearance: appearance,
    semanticLabel: semanticLabel,
    eyebrow: eyebrow,
    child: ValueListenableBuilder<UiGalleryTimelineState>(
      valueListenable: progress,
      builder: (context, value, _) => UiGalleryTimeline(
        state: value,
        appearance: appearance,
        style: style,
        motion: motion,
      ),
    ),
  );

  /// Searches caller-supplied commands and returns the selected value.
  static Future<T?> commands<T>({
    required BuildContext context,
    required String title,
    required List<UiGalleryDialogAction<T>> commands,
    required String emptyLabel,
    String? searchHint,
    bool useRootNavigator = true,
    UiGallerySurfaceStyle? style,
    UiGalleryMotion? motion,
    UiGalleryTheme? appearance,
  }) => show<T>(
    context: context,
    title: title,
    preset: UiGalleryDialogPreset.commandPalette,
    useRootNavigator: useRootNavigator,
    barrierDismissible: true,
    style: style,
    motion: motion,
    appearance: appearance,
    builder: (context) => _CommandPalette<T>(
      commands: commands,
      emptyLabel: emptyLabel,
      searchHint: searchHint,
      appearance: appearance,
      style: style,
      motion: motion,
    ),
  );
}

// Backwards-compatible aliases
typedef NovaDialog = UiGalleryDialog;
typedef NovaDialogPreset = UiGalleryDialogPreset;
typedef NovaDialogAction<T> = UiGalleryDialogAction<T>;
typedef NovaResult = UiGalleryResult;
typedef NovaTimelineState = UiGalleryTimelineState;
typedef NovaTimeline = UiGalleryTimeline;

class _GalleryDialogRoute<T> extends DialogRoute<T> {
  _GalleryDialogRoute({
    required super.context,
    required super.builder,
    required this.preset,
    required this.curve,
    super.barrierColor,
    required Duration duration,
    required this.reverseDuration,
    required super.themes,
    required super.barrierDismissible,
    super.requestFocus,
    super.settings,
  }) : super(animationStyle: AnimationStyle(duration: duration));
  final UiGalleryDialogPreset preset;
  final Curve curve;
  final Duration reverseDuration;

  @override
  Duration get reverseTransitionDuration => reverseDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      final t = curve.transform(animation.value).clamp(0.0, 1.0);
      return Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(
            preset == UiGalleryDialogPreset.split ||
                    preset == UiGalleryDialogPreset.sideBySideChoice
                ? (1 - t) * 20
                : 0,
            preset == UiGalleryDialogPreset.timeline ||
                    preset == UiGalleryDialogPreset.milestone ||
                    preset == UiGalleryDialogPreset.alertCapsule
                ? (1 - t) * 16
                : 0,
          ),
          child: Transform.scale(
            scale:
                preset == UiGalleryDialogPreset.halo ||
                    preset == UiGalleryDialogPreset.spotlight ||
                    preset == UiGalleryDialogPreset.orbitConfirm
                ? .96 + .04 * t
                : 1,
            child: child,
          ),
        ),
      );
    },
  );
}

class _DialogSurface<T> extends StatelessWidget {
  const _DialogSurface({
    required this.title,
    required this.preset,
    required this.result,
    required this.actions,
    this.message,
    this.child,
    this.appearance,
    this.style,
    this.motion,
    this.icon,
    this.semanticLabel,
    this.eyebrow,
    this.alignment = Alignment.center,
    this.actionLayout,
  });
  final String title;
  final String? message;
  final Widget? child;
  final UiGalleryDialogPreset preset;
  final UiGalleryResult result;
  final List<UiGalleryDialogAction<T>> actions;
  final UiGalleryTheme? appearance;
  final UiGallerySurfaceStyle? style;
  final UiGalleryMotion? motion;
  final Widget? icon;
  final String? semanticLabel, eyebrow;
  final AlignmentGeometry alignment;
  final UiGalleryActionLayout? actionLayout;

  @override
  Widget build(BuildContext context) {
    final s = UiGalleryStyle.of(
      context,
      appearance,
      style,
      motion,
      UiGallerySurface.dialog,
    );
    final spotlight = preset == UiGalleryDialogPreset.spotlight;
    final split =
        preset == UiGalleryDialogPreset.split ||
        preset == UiGalleryDialogPreset.panelDecision;
    final resultColor = switch (result) {
      UiGalleryResult.success => s.accent,
      UiGalleryResult.warning => s.theme.colorScheme.tertiary,
      UiGalleryResult.failure => s.theme.colorScheme.error,
    };
    Widget body = Padding(
      padding: s.visual.padding ?? const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: spotlight
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (spotlight) ...[
            SizedBox(
              width: 112,
              height: 112,
              child: CustomPaint(
                painter: _SpotlightPainter(resultColor, s.line),
                child: Center(
                  child: Icon(
                    switch (result) {
                      UiGalleryResult.success => Icons.check_rounded,
                      UiGalleryResult.warning => Icons.priority_high_rounded,
                      UiGalleryResult.failure => Icons.close_rounded,
                    },
                    size: 44,
                    color: resultColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            Row(
              children: [
                Container(
                  width: preset == UiGalleryDialogPreset.timeline ? 6 : 24,
                  height: 6,
                  decoration: BoxDecoration(
                    color: s.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 10),
                if (eyebrow != null)
                  Expanded(
                    child: UiGallerySectionLabel(eyebrow!, color: s.muted),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          Semantics(
            namesRoute: true,
            header: true,
            child: Text(
              title,
              textAlign: spotlight ? TextAlign.center : TextAlign.start,
              style:
                  s.visual.titleStyle ??
                  s.theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: s.content,
                    height: 1.15,
                  ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: spotlight ? TextAlign.center : TextAlign.start,
              style:
                  s.visual.messageStyle ??
                  s.theme.textTheme.bodyLarge?.copyWith(
                    color: s.muted,
                    height: 1.5,
                  ),
            ),
          ],
          if (child != null) ...[const SizedBox(height: 24), child!],
        ],
      ),
    );
    Widget decisions = Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 10,
        runSpacing: 8,
        children: [
          for (final action in actions)
            _DecisionButton<T>(
              action: action,
              style: s,
              halo: preset == UiGalleryDialogPreset.halo,
            ),
        ],
      ),
    );
    final mark =
        icon ??
        Icon(
          preset == UiGalleryDialogPreset.milestone
              ? Icons.flag_rounded
              : preset == UiGalleryDialogPreset.statusBeacon
              ? Icons.sensors_rounded
              : Icons.check_rounded,
          size: 32,
          color: resultColor,
        );
    switch (preset) {
      case UiGalleryDialogPreset.orbitConfirm:
        body = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 24, end: 24),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: s.tinted,
                    shape: BoxShape.circle,
                    border: Border.all(color: s.line),
                  ),
                  child: Center(child: mark),
                ),
              ),
            ),
            body,
          ],
        );
      case UiGalleryDialogPreset.sideBySideChoice:
        decisions = Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                for (final action in actions)
                  _ChoiceCard<T>(action: action, style: s),
              ];
              if (constraints.maxWidth >= 380 &&
                  s.media.textScaler.scale(1) < 1.5) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final card in cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: card,
                    ),
                ],
              );
            },
          ),
        );
      case UiGalleryDialogPreset.alertCapsule:
        body = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 20, top: 28),
              child: mark,
            ),
            Expanded(child: body),
          ],
        );
      case UiGalleryDialogPreset.milestone:
        body = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: s.tinted,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  mark,
                  const SizedBox(width: 16),
                  Expanded(child: Divider(color: s.line)),
                ],
              ),
            ),
            body,
          ],
        );
      case UiGalleryDialogPreset.panelDecision:
        body = Container(
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: s.accent, width: 4),
            ),
          ),
          child: body,
        );
      case UiGalleryDialogPreset.statusBeacon:
        body = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              color: s.tinted,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: mark,
            ),
            Expanded(child: body),
          ],
        );
      default:
        break;
    }
    if (actionLayout == UiGalleryActionLayout.stacked ||
        preset == UiGalleryDialogPreset.statusBeacon ||
        preset == UiGalleryDialogPreset.panelDecision) {
      decisions = Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final action in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DecisionButton<T>(
                  action: action,
                  style: s,
                  halo: false,
                ),
              ),
          ],
        ),
      );
    } else if (actionLayout == UiGalleryActionLayout.sideBySide &&
        preset != UiGalleryDialogPreset.sideBySideChoice) {
      decisions = Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final action in actions)
              _ChoiceCard<T>(action: action, style: s),
          ],
        ),
      );
    }
    return Semantics(
      label: semanticLabel,
      child: Dialog(
        alignment: alignment.resolve(Directionality.of(context)),
        backgroundColor: s.surface,
        surfaceTintColor: Colors.transparent,
        elevation: s.visual.elevation ?? 12,
        shadowColor: s.visual.shadowColor,
        insetAnimationDuration: s.duration(s.motion.change),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape:
            s.visual.shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                spotlight
                    ? 40
                    : split
                    ? 16
                    : 28,
              ),
              side: BorderSide(color: s.line),
            ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                s.visual.maxWidth ??
                (preset == UiGalleryDialogPreset.alertCapsule
                    ? 420
                    : UiGalleryTokens.dialogWidth),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: s.visual.gradient),
            child: Padding(
              padding: galleryCurveInsets(s.visual.shape),
              child: SingleChildScrollView(
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: s.content),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final divided =
                          split &&
                          constraints.maxWidth >= 480 &&
                          s.media.textScaler.scale(1) < 1.5;
                      if (divided) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 3, child: body),
                              Expanded(
                                flex: 2,
                                child: ColoredBox(
                                  color: s.tinted,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Icon(
                                          Icons.call_split_rounded,
                                          size: 40,
                                          color: s.accent,
                                        ),
                                      ),
                                      decisions,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          body,
                          if (actions.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: split ? s.tinted : null,
                                border: split
                                    ? Border(top: BorderSide(color: s.line))
                                    : null,
                              ),
                              child: decisions,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard<T> extends StatelessWidget {
  const _ChoiceCard({required this.action, required this.style});
  final UiGalleryDialogAction<T> action;
  final UiGalleryStyle style;
  @override
  Widget build(BuildContext context) => Material(
    color: action.primary ? style.tinted : style.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: style.line),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: action.enabled
          ? () => Navigator.of(context).pop<T>(action.value)
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (action.icon != null) ...[
                action.icon!,
                const SizedBox(height: 16),
              ],
              Text(
                action.label,
                style: style.theme.textTheme.titleMedium?.copyWith(
                  color: action.destructive
                      ? style.theme.colorScheme.error
                      : style.content,
                ),
              ),
              if (action.description != null) ...[
                const SizedBox(height: 8),
                Text(action.description!, style: TextStyle(color: style.muted)),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _DecisionButton<T> extends StatelessWidget {
  const _DecisionButton({
    required this.action,
    required this.style,
    required this.halo,
  });
  final UiGalleryDialogAction<T> action;
  final UiGalleryStyle style;
  final bool halo;

  @override
  Widget build(BuildContext context) {
    final color = action.destructive
        ? style.theme.colorScheme.error
        : style.accent;
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    final buttonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      foregroundColor: WidgetStatePropertyAll(
        !action.enabled
            ? style.content.withValues(alpha: .38)
            : action.primary
            ? onColor
            : style.content,
      ),
      backgroundColor: WidgetStatePropertyAll(
        action.primary
            ? action.enabled
                  ? color
                  : style.content.withValues(alpha: .12)
            : Colors.transparent,
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    return Container(
      padding: halo && action.primary && action.enabled
          ? const EdgeInsets.all(4)
          : EdgeInsets.zero,
      decoration: halo && action.primary && action.enabled
          ? BoxDecoration(
              border: Border.all(color: color.withValues(alpha: .3)),
              borderRadius: BorderRadius.circular(21),
            )
          : null,
      child: TextButton(
        style: buttonStyle,
        onPressed: action.enabled
            ? () => Navigator.of(context).pop<T>(action.value)
            : null,
        child: Text(action.label, textAlign: TextAlign.center),
      ),
    );
  }
}

class _CommandPalette<T> extends StatefulWidget {
  const _CommandPalette({
    required this.commands,
    required this.emptyLabel,
    this.searchHint,
    this.appearance,
    this.style,
    this.motion,
  });
  final List<UiGalleryDialogAction<T>> commands;
  final String emptyLabel;
  final String? searchHint;
  final UiGalleryTheme? appearance;
  final UiGallerySurfaceStyle? style;
  final UiGalleryMotion? motion;
  @override
  State<_CommandPalette<T>> createState() => _CommandPaletteState<T>();
}

class _CommandPaletteState<T> extends State<_CommandPalette<T>> {
  late final FocusNode _focus = FocusNode(onKeyEvent: _key);
  final _keys = <int, GlobalKey>{};
  String _query = '';
  int _active = -1;
  List<UiGalleryDialogAction<T>> get _filtered => widget.commands
      .where(
        (command) => '${command.label} ${command.description ?? ''}'
            .toLowerCase()
            .contains(_query),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _active = _filtered.indexWhere((command) => command.enabled);
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _select() {
    final commands = _filtered;
    if (_active >= 0 &&
        _active < commands.length &&
        commands[_active].enabled) {
      Navigator.of(context).pop<T>(commands[_active].value);
    }
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _select();
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      final commands = _filtered;
      final enabled = [
        for (var i = 0; i < commands.length; i++)
          if (commands[i].enabled) i,
      ];
      if (enabled.isEmpty) return KeyEventResult.handled;
      final current = enabled.indexOf(_active);
      final next =
          (current + (key == LogicalKeyboardKey.arrowDown ? 1 : -1)) %
          enabled.length;
      setState(() => _active = enabled[next]);
      final command = commands[_active];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            _active < 0 ||
            _active >= _filtered.length ||
            !identical(_filtered[_active], command)) {
          return;
        }
        final activeContext = _keys[_active]?.currentContext;
        if (activeContext != null) {
          Scrollable.ensureVisible(activeContext, alignment: .5);
        }
      });
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final s = UiGalleryStyle.of(
      context,
      widget.appearance,
      widget.style,
      widget.motion,
      UiGallerySurface.dialog,
    );
    final commands = _filtered;
    final available =
        (s.media.size.height -
                s.media.viewInsets.bottom -
                s.media.padding.vertical -
                240)
            .clamp(48.0, 280.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          autofocus: true,
          focusNode: _focus,
          style: TextStyle(color: s.content),
          decoration: InputDecoration(
            hintText:
                widget.searchHint ??
                MaterialLocalizations.of(context).searchFieldLabel,
            prefixIcon: Icon(Icons.search_rounded, color: s.accent),
            filled: true,
            fillColor: s.tinted,
          ),
          onChanged: (value) => setState(() {
            _query = value.trim().toLowerCase();
            _active = _filtered.indexWhere((command) => command.enabled);
          }),
          onSubmitted: (_) => _select(),
        ),
        const SizedBox(height: 12),
        if (commands.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(widget.emptyLabel, style: TextStyle(color: s.muted)),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: available),
            child: ListView(
              shrinkWrap: true,
              primary: false,
              children: [
                for (var i = 0; i < commands.length; i++)
                  Material(
                    key: _keys.putIfAbsent(i, GlobalKey.new),
                    color: i == _active ? s.tinted : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      selected: i == _active,
                      enabled: commands[i].enabled,
                      selectedColor: commands[i].destructive
                          ? s.theme.colorScheme.error
                          : s.accent,
                      textColor: commands[i].destructive
                          ? s.theme.colorScheme.error
                          : s.content,
                      leading: commands[i].icon,
                      title: Text(commands[i].label),
                      subtitle: commands[i].description == null
                          ? null
                          : Text(commands[i].description!),
                      trailing: i == _active
                          ? const Icon(Icons.keyboard_return_rounded)
                          : null,
                      onTap: commands[i].enabled
                          ? () =>
                                Navigator.of(context).pop<T>(commands[i].value)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter(this.color, this.line);
  final Color color;
  final Color line;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(center, 40, Paint()..color = color.withValues(alpha: .1));
    canvas.drawCircle(
      center,
      54,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 54),
      -math.pi / 2,
      math.pi * .65,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      color != oldDelegate.color || line != oldDelegate.line;
}

/// Snapshot of actual work supplied by the caller, never generated by a timer.
@immutable
class UiGalleryTimelineState {
  const UiGalleryTimelineState({
    required this.steps,
    required this.currentStep,
    this.completed = false,
    this.failed = false,
  }) : assert(currentStep >= 0),
       assert(!(completed && failed));
  final List<String> steps;
  final int currentStep;
  final bool completed;
  final bool failed;
}

class UiGalleryTimeline extends StatelessWidget {
  const UiGalleryTimeline({
    super.key,
    required this.state,
    this.appearance,
    this.style,
    this.motion,
  });
  final UiGalleryTimelineState state;
  final UiGalleryTheme? appearance;
  final UiGallerySurfaceStyle? style;
  final UiGalleryMotion? motion;

  @override
  Widget build(BuildContext context) {
    final s = UiGalleryStyle.of(
      context,
      appearance,
      style,
      motion,
      UiGallerySurface.dialog,
    );
    assert(state.steps.isNotEmpty && state.currentStep < state.steps.length);
    return Semantics(
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < state.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: s.duration(s.motion.change),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: i <= state.currentStep ? s.tinted : s.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: i == state.currentStep && state.failed
                                ? s.theme.colorScheme.error
                                : i <= state.currentStep
                                ? s.accent
                                : s.line,
                          ),
                        ),
                        child: Icon(
                          i < state.currentStep || state.completed
                              ? Icons.check_rounded
                              : i == state.currentStep && state.failed
                              ? Icons.close_rounded
                              : Icons.circle,
                          size:
                              i < state.currentStep ||
                                  state.completed ||
                                  state.failed
                              ? 16
                              : 6,
                          color: i == state.currentStep && state.failed
                              ? s.theme.colorScheme.error
                              : s.accent,
                        ),
                      ),
                      if (i < state.steps.length - 1)
                        Container(width: 1, height: 18, color: s.line),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        state.steps[i],
                        style: s.theme.textTheme.bodyMedium?.copyWith(
                          color: i <= state.currentStep ? s.content : s.muted,
                          fontWeight: i == state.currentStep
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
