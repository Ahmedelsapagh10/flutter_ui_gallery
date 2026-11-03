import 'package:flutter/material.dart';
import '../core/gallery_theme.dart';
import '../core/gallery_style.dart';
import '../core/gallery_signature.dart';
import '../core/gallery_signature_exceptions.dart';
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
  final _bodyKey = GlobalKey();
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
    final calm =
        s.signatureEnabled &&
        (p == UiGallerySheetPreset.orbit ||
            p == UiGallerySheetPreset.splitLayer);
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
        topStart: Radius.circular(UiGalleryTokens.radiusOrbitStart),
        topEnd: Radius.circular(UiGalleryTokens.radiusAction),
        bottomStart: Radius.circular(UiGalleryTokens.radiusLarge),
        bottomEnd: Radius.circular(UiGalleryTokens.radiusOrbitEnd),
      ),
      UiGallerySheetPreset.prism => const BorderRadiusDirectional.only(
        topStart: Radius.circular(UiGalleryTokens.radiusSmall),
        topEnd: Radius.circular(UiGalleryTokens.radiusStage),
        bottomStart: Radius.circular(UiGalleryTokens.radiusSmall),
        bottomEnd: Radius.circular(UiGalleryTokens.radiusSmall),
      ),
      UiGallerySheetPreset.fold => const BorderRadius.vertical(
        top: Radius.circular(UiGalleryTokens.radiusCapsule),
      ),
      UiGallerySheetPreset.flow => const BorderRadius.vertical(
        top: Radius.circular(UiGalleryTokens.radiusLarge),
      ),
      UiGallerySheetPreset.edgeLift => BorderRadius.zero,
      UiGallerySheetPreset.depthFrame => BorderRadius.circular(
        UiGalleryTokens.radiusFrame,
      ),
      UiGallerySheetPreset.neoTray ||
      UiGallerySheetPreset.taskRail => const BorderRadius.vertical(
        top: Radius.circular(UiGalleryTokens.radiusToolbar),
      ),
      UiGallerySheetPreset.pulseDock => BorderRadius.circular(
        UiGalleryTokens.radiusOrbitEnd,
      ),
      _ => BorderRadius.circular(UiGalleryTokens.radiusLarge),
    };
    Widget content = calm
        ? GalleryFamilyEdge(
            style: s,
            child: Padding(
              padding: s.gallery.designFamily == UiGalleryDesignFamily.spatial
                  ? const EdgeInsetsDirectional.only(
                      end: UiGalleryTokens.space3,
                      bottom: UiGalleryTokens.space3,
                    )
                  : EdgeInsets.zero,
              child: KeyedSubtree(key: _bodyKey, child: widget.child),
            ),
          )
        : GalleryFamilyRegion(
            style: s,
            framed: GallerySignatureExceptions.sheetWells.contains(p),
            child: widget.child,
          );
    if (calm) {
      final canvas = content;
      content = LayoutBuilder(
        builder: (context, bounds) {
          final stacked =
              bounds.maxWidth < UiGalleryTokens.sheetSplitBreakpoint ||
              s.media.textScaler.scale(1) >= 1.5;
          final contextWidth = bounds.maxWidth * .32;
          final contextPanel = widget.secondary == null
              ? null
              : GalleryFamilyEdge(
                  style: s,
                  ownsRule: true,
                  child: Container(
                    padding: const EdgeInsets.all(UiGalleryTokens.space4),
                    decoration: BoxDecoration(
                      color:
                          s.gallery.designFamily == UiGalleryDesignFamily.soft
                          ? s.tinted
                          : s.surface,
                      border: BorderDirectional(
                        start: BorderSide(
                          color: s.accent,
                          width: UiGalleryTokens.lineWidth * 2,
                        ),
                      ),
                    ),
                    child: widget.secondary,
                  ),
                );
          if (!widget.scrollable) {
            return Flex(
              direction: stacked ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (contextPanel != null) ...[
                  Flexible(
                    flex: 2,
                    child: SingleChildScrollView(
                      primary: false,
                      child: contextPanel,
                    ),
                  ),
                  SizedBox(
                    width: stacked ? 0 : UiGalleryTokens.space4,
                    height: stacked ? UiGalleryTokens.space4 : 0,
                  ),
                ],
                Expanded(flex: 3, child: canvas),
              ],
            );
          }
          return Wrap(
            spacing: UiGalleryTokens.space4,
            runSpacing: UiGalleryTokens.space4,
            children: [
              if (contextPanel != null)
                SizedBox(
                  width: stacked ? bounds.maxWidth : contextWidth,
                  child: contextPanel,
                ),
              SizedBox(
                width: stacked || contextPanel == null
                    ? bounds.maxWidth
                    : bounds.maxWidth - contextWidth - UiGalleryTokens.space4,
                child: canvas,
              ),
            ],
          );
        },
      );
    }
    final body = widget.scrollable
        ? SingleChildScrollView(
            padding:
                s.visual.padding ??
                const EdgeInsets.all(UiGalleryTokens.space6),
            child: content,
          )
        : Padding(
            padding:
                s.visual.padding ??
                const EdgeInsets.all(UiGalleryTokens.space6),
            child: content,
          );
    final header =
        widget.header == null &&
            widget.leading == null &&
            widget.trailing == null
        ? null
        : Padding(
            padding: const EdgeInsets.fromLTRB(
              UiGalleryTokens.space6,
              UiGalleryTokens.space3,
              UiGalleryTokens.space6,
              UiGalleryTokens.space4,
            ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: UiGalleryTokens.space3),
                ],
                if (widget.header != null)
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: s.gallery.designFamily == null
                          ? s.visual.titleStyle
                          : s.heading(
                              s.theme.textTheme.titleLarge?.copyWith(
                                color: s.content,
                              ),
                            ),
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
            padding: const EdgeInsets.all(UiGalleryTokens.space4),
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
                constraints: const BoxConstraints(
                  minHeight: UiGalleryTokens.touchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(UiGalleryTokens.space2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                      ),
                      const SizedBox(width: UiGalleryTokens.space2),
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
            padding: const EdgeInsets.only(
              top: UiGalleryTokens.insetHandle,
              bottom: UiGalleryTokens.space2,
            ),
            child: Center(
              child: Container(
                width: UiGalleryTokens.handleWidth,
                height: UiGalleryTokens.space1,
                decoration: BoxDecoration(
                  color: s.line,
                  borderRadius: BorderRadius.circular(
                    UiGalleryTokens.radiusFrame,
                  ),
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
        if (calm && constraints.maxHeight < s.media.textScaler.scale(140)) {
          return SingleChildScrollView(
            primary: false,
            child: column([
              handle,
              ?header,
              widget.scrollable
                  ? body
                  : SizedBox(height: constraints.maxHeight * .65, child: body),
              ?footer,
            ]),
          );
        }
        final wide =
            constraints.maxWidth >= UiGalleryTokens.sheetSplitBreakpoint &&
            s.media.textScaler.scale(1) < 1.5;
        if (p == UiGallerySheetPreset.splitLayer &&
            !calm &&
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
                  padding: const EdgeInsets.all(UiGalleryTokens.space5),
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
                width: UiGalleryTokens.touchTarget,
                color: s.tinted,
                padding: const EdgeInsets.symmetric(
                  vertical: UiGalleryTokens.space5,
                ),
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
            Container(height: UiGalleryTokens.space1, color: s.accent),
            if (header != null) ColoredBox(color: s.tinted, child: header),
            Flexible(
              child: Container(
                margin: const EdgeInsets.all(UiGalleryTokens.space3),
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
                  const SizedBox(height: UiGalleryTokens.space5),
                  Icon(
                    Icons.bolt_rounded,
                    size: UiGalleryTokens.iconLarge,
                    color: s.accent,
                  ),
                  header,
                ]),
              ),
            Flexible(child: body),
            ?footer,
          ]);
        }
        return column([
          if (p == UiGallerySheetPreset.edgeLift)
            Container(height: UiGalleryTokens.baselineHeight, color: s.accent)
          else
            handle,
          if (p == UiGallerySheetPreset.horizonPeek && widget.secondary != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(UiGalleryTokens.space4),
                child: widget.secondary!,
              ),
            ),
          if (header != null)
            ColoredBox(
              color:
                  p == UiGallerySheetPreset.prism ||
                      (p == UiGallerySheetPreset.splitLayer && !calm)
                  ? s.tinted
                  : s.surface,
              child: header,
            ),
          Flexible(child: body),
          if (p != UiGallerySheetPreset.horizonPeek &&
              !calm &&
              widget.secondary != null)
            Padding(
              padding: const EdgeInsets.all(UiGalleryTokens.space4),
              child: widget.secondary!,
            ),
          ?footer,
          if (p == UiGallerySheetPreset.prism)
            Container(height: UiGalleryTokens.markerThickness, color: s.accent),
        ]);
      },
    );
    composition = Material(
      color: s.surface,
      elevation: s.elevation(floating ? 10 : 2),
      shadowColor: s.shadowFor(.2),
      shape: s.shape(
        RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: s.line),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: s.visual.gradient),
        child: DefaultTextStyle.merge(
          style: s.body(
            s.gallery.designFamily == null
                ? TextStyle(color: s.content)
                : s.theme.textTheme.bodyMedium?.copyWith(color: s.content),
          ),
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
        padding: const EdgeInsets.all(UiGalleryTokens.space2),
        decoration: BoxDecoration(
          color: s.tinted,
          border: Border.all(
            color: s.line,
            width: UiGalleryTokens.baselineHeight,
          ),
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
                borderRadius: BorderRadius.circular(
                  UiGalleryTokens.radiusLarge,
                ),
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
                borderRadius: BorderRadius.circular(
                  UiGalleryTokens.radiusLarge,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: UiGalleryTokens.space4),
            child: composition,
          ),
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
            floating ? UiGalleryTokens.space4 : 0,
            UiGalleryTokens.space3,
            floating ? UiGalleryTokens.space4 : 0,
            floating ? UiGalleryTokens.space4 : 0,
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
            offset: Offset(0, (1 - t) * UiGalleryTokens.sheetRevealDistance),
            child: child,
          ),
          UiGallerySheetPreset.depthFrame ||
          UiGallerySheetPreset.prism => Transform.scale(
            scale:
                UiGalleryTokens.sheetRevealScale +
                (1 - UiGalleryTokens.sheetRevealScale) * t,
            child: child,
          ),
          UiGallerySheetPreset.pulseDock => Transform.scale(
            scale:
                UiGalleryTokens.pulseRevealScale +
                (1 - UiGalleryTokens.pulseRevealScale) * t,
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
                        end: i == steps.length - 1
                            ? 0
                            : UiGalleryTokens.gapCompact,
                      ),
                      height: i == currentStep ? 6 : 3,
                      decoration: BoxDecoration(
                        color: i <= currentStep ? s.accent : s.line,
                        borderRadius: BorderRadius.circular(
                          UiGalleryTokens.radiusStep,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: UiGalleryTokens.space5),
        Text(
          steps[currentStep],
          style: s.theme.textTheme.titleLarge?.copyWith(color: s.content),
        ),
        const SizedBox(height: UiGalleryTokens.space5),
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
