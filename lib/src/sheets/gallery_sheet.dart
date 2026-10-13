import 'package:flutter/material.dart';

import '../core/gallery_theme.dart';

/// The four sheet compositions in Flutter UI Gallery.
enum UiGallerySheetPreset { orbit, fold, prism, flow }

abstract final class UiGallerySheet {
  /// Uses Flutter's modal route, with typed results and navigator ownership.
  ///
  /// Content scrolls by default. Set [scrollable] to false for a ListView or
  /// another widget that manages its own scrolling. [footer] stays visible.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    UiGallerySheetPreset preset = UiGallerySheetPreset.orbit,
    Widget? header,
    Widget? footer,
    UiGalleryTheme? appearance,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool scrollable = true,
    bool? requestFocus,
    String? barrierLabel,
    RouteSettings? routeSettings,
  }) {
    final style = UiGalleryStyle.of(context, appearance);
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      requestFocus: requestFocus,
      barrierLabel: barrierLabel,
      routeSettings: routeSettings,
      backgroundColor: Colors.transparent,
      elevation: 0,
      constraints: const BoxConstraints(maxWidth: UiGalleryTokens.sheetWidth),
      sheetAnimationStyle: AnimationStyle(
        duration: style.duration(UiGalleryTokens.entrance),
        reverseDuration: style.duration(UiGalleryTokens.exit),
      ),
      builder: (context) => _SheetSurface(
        preset: preset,
        header: header,
        footer: footer,
        appearance: appearance,
        scrollable: scrollable,
        child: child,
      ),
    );
  }
}

// Backwards-compatible aliases
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
    this.appearance,
  });
  final UiGallerySheetPreset preset;
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final UiGalleryTheme? appearance;
  final bool scrollable;

  @override
  State<_SheetSurface> createState() => _SheetSurfaceState();
}

class _SheetSurfaceState extends State<_SheetSurface> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = UiGalleryStyle.of(context, widget.appearance);
    final fold = widget.preset == UiGallerySheetPreset.fold;
    final orbit = widget.preset == UiGallerySheetPreset.orbit;
    final prism = widget.preset == UiGallerySheetPreset.prism;
    final bottom = s.media.viewInsets.bottom;
    final height = (s.media.size.height - s.media.padding.top - bottom - 32)
        .clamp(0.0, double.infinity);
    final radius = switch (widget.preset) {
      UiGallerySheetPreset.orbit => const BorderRadiusDirectional.only(
        topStart: Radius.circular(48),
        topEnd: Radius.circular(20),
        bottomStart: Radius.circular(24),
        bottomEnd: Radius.circular(36),
      ),
      UiGallerySheetPreset.fold => const BorderRadius.vertical(
        top: Radius.circular(32),
      ),
      UiGallerySheetPreset.prism => const BorderRadiusDirectional.only(
        topStart: Radius.circular(8),
        topEnd: Radius.circular(52),
        bottomStart: Radius.circular(8),
        bottomEnd: Radius.circular(8),
      ),
      UiGallerySheetPreset.flow => const BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    };
    final content = widget.scrollable
        ? SingleChildScrollView(
            padding: EdgeInsets.all(prism ? 28 : 24),
            child: widget.child,
          )
        : Padding(padding: const EdgeInsets.all(24), child: widget.child);
    return AnimatedPadding(
      duration: s.duration(UiGalleryTokens.change),
      curve: UiGalleryTokens.curve,
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            orbit || prism ? 16 : 0,
            12,
            orbit || prism ? 16 : 0,
            orbit || prism ? 16 : 0,
          ),
          child: AnimatedSize(
            duration: s.duration(UiGalleryTokens.entrance),
            curve: UiGalleryTokens.curve,
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: fold && !_expanded ? height * .56 : height,
              ),
              child: Material(
                color: s.surface,
                elevation: orbit ? 12 : 4,
                shadowColor: Colors.black.withValues(alpha: .2),
                shape: RoundedRectangleBorder(
                  borderRadius: radius,
                  side: BorderSide(color: s.line),
                ),
                clipBehavior: Clip.antiAlias,
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: s.content),
                  child: IconTheme(
                    data: IconThemeData(color: s.accent),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (fold)
                          Semantics(
                            button: true,
                            expanded: _expanded,
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _expanded = !_expanded),
                              child: SizedBox(
                                height: UiGalleryTokens.touchTarget,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _expanded
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_up,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _expanded
                                          ? MaterialLocalizations.of(
                                              context,
                                            ).expandedIconTapHint
                                          : MaterialLocalizations.of(
                                              context,
                                            ).collapsedIconTapHint,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 8),
                            child: Center(
                              child: Container(
                                width: orbit ? 32 : 44,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: s.line,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        if (widget.header != null)
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                            decoration: BoxDecoration(
                              color: prism ? s.tinted : null,
                              border: widget.preset == UiGallerySheetPreset.flow
                                  ? Border(bottom: BorderSide(color: s.line))
                                  : null,
                            ),
                            child: widget.header,
                          ),
                        Flexible(child: content),
                        if (widget.footer != null)
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  prism ||
                                      widget.preset == UiGallerySheetPreset.flow
                                  ? s.tinted
                                  : null,
                              border: Border(top: BorderSide(color: s.line)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: widget.footer,
                          ),
                        if (prism) Container(height: 3, color: s.accent),
                      ],
                    ),
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

/// A controlled multi-step canvas. Every page stays mounted, retaining forms
/// and scroll state. Supply this as the child of a Flow sheet or use it inline.
class UiGalleryFlow extends StatelessWidget {
  const UiGalleryFlow({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.children,
  }) : assert(currentStep >= 0);

  final List<String> steps;
  final int currentStep;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    assert(
      steps.isNotEmpty &&
          steps.length == children.length &&
          currentStep < steps.length,
    );
    final s = UiGalleryStyle.of(context);
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
      _motion.duration = UiGalleryStyle.of(
        context,
      ).duration(UiGalleryTokens.change);
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
        (1 - UiGalleryTokens.curve.transform(_motion.value)) *
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
