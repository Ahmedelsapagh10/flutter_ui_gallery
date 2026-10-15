import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderBox, ScrollDirection;
import 'package:flutter/semantics.dart';

import '../core/gallery_shape.dart';
import '../core/gallery_style.dart';
import '../core/gallery_theme.dart';

enum UiGalleryBottomNavPreset {
  floatingCove,
  concaveNotch,
  convexWave,
  orbitDock,
  ribbonCurve,
  layeredShelf,
  splitIsland,
  perspectiveDock,
  morphingCapsule,
  adaptiveMinimal,
  glassDock,
  liquidDrop,
  scrollDock,
  flipTiles,
  overflowDock,
}

enum UiGalleryNavLabels { always, selected, adaptive }

@immutable
class UiGalleryBottomNavItem {
  const UiGalleryBottomNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.enabled = true,
    this.semanticLabel,
  });
  final Widget icon;
  final Widget? selectedIcon, badge;
  final String label;
  final bool enabled;
  final String? semanticLabel;
}

/// Navigation-specific layout and state styling; shared surface/motion options
/// remain available through [UiGalleryBottomNav.style] and `.motion`.
@immutable
class UiGalleryBottomNavOptions {
  const UiGalleryBottomNavOptions({
    this.height = 64,
    this.spacing = 4,
    this.curveDepth = 14,
    this.notchWidth = 72,
    this.notchDepth = 24,
    this.groupBreak,
    this.depthIntensity = 1,
    this.labels = UiGalleryNavLabels.adaptive,
    this.hideWhenKeyboard = true,
    this.selectedColor,
    this.unselectedColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.margin,
    this.maxVisibleItems = 5,
    this.overflowLabel,
  }) : assert(maxVisibleItems >= 2),
       assert(height >= 48),
       assert(spacing >= 0),
       assert(curveDepth >= 0),
       assert(notchWidth >= 48),
       assert(notchDepth >= 0),
       assert(depthIntensity >= 0 && depthIntensity <= 1);
  final double height,
      spacing,
      curveDepth,
      notchWidth,
      notchDepth,
      depthIntensity;
  final int? groupBreak;
  final int maxVisibleItems;
  final String? overflowLabel;
  final UiGalleryNavLabels labels;
  final bool hideWhenKeyboard;
  final Color? selectedColor, unselectedColor;
  final TextStyle? selectedLabelStyle, unselectedLabelStyle;
  final EdgeInsetsGeometry? margin;
}

typedef UiGalleryBottomNavItemBuilder =
    Widget Function(
      BuildContext context,
      UiGalleryBottomNavItem item,
      int index,
      bool selected,
    );

/// Controlled navigation UI. It never changes routes or stores page state.
class UiGalleryBottomNav extends StatefulWidget {
  const UiGalleryBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.preset = UiGalleryBottomNavPreset.floatingCove,
    this.options = const UiGalleryBottomNavOptions(),
    this.style,
    this.motion,
    this.appearance,
    this.centerAction,
    this.itemBuilder,
    this.semanticLabel,
  }) : assert(items.length >= 2),
       assert(selectedIndex >= 0 && selectedIndex < items.length);

  final List<UiGalleryBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final UiGalleryBottomNavPreset preset;
  final UiGalleryBottomNavOptions options;
  final UiGallerySurfaceStyle? style;
  final UiGalleryMotion? motion;
  final UiGalleryTheme? appearance;
  final Widget? centerAction;
  final UiGalleryBottomNavItemBuilder? itemBuilder;
  final String? semanticLabel;

  @override
  State<UiGalleryBottomNav> createState() => _UiGalleryBottomNavState();
}

class _UiGalleryBottomNavState extends State<UiGalleryBottomNav>
    with SingleTickerProviderStateMixin {
  ScrollNotificationObserverState? _observer;
  ScrollDirection _scrollDirection = ScrollDirection.idle;
  bool _hidden = false;
  late final AnimationController _selection = AnimationController(
    vsync: this,
    value: 1,
  );
  late double _from = widget.selectedIndex.toDouble();
  late double _target = _from;
  Curve _curve = Curves.easeOutCubic;
  double get _position => lerpDouble(
    _from,
    _target,
    _curve.transform(_selection.value).clamp(0.0, 1.0),
  )!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = ScrollNotificationObserver.maybeOf(context);
    if (!identical(observer, _observer)) {
      _observer?.removeListener(_scroll);
      _observer = observer;
      _observer?.addListener(_scroll);
    }
    final s = UiGalleryStyle.of(
      context,
      widget.appearance,
      widget.style,
      widget.motion,
      UiGallerySurface.bottomNav,
    );
    _selection.duration = s.duration(s.motion.change);
    _curve = s.curve;
    if (s.reduceMotion) _selection.value = 1;
  }

  @override
  void didUpdateWidget(UiGalleryBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preset != widget.preset ||
        oldWidget.selectedIndex != widget.selectedIndex) {
      _hidden = false;
      _scrollDirection = ScrollDirection.idle;
    }
    final s = UiGalleryStyle.of(
      context,
      widget.appearance,
      widget.style,
      widget.motion,
      UiGallerySurface.bottomNav,
    );
    _selection.duration = s.duration(s.motion.change);
    _curve = s.curve;
    if (s.reduceMotion) _selection.value = 1;
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.items.length != widget.items.length) {
      _from = _position.clamp(0.0, widget.items.length - 1.0);
      _target = widget.selectedIndex.toDouble();
      _curve = s.curve;
      if (s.reduceMotion || _selection.duration == Duration.zero) {
        _selection.value = 1;
      } else {
        _selection.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _observer?.removeListener(_scroll);
    _selection.dispose();
    super.dispose();
  }

  void _scroll(ScrollNotification notification) {
    if (widget.preset != UiGalleryBottomNavPreset.scrollDock ||
        notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical) {
      return;
    }
    if (notification is UserScrollNotification) {
      _scrollDirection = notification.direction;
    } else if (notification is! ScrollUpdateNotification) {
      return;
    }
    if (_scrollDirection == ScrollDirection.idle) return;
    if (!_hidden && _scrollDirection == ScrollDirection.reverse) {
      final box = context.findRenderObject();
      final height = box is RenderBox && box.hasSize
          ? box.size.height
          : widget.options.height;
      if (notification.metrics.maxScrollExtent -
              notification.metrics.minScrollExtent <=
          height + 32) {
        return;
      }
    }
    final hidden =
        _scrollDirection == ScrollDirection.reverse &&
        notification.metrics.pixels > 32;
    if (_hidden != hidden) setState(() => _hidden = hidden);
  }

  @override
  Widget build(BuildContext context) {
    final s = UiGalleryStyle.of(
      context,
      widget.appearance,
      widget.style,
      widget.motion,
      UiGallerySurface.bottomNav,
    );
    if (widget.options.hideWhenKeyboard && s.media.viewInsets.bottom > 0) {
      return const SizedBox.shrink();
    }
    final minimal = widget.preset == UiGalleryBottomNavPreset.adaptiveMinimal;
    final navigation = Semantics(
      label: widget.semanticLabel,
      child: RepaintBoundary(
        child: SafeArea(
          top: false,
          child: Padding(
            padding:
                widget.options.margin ??
                (minimal
                    ? EdgeInsets.zero
                    : const EdgeInsets.fromLTRB(12, 6, 12, 8)),
            child: Align(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: s.visual.maxWidth ?? 760),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (widget.preset ==
                        UiGalleryBottomNavPreset.overflowDock) {
                      return AnimatedBuilder(
                        animation: _selection,
                        builder: (context, _) =>
                            _overflow(context, s, constraints.maxWidth),
                      );
                    }
                    final split =
                        (widget.options.groupBreak ?? widget.items.length ~/ 2)
                            .clamp(1, widget.items.length - 1);
                    final gap =
                        widget.preset == UiGalleryBottomNavPreset.concaveNotch
                        ? widget.options.notchWidth
                        : widget.preset == UiGalleryBottomNavPreset.splitIsland
                        ? (widget.centerAction == null
                              ? 16.0
                              : widget.options.notchWidth)
                        : 0.0;
                    final width = math.max(
                      constraints.maxWidth,
                      widget.items.length * 48.0 +
                          gap +
                          (widget.preset ==
                                  UiGalleryBottomNavPreset.morphingCapsule
                              ? 48 * .85
                              : 0) +
                          (s.visual.padding
                                  ?.resolve(Directionality.of(context))
                                  .horizontal ??
                              0),
                    );
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      hitTestBehavior: HitTestBehavior.deferToChild,
                      child: SizedBox(
                        width: width,
                        child: AnimatedBuilder(
                          animation: _selection,
                          builder: (context, _) =>
                              _surface(context, s, width, gap, split),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return widget.preset == UiGalleryBottomNavPreset.scrollDock
        ? ClipRect(
            child: AnimatedAlign(
              duration: s.duration(s.motion.change),
              curve: s.curve,
              alignment: Alignment.bottomCenter,
              heightFactor: _hidden ? 0 : 1,
              child: ExcludeFocus(
                excluding: _hidden,
                child: ExcludeSemantics(
                  excluding: _hidden,
                  child: IgnorePointer(ignoring: _hidden, child: navigation),
                ),
              ),
            ),
          )
        : navigation;
  }

  Widget _overflow(BuildContext context, UiGalleryStyle s, double available) {
    final direction = Directionality.of(context);
    final shape =
        s.visual.shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: s.line),
        );
    final padding = (s.visual.padding ?? EdgeInsets.zero)
        .add(galleryCurveInsets(shape))
        .resolve(direction);
    final width = math.max(available, 96.0 + padding.horizontal);
    final slots = math.max(
      2,
      math.min(
        widget.options.maxVisibleItems,
        ((width - padding.horizontal) / 48).floor(),
      ),
    );
    final overflow = widget.items.length > slots;
    final visible = overflow ? slots - 1 : widget.items.length;
    final itemWidth =
        (width - padding.horizontal) / (visible + (overflow ? 1 : 0));
    final rowHeight = math.max(
      widget.options.height,
      s.media.textScaler.scale(12).clamp(12.0, 28.0) + 40,
    );
    final hiddenSelected = widget.selectedIndex >= visible;
    final label =
        widget.options.overflowLabel ??
        MaterialLocalizations.of(context).moreButtonTooltip;
    final color = hiddenSelected
        ? widget.options.selectedColor ?? s.accent
        : widget.options.unselectedColor ?? s.muted;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      hitTestBehavior: HitTestBehavior.deferToChild,
      child: SizedBox(
        width: width,
        child: Material(
          color: s.surface,
          elevation: s.visual.elevation ?? 4,
          shadowColor: s.visual.shadowColor,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: s.visual.gradient),
            child: Padding(
              padding: padding,
              child: Row(
                children: [
                  for (var i = 0; i < visible; i++)
                    SizedBox(
                      width: itemWidth,
                      height: rowHeight,
                      child: _item(
                        context,
                        s,
                        i,
                        hiddenSelected
                            ? 0
                            : (1 - (_position - i).abs()).clamp(0.0, 1.0),
                        itemWidth,
                        s.reduceMotion
                            ? 0
                            : widget.options.depthIntensity *
                                  s.motion.intensity,
                      ),
                    ),
                  if (overflow)
                    SizedBox(
                      width: itemWidth,
                      height: rowHeight,
                      child: MenuAnchor(
                        style: MenuStyle(
                          backgroundColor: WidgetStatePropertyAll(s.surface),
                          maximumSize: WidgetStatePropertyAll(
                            Size(
                              320,
                              math.max(
                                48,
                                s.media.size.height -
                                    s.media.padding.vertical -
                                    48,
                              ),
                            ),
                          ),
                        ),
                        menuChildren: [
                          for (var i = visible; i < widget.items.length; i++)
                            MenuItemButton(
                              onPressed: widget.items[i].enabled
                                  ? () => widget.onDestinationSelected(i)
                                  : null,
                              leadingIcon: widget.items[i].icon,
                              trailingIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.items[i].badge != null)
                                    widget.items[i].badge!,
                                  if (i == widget.selectedIndex)
                                    Icon(Icons.check_rounded, color: s.accent),
                                ],
                              ),
                              child: Semantics(
                                selected: i == widget.selectedIndex,
                                label: widget.items[i].semanticLabel,
                                excludeSemantics:
                                    widget.items[i].semanticLabel != null,
                                child: Text(widget.items[i].label),
                              ),
                            ),
                        ],
                        builder: (context, controller, _) => MergeSemantics(
                          child: Semantics(
                            selected: hiddenSelected,
                            child: Tooltip(
                              message: label,
                              excludeFromSemantics: true,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: color,
                                  minimumSize: const Size(48, 48),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: widget.options.spacing,
                                  ),
                                  shape: const RoundedRectangleBorder(),
                                ),
                                onPressed: () => controller.isOpen
                                    ? controller.close()
                                    : controller.open(),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: BorderDirectional(
                                      start: BorderSide(color: s.line),
                                    ),
                                  ),
                                  child: SizedBox.expand(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Badge(
                                          isLabelVisible: widget.items
                                              .skip(visible)
                                              .any(
                                                (item) => item.badge != null,
                                              ),
                                          child: const Icon(
                                            Icons.more_horiz_rounded,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Flexible(
                                          child: Text(
                                            label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                s.visual.messageStyle ??
                                                s.theme.textTheme.labelSmall
                                                    ?.copyWith(color: color),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
      ),
    );
  }

  Widget _surface(
    BuildContext context,
    UiGalleryStyle s,
    double width,
    double gap,
    int split,
  ) {
    final p = widget.preset;
    final o = widget.options;
    final count = widget.items.length;
    final direction = Directionality.of(context);
    final horizontalPadding =
        s.visual.padding?.resolve(direction) ?? EdgeInsets.zero;
    final trackWidth = width - horizontalPadding.horizontal;
    final position = _position.clamp(0.0, count - 1.0);
    final weights = List.generate(
      count,
      (i) => p == UiGalleryBottomNavPreset.morphingCapsule
          ? 1 + .85 * (1 - (position - i).abs()).clamp(0.0, 1.0)
          : 1.0,
    );
    final total = weights.fold(0.0, (a, b) => a + b);
    final widths = weights.map((v) => (trackWidth - gap) * v / total).toList();
    final centers = <double>[];
    var offset = 0.0;
    for (var i = 0; i < count; i++) {
      if (gap > 0 && i == split) offset += gap;
      centers.add(offset + widths[i] / 2);
      offset += widths[i];
    }
    final lower = position.floor();
    final selectedCenter = lerpDouble(
      centers[lower],
      centers[math.min(lower + 1, count - 1)],
      position - lower,
    )!;
    final physical = direction == TextDirection.rtl
        ? horizontalPadding.left + trackWidth - selectedCenter
        : horizontalPadding.left + selectedCenter;
    final shapePosition =
        (((direction == TextDirection.rtl
                        ? horizontalPadding.right
                        : horizontalPadding.left) +
                    selectedCenter) /
                width)
            .clamp(0.0, 1.0);
    final scaledLabel = s.media.textScaler.scale(12).clamp(12.0, 28.0);
    final rowHeight = math.max(
      o.height,
      scaledLabel + (p == UiGalleryBottomNavPreset.orbitDock ? 48 : 40),
    );
    final notchCenter =
        widths.take(split).fold<double>(0.0, (a, b) => a + b) + gap / 2;
    final shape =
        s.visual.shape ??
        switch (p) {
          UiGalleryBottomNavPreset.floatingCove => UiGalleryCurvedBorder(
            curve: UiGalleryCurve.wave,
            edge: UiGalleryCurveEdge.bottom,
            depth: o.curveDepth,
            span: 1,
            position: .3,
            radius: 26,
            side: BorderSide(color: s.line),
          ),
          UiGalleryBottomNavPreset.concaveNotch => UiGalleryCurvedBorder(
            curve: UiGalleryCurve.concave,
            depth: o.notchDepth,
            position:
                ((direction == TextDirection.rtl
                        ? horizontalPadding.right
                        : horizontalPadding.left) +
                    notchCenter) /
                width,
            span: (o.notchWidth / width).clamp(.01, 1.0),
            radius: 18,
            side: BorderSide(color: s.line),
          ),
          UiGalleryBottomNavPreset.convexWave => UiGalleryCurvedBorder(
            curve: UiGalleryCurve.convex,
            depth: o.curveDepth,
            position: shapePosition,
            span: (2 / count).clamp(.01, 1.0),
            radius: 20,
            side: BorderSide(color: s.line),
          ),
          UiGalleryBottomNavPreset.ribbonCurve => UiGalleryCurvedBorder(
            curve: UiGalleryCurve.ribbon,
            edge: UiGalleryCurveEdge.bottom,
            depth: o.curveDepth,
            position: shapePosition,
            span: .7,
            radius: 12,
            side: BorderSide(color: s.line),
          ),
          UiGalleryBottomNavPreset.adaptiveMinimal => Border(
            top: BorderSide(color: s.line),
          ),
          UiGalleryBottomNavPreset.splitIsland => _IslandBorder(
            leadingWidth: widths.take(split).fold<double>(0, (a, b) => a + b),
            trailingWidth: widths.skip(split).fold<double>(0, (a, b) => a + b),
            padding: horizontalPadding,
            side: BorderSide(color: s.line),
          ),
          UiGalleryBottomNavPreset.perspectiveDock => BeveledRectangleBorder(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
              bottom: Radius.circular(6),
            ),
            side: BorderSide(color: s.line),
          ),
          _ => RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              p == UiGalleryBottomNavPreset.morphingCapsule ? 40 : 22,
            ),
            side: BorderSide(color: s.line),
          ),
        };
    final insets = (s.visual.padding ?? EdgeInsets.zero)
        .add(galleryCurveInsets(shape))
        .resolve(direction);
    final height = rowHeight + insets.vertical;
    final grouped = p == UiGalleryBottomNavPreset.splitIsland;
    final depth = s.reduceMotion ? 0.0 : o.depthIntensity * s.motion.intensity;
    final row = FocusTraversalGroup(
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (gap > 0 && i == split) SizedBox(width: gap),
            SizedBox(
              width: widths[i],
              height: rowHeight,
              child: _item(
                context,
                s,
                i,
                (1 - (position - i).abs()).clamp(0.0, 1.0),
                widths[i],
                depth,
              ),
            ),
          ],
        ],
      ),
    );
    final panelWidth = widths[widget.selectedIndex].clamp(48.0, width);
    final movingPanel =
        p == UiGalleryBottomNavPreset.floatingCove ||
        p == UiGalleryBottomNavPreset.layeredShelf;
    Widget face = Material(
      color: grouped
          ? Colors.transparent
          : p == UiGalleryBottomNavPreset.glassDock
          ? s.visual.surfaceColor ?? s.surface.withValues(alpha: .74)
          : s.surface,
      elevation:
          s.visual.elevation ??
          (p == UiGalleryBottomNavPreset.adaptiveMinimal || grouped ? 0 : 6),
      shadowColor: s.visual.shadowColor ?? Colors.black.withValues(alpha: .13),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: grouped ? null : s.visual.gradient,
          ),
          child: Stack(
            children: [
              if (grouped) ...[
                PositionedDirectional(
                  start: direction == TextDirection.rtl
                      ? horizontalPadding.right
                      : horizontalPadding.left,
                  top: 0,
                  bottom: 0,
                  width: widths.take(split).fold<double>(0.0, (a, b) => a + b),
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: s.surface,
                        gradient: s.visual.gradient,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: s.line),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: direction == TextDirection.rtl
                      ? horizontalPadding.left
                      : horizontalPadding.right,
                  top: 0,
                  bottom: 0,
                  width: widths.skip(split).fold<double>(0.0, (a, b) => a + b),
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: s.surface,
                        gradient: s.visual.gradient,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: s.line),
                      ),
                    ),
                  ),
                ),
              ],
              if (movingPanel)
                Positioned(
                  left: physical - panelWidth / 2 + o.spacing,
                  top:
                      insets.top +
                      (p == UiGalleryBottomNavPreset.layeredShelf ? 2 : 6),
                  width: math.max(0, panelWidth - o.spacing * 2),
                  height:
                      rowHeight -
                      (p == UiGalleryBottomNavPreset.layeredShelf ? 4 : 12),
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: p == UiGalleryBottomNavPreset.layeredShelf
                            ? s.tinted
                            : s.accent.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(
                          p == UiGalleryBottomNavPreset.layeredShelf ? 10 : 28,
                        ),
                        border: p == UiGalleryBottomNavPreset.layeredShelf
                            ? Border.all(color: s.accent.withValues(alpha: .4))
                            : null,
                      ),
                    ),
                  ),
                ),
              if (p == UiGalleryBottomNavPreset.liquidDrop)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DropIndicator(
                        center: physical,
                        color: (o.selectedColor ?? s.accent).withValues(
                          alpha: .16,
                        ),
                        pulse: math.sin(_selection.value * math.pi) * depth,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: insets.top,
                left: horizontalPadding.left,
                right: horizontalPadding.right,
                height: rowHeight,
                child: row,
              ),
              if (p == UiGalleryBottomNavPreset.ribbonCurve)
                Positioned(
                  left: physical - 18,
                  bottom: 3,
                  width: 36,
                  height: 3,
                  child: IgnorePointer(child: ColoredBox(color: s.accent)),
                ),
              if (p == UiGalleryBottomNavPreset.adaptiveMinimal)
                Positioned(
                  left: physical - 12,
                  bottom: 0,
                  width: 24,
                  height: 2,
                  child: IgnorePointer(child: ColoredBox(color: s.accent)),
                ),
              if (p == UiGalleryBottomNavPreset.glassDock ||
                  p == UiGalleryBottomNavPreset.scrollDock)
                Positioned(
                  left:
                      physical -
                      (p == UiGalleryBottomNavPreset.glassDock ? 3 : 14),
                  bottom: 4,
                  width: p == UiGalleryBottomNavPreset.glassDock ? 6 : 28,
                  height: 3,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: o.selectedColor ?? s.accent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (p == UiGalleryBottomNavPreset.glassDock) {
      face = ClipPath(
        clipper: ShapeBorderClipper(shape: shape, textDirection: direction),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: face,
        ),
      );
    }
    if (p == UiGalleryBottomNavPreset.orbitDock ||
        p == UiGalleryBottomNavPreset.layeredShelf ||
        p == UiGalleryBottomNavPreset.perspectiveDock) {
      final perspective = p == UiGalleryBottomNavPreset.perspectiveDock;
      face = SizedBox(
        height: height + 8,
        child: Stack(
          children: [
            Positioned.fill(
              top: 8,
              left: perspective ? 18 : 10,
              right: perspective ? 18 : 10,
              child: IgnorePointer(
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, .001)
                    ..rotateX(perspective ? -.12 * depth : 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: s.accent.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(bottom: 8, child: face),
          ],
        ),
      );
    }
    if (widget.centerAction != null && gap > 0) {
      final actionInset = math.min(4.0, (gap - 48) / 2);
      face = SizedBox(
        height: height + 8,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(top: 8, child: face),
            PositionedDirectional(
              start:
                  (direction == TextDirection.rtl
                      ? horizontalPadding.right
                      : horizontalPadding.left) +
                  notchCenter -
                  gap / 2 +
                  actionInset,
              top: 0,
              width: gap - actionInset * 2,
              height: math.max(48, o.notchDepth + 32),
              child: Semantics(
                sortKey: OrdinalSortKey(split - .5),
                child: widget.centerAction!,
              ),
            ),
          ],
        ),
      );
    }
    return face;
  }

  Widget _item(
    BuildContext context,
    UiGalleryStyle s,
    int index,
    double active,
    double width,
    double depth,
  ) {
    final item = widget.items[index];
    final o = widget.options;
    final p = widget.preset;
    final selected = index == widget.selectedIndex;
    final color = item.enabled
        ? Color.lerp(
            o.unselectedColor ?? s.muted,
            o.selectedColor ?? s.accent,
            active,
          )!
        : s.muted.withValues(alpha: .45);
    final showLabel =
        o.labels == UiGalleryNavLabels.always ||
        (o.labels == UiGalleryNavLabels.selected && selected) ||
        (o.labels == UiGalleryNavLabels.adaptive && (width >= 72 || selected));
    Widget icon = ExcludeSemantics(
      child: IconTheme.merge(
        data: IconThemeData(color: color, size: 24),
        child: selected ? item.selectedIcon ?? item.icon : item.icon,
      ),
    );
    if (p == UiGalleryBottomNavPreset.orbitDock ||
        p == UiGalleryBottomNavPreset.convexWave) {
      icon = Transform.translate(
        offset: Offset(0, -3 * active * depth),
        child: icon,
      );
    } else if (p == UiGalleryBottomNavPreset.perspectiveDock) {
      icon = Transform(
        alignment: Alignment.center,
        transformHitTests: false,
        transform: Matrix4.identity()
          ..setEntry(3, 2, .001)
          ..rotateY(.15 * active * depth)
          ..rotateX(-.1 * active * depth),
        child: icon,
      );
    }
    if (p == UiGalleryBottomNavPreset.orbitDock) {
      icon = SizedBox.square(
        dimension: 40,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: s.accent.withValues(alpha: .12 * active),
            border: Border.all(color: Color.lerp(s.line, s.accent, active)!),
            boxShadow: active > 0
                ? [
                    BoxShadow(
                      color: s.accent.withValues(alpha: .1 * active),
                      blurRadius: 6 * depth,
                      offset: Offset(0, 3 * depth),
                    ),
                  ]
                : null,
          ),
          child: Center(child: icon),
        ),
      );
    }
    if (p == UiGalleryBottomNavPreset.flipTiles) {
      icon = TweenAnimationBuilder<double>(
        tween: Tween(begin: selected ? 1.0 : 0.0, end: selected ? 1.0 : 0.0),
        duration: s.duration(s.motion.change),
        curve: s.curve,
        builder: (context, value, child) => Transform(
          alignment: Alignment.center,
          transformHitTests: false,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .001)
            ..rotateY(math.sin(value * math.pi) * math.pi / 2 * depth),
          child: child,
        ),
        child: SizedBox.square(
          dimension: 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? s.tinted : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selected ? color : s.line),
            ),
            child: Center(child: icon),
          ),
        ),
      );
    }
    if (item.badge != null) icon = Badge(label: item.badge, child: icon);
    final label = ExcludeSemantics(
      child: Text(
        item.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: (s.theme.textTheme.labelSmall ?? const TextStyle(fontSize: 12))
            .copyWith(color: color)
            .merge(s.visual.messageStyle)
            .merge(selected ? o.selectedLabelStyle : o.unselectedLabelStyle),
      ),
    );
    final horizontal =
        p == UiGalleryBottomNavPreset.morphingCapsule ||
        p == UiGalleryBottomNavPreset.ribbonCurve ||
        (p == UiGalleryBottomNavPreset.adaptiveMinimal && width >= 120);
    Widget content = horizontal
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (showLabel &&
                  (p != UiGalleryBottomNavPreset.morphingCapsule ||
                      selected)) ...[
                const SizedBox(width: 6),
                Flexible(child: label),
              ],
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (showLabel) ...[
                const SizedBox(height: 4),
                Flexible(child: label),
              ],
            ],
          );
    content =
        widget.itemBuilder?.call(context, item, index, selected) ?? content;
    final callback = item.enabled
        ? () => widget.onDestinationSelected(index)
        : null;
    return MergeSemantics(
      child: Semantics(
        container: true,
        button: true,
        selected: selected,
        enabled: item.enabled,
        label: item.semanticLabel ?? item.label,
        sortKey: OrdinalSortKey(index.toDouble()),
        onTap: callback,
        child: Tooltip(
          message: item.label,
          excludeFromSemantics: true,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: callback,
              excludeFromSemantics: true,
              canRequestFocus: item.enabled,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: o.spacing),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: p == UiGalleryBottomNavPreset.morphingCapsule
                        ? s.accent.withValues(alpha: .14 * active)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: AbsorbPointer(
                    absorbing: !item.enabled,
                    child: Center(child: content),
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

class _DropIndicator extends CustomPainter {
  const _DropIndicator({
    required this.center,
    required this.color,
    required this.pulse,
  });
  final double center, pulse;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final x = center;
    final top = 7.0 + 5 * pulse;
    final neck = 14.0 - 4 * pulse;
    final bottom = size.height;
    final path = Path()
      ..moveTo(x - 28, bottom)
      ..cubicTo(x - 12, bottom, x - neck, bottom * .62, x - neck, bottom * .55)
      ..cubicTo(x - 24, top + 8, x - 10, top, x, top)
      ..cubicTo(x + 10, top, x + 24, top + 8, x + neck, bottom * .55)
      ..cubicTo(x + neck, bottom * .62, x + 12, bottom, x + 28, bottom)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_DropIndicator oldDelegate) =>
      center != oldDelegate.center ||
      color != oldDelegate.color ||
      pulse != oldDelegate.pulse;
}

class _IslandBorder extends ShapeBorder {
  const _IslandBorder({
    required this.leadingWidth,
    required this.trailingWidth,
    required this.padding,
    required this.side,
  });
  final double leadingWidth, trailingWidth;
  final EdgeInsets padding;
  final BorderSide side;
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  ShapeBorder scale(double t) => _IslandBorder(
    leadingWidth: leadingWidth * t,
    trailingWidth: trailingWidth * t,
    padding: padding * t,
    side: side.scale(t),
  );
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final rtl = textDirection == TextDirection.rtl;
    final leftWidth = rtl ? trailingWidth : leadingWidth;
    final rightWidth = rtl ? leadingWidth : trailingWidth;
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left + padding.left,
            rect.top,
            leftWidth,
            rect.height,
          ),
          const Radius.circular(22),
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.right - padding.right - rightWidth,
            rect.top,
            rightWidth,
            rect.height,
          ),
          const Radius.circular(22),
        ),
      );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(side.width), textDirection: textDirection);
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}
