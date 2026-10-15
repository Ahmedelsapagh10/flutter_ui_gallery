import 'package:flutter/material.dart';
import '../core/gallery_theme.dart';
import '../core/gallery_style.dart';
import '../core/gallery_shape.dart';

enum UiGalleryAppBarPreset {
  adaptiveHorizon,
  floatingArc,
  compactRail,
  splitHeader,
  focusBar,
  panoramaBar,
  layeredNav,
  editorialTopbar,
  sculptedWave,
  foldedCanopy,
  parallaxCrest,
  orbitCommand,
  searchSwitch,
  centeredTitle,
  breadcrumbTrail,
  sectionTabs,
  selectionBar,
}

double _height(UiGalleryAppBarPreset preset) => switch (preset) {
  UiGalleryAppBarPreset.adaptiveHorizon ||
  UiGalleryAppBarPreset.compactRail => 56,
  UiGalleryAppBarPreset.floatingArc => 80,
  UiGalleryAppBarPreset.splitHeader => 96,
  UiGalleryAppBarPreset.focusBar || UiGalleryAppBarPreset.layeredNav => 112,
  UiGalleryAppBarPreset.panoramaBar => 144,
  UiGalleryAppBarPreset.editorialTopbar => 128,
  UiGalleryAppBarPreset.sculptedWave => 120,
  UiGalleryAppBarPreset.foldedCanopy => 144,
  UiGalleryAppBarPreset.parallaxCrest => 168,
  UiGalleryAppBarPreset.orbitCommand => 96,
  UiGalleryAppBarPreset.searchSwitch ||
  UiGalleryAppBarPreset.centeredTitle => 64,
  UiGalleryAppBarPreset.breadcrumbTrail => 96,
  UiGalleryAppBarPreset.sectionTabs => 88,
  UiGalleryAppBarPreset.selectionBar => 64,
};

/// All headers work with Scaffold, without a required ScrollController.
class UiGalleryAppBar extends StatefulWidget implements PreferredSizeWidget {
  const UiGalleryAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.automaticallyImplyLeading = true,
    this.scrollAware = false,
    this.expandedHeight = 104,
    this.appearance,
    this.preset = UiGalleryAppBarPreset.adaptiveHorizon,
    this.style,
    this.motion,
    this.bottom,
    this.searchField,
    this.onSearchChanged,
    this.semanticLabel,
    this.selectionCount = 0,
    this.onSelectionCleared,
  }) : assert(expandedHeight >= kToolbarHeight),
       assert(selectionCount >= 0);
  final int selectionCount;
  final VoidCallback? onSelectionCleared;
  final Widget title;
  final Widget? subtitle, leading, searchField;
  final List<Widget> actions;
  final bool automaticallyImplyLeading, scrollAware;
  final double expandedHeight;
  final UiGalleryTheme? appearance;
  final UiGalleryAppBarPreset preset;
  final UiGallerySurfaceStyle? style;
  final UiGalleryMotion? motion;
  final PreferredSizeWidget? bottom;
  final ValueChanged<String>? onSearchChanged;
  final String? semanticLabel;
  @override
  Size get preferredSize => Size.fromHeight(
    (scrollAware
            ? expandedHeight.clamp(_height(preset), double.infinity)
            : _height(preset)) +
        (bottom?.preferredSize.height ?? 0) +
        galleryCurveInsets(style?.shape).vertical,
  );
  @override
  State<UiGalleryAppBar> createState() => _UiGalleryAppBarState();
}

class _UiGalleryAppBarState extends State<UiGalleryAppBar> {
  ScrollNotificationObserverState? _observer;
  double _progress = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = ScrollNotificationObserver.maybeOf(context);
    if (!identical(observer, _observer)) {
      _observer?.removeListener(_scroll);
      _observer = observer;
      _observer?.addListener(_scroll);
    }
  }

  void _scroll(ScrollNotification notification) {
    if (!widget.scrollAware ||
        notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical) {
      return;
    }
    final progress = (notification.metrics.pixels / 100).clamp(0.0, 1.0);
    if ((progress - _progress).abs() >= .02) {
      setState(() => _progress = progress);
    }
  }

  @override
  void dispose() {
    _observer?.removeListener(_scroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = UiGalleryStyle.of(
      context,
      widget.appearance,
      widget.style,
      widget.motion,
      UiGallerySurface.appBar,
    );
    return Semantics(
      label: widget.semanticLabel,
      child: Column(
        children: [
          Expanded(
            child: _HeaderWidth(
              maxWidth: s.visual.maxWidth,
              child: _HeaderSurface(
                title: widget.title,
                selectionCount: widget.selectionCount,
                onSelectionCleared: widget.onSelectionCleared,
                subtitle: widget.subtitle,
                leading: widget.leading,
                actions: widget.actions,
                implyLeading: widget.automaticallyImplyLeading,
                progress: widget.scrollAware ? _progress : 0,
                style: s,
                preset: widget.preset,
                searchField: widget.searchField,
                onSearchChanged: widget.onSearchChanged,
              ),
            ),
          ),
          if (widget.bottom != null) widget.bottom!,
        ],
      ),
    );
  }
}

class UiGallerySliverAppBar extends StatelessWidget {
  const UiGallerySliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.leading,
    this.expandedHeight = 168,
    this.pinned = true,
    this.automaticallyImplyLeading = true,
    this.appearance,
    this.preset = UiGalleryAppBarPreset.adaptiveHorizon,
    this.style,
    this.motion,
    this.bottom,
    this.searchField,
    this.onSearchChanged,
    this.semanticLabel,
    this.selectionCount = 0,
    this.onSelectionCleared,
  }) : assert(expandedHeight >= kToolbarHeight),
       assert(selectionCount >= 0);
  final int selectionCount;
  final VoidCallback? onSelectionCleared;
  final Widget title;
  final Widget? subtitle, leading, searchField;
  final List<Widget> actions;
  final double expandedHeight;
  final bool pinned, automaticallyImplyLeading;
  final UiGalleryTheme? appearance;
  final UiGalleryAppBarPreset preset;
  final UiGallerySurfaceStyle? style;
  final UiGalleryMotion? motion;
  final PreferredSizeWidget? bottom;
  final ValueChanged<String>? onSearchChanged;
  final String? semanticLabel;
  @override
  Widget build(BuildContext context) {
    final s = UiGalleryStyle.of(
      context,
      appearance,
      style,
      motion,
      UiGallerySurface.appBar,
    );
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    final collapsedHeight =
        kToolbarHeight + galleryCurveInsets(s.visual.shape).vertical;
    final effectiveExpandedHeight = expandedHeight.clamp(
      collapsedHeight + bottomHeight,
      double.infinity,
    );
    return SliverAppBar(
      pinned: pinned,
      collapsedHeight: collapsedHeight,
      expandedHeight: effectiveExpandedHeight,
      bottom: bottom,
      backgroundColor: s.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = MediaQuery.paddingOf(context).top;
          final range =
              effectiveExpandedHeight - bottomHeight - collapsedHeight;
          final progress = range == 0
              ? 1.0
              : (1 -
                        (constraints.maxHeight -
                                top -
                                bottomHeight -
                                collapsedHeight) /
                            range)
                    .clamp(0.0, 1.0);
          return Semantics(
            label: semanticLabel,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: bottom?.preferredSize.height ?? 0,
              ),
              child: _HeaderWidth(
                maxWidth: s.visual.maxWidth,
                child: _HeaderSurface(
                  title: title,
                  selectionCount: selectionCount,
                  onSelectionCleared: onSelectionCleared,
                  subtitle: subtitle,
                  leading: leading,
                  actions: actions,
                  implyLeading: automaticallyImplyLeading,
                  progress: progress,
                  style: s,
                  preset: preset,
                  searchField: searchField,
                  onSearchChanged: onSearchChanged,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

typedef NovaAppBar = UiGalleryAppBar;
typedef NovaSliverAppBar = UiGallerySliverAppBar;

class _HeaderWidth extends StatelessWidget {
  const _HeaderWidth({required this.child, this.maxWidth});
  final Widget child;
  final double? maxWidth;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Align(
      child: SizedBox(
        width:
            maxWidth?.clamp(0.0, constraints.maxWidth) ?? constraints.maxWidth,
        height: constraints.maxHeight,
        child: child,
      ),
    ),
  );
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({required this.actions, required this.maxWidth});

  final List<Widget> actions;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth.clamp(0.0, 220.0)),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: action,
            ),
        ],
      ),
    ),
  );
}

class _HeaderSurface extends StatelessWidget {
  const _HeaderSurface({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.actions,
    required this.implyLeading,
    required this.progress,
    required this.style,
    required this.preset,
    this.searchField,
    this.onSearchChanged,
    this.selectionCount = 0,
    this.onSelectionCleared,
  });
  final int selectionCount;
  final VoidCallback? onSelectionCleared;
  final Widget title;
  final Widget? subtitle, leading, searchField;
  final List<Widget> actions;
  final bool implyLeading;
  final double progress;
  final UiGalleryStyle style;
  final UiGalleryAppBarPreset preset;
  final ValueChanged<String>? onSearchChanged;
  @override
  Widget build(BuildContext context) {
    if (preset == UiGalleryAppBarPreset.adaptiveHorizon) {
      return _HorizonSurface(
        title: title,
        subtitle: subtitle,
        leading: leading,
        actions: actions,
        implyLeading: implyLeading,
        progress: progress,
        style: style,
      );
    }
    final selecting =
        preset == UiGalleryAppBarPreset.selectionBar && selectionCount > 0;
    final displayTitle = selecting
        ? Text(
            MaterialLocalizations.of(
              context,
            ).selectedRowCountTitle(selectionCount),
          )
        : title;
    final surfaceColor = selecting && style.visual.surfaceColor == null
        ? style.tinted
        : style.surface;
    final scaffold = Scaffold.maybeOf(context);
    Widget? navigation = selecting && onSelectionCleared != null
        ? IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: onSelectionCleared,
            icon: const Icon(Icons.close_rounded),
          )
        : leading;
    if (navigation == null && implyLeading) {
      if (scaffold?.hasDrawer ?? false) {
        navigation = IconButton(
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          onPressed: scaffold!.openDrawer,
          icon: const Icon(Icons.menu_rounded),
        );
      } else if (ModalRoute.of(context)?.impliesAppBarDismissal ?? false) {
        navigation = const BackButton();
      }
    }
    if (const {
      UiGalleryAppBarPreset.sculptedWave,
      UiGalleryAppBarPreset.foldedCanopy,
      UiGalleryAppBarPreset.parallaxCrest,
      UiGalleryAppBarPreset.orbitCommand,
    }.contains(preset)) {
      return _SpatialHeader(
        title: title,
        subtitle: subtitle,
        navigation: navigation,
        actions: actions,
        progress: progress,
        style: style,
        preset: preset,
      );
    }
    Widget headline({bool large = false, bool editorial = false}) =>
        DefaultTextStyle(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              style.visual.titleStyle ??
              (editorial
                      ? style.theme.textTheme.headlineMedium
                      : large
                      ? style.theme.textTheme.headlineSmall
                      : style.theme.textTheme.titleLarge)!
                  .copyWith(
                    color: style.content,
                    fontWeight: editorial ? FontWeight.w400 : FontWeight.w600,
                    height: 1.1,
                  ),
          child: displayTitle,
        );
    Widget toolbar(Widget buttons, {bool rail = false}) => Row(
      children: [
        if (navigation != null)
          SizedBox.square(dimension: 48, child: navigation),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: headline(),
          ),
        ),
        if (actions.isNotEmpty) buttons,
        if (rail)
          Container(
            width: 3,
            height: 24,
            margin: const EdgeInsetsDirectional.only(start: 12),
            color: style.accent,
          ),
      ],
    );
    return Material(
      color:
          preset == UiGalleryAppBarPreset.floatingArc ||
              style.visual.shape != null
          ? Colors.transparent
          : surfaceColor,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final curveInsets = galleryCurveInsets(style.visual.shape);
            final compact =
                constraints.maxHeight - curveInsets.vertical < 84 ||
                progress >= .7;
            final floating = preset == UiGalleryAppBarPreset.floatingArc;
            final padding =
                style.visual.padding ??
                const EdgeInsets.symmetric(horizontal: 16);
            final buttons = _HeaderActions(
              actions: actions,
              maxWidth:
                  (constraints.maxWidth -
                      padding.horizontal -
                      (floating ? 20 : 0) -
                      (preset == UiGalleryAppBarPreset.searchSwitch ? 48 : 0)) /
                  2,
            );
            Widget composition;
            if (preset == UiGalleryAppBarPreset.searchSwitch) {
              composition = _SearchToolbar(
                title: headline(),
                navigation: navigation,
                actions: actions.isEmpty ? null : buttons,
                searchField: searchField,
                onSearchChanged: onSearchChanged,
                style: style,
              );
            } else if (preset == UiGalleryAppBarPreset.centeredTitle) {
              composition = NavigationToolbar(
                centerMiddle: true,
                middleSpacing: 12,
                leading: navigation == null
                    ? null
                    : SizedBox.square(dimension: 48, child: navigation),
                middle: headline(),
                trailing: actions.isEmpty ? null : buttons,
              );
            } else if (compact) {
              composition = toolbar(
                buttons,
                rail: preset == UiGalleryAppBarPreset.compactRail,
              );
            } else {
              switch (preset) {
                case UiGalleryAppBarPreset.floatingArc:
                  composition = toolbar(buttons);
                case UiGalleryAppBarPreset.compactRail:
                  composition = toolbar(buttons, rail: true);
                case UiGalleryAppBarPreset.splitHeader:
                  composition = Row(
                    children: [
                      if (navigation != null)
                        SizedBox.square(dimension: 48, child: navigation),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headline(large: true),
                            if (subtitle != null)
                              Flexible(
                                child: DefaultTextStyle.merge(
                                  style: TextStyle(color: style.muted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  child: subtitle!,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (actions.isNotEmpty)
                        Container(
                          padding: const EdgeInsetsDirectional.only(start: 16),
                          decoration: BoxDecoration(
                            border: BorderDirectional(
                              start: BorderSide(color: style.line, width: 2),
                            ),
                          ),
                          child: buttons,
                        ),
                    ],
                  );
                case UiGalleryAppBarPreset.focusBar:
                  composition = Column(
                    children: [
                      SizedBox(height: 48, child: toolbar(buttons)),
                      Expanded(
                        child: Center(
                          child:
                              searchField ??
                              TextField(
                                onChanged: onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: MaterialLocalizations.of(
                                    context,
                                  ).searchFieldLabel,
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  filled: true,
                                  fillColor: style.tinted,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],
                  );
                case UiGalleryAppBarPreset.panoramaBar:
                  composition = Stack(
                    children: [
                      PositionedDirectional(
                        end: 0,
                        top: 0,
                        bottom: 0,
                        width: constraints.maxWidth * .3,
                        child: ColoredBox(color: style.tinted),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 48,
                            child: Row(
                              children: [
                                if (navigation != null)
                                  SizedBox.square(
                                    dimension: 48,
                                    child: navigation,
                                  ),
                                const Spacer(),
                                if (actions.isNotEmpty) buttons,
                              ],
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.bottomStart,
                              child: headline(large: true),
                            ),
                          ),
                          if (subtitle != null)
                            Flexible(
                              child: DefaultTextStyle.merge(
                                style: TextStyle(color: style.muted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                child: subtitle!,
                              ),
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ],
                  );
                case UiGalleryAppBarPreset.layeredNav:
                  composition = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            if (navigation != null)
                              SizedBox.square(dimension: 48, child: navigation),
                            Expanded(
                              child: DefaultTextStyle.merge(
                                style: TextStyle(color: style.muted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                child: subtitle ?? title,
                              ),
                            ),
                            if (actions.isNotEmpty) buttons,
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(start: 20),
                          decoration: BoxDecoration(
                            color: style.tinted,
                            border: BorderDirectional(
                              start: BorderSide(color: style.accent, width: 3),
                            ),
                          ),
                          alignment: AlignmentDirectional.centerStart,
                          child: headline(large: true),
                        ),
                      ),
                    ],
                  );
                case UiGalleryAppBarPreset.editorialTopbar:
                  composition = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            if (navigation != null)
                              SizedBox.square(dimension: 48, child: navigation),
                            if (subtitle != null)
                              Expanded(
                                child: DefaultTextStyle.merge(
                                  style: style.theme.textTheme.labelSmall
                                      ?.copyWith(
                                        letterSpacing: 1.6,
                                        color: style.muted,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  child: subtitle!,
                                ),
                              )
                            else
                              const Spacer(),
                            if (actions.isNotEmpty) buttons,
                          ],
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: headline(editorial: true),
                        ),
                      ),
                      Divider(height: 1, color: style.content),
                    ],
                  );
                case UiGalleryAppBarPreset.breadcrumbTrail:
                  composition = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (subtitle != null)
                        SizedBox(
                          height: 36,
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DefaultTextStyle.merge(
                                maxLines: 1,
                                style: style.theme.textTheme.labelMedium!
                                    .copyWith(color: style.muted),
                                child: subtitle!,
                              ),
                            ),
                          ),
                        ),
                      Expanded(child: toolbar(buttons)),
                    ],
                  );
                case UiGalleryAppBarPreset.sectionTabs:
                  composition = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: toolbar(buttons)),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 12,
                            bottom: 12,
                          ),
                          child: DefaultTextStyle.merge(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style.theme.textTheme.labelMedium!.copyWith(
                              color: style.muted,
                            ),
                            child: subtitle!,
                          ),
                        ),
                    ],
                  );
                case UiGalleryAppBarPreset.adaptiveHorizon:
                  composition = toolbar(buttons);
                case UiGalleryAppBarPreset.sculptedWave:
                case UiGalleryAppBarPreset.foldedCanopy:
                case UiGalleryAppBarPreset.parallaxCrest:
                case UiGalleryAppBarPreset.orbitCommand:
                case UiGalleryAppBarPreset.searchSwitch:
                case UiGalleryAppBarPreset.centeredTitle:
                case UiGalleryAppBarPreset.selectionBar:
                  composition = toolbar(buttons);
              }
            }
            return Padding(
              padding: floating
                  ? EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical:
                          (constraints.maxHeight -
                                  padding.vertical -
                                  curveInsets.vertical -
                                  48)
                              .clamp(0.0, 20.0) /
                          2,
                    )
                  : EdgeInsets.zero,
              child: AnimatedContainer(
                clipBehavior: style.visual.shape == null
                    ? Clip.none
                    : Clip.antiAlias,
                duration: style.duration(style.motion.change),
                curve: style.curve,
                padding: padding,
                decoration: ShapeDecoration(
                  color: surfaceColor,
                  gradient: style.visual.gradient,
                  shadows: floating
                      ? [
                          BoxShadow(
                            color:
                                style.visual.shadowColor ??
                                Colors.black.withValues(alpha: .1),
                            blurRadius: style.visual.elevation ?? 12,
                          ),
                        ]
                      : null,
                  shape:
                      style.visual.shape ??
                      (floating
                          ? const StadiumBorder()
                          : const RoundedRectangleBorder()),
                ),
                child: IconTheme(
                  data: IconThemeData(color: style.accent),
                  child: composition,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchToolbar extends StatefulWidget {
  const _SearchToolbar({
    required this.title,
    required this.navigation,
    required this.actions,
    required this.searchField,
    required this.onSearchChanged,
    required this.style,
  });

  final Widget title;
  final Widget? navigation, actions, searchField;
  final ValueChanged<String>? onSearchChanged;
  final UiGalleryStyle style;

  @override
  State<_SearchToolbar> createState() => _SearchToolbarState();
}

class _SearchToolbarState extends State<_SearchToolbar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _searching = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    if (_searching) FocusScope.of(context).unfocus();
    setState(() => _searching = !_searching);
    if (_searching && widget.searchField == null) _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (widget.navigation != null)
        SizedBox.square(dimension: 48, child: widget.navigation),
      Expanded(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
          child: AnimatedSwitcher(
            duration: widget.style.duration(widget.style.motion.change),
            switchInCurve: widget.style.curve,
            layoutBuilder: (current, previous) => Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [...previous, ?current],
            ),
            child: _searching
                ? KeyedSubtree(
                    key: const ValueKey('search'),
                    child:
                        widget.searchField ??
                        TextField(
                          controller: _controller,
                          focusNode: _focus,
                          onChanged: widget.onSearchChanged,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: MaterialLocalizations.of(
                              context,
                            ).searchFieldLabel,
                            filled: true,
                            fillColor: widget.style.tinted,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                  )
                : KeyedSubtree(
                    key: const ValueKey('title'),
                    child: widget.title,
                  ),
          ),
        ),
      ),
      SizedBox.square(
        dimension: 48,
        child: IconButton(
          tooltip: _searching
              ? MaterialLocalizations.of(context).closeButtonTooltip
              : MaterialLocalizations.of(context).searchFieldLabel,
          onPressed: _toggleSearch,
          icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
        ),
      ),
      if (widget.actions != null) widget.actions!,
    ],
  );
}

class _SpatialHeader extends StatelessWidget {
  const _SpatialHeader({
    required this.title,
    required this.subtitle,
    required this.navigation,
    required this.actions,
    required this.progress,
    required this.style,
    required this.preset,
  });
  final Widget title;
  final Widget? subtitle, navigation;
  final List<Widget> actions;
  final double progress;
  final UiGalleryStyle style;
  final UiGalleryAppBarPreset preset;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: progress, end: progress),
    duration: style.duration(style.motion.change),
    curve: style.curve,
    builder: (context, value, _) => SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight -
                  galleryCurveInsets(style.visual.shape).vertical <
              84;
          final t = value.clamp(0.0, 1.0);
          final depthIntensity = style.reduceMotion
              ? 0.0
              : style.motion.intensity * style.gallery.motionIntensity;
          final orbit = preset == UiGalleryAppBarPreset.orbitCommand;
          final canopy = preset == UiGalleryAppBarPreset.foldedCanopy;
          final crest = preset == UiGalleryAppBarPreset.parallaxCrest;
          final direction = Directionality.of(context) == TextDirection.rtl
              ? -1.0
              : 1.0;
          final shape =
              style.visual.shape ??
              UiGalleryCurvedBorder(
                edge: UiGalleryCurveEdge.bottom,
                curve: orbit
                    ? UiGalleryCurve.ribbon
                    : canopy
                    ? UiGalleryCurve.convex
                    : UiGalleryCurve.wave,
                depth: compact ? 0 : (canopy ? 12 : 18) * (1 - t * .7),
                position: orbit
                    ? .78
                    : canopy
                    ? .65
                    : .35 + t * .3,
                span: orbit
                    ? .65
                    : canopy
                    ? .85
                    : 1,
                radius: orbit
                    ? 28
                    : canopy
                    ? 12
                    : 0,
                side: BorderSide(color: style.line),
              );
          final padding =
              (style.visual.padding ??
                      const EdgeInsets.symmetric(horizontal: 16))
                  .add(galleryCurveInsets(shape));
          final surfaceInset = compact
              ? 0.0
              : orbit
              ? 20.0
              : crest
              ? constraints.maxWidth * .12
              : 0.0;
          final buttons = _HeaderActions(
            actions: actions,
            maxWidth:
                (constraints.maxWidth - padding.horizontal - surfaceInset) / 2,
          );
          Widget heading({bool expanded = false}) => _HorizonTitle(
            title: title,
            style: style,
            expanded: expanded,
            duration: style.duration(style.motion.change),
          );
          Widget controls({bool includeTitle = true}) => SizedBox(
            height: 48,
            child: Row(
              children: [
                if (navigation != null)
                  SizedBox(width: 48, height: 48, child: navigation),
                if (includeTitle)
                  Expanded(child: heading())
                else
                  const Spacer(),
                if (actions.isNotEmpty) buttons,
              ],
            ),
          );
          Widget content;
          if (compact) {
            content = controls();
          } else if (orbit) {
            content = Row(
              children: [
                if (navigation != null)
                  SizedBox(width: 48, height: 48, child: navigation),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: heading()),
                      if (subtitle != null)
                        Flexible(
                          child: DefaultTextStyle.merge(
                            style:
                                style.visual.messageStyle ??
                                TextStyle(color: style.muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: subtitle!,
                          ),
                        ),
                    ],
                  ),
                ),
                if (actions.isNotEmpty)
                  Container(
                    margin: const EdgeInsetsDirectional.only(start: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: style.tinted,
                      border: Border.all(color: style.line),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: buttons,
                  ),
              ],
            );
          } else {
            content = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                controls(includeTitle: false),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: heading(expanded: true),
                  ),
                ),
                if (subtitle != null)
                  Flexible(
                    child: DefaultTextStyle.merge(
                      style:
                          style.visual.messageStyle ??
                          style.theme.textTheme.labelMedium?.copyWith(
                            color: style.muted,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: subtitle!,
                    ),
                  ),
              ],
            );
          }
          final surface = Material(
            color: style.surface,
            elevation: style.visual.elevation ?? (orbit ? 6 : 0),
            shadowColor: style.visual.shadowColor,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: style.visual.gradient),
              child: Padding(
                padding: padding,
                child: IconTheme(
                  data: IconThemeData(color: style.accent),
                  child: content,
                ),
              ),
            ),
          );
          if (compact) return surface;
          if (canopy) {
            return Stack(
              children: [
                Positioned.fill(
                  left: 16,
                  right: 16,
                  top: constraints.maxHeight * .5,
                  bottom: 2,
                  child: _SpatialPlane(
                    color: style.tinted,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                      side: BorderSide(color: style.line),
                    ),
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, .001)
                      ..rotateX(-.32 * (1 - t) * depthIntensity),
                    alignment: Alignment.topCenter,
                  ),
                ),
                Positioned.fill(bottom: 12, child: surface),
              ],
            );
          }
          if (crest) {
            return Stack(
              children: [
                PositionedDirectional(
                  end: 4 + t * 12 * depthIntensity,
                  top: 4,
                  bottom: 4,
                  width: constraints.maxWidth * .4,
                  child: _SpatialPlane(
                    color: style.accent.withValues(alpha: .16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    transform: Matrix4.translationValues(
                      0,
                      8 * (1 - t) * depthIntensity,
                      0,
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 12,
                  end: constraints.maxWidth * .07,
                  top: 10,
                  bottom: 0,
                  child: _SpatialPlane(
                    color: style.tinted,
                    shape: const UiGalleryCurvedBorder(
                      edge: UiGalleryCurveEdge.bottom,
                      curve: UiGalleryCurve.convex,
                      depth: 16,
                      radius: 8,
                    ),
                    transform: Matrix4.translationValues(
                      direction * 5 * t * depthIntensity,
                      0,
                      0,
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 0,
                  end: constraints.maxWidth * .12,
                  top: 0,
                  bottom: 10,
                  child: surface,
                ),
              ],
            );
          }
          if (orbit) {
            return Stack(
              children: [
                PositionedDirectional(
                  start: 18,
                  end: 12,
                  top: 12,
                  bottom: 4,
                  child: _SpatialPlane(
                    color: style.accent.withValues(alpha: .2),
                    shape: const UiGalleryCurvedBorder(
                      edge: UiGalleryCurveEdge.bottom,
                      curve: UiGalleryCurve.ribbon,
                      position: .78,
                      span: .65,
                      depth: 12,
                      radius: 28,
                    ),
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, .001)
                      ..rotateY(direction * (.08 - .04 * t) * depthIntensity)
                      ..rotateZ(direction * .012 * (1 - t) * depthIntensity),
                  ),
                ),
                Positioned.fill(
                  left: 10,
                  right: 10,
                  top: 8,
                  bottom: 8,
                  child: surface,
                ),
              ],
            );
          }
          return surface;
        },
      ),
    ),
  );
}

/// Only decorative planes transform; controls retain their visible hit bounds.
class _SpatialPlane extends StatelessWidget {
  const _SpatialPlane({
    required this.color,
    required this.shape,
    required this.transform,
    this.alignment = Alignment.center,
  });
  final Color color;
  final ShapeBorder shape;
  final Matrix4 transform;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: Transform(
        alignment: alignment,
        transform: transform,
        child: DecoratedBox(
          decoration: ShapeDecoration(color: color, shape: shape),
        ),
      ),
    ),
  );
}

class _HorizonSurface extends StatelessWidget {
  const _HorizonSurface({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.actions,
    required this.implyLeading,
    required this.progress,
    required this.style,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool implyLeading;
  final double progress;
  final UiGalleryStyle style;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    Widget? navigation = leading;
    if (navigation == null && implyLeading) {
      if (scaffold?.hasDrawer ?? false) {
        navigation = IconButton(
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          onPressed: scaffold!.openDrawer,
          icon: const Icon(Icons.menu_rounded),
        );
      } else if (ModalRoute.of(context)?.impliesAppBarDismissal ?? false) {
        navigation = const BackButton();
      }
    }
    final duration = style.duration(style.motion.change);
    return Material(
      color: style.surface,
      elevation: style.visual.elevation ?? 0,
      shape: style.visual.shape,
      clipBehavior: style.visual.shape == null ? Clip.none : Clip.antiAlias,
      shadowColor: style.visual.shadowColor,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: style.line)),
          gradient: style.visual.gradient,
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final expanded = constraints.maxHeight >= 88 && progress < .5;
              final padding =
                  (style.visual.padding ??
                          const EdgeInsets.symmetric(horizontal: 12))
                      .add(galleryCurveInsets(style.visual.shape));
              return Padding(
                padding: padding,
                child: Row(
                  children: [
                    if (navigation != null)
                      IconTheme(
                        data: IconThemeData(color: style.content),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          child: navigation,
                        ),
                      ),
                    Expanded(
                      child: AnimatedAlign(
                        duration: duration,
                        curve: style.curve,
                        alignment: expanded
                            ? AlignmentDirectional.bottomStart
                            : AlignmentDirectional.centerStart,
                        child: AnimatedPadding(
                          duration: duration,
                          curve: style.curve,
                          padding: EdgeInsetsDirectional.only(
                            start: 12,
                            bottom: expanded ? 16 : 0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: _HorizonTitle(
                                  title: title,
                                  style: style,
                                  expanded: expanded,
                                  duration: duration,
                                ),
                              ),
                              if (subtitle != null && expanded)
                                DefaultTextStyle.merge(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: style.theme.textTheme.labelMedium
                                      ?.copyWith(color: style.muted),
                                  child: subtitle!,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (actions.isNotEmpty)
                      Container(
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        decoration: BoxDecoration(
                          border: BorderDirectional(
                            start: BorderSide(color: style.line),
                          ),
                        ),
                        child: IconTheme(
                          data: IconThemeData(color: style.accent),
                          child: _HeaderActions(
                            actions: actions,
                            maxWidth:
                                (constraints.maxWidth - padding.horizontal) / 2,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HorizonTitle extends StatelessWidget {
  const _HorizonTitle({
    required this.title,
    required this.style,
    required this.expanded,
    required this.duration,
  });
  final Widget title;
  final UiGalleryStyle style;
  final bool expanded;
  final Duration duration;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) => FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: bounds.maxWidth),
        child: AnimatedDefaultTextStyle(
          duration: duration,
          curve: style.curve,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              style.visual.titleStyle ??
              (expanded
                      ? style.theme.textTheme.headlineSmall
                      : style.theme.textTheme.titleLarge)!
                  .copyWith(color: style.content, fontWeight: FontWeight.w600),
          child: title,
        ),
      ),
    ),
  );
}
