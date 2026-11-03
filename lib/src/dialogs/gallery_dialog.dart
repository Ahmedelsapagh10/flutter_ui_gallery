import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/gallery_theme.dart';
import '../core/gallery_style.dart';
import '../core/gallery_signature.dart';
import '../core/gallery_signature_exceptions.dart';
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
        barrierColor:
            barrierColor ?? s.theme.colorScheme.scrim.withValues(alpha: .54),
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
                ? (1 - t) * UiGalleryTokens.sideDistance
                : 0,
            preset == UiGalleryDialogPreset.timeline ||
                    preset == UiGalleryDialogPreset.milestone ||
                    preset == UiGalleryDialogPreset.alertCapsule
                ? (1 - t) * UiGalleryTokens.revealDistance
                : 0,
          ),
          child: Transform.scale(
            scale:
                preset == UiGalleryDialogPreset.halo ||
                    preset == UiGalleryDialogPreset.spotlight ||
                    preset == UiGalleryDialogPreset.orbitConfirm
                ? UiGalleryTokens.dialogRevealScale +
                      (1 - UiGalleryTokens.dialogRevealScale) * t
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
    final calmCommands =
        preset == UiGalleryDialogPreset.commandPalette && s.signatureEnabled;
    final split =
        preset == UiGalleryDialogPreset.split ||
        preset == UiGalleryDialogPreset.panelDecision;
    final resultColor = switch (result) {
      UiGalleryResult.success => s.accent,
      UiGalleryResult.warning => s.theme.colorScheme.tertiary,
      UiGalleryResult.failure => s.theme.colorScheme.error,
    };
    Widget body = Padding(
      padding: s.visual.padding ?? const EdgeInsets.all(UiGalleryTokens.space7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: spotlight
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (spotlight) ...[
            SizedBox(
              width: UiGalleryTokens.resultMarkSize,
              height: UiGalleryTokens.resultMarkSize,
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
            const SizedBox(height: UiGalleryTokens.space6),
          ] else ...[
            Row(
              children: [
                Container(
                  width: preset == UiGalleryDialogPreset.timeline ? 6 : 24,
                  height: calmCommands ? 3 : UiGalleryTokens.gapCompact,
                  decoration: BoxDecoration(
                    color: s.accent,
                    borderRadius: BorderRadius.circular(
                      UiGalleryTokens.radiusSmall,
                    ),
                  ),
                ),
                const SizedBox(width: UiGalleryTokens.gapInline),
                if (eyebrow != null)
                  Expanded(
                    child: UiGallerySectionLabel(eyebrow!, color: s.muted),
                  ),
              ],
            ),
            SizedBox(
              height: calmCommands
                  ? UiGalleryTokens.space3
                  : UiGalleryTokens.space6,
            ),
          ],
          Semantics(
            namesRoute: true,
            header: true,
            child: Text(
              title,
              textAlign: spotlight ? TextAlign.center : TextAlign.start,
              style: s.heading(
                (calmCommands
                        ? s.theme.textTheme.titleLarge
                        : s.theme.textTheme.headlineSmall)
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: s.content,
                      height: 1.15,
                    ),
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: UiGalleryTokens.space4),
            Text(
              message!,
              textAlign: spotlight ? TextAlign.center : TextAlign.start,
              style: s.body(
                s.theme.textTheme.bodyLarge?.copyWith(
                  color: s.muted,
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (child != null) ...[
            SizedBox(
              height: calmCommands
                  ? UiGalleryTokens.space3
                  : UiGalleryTokens.space6,
            ),
            child!,
          ],
        ],
      ),
    );
    if (!calmCommands) {
      body = GalleryFamilyRegion(
        style: s,
        framed: GallerySignatureExceptions.dialogWells.contains(preset),
        child: body,
      );
    }
    Widget decisions = Padding(
      padding: const EdgeInsets.all(UiGalleryTokens.space5),
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
          size: UiGalleryTokens.iconLarge,
          color: resultColor,
        );
    switch (preset) {
      case UiGalleryDialogPreset.orbitConfirm:
        body = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: UiGalleryTokens.space6,
                end: UiGalleryTokens.space6,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  width: UiGalleryTokens.space16,
                  height: UiGalleryTokens.space16,
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
          padding: const EdgeInsets.all(UiGalleryTokens.space5),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                for (final action in actions)
                  _ChoiceCard<T>(action: action, style: s),
              ];
              if (constraints.maxWidth >= UiGalleryTokens.choiceBreakpoint &&
                  s.media.textScaler.scale(1) < 1.5) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: UiGalleryTokens.space3),
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
                      padding: const EdgeInsets.only(
                        bottom: UiGalleryTokens.space2,
                      ),
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
              padding: const EdgeInsetsDirectional.only(
                start: UiGalleryTokens.space5,
                top: UiGalleryTokens.space7,
              ),
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
              padding: const EdgeInsets.all(UiGalleryTokens.space5),
              child: Row(
                children: [
                  mark,
                  const SizedBox(width: UiGalleryTokens.space4),
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
              start: BorderSide(color: s.accent, width: UiGalleryTokens.space1),
            ),
          ),
          child: body,
        );
      case UiGalleryDialogPreset.statusBeacon:
        body = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: UiGalleryTokens.space14,
              color: s.tinted,
              padding: const EdgeInsets.symmetric(
                vertical: UiGalleryTokens.space7,
              ),
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
        padding: const EdgeInsets.all(UiGalleryTokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final action in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: UiGalleryTokens.space2),
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
        padding: const EdgeInsets.all(UiGalleryTokens.space5),
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
        elevation: s.elevation(UiGalleryTokens.elevationHigh),
        shadowColor: s.visual.shadowColor,
        insetAnimationDuration: s.duration(s.motion.change),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: UiGalleryTokens.space5,
          vertical: UiGalleryTokens.space6,
        ),
        shape: s.shape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              spotlight
                  ? UiGalleryTokens.radiusSpotlight
                  : split
                  ? UiGalleryTokens.radiusMedium
                  : UiGalleryTokens.radiusPanel,
            ),
            side: BorderSide(color: s.line),
          ),
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
                      if (preset == UiGalleryDialogPreset.split &&
                          s.signatureEnabled &&
                          actionLayout == null) {
                        final lanes = [
                          for (final action in actions)
                            _ConsequenceLane<T>(action: action, style: s),
                        ];
                        final horizontal =
                            constraints.maxWidth >=
                                UiGalleryTokens.choiceBreakpoint &&
                            s.media.textScaler.scale(1) < 1.5;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            body,
                            Padding(
                              padding: const EdgeInsets.all(
                                UiGalleryTokens.space4,
                              ),
                              child: horizontal
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (
                                          var i = 0;
                                          i < lanes.length;
                                          i++
                                        ) ...[
                                          if (i > 0)
                                            const SizedBox(
                                              width: UiGalleryTokens.space3,
                                            ),
                                          Expanded(child: lanes[i]),
                                        ],
                                      ],
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        for (final lane in lanes)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: UiGalleryTokens.space3,
                                            ),
                                            child: lane,
                                          ),
                                      ],
                                    ),
                            ),
                          ],
                        );
                      }
                      final divided =
                          split &&
                          constraints.maxWidth >=
                              UiGalleryTokens.dialogSplitBreakpoint &&
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
                                        padding: const EdgeInsets.all(
                                          UiGalleryTokens.space5,
                                        ),
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

class _ConsequenceLane<T> extends StatelessWidget {
  const _ConsequenceLane({required this.action, required this.style});
  final UiGalleryDialogAction<T> action;
  final UiGalleryStyle style;
  @override
  Widget build(BuildContext context) {
    final colors = style.theme.colorScheme;
    final ink = action.destructive ? colors.onErrorContainer : style.content;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: action.destructive ? colors.errorContainer : style.tinted,
        border: BorderDirectional(
          start: BorderSide(
            color: action.destructive ? colors.error : style.accent,
            width: UiGalleryTokens.accentWidth,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UiGalleryTokens.space3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (action.icon != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: ExcludeSemantics(
                  child: IconTheme.merge(
                    data: IconThemeData(color: ink),
                    child: action.icon!,
                  ),
                ),
              ),
            if (action.description != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: UiGalleryTokens.space3,
                ),
                child: Text(
                  action.description!,
                  style: TextStyle(color: ink, height: 1.4),
                ),
              ),
            _DecisionButton<T>(action: action, style: style, halo: false),
          ],
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
      borderRadius: BorderRadius.circular(UiGalleryTokens.radiusMedium),
      side: BorderSide(color: style.line),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(UiGalleryTokens.radiusMedium),
      onTap: action.enabled
          ? () => Navigator.of(context).pop<T>(action.value)
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: UiGalleryTokens.touchTarget,
        ),
        child: Padding(
          padding: const EdgeInsets.all(UiGalleryTokens.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (action.icon != null) ...[
                action.icon!,
                const SizedBox(height: UiGalleryTokens.space4),
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
                const SizedBox(height: UiGalleryTokens.space2),
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
    final onColor = style.foregroundFor(color);
    final buttonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(UiGalleryTokens.touchTarget, UiGalleryTokens.touchTarget),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: UiGalleryTokens.space5,
          vertical: UiGalleryTokens.insetHandle,
        ),
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
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiGalleryTokens.radiusMedium),
        ),
      ),
    );
    return Container(
      padding: halo && action.primary && action.enabled
          ? const EdgeInsets.all(UiGalleryTokens.space1)
          : EdgeInsets.zero,
      decoration: halo && action.primary && action.enabled
          ? BoxDecoration(
              border: Border.all(color: color.withValues(alpha: .3)),
              borderRadius: BorderRadius.circular(UiGalleryTokens.radiusHalo),
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
  final _focus = FocusNode();
  final _commandFocus = <int, FocusNode>{};
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
    for (final node in _commandFocus.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _commandNode(int index) =>
      _commandFocus.putIfAbsent(index, FocusNode.new);

  void _activate(int index) {
    if (_active != index) setState(() => _active = index);
    final command = _filtered[index];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _active != index ||
          index >= _filtered.length ||
          !identical(_filtered[index], command)) {
        return;
      }
      final activeContext = _keys[index]?.currentContext;
      if (activeContext != null) {
        Scrollable.ensureVisible(activeContext, alignment: .5);
      }
    });
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
      _activate(enabled[next]);
      if (!_focus.hasFocus) _commandNode(_active).requestFocus();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  Widget _command(
    UiGalleryStyle s,
    UiGalleryDialogAction<T> command,
    int index,
  ) {
    final active = index == _active;
    final ink = !command.enabled
        ? s.muted
        : command.destructive
        ? s.theme.colorScheme.error
        : s.content;
    final labelStyle = s.body(
      s.theme.textTheme.titleMedium?.copyWith(
        color: ink,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
      ),
    );
    return Semantics(
      button: true,
      enabled: command.enabled,
      selected: active,
      child: InkWell(
        focusNode: _commandNode(index),
        onFocusChange: (focused) {
          if (focused) _activate(index);
        },
        borderRadius: BorderRadius.circular(UiGalleryTokens.radiusToolbar),
        onTap: command.enabled
            ? () => Navigator.of(context).pop<T>(command.value)
            : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: UiGalleryTokens.touchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.all(UiGalleryTokens.space3),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final painter = TextPainter(
                  text: TextSpan(text: command.label, style: labelStyle),
                  textDirection: Directionality.of(context),
                  textScaler: s.media.textScaler,
                  locale: Localizations.maybeLocaleOf(context),
                  maxLines: 1,
                )..layout();
                final textWidth =
                    constraints.maxWidth -
                    (command.icon == null ? 0 : 36) -
                    (active ? 36 : 0);
                final reflow =
                    constraints.maxWidth < 240 ||
                    s.media.textScaler.scale(1) >= 1.5 ||
                    painter.width > textWidth;
                painter.dispose();
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(command.label, style: labelStyle),
                    if (command.description != null) ...[
                      const SizedBox(height: UiGalleryTokens.space1),
                      Text(
                        command.description!,
                        style: s.body(
                          s.theme.textTheme.bodyMedium?.copyWith(
                            color: s.muted,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
                final hint = ExcludeSemantics(
                  child: Icon(Icons.keyboard_return_rounded, color: ink),
                );
                final icon = command.icon == null
                    ? null
                    : IconTheme.merge(
                        data: IconThemeData(color: ink),
                        child: command.icon!,
                      );
                return reflow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          copy,
                          if (icon != null || active) ...[
                            const SizedBox(height: UiGalleryTokens.space2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [?icon, if (active) hint],
                            ),
                          ],
                        ],
                      )
                    : Row(
                        children: [
                          if (icon != null) ...[
                            icon,
                            const SizedBox(width: UiGalleryTokens.space3),
                          ],
                          Expanded(child: copy),
                          if (active) ...[
                            const SizedBox(width: UiGalleryTokens.space3),
                            hint,
                          ],
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
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
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Focus(
        canRequestFocus: false,
        onKeyEvent: _key,
        child: Column(
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
            const SizedBox(height: UiGalleryTokens.space3),
            if (commands.isEmpty)
              Padding(
                padding: const EdgeInsets.all(UiGalleryTokens.space4),
                child: Text(
                  widget.emptyLabel,
                  style: TextStyle(color: s.muted),
                ),
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
                        borderRadius: BorderRadius.circular(
                          UiGalleryTokens.radiusToolbar,
                        ),
                        child: s.signatureEnabled
                            ? _command(s, commands[i], i)
                            : ListTile(
                                focusNode: _commandNode(i),
                                onFocusChange: (focused) {
                                  if (focused) _activate(i);
                                },
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
                                    ? () => Navigator.of(
                                        context,
                                      ).pop<T>(commands[i].value)
                                    : null,
                              ),
                      ),
                  ],
                ),
              ),
          ],
        ),
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
              padding: const EdgeInsets.only(bottom: UiGalleryTokens.space3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: s.duration(s.motion.change),
                        width: UiGalleryTokens.space7,
                        height: UiGalleryTokens.space7,
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
                        Container(
                          width: UiGalleryTokens.lineWidth,
                          height: 18,
                          color: s.line,
                        ),
                    ],
                  ),
                  const SizedBox(width: UiGalleryTokens.insetHandle),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: UiGalleryTokens.space1,
                      ),
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
