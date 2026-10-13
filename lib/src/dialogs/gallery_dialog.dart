import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/gallery_theme.dart';

enum UiGalleryDialogPreset { halo, split, timeline, spotlight }

enum UiGalleryResult { success, warning, failure }

/// A typed route result. Labels are supplied by the application for localization.
@immutable
class UiGalleryDialogAction<T> {
  const UiGalleryDialogAction({
    required this.label,
    required this.value,
    this.primary = false,
    this.destructive = false,
  });
  final String label;
  final T value;
  final bool primary;
  final bool destructive;
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
    bool barrierDismissible = false,
    bool useRootNavigator = true,
    bool? requestFocus,
    RouteSettings? routeSettings,
  }) {
    assert(child == null || builder == null, 'Use either child or builder.');
    final s = UiGalleryStyle.of(context, appearance);
    final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
    return navigator.push<T>(
      _GalleryDialogRoute<T>(
        context: context,
        preset: preset,
        duration: s.duration(UiGalleryTokens.entrance),
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
  }) {
    final labels = MaterialLocalizations.of(context);
    return show<bool>(
      context: context,
      title: title,
      message: message,
      preset: preset,
      appearance: appearance,
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
    List<UiGalleryDialogAction<T>> actions = const [],
    bool barrierDismissible = false,
    bool useRootNavigator = true,
  }) => show<T>(
    context: context,
    title: title,
    preset: UiGalleryDialogPreset.timeline,
    actions: actions,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    child: ValueListenableBuilder<UiGalleryTimelineState>(
      valueListenable: progress,
      builder: (context, value, _) => UiGalleryTimeline(state: value),
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
    required Duration duration,
    required super.themes,
    required super.barrierDismissible,
    super.requestFocus,
    super.settings,
  }) : super(animationStyle: AnimationStyle(duration: duration));
  final UiGalleryDialogPreset preset;

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
      final t = UiGalleryTokens.curve.transform(animation.value);
      return Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(
            preset == UiGalleryDialogPreset.split ? (1 - t) * 20 : 0,
            preset == UiGalleryDialogPreset.timeline ? (1 - t) * 12 : 0,
          ),
          child: Transform.scale(
            scale:
                preset == UiGalleryDialogPreset.halo ||
                    preset == UiGalleryDialogPreset.spotlight
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
  });
  final String title;
  final String? message;
  final Widget? child;
  final UiGalleryDialogPreset preset;
  final UiGalleryResult result;
  final List<UiGalleryDialogAction<T>> actions;
  final UiGalleryTheme? appearance;

  @override
  Widget build(BuildContext context) {
    final s = UiGalleryStyle.of(context, appearance);
    final spotlight = preset == UiGalleryDialogPreset.spotlight;
    final split = preset == UiGalleryDialogPreset.split;
    final resultColor = switch (result) {
      UiGalleryResult.success => s.accent,
      UiGalleryResult.warning => s.theme.colorScheme.tertiary,
      UiGalleryResult.failure => s.theme.colorScheme.error,
    };
    final body = Padding(
      padding: const EdgeInsets.all(28),
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
                Expanded(
                  child: UiGallerySectionLabel(
                    preset.name.toUpperCase(),
                    color: s.muted,
                  ),
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
              style: s.theme.textTheme.headlineSmall?.copyWith(
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
              style: s.theme.textTheme.bodyLarge?.copyWith(
                color: s.muted,
                height: 1.5,
              ),
            ),
          ],
          if (child != null) ...[const SizedBox(height: 24), child!],
        ],
      ),
    );
    final decisions = Padding(
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
    return Dialog(
      backgroundColor: s.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      insetAnimationDuration: s.duration(UiGalleryTokens.change),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
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
        constraints: const BoxConstraints(
          maxWidth: UiGalleryTokens.dialogWidth,
        ),
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
    );
  }
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
        action.primary ? onColor : style.content,
      ),
      backgroundColor: WidgetStatePropertyAll(
        action.primary ? color : Colors.transparent,
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    return Container(
      padding: halo && action.primary
          ? const EdgeInsets.all(4)
          : EdgeInsets.zero,
      decoration: halo && action.primary
          ? BoxDecoration(
              border: Border.all(color: color.withValues(alpha: .3)),
              borderRadius: BorderRadius.circular(21),
            )
          : null,
      child: TextButton(
        style: buttonStyle,
        onPressed: () => Navigator.of(context).pop<T>(action.value),
        child: Text(action.label, textAlign: TextAlign.center),
      ),
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
  const UiGalleryTimeline({super.key, required this.state});
  final UiGalleryTimelineState state;

  @override
  Widget build(BuildContext context) {
    final s = UiGalleryStyle.of(context);
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
                        duration: s.duration(UiGalleryTokens.change),
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
