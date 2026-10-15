import 'package:flutter/material.dart';
import '../core/gallery_theme.dart';
import '../core/gallery_style.dart';
import '../core/gallery_shape.dart';

enum UiGallerySheetPreset {
  orbit,
  fold,
  prism,
  flow,
  edgeLift,
  stackPanel,
  neoTray,
  splitLayer,
  pulseDock,
  horizonPeek,
  depthFrame,
  taskRail;

  static const orbitDock = orbit;
  static const foldMotion = fold;
  static const prismStage = prism;
  static const flowCanvas = flow;
}

abstract final class UiGallerySheet {
  /// Footer stays outside the scroller. Secondary is a preview/second content
  /// zone. Use scrollable:false for ListView or other self-scrolling content.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    UiGallerySheetPreset preset = UiGallerySheetPreset.orbit,
    Widget? header,
    Widget? footer,
    Widget? secondary,
    Widget? leading,
    Widget? trailing,
    UiGalleryTheme? appearance,
    UiGallerySurfaceStyle? style,
    UiGalleryMotion? motion,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool scrollable = true,
    bool? requestFocus,
    String? barrierLabel,
    Color? barrierColor,
    String? semanticLabel,
    RouteSettings? routeSettings,
    AlignmentGeometry alignment = Alignment.bottomCenter,
  }) {
    final s = UiGalleryStyle.of(
      context,
      appearance,
      style,
      motion,
      UiGallerySurface.sheet,
    );
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      requestFocus: requestFocus,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      routeSettings: routeSettings,
      backgroundColor: Colors.transparent,
      elevation: 0,
      constraints: BoxConstraints(
        maxWidth: s.visual.maxWidth ?? UiGalleryTokens.sheetWidth,
      ),
      sheetAnimationStyle: AnimationStyle(
        duration: s.duration(s.motion.entrance),
        reverseDuration: s.duration(s.motion.exit),
      ),
      builder: (context) => Align(
        alignment: alignment,
        heightFactor: 1,
        child: Semantics(
          label: semanticLabel,
          child: _SheetSurface(
            preset: preset,
            header: header,
            footer: footer,
            secondary: secondary,
            leading: leading,
            trailing: trailing,
            appearance: appearance,
            style: style,
            motion: motion,
            scrollable: scrollable,
            child: child,
          ),
        ),
      ),
    );
  }
}

typedef NovaSheet = UiGallerySheet;
typedef NovaSheetPreset = UiGallerySheetPreset;
typedef NovaFlow = UiGalleryFlow;

class _SheetSurface extends StatefulWidget {
  const _SheetSurface({
    required this.preset,
    required this.child,
    required this.scrollable,
    this.header,
    this.footer,
    this.secondary,
    this.leading,
    this.trailing,
    this.appearance,
    this.style,
    this.motion,
  });
  final UiGallerySheetPreset preset;
  final Widget child;
  final bool scrollable;
  final Widget? header, footer, secondary, leading, trailing;
  final UiGalleryTheme? appearance;
  final UiGallerySurfaceStyle? style;
  final UiGalleryMotion? motion;
  @override
  State<_SheetSurface> createState() => _SheetSurfaceState();
}

class _SheetSurfaceState extends State<_SheetSurface> {
  bool _expanded = false;
  final _contentKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final s = UiGalleryStyle.of(
      context,
      widget.appearance,
      widget.style,
      widget.motion,
      UiGallerySurface.sheet,
    );
    final p = widget.preset;
    final floating = {
      UiGallerySheetPreset.orbit,
      UiGallerySheetPreset.prism,
      UiGallerySheetPreset.stackPanel,
      UiGallerySheetPreset.pulseDock,
      UiGallerySheetPreset.depthFrame,
    }.contains(p);
    final fold = p == UiGallerySheetPreset.fold;
    final height =
        (s.media.size.height -
                s.media.padding.top -
                s.media.padding.bottom -
                s.media.viewInsets.bottom -
                40)
            .clamp(0.0, double.infinity);
    final radius = switch (p) {
      UiGallerySheetPreset.orbit => const BorderRadiusDirectional.only(
        topStart: Radius.circular(48),
        topEnd: Radius.circular(20),
        bottomStart: Radius.circular(24),
        bottomEnd: Radius.circular(36),
      ),
      UiGallerySheetPreset.prism => const BorderRadiusDirectional.only(
        topStart: Radius.circular(8),
        topEnd: Radius.circular(52),
        bottomStart: Radius.circular(8),
        bottomEnd: Radius.circular(8),
      ),
      UiGallerySheetPreset.fold => const BorderRadius.vertical(
        top: Radius.circular(32),
      ),
      UiGallerySheetPreset.flow => const BorderRadius.vertical(
        top: Radius.circular(24),
      ),
      UiGallerySheetPreset.edgeLift => BorderRadius.zero,
      UiGallerySheetPreset.depthFrame => BorderRadius.circular(4),
      UiGallerySheetPreset.neoTray || UiGallerySheetPreset.taskRail =>
        const BorderRadius.vertical(top: Radius.circular(12)),
      UiGallerySheetPreset.pulseDock => BorderRadius.circular(36),
      _ => BorderRadius.circular(24),
    };
    final body = widget.scrollable
        ? SingleChildScrollView(
            padding: s.visual.padding ?? const EdgeInsets.all(24),
            child: widget.child,
          )
        : Padding(
            padding: s.visual.padding ?? const EdgeInsets.all(24),
            child: widget.child,
          );
    final header =
        widget.header == null &&
            widget.leading == null &&
            widget.trailing == null
        ? null
        : Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 12),
                ],
                if (widget.header != null)
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: s.visual.titleStyle,
                      child: widget.header!,
                    ),
                  ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
          );
    final footer = widget.footer == null
        ? null
        : Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: s.tinted,
              border: Border(top: BorderSide(color: s.line)),
            ),
            child: widget.footer,
          );
    final handle = fold
        ? Semantics(
            button: true,
            expanded: _expanded,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _expanded
                              ? MaterialLocalizations.of(
                                  context,
                                ).expandedIconTapHint
                              : MaterialLocalizations.of(
                                  context,
                                ).collapsedIconTapHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: s.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
    Widget composition = LayoutBuilder(
      builder: (context, constraints) {
        Widget column(List<Widget> children) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
        final wide =
            constraints.maxWidth >= 500 && s.media.textScaler.scale(1) < 1.5;
        if (p == UiGallerySheetPreset.splitLayer &&
            wide &&
            (widget.secondary != null || footer != null)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: column([handle, ?header, Flexible(child: body)]),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: s.tinted,
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: column([
                      if (widget.secondary != null) widget.secondary!,
                      ?footer,
                    ]),
                  ),
                ),
              ),
            ],
          );
        }
        if (p == UiGallerySheetPreset.taskRail) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                color: s.tinted,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: const Icon(Icons.tune_rounded),
              ),
              Expanded(
                child: column([?header, Flexible(child: body), ?footer]),
              ),
            ],
          );
        }
        if (p == UiGallerySheetPreset.neoTray) {
          return column([
            Container(height: 4, color: s.accent),
            if (header != null) ColoredBox(color: s.tinted, child: header),
            Flexible(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: s.line)),
                child: body,
              ),
            ),
            ?footer,
          ]);
        }
        if (p == UiGallerySheetPreset.pulseDock) {
          return column([
            if (header != null)
              Container(
                color: s.tinted,
                child: column([
                  const SizedBox(height: 20),
                  Icon(Icons.bolt_rounded, size: 32, color: s.accent),
                  header,
                ]),
              ),
            Flexible(child: body),
            ?footer,
          ]);
        }
        return column([
          if (p == UiGallerySheetPreset.edgeLift)
            Container(height: 2, color: s.accent)
          else
            handle,
          if (p == UiGallerySheetPreset.horizonPeek && widget.secondary != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: widget.secondary!,
              ),
            ),
          if (header != null)
            ColoredBox(
              color:
                  p == UiGallerySheetPreset.prism ||
                      p == UiGallerySheetPreset.splitLayer
                  ? s.tinted
                  : s.surface,
              child: header,
            ),
          Flexible(child: body),
          if (p != UiGallerySheetPreset.horizonPeek && widget.secondary != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: widget.secondary!,
            ),
          ?footer,
          if (p == UiGallerySheetPreset.prism)
            Container(height: 3, color: s.accent),
        ]);
      },
    );
    composition = Material(
      color: s.surface,
      elevation: s.visual.elevation ?? (floating ? 10 : 2),
      shadowColor: s.visual.shadowColor ?? Colors.black.withValues(alpha: .2),
      shape:
          s.visual.shape ??
          RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: s.line),
          ),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: s.visual.gradient),
        child: DefaultTextStyle.merge(
          style: s.visual.messageStyle ?? TextStyle(color: s.content),
          child: IconTheme(
            data: IconThemeData(color: s.accent),
            child: Padding(
              padding: galleryCurveInsets(s.visual.shape),
              child: composition,
            ),
          ),
        ),
      ),
    );
    if (p == UiGallerySheetPreset.depthFrame) {
      composition = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: s.tinted,
          border: Border.all(color: s.line, width: 2),
        ),
        child: composition,
      );
    }
    if (p == UiGallerySheetPreset.stackPanel) {
      composition = Stack(
        children: [
          Positioned(
            top: 0,
            left: 24,
            right: 24,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: s.accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            top: 7,
            left: 12,
            right: 12,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: s.tinted,
                border: Border.all(color: s.line),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.only(top: 16), child: composition),
        ],
      );
    }
    Widget sized = KeyedSubtree(
      key: _contentKey,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: fold && !_expanded && s.media.viewInsets.bottom == 0
              ? height * .56
              : p == UiGallerySheetPreset.horizonPeek
              ? height * .72
              : height,
        ),
        child: _SheetReveal(preset: p, style: s, child: composition),
      ),
    );
    if (!s.reduceMotion && s.duration(s.motion.entrance) > Duration.zero) {
      sized = AnimatedSize(
        duration: s.duration(s.motion.entrance),
        curve: s.curve,
        alignment: Alignment.bottomCenter,
        child: sized,
      );
    }
    return AnimatedPadding(
      duration: s.duration(s.motion.change),
      curve: s.curve,
      padding: EdgeInsets.only(bottom: s.media.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            floating ? 16 : 0,
            12,
            floating ? 16 : 0,
            floating ? 16 : 0,
          ),
          child: sized,
        ),
      ),
    );
  }
}

class _SheetReveal extends StatelessWidget {
  const _SheetReveal({
    required this.preset,
    required this.style,
    required this.child,
  });
  final UiGallerySheetPreset preset;
  final UiGalleryStyle style;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final animation = style.reduceMotion
        ? const AlwaysStoppedAnimation<double>(1)
        : ModalRoute.of(context)?.animation ??
              const AlwaysStoppedAnimation<double>(1);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = style.curve.transform(animation.value).clamp(0.0, 1.0);
        return switch (preset) {
          UiGallerySheetPreset.stackPanel => Transform.translate(
            offset: Offset(0, (1 - t) * 12),
            child: child,
          ),
          UiGallerySheetPreset.depthFrame || UiGallerySheetPreset.prism =>
            Transform.scale(scale: .97 + .03 * t, child: child),
          UiGallerySheetPreset.pulseDock => Transform.scale(
            scale: .94 + .06 * t,
            child: child,
          ),
          UiGallerySheetPreset.edgeLift ||
          UiGallerySheetPreset.taskRail => child!,
          _ => Opacity(opacity: .7 + .3 * t, child: child),
        };
      },
    );
  }
}

/// A controlled multi-step canvas. Every page stays mounted, retaining forms
/// and scroll state. Supply this as the child of a Flow sheet or use it inline.
class UiGalleryFlow extends StatelessWidget {
  const UiGalleryFlow({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.children,
    this.appearance,
    this.style,
    this.motion,
  }) : assert(currentStep >= 0);

  final List<String> steps;
  final int currentStep;
  final List<Widget> children;
  final UiGalleryTheme? appearance;
  final UiGallerySurfaceStyle? style;
  final UiGalleryMotion? motion;

  @override
  Widget build(BuildContext context) {
    assert(
      steps.isNotEmpty &&
          steps.length == children.length &&
          currentStep < steps.length,
    );
    final s = UiGalleryStyle.of(
      context,
      appearance,
      style,
      motion,
      UiGallerySurface.sheet,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          liveRegion: true,
          label: '${currentStep + 1} / ${steps.length}: ${steps[currentStep]}',
          child: ExcludeSemantics(
            child: Row(
              children: [
                for (var i = 0; i < steps.length; i++)
                  Expanded(
                    child: AnimatedContainer(
                      duration: s.duration(UiGalleryTokens.change),
                      margin: EdgeInsetsDirectional.only(
                        end: i == steps.length - 1 ? 0 : 6,
                      ),
                      height: i == currentStep ? 6 : 3,
                      decoration: BoxDecoration(
                        color: i <= currentStep ? s.accent : s.line,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          steps[currentStep],
          style: s.theme.textTheme.titleLarge?.copyWith(color: s.content),
        ),
        const SizedBox(height: 20),
        _FlowPages(currentStep: currentStep, children: children),
      ],
    );
  }
}

class _FlowPages extends StatefulWidget {
  const _FlowPages({required this.currentStep, required this.children});
  final int currentStep;
  final List<Widget> children;
  @override
  State<_FlowPages> createState() => _FlowPagesState();
}

class _FlowPagesState extends State<_FlowPages>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    value: 1,
  );
  double _direction = 1;

  @override
  void didUpdateWidget(_FlowPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _direction = widget.currentStep > oldWidget.currentStep ? 1 : -1;
      final style = UiGalleryStyle.of(
        context,
        null,
        null,
        null,
        UiGallerySurface.sheet,
      );
      _motion.duration = style.duration(style.motion.change);
      _motion.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _motion,
    builder: (context, child) => Transform.translate(
      offset: Offset(
        (1 -
                UiGalleryStyle.of(
                  context,
                  null,
                  null,
                  null,
                  UiGallerySurface.sheet,
                ).curve.transform(_motion.value).clamp(0.0, 1.0)) *
            _direction *
            (Directionality.of(context) == TextDirection.rtl ? -16 : 16),
        0,
      ),
      child: child,
    ),
    child: IndexedStack(
      index: widget.currentStep,
      alignment: AlignmentDirectional.topStart,
      children: widget.children,
    ),
  );
}
