import 'package:flutter/material.dart';

import '../core/gallery_theme.dart';

/// Adaptive Horizon. Scroll awareness uses Scaffold's existing notification
/// observer, so basic usage requires no ScrollController.
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
  }) : assert(expandedHeight >= kToolbarHeight);

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;
  final bool scrollAware;
  final double expandedHeight;
  final UiGalleryTheme? appearance;

  @override
  Size get preferredSize =>
      Size.fromHeight(scrollAware ? expandedHeight : kToolbarHeight);

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
    final s = UiGalleryStyle.of(context, widget.appearance);
    final progress = widget.scrollAware ? _progress : 1.0;
    return _HorizonSurface(
      title: widget.title,
      subtitle: widget.subtitle,
      leading: widget.leading,
      actions: widget.actions,
      implyLeading: widget.automaticallyImplyLeading,
      progress: progress,
      style: s,
    );
  }
}

/// A sliver variant sharing Horizon's visual language and native pinned behavior.
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
  }) : assert(expandedHeight >= kToolbarHeight);

  final Widget title;
  final Widget? subtitle;
  final List<Widget> actions;
  final Widget? leading;
  final double expandedHeight;
  final bool pinned;
  final bool automaticallyImplyLeading;
  final UiGalleryTheme? appearance;

  @override
  Widget build(BuildContext context) {
    final s = UiGalleryStyle.of(context, appearance);
    return SliverAppBar(
      pinned: pinned,
      expandedHeight: expandedHeight,
      backgroundColor: s.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = MediaQuery.paddingOf(context).top;
          final range = expandedHeight - kToolbarHeight;
          final progress = range == 0
              ? 1.0
              : (1 - (constraints.maxHeight - top - kToolbarHeight) / range)
                    .clamp(0.0, 1.0);
          return _HorizonSurface(
            title: title,
            subtitle: subtitle,
            leading: leading,
            actions: actions,
            implyLeading: automaticallyImplyLeading,
            progress: progress,
            style: s,
          );
        },
      ),
    );
  }
}

// Backwards-compatible aliases
typedef NovaAppBar = UiGalleryAppBar;
typedef NovaSliverAppBar = UiGallerySliverAppBar;

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
    final duration = style.duration(UiGalleryTokens.change);
    return Material(
      color: style.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: style.line)),
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final expanded = constraints.maxHeight >= 88 && progress < .5;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        curve: UiGalleryTokens.curve,
                        alignment: expanded
                            ? AlignmentDirectional.bottomStart
                            : AlignmentDirectional.centerStart,
                        child: AnimatedPadding(
                          duration: duration,
                          curve: UiGalleryTokens.curve,
                          padding: EdgeInsetsDirectional.only(
                            start: 12,
                            bottom: expanded ? 16 : 0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: AnimatedDefaultTextStyle(
                                    duration: duration,
                                    curve: UiGalleryTokens.curve,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        (expanded
                                                ? style
                                                      .theme
                                                      .textTheme
                                                      .headlineSmall
                                                : style
                                                      .theme
                                                      .textTheme
                                                      .titleLarge)!
                                            .copyWith(
                                              color: style.content,
                                              fontWeight: FontWeight.w600,
                                            ),
                                    child: title,
                                  ),
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
                      Flexible(
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          decoration: BoxDecoration(
                            border: BorderDirectional(
                              start: BorderSide(color: style.line),
                            ),
                          ),
                          child: IconTheme(
                            data: IconThemeData(color: style.accent),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final action in actions)
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minWidth: 48,
                                        minHeight: 48,
                                      ),
                                      child: action,
                                    ),
                                ],
                              ),
                            ),
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
