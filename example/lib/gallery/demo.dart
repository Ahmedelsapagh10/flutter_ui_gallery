import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

import 'catalog.dart';

/// Every launch runs the real package inside a local navigator, including its
/// overlay. Device frames therefore constrain sheets, dialogs and toasts too.
class SurfaceDemo extends StatefulWidget {
  const SurfaceDemo({
    super.key,
    required this.index,
    required this.title,
    required this.message,
    this.curveDepth,
    this.depthIntensity = 1,
  });
  final int index;
  final String title;
  final String message;
  final double? curveDepth;
  final double depthIntensity;
  @override
  State<SurfaceDemo> createState() => _SurfaceDemoState();
}

class _SurfaceDemoState extends State<SurfaceDemo> {
  final _progress = ValueNotifier(
    UiGalleryTimelineState(
      steps: ['Review details', 'Verify identity', 'Ready to continue'],
      currentStep: 0,
    ),
  );
  UiGalleryResult _result = UiGalleryResult.success;
  String? _lastResult;
  bool _removed = false;
  bool _opening = false;
  UiGalleryToastHandle? _toast;
  final _taskProgress = ValueNotifier(0.0);
  final _selectedNotes = <int>{};
  final _archivedNotes = <int>{};

  @override
  void dispose() {
    _progress.dispose();
    _taskProgress.dispose();
    super.dispose();
  }

  Future<void> _launch() async {
    if (_opening) return;
    final d = designs[widget.index];
    final title = widget.title;
    final message = widget.message;
    if (d.toast != null) {
      if (_toast != null) return;
      if (d.toast == UiGalleryToastPreset.progressCard) {
        _taskProgress.value = 0;
        final handle = UiGalleryToast.progress(
          context,
          message: message,
          title: title,
          progress: _taskProgress,
          actionLabel: 'Cancel',
          onAction: () {
            if (mounted) setState(() => _lastResult = 'Cancelled');
          },
        );
        setState(() => _toast = handle);
        handle.closed.then((_) {
          if (mounted) setState(() => _toast = null);
        });
        return;
      }
      final actionable = {
        UiGalleryToastPreset.action,
        UiGalleryToastPreset.ribbonActionBar,
        UiGalleryToastPreset.dock,
      }.contains(d.toast);
      if (actionable) setState(() => _removed = true);
      final toast = UiGalleryToast.show(
        context,
        message: message,
        preset: d.toast!,
        title: d.toast == UiGalleryToastPreset.miniConsole
            ? 'WORKSPACE / STATUS'
            : 'Workspace updated',
        kind: d.toast == UiGalleryToastPreset.ribbon
            ? UiGalleryToastKind.warning
            : UiGalleryToastKind.success,
        position:
            d.toast == UiGalleryToastPreset.ribbon ||
                d.toast == UiGalleryToastPreset.inlinePulse
            ? UiGalleryToastPosition.top
            : UiGalleryToastPosition.bottom,
        showProgress: actionable,
        actionLabel: actionable ? 'Undo' : null,
        onAction: actionable
            ? () {
                if (mounted) setState(() => _removed = false);
              }
            : null,
      );
      setState(() => _toast = toast);
      toast.closed.then((_) {
        if (mounted) setState(() => _toast = null);
      });
      return;
    }
    if (d.appBar != null) return;
    setState(() => _opening = true);
    Object? result;
    try {
      if (d.dialog == UiGalleryDialogPreset.commandPalette) {
        result = await UiGalleryDialog.commands<String>(
          context: context,
          title: title,
          useRootNavigator: false,
          emptyLabel: 'No matching commands',
          commands: const [
            UiGalleryDialogAction(
              label: 'New note',
              description: 'Start a draft',
              value: 'New note',
              icon: Icon(Icons.add_rounded),
            ),
            UiGalleryDialogAction(
              label: 'Saved ideas',
              description: 'Open your collection',
              value: 'Saved ideas',
              icon: Icon(Icons.bookmark_outline),
            ),
            UiGalleryDialogAction(
              label: 'Archive collection',
              value: 'Archive',
              enabled: false,
            ),
          ],
        );
      } else if (d.sheet != null) {
        final p = d.sheet!;
        result = await UiGallerySheet.show<String>(
          context: context,
          preset: p,
          header: Text(title, style: Theme.of(context).textTheme.titleLarge),
          secondary: p == UiGallerySheetPreset.horizonPeek
              ? const _PreviewLandscape()
              : p == UiGallerySheetPreset.splitLayer
              ? const _OrderSummary()
              : null,
          footer: p == UiGallerySheetPreset.prism || p.index >= 4
              ? Builder(
                  builder: (context) => FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      p == UiGallerySheetPreset.prism ? 'Reserved' : 'Applied',
                    ),
                    child: Text(
                      p == UiGallerySheetPreset.prism
                          ? 'Reserve a place'
                          : 'Apply selection',
                    ),
                  ),
                )
              : null,
          child: switch (p) {
            UiGallerySheetPreset.orbit => _OrbitActions(message: message),
            UiGallerySheetPreset.fold => _FoldDetails(message: message),
            UiGallerySheetPreset.prism => _PrismBooking(message: message),
            UiGallerySheetPreset.flow => _FlowSelection(message: message),
            _ => _UtilityExample(preset: p, message: message),
          },
        );
      } else if (d.dialog == UiGalleryDialogPreset.timeline ||
          d.dialog == UiGalleryDialogPreset.milestone) {
        _progress.value = UiGalleryTimelineState(
          steps: ['Review details', 'Verify identity', 'Ready to continue'],
          currentStep: 0,
        );
        result = await UiGalleryDialog.show<String>(
          context: context,
          title: title,
          message: message,
          preset: d.dialog!,
          useRootNavigator: false,
          child: ValueListenableBuilder<UiGalleryTimelineState>(
            valueListenable: _progress,
            builder: (context, value, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UiGalleryTimeline(state: value),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: value.completed
                      ? null
                      : () {
                          _progress.value = UiGalleryTimelineState(
                            steps: value.steps,
                            currentStep: value.currentStep < 2
                                ? value.currentStep + 1
                                : 2,
                            completed: value.currentStep == 2,
                          );
                        },
                  child: Text(
                    value.completed ? 'Verified' : 'Complete current step',
                  ),
                ),
              ],
            ),
          ),
          actions: const [
            UiGalleryDialogAction(label: 'Close', value: 'Closed'),
          ],
        );
      } else if (d.dialog == UiGalleryDialogPreset.spotlight ||
          d.dialog == UiGalleryDialogPreset.statusBeacon) {
        result = await UiGalleryDialog.show<String>(
          context: context,
          title: title,
          message: message,
          preset: d.dialog!,
          result: _result,
          useRootNavigator: false,
          actions: const [
            UiGalleryDialogAction(
              label: 'Continue',
              value: 'Continued',
              primary: true,
            ),
          ],
        );
      } else if (d.dialog == UiGalleryDialogPreset.sideBySideChoice) {
        result = await UiGalleryDialog.show<String>(
          context: context,
          title: title,
          message: message,
          preset: d.dialog!,
          useRootNavigator: false,
          actions: const [
            UiGalleryDialogAction(
              label: 'Personal',
              description: 'A private space for your own projects.',
              icon: Icon(Icons.person_outline),
              value: 'Personal',
            ),
            UiGalleryDialogAction(
              label: 'Team',
              description: 'Share collections with collaborators.',
              icon: Icon(Icons.groups_outlined),
              value: 'Team',
              primary: true,
            ),
          ],
        );
      } else {
        result = await UiGalleryDialog.confirm(
          context: context,
          title: title,
          message: message,
          preset: d.dialog!,
          destructive: d.dialog == UiGalleryDialogPreset.split,
          useRootNavigator: false,
          confirmLabel: d.dialog == UiGalleryDialogPreset.split
              ? 'Discard draft'
              : 'Confirm',
        );
      }
      if (mounted) {
        setState(() => _lastResult = result?.toString() ?? 'Dismissed');
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final design = designs[widget.index];
    final motion =
        Theme.of(context).extension<UiGalleryTheme>()?.motion ??
        const UiGalleryMotion();
    if (design.bottomNav != null) {
      return _NavigationDemo(
        preset: design.bottomNav!,
        title: widget.title,
        message: widget.message,
        curveDepth: widget.curveDepth,
        depthIntensity: widget.depthIntensity,
      );
    }
    final scaffold = Scaffold(
      appBar: UiGalleryAppBar(
        preset:
            designs[widget.index].appBar ??
            UiGalleryAppBarPreset.adaptiveHorizon,
        title: Text(
          designs[widget.index].appBar != null
              ? widget.title
              : 'Your workspace',
        ),
        onSearchChanged: (value) => setState(
          () => _lastResult = value.isEmpty ? null : 'Search: $value',
        ),
        subtitle: design.appBar == UiGalleryAppBarPreset.breadcrumbTrail
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('Workspace')),
                          body: Center(
                            child: FilledButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Open collection'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: const Text('Workspace'),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 16),
                  Text(widget.message),
                ],
              )
            : Text(design.appBar != null ? widget.message : 'Your collection'),
        bottom: design.appBar == UiGalleryAppBarPreset.sectionTabs
            ? const TabBar(
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Saved'),
                  Tab(text: 'Shared'),
                ],
              )
            : null,
        scrollAware: true,
        selectionCount: design.appBar == UiGalleryAppBarPreset.selectionBar
            ? _selectedNotes.length
            : 0,
        onSelectionCleared: design.appBar == UiGalleryAppBarPreset.selectionBar
            ? () => setState(_selectedNotes.clear)
            : null,
        motion: UiGalleryMotion(
          entrance: motion.entrance,
          exit: motion.exit,
          change: motion.change,
          curve: motion.curve,
          intensity: widget.depthIntensity,
        ),
        style:
            design.appBar == UiGalleryAppBarPreset.sculptedWave &&
                widget.curveDepth != null
            ? UiGallerySurfaceStyle(
                shape: UiGalleryCurvedBorder(
                  edge: UiGalleryCurveEdge.bottom,
                  depth: widget.curveDepth!,
                ),
              )
            : null,
        actions: [
          if (design.appBar == UiGalleryAppBarPreset.selectionBar &&
              _selectedNotes.isNotEmpty)
            IconButton(
              tooltip: 'Archive selected',
              onPressed: () => setState(() {
                final count = _selectedNotes.length;
                _archivedNotes.addAll(_selectedNotes);
                _selectedNotes.clear();
                _lastResult = 'Archived $count notes';
              }),
              icon: const Icon(Icons.archive_outlined),
            )
          else
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => UiGalleryToast.success(
                context,
                message: 'You’re all caught up.',
              ),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
        ],
      ),
      body: design.appBar == UiGalleryAppBarPreset.sectionTabs
          ? const _SectionPages()
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (design.appBar == null) ...[
                  Icon(designs[widget.index].icon, size: 32, color: s.primary),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: s.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (designs[widget.index].dialog ==
                        UiGalleryDialogPreset.spotlight ||
                    designs[widget.index].dialog ==
                        UiGalleryDialogPreset.statusBeacon)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final result in UiGalleryResult.values)
                        ChoiceChip(
                          label: Text(result.name),
                          selected: _result == result,
                          onSelected: (_) => setState(() => _result = result),
                        ),
                    ],
                  ),
                if (designs[widget.index].appBar == null)
                  FilledButton.icon(
                    key: const ValueKey('launch-preview'),
                    onPressed: _opening || _toast != null ? null : _launch,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      design.sheet != null
                          ? 'Show sheet'
                          : design.dialog != null
                          ? 'Show dialog'
                          : 'Show toast',
                    ),
                  ),
                if (_lastResult != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Returned: $_lastResult',
                      style: TextStyle(color: s.primary),
                    ),
                  ),
                if (design.toast == UiGalleryToastPreset.progressCard)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: FilledButton.tonal(
                      onPressed: _toast == null
                          ? null
                          : () => setState(() {
                              if (_taskProgress.value >= 1) {
                                _toast!.dismiss();
                                _lastResult = 'Completed';
                              } else {
                                _taskProgress.value =
                                    (_taskProgress.value + .25).clamp(0.0, 1.0);
                              }
                            }),
                      child: Text(
                        _taskProgress.value >= 1
                            ? 'Dismiss completed'
                            : 'Complete next item',
                      ),
                    ),
                  ),
                const SizedBox(height: 36),
                if (!_removed)
                  _WorkspaceItem(
                    title: 'Weekend in the mountains',
                    label: 'PERSONAL · DRAFT',
                    icon: Icons.landscape_outlined,
                  ),
                const _WorkspaceItem(
                  title: 'A place for new ideas',
                  label: 'WORKSPACE · PRIVATE',
                  icon: Icons.lightbulb_outline_rounded,
                ),
                const _WorkspaceItem(
                  title: 'Everything in its own time',
                  label: 'COLLECTION · 8 ITEMS',
                  icon: Icons.schedule_rounded,
                ),
                if (designs[widget.index].appBar != null) ...[
                  if (design.appBar == UiGalleryAppBarPreset.selectionBar) ...[
                    for (var i = 0; i < 8; i++)
                      if (!_archivedNotes.contains(i))
                        CheckboxListTile(
                          title: Text('Selectable note ${i + 1}'),
                          value: _selectedNotes.contains(i),
                          onChanged: (value) => setState(() {
                            if (value == true) {
                              _selectedNotes.add(i);
                            } else {
                              _selectedNotes.remove(i);
                            }
                          }),
                        ),
                  ] else ...[
                    for (var i = 0; i < 12; i++)
                      _WorkspaceItem(
                        title: 'Field note ${i + 1}',
                        label: 'THOUGHTS · SAVED',
                        icon: Icons.notes_rounded,
                      ),
                  ],
                ],
              ],
            ),
    );
    return design.appBar == UiGalleryAppBarPreset.sectionTabs
        ? DefaultTabController(length: 3, child: scaffold)
        : scaffold;
  }
}

class _SectionPages extends StatelessWidget {
  const _SectionPages();

  @override
  Widget build(BuildContext context) => TabBarView(
    children: [
      for (final section in ['Overview', 'Saved', 'Shared'])
        ListView(
          key: PageStorageKey('header-section-$section'),
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '$section collection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            for (var i = 0; i < 12; i++)
              _WorkspaceItem(
                title: '$section note ${i + 1}',
                label: section == 'Shared'
                    ? 'TEAM · SHARED'
                    : 'PERSONAL · SAVED',
                icon: section == 'Shared'
                    ? Icons.people_outline
                    : Icons.notes_rounded,
              ),
          ],
        ),
    ],
  );
}

class _NavigationDemo extends StatefulWidget {
  const _NavigationDemo({
    required this.preset,
    required this.title,
    required this.message,
    required this.curveDepth,
    required this.depthIntensity,
  });

  final UiGalleryBottomNavPreset preset;
  final String title, message;
  final double? curveDepth;
  final double depthIntensity;

  @override
  State<_NavigationDemo> createState() => _NavigationDemoState();
}

class _NavigationDemoState extends State<_NavigationDemo> {
  int _selected = 0;
  int _callbacks = 0;
  int _created = 0;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final labels = <String>[
      ...(rtl
          ? ['اكتشف', 'المحفوظات', 'الوارد', 'النشاط']
          : ['Discover', 'Saved', 'Inbox', 'Activity']),
      if (widget.preset == UiGalleryBottomNavPreset.overflowDock)
        ...(rtl ? ['المجموعات', 'الملاحظات'] : ['Collections', 'Notes']),
    ];
    final hasCenter =
        widget.preset == UiGalleryBottomNavPreset.concaveNotch ||
        widget.preset == UiGalleryBottomNavPreset.splitIsland;
    return PopScope<void>(
      canPop: _selected == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selected != 0) setState(() => _selected = 0);
      },
      child: Scaffold(
        extendBody: widget.preset == UiGalleryBottomNavPreset.glassDock,
        appBar: UiGalleryAppBar(
          preset: UiGalleryAppBarPreset.compactRail,
          title: Text(widget.title),
          subtitle: const Text('Your place to explore'),
        ),
        body: IndexedStack(
          index: _selected,
          children: [
            for (var i = 0; i < labels.length; i++)
              _NavigationPage(
                key: ValueKey('navigation-page-$i'),
                index: i,
                label: labels[i],
                message: widget.message,
                callbacks: _callbacks,
                created: _created,
              ),
          ],
        ),
        bottomNavigationBar: UiGalleryBottomNav(
          preset: widget.preset,
          selectedIndex: _selected,
          onDestinationSelected: (value) => setState(() {
            _selected = value;
            _callbacks++;
          }),
          options: UiGalleryBottomNavOptions(
            curveDepth: widget.curveDepth ?? 14,
            notchDepth: widget.curveDepth ?? 24,
            depthIntensity: widget.depthIntensity,
            groupBreak: 2,
          ),
          centerAction: hasCenter
              ? IconButton.filled(
                  tooltip: 'Create a note',
                  onPressed: () => setState(() => _created++),
                  icon: const Icon(Icons.add_rounded),
                )
              : null,
          items: [
            UiGalleryBottomNavItem(
              icon: const Icon(
                Icons.explore_outlined,
                key: ValueKey('nav-tab-0'),
              ),
              selectedIcon: const Icon(
                Icons.explore,
                key: ValueKey('nav-tab-0'),
              ),
              label: labels[0],
            ),
            UiGalleryBottomNavItem(
              icon: const Icon(
                Icons.bookmark_border,
                key: ValueKey('nav-tab-1'),
              ),
              selectedIcon: const Icon(
                Icons.bookmark,
                key: ValueKey('nav-tab-1'),
              ),
              label: labels[1],
              badge: const Text('3'),
            ),
            UiGalleryBottomNavItem(
              icon: const Icon(
                Icons.inbox_outlined,
                key: ValueKey('nav-tab-2'),
              ),
              selectedIcon: const Icon(Icons.inbox, key: ValueKey('nav-tab-2')),
              label: labels[2],
              badge: const Text('2'),
            ),
            UiGalleryBottomNavItem(
              icon: const Icon(Icons.timeline, key: ValueKey('nav-tab-3')),
              label: labels[3],
              enabled: false,
              semanticLabel: rtl ? 'النشاط غير متاح' : 'Activity unavailable',
            ),
            if (widget.preset == UiGalleryBottomNavPreset.overflowDock)
              for (var i = 4; i < labels.length; i++)
                UiGalleryBottomNavItem(
                  icon: Icon(
                    i == 4
                        ? Icons.collections_bookmark_outlined
                        : Icons.notes_rounded,
                    key: ValueKey('nav-tab-$i'),
                  ),
                  label: labels[i],
                ),
          ],
        ),
      ),
    );
  }
}

class _NavigationPage extends StatefulWidget {
  const _NavigationPage({
    super.key,
    required this.index,
    required this.label,
    required this.message,
    required this.callbacks,
    required this.created,
  });
  final int index, callbacks, created;
  final String label, message;

  @override
  State<_NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<_NavigationPage> {
  int _saved = 3;
  String _draft = '';
  String? _savedNote;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      key: PageStorageKey('destination-${widget.index}'),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Text(
          widget.label,
          key: const ValueKey('navigation-page-heading'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(widget.message),
        const SizedBox(height: 20),
        Text(
          'Selection callbacks: ${widget.callbacks}',
          key: const ValueKey('navigation-callbacks'),
          style: TextStyle(color: colors.primary),
        ),
        if (widget.created > 0) ...[
          const SizedBox(height: 8),
          Text('Notes created: ${widget.created}'),
        ],
        const SizedBox(height: 24),
        if (widget.index == 0) ...[
          const TextField(
            key: ValueKey('navigation-draft'),
            decoration: InputDecoration(
              labelText: 'A thought to keep',
              hintText: 'Write something, then switch tabs',
            ),
          ),
          const SizedBox(height: 24),
          const _WorkspaceItem(
            title: 'The quiet places',
            label: 'DISCOVER · FIELD NOTES',
            icon: Icons.landscape_outlined,
          ),
          const _WorkspaceItem(
            title: 'A different perspective',
            label: 'DISCOVER · COLLECTION',
            icon: Icons.auto_awesome_outlined,
          ),
        ] else if (widget.index == 1) ...[
          Text(
            '$_saved saved ideas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => setState(() => _saved++),
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Save another idea'),
          ),
          const _WorkspaceItem(
            title: 'Weekend in the mountains',
            label: 'SAVED · PERSONAL',
            icon: Icons.landscape_outlined,
          ),
        ] else if (widget.index == 2) ...[
          const _WorkspaceItem(
            title: 'Your collection is ready',
            label: 'INBOX · JUST NOW',
            icon: Icons.collections_bookmark_outlined,
          ),
          const _WorkspaceItem(
            title: 'A note from your team',
            label: 'INBOX · TODAY',
            icon: Icons.chat_bubble_outline,
          ),
        ] else if (widget.index == 4) ...[
          const _WorkspaceItem(
            title: 'Places to return to',
            label: 'COLLECTION · 8 IDEAS',
            icon: Icons.landscape_outlined,
          ),
          const _WorkspaceItem(
            title: 'Everyday discoveries',
            label: 'COLLECTION · 12 IDEAS',
            icon: Icons.lightbulb_outline,
          ),
        ] else if (widget.index == 5) ...[
          TextField(
            key: const ValueKey('overflow-note-draft'),
            decoration: const InputDecoration(labelText: 'A note for later'),
            maxLines: 3,
            onChanged: (value) => setState(() => _draft = value),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: _draft.trim().isEmpty
                ? null
                : () => setState(() => _savedNote = _draft.trim()),
            child: const Text('Save note'),
          ),
          if (_savedNote != null) ...[
            const SizedBox(height: 16),
            Text('Saved note: $_savedNote'),
          ],
        ],
      ],
    );
  }
}

class _WorkspaceItem extends StatelessWidget {
  const _WorkspaceItem({
    required this.title,
    required this.label,
    required this.icon,
  });
  final String title;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 6),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    ),
  );
}

class _OrbitActions extends StatelessWidget {
  const _OrbitActions({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(message, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 24),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final action in [
            (Icons.link_rounded, 'Copy link'),
            (Icons.bookmark_border_rounded, 'Save'),
            (Icons.ios_share_rounded, 'Share'),
            (Icons.tune_rounded, 'Adjust'),
          ])
            SizedBox(
              width: 120,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(action.$2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(action.$1),
                    const SizedBox(height: 12),
                    Text(action.$2),
                  ],
                ),
              ),
            ),
        ],
      ),
    ],
  );
}

class _FoldDetails extends StatelessWidget {
  const _FoldDetails({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(message, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 24),
      const TextField(
        decoration: InputDecoration(
          labelText: 'Give this space a name',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 24),
      for (final section in [
        'A flexible space',
        'Built for the everyday',
        'Make it yours',
      ]) ...[
        Text(section, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Text(
          'Keep your notes, collections and small discoveries together. This surface unfolds when you need more room, while your input stays right where you left it.',
          style: TextStyle(height: 1.6),
        ),
        const SizedBox(height: 28),
      ],
      FilledButton(
        onPressed: () => Navigator.of(context).pop('Saved'),
        child: const Text('Save workspace'),
      ),
    ],
  );
}

class _PrismBooking extends StatelessWidget {
  const _PrismBooking({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadiusDirectional.only(
            topEnd: Radius.circular(36),
            bottomStart: Radius.circular(36),
          ),
        ),
        child: Icon(
          Icons.landscape_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'The quiet retreat',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 12),
      Text(message),
      const SizedBox(height: 20),
      const Wrap(
        spacing: 24,
        runSpacing: 12,
        children: [
          Text('2 nights'),
          Text('Mountain view'),
          Text('Breakfast included'),
        ],
      ),
    ],
  );
}

class _FlowSelection extends StatefulWidget {
  const _FlowSelection({required this.message});
  final String message;
  @override
  State<_FlowSelection> createState() => _FlowSelectionState();
}

class _FlowSelectionState extends State<_FlowSelection> {
  int _step = 0;
  String _delivery = 'Standard';
  final _name = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      UiGalleryFlow(
        steps: const ['Delivery', 'Your details', 'Review'],
        currentStep: _step,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.message),
              const SizedBox(height: 16),
              for (final option in ['Standard', 'Express'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: _delivery == option
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    title: Text(option),
                    subtitle: Text(
                      option == 'Standard'
                          ? '3–5 working days'
                          : 'Next working day',
                    ),
                    trailing: Icon(
                      _delivery == option
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                    ),
                    onTap: () => setState(() => _delivery = option),
                  ),
                ),
            ],
          ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Full name',
              border: OutlineInputBorder(),
            ),
          ),
          Text(
            '$_delivery delivery${_name.text.isEmpty ? '' : ' for ${_name.text}'}. Your selections are ready.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      const SizedBox(height: 28),
      Wrap(
        alignment: WrapAlignment.end,
        spacing: 12,
        children: [
          if (_step > 0)
            TextButton(
              onPressed: () => setState(() => _step--),
              child: const Text('Back'),
            ),
          FilledButton(
            onPressed: () {
              if (_step == 2) {
                Navigator.of(context).pop('$_delivery delivery confirmed');
              } else {
                setState(() => _step++);
              }
            },
            child: Text(_step == 2 ? 'Confirm' : 'Continue'),
          ),
        ],
      ),
    ],
  );
}

class _PreviewLandscape extends StatelessWidget {
  const _PreviewLandscape();
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 9,
    child: ColoredBox(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.landscape_outlined,
        size: 80,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    ),
  );
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary();
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Order summary', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 24),
      const Text('Field journal × 1'),
      const SizedBox(height: 12),
      const Text('Delivery included'),
      const Divider(height: 32),
      Text('Total · 24.00', style: Theme.of(context).textTheme.titleLarge),
    ],
  );
}

class _UtilityExample extends StatefulWidget {
  const _UtilityExample({required this.preset, required this.message});
  final UiGallerySheetPreset preset;
  final String message;
  @override
  State<_UtilityExample> createState() => _UtilityExampleState();
}

class _UtilityExampleState extends State<_UtilityExample> {
  double _value = .6;
  bool _enabled = true;
  String _collection = 'Inspiration';
  @override
  Widget build(BuildContext context) {
    final p = widget.preset;
    if (p == UiGallerySheetPreset.edgeLift) {
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          for (final action in ['Copy', 'Share', 'Save'])
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(action),
              child: Text(action),
            ),
        ],
      );
    }
    if (p == UiGallerySheetPreset.stackPanel) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final collection in [
            'Inspiration',
            'Weekend plans',
            'Reading list',
          ])
            ListTile(
              title: Text(collection),
              leading: const Icon(Icons.folder_outlined),
              trailing: Icon(
                _collection == collection
                    ? Icons.check_circle
                    : Icons.circle_outlined,
              ),
              onTap: () => setState(() => _collection = collection),
            ),
        ],
      );
    }
    if (p == UiGallerySheetPreset.splitLayer) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.message),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Gift packaging'),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          const Text('Your selection stays alongside the order summary.'),
        ],
      );
    }
    if (p == UiGallerySheetPreset.horizonPeek) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mountain trail · 4.2 km',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(widget.message),
          const SizedBox(height: 20),
          const Text('Easy route · approximately 90 minutes'),
        ],
      );
    }
    if (p == UiGallerySheetPreset.depthFrame) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('INVOICE / 024'),
          const SizedBox(height: 20),
          Text(
            'Workspace membership',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(widget.message),
          const Divider(height: 32),
          const Wrap(
            spacing: 32,
            runSpacing: 12,
            children: [Text('Monthly plan'), Text('24.00 / month')],
          ),
        ],
      );
    }
    if (p == UiGallerySheetPreset.pulseDock) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Start a focused session',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(widget.message),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Silence workspace notifications'),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          p == UiGallerySheetPreset.taskRail
              ? 'Exposure ${(100 * _value).round()}%'
              : 'Display brightness ${(100 * _value).round()}%',
        ),
        Slider(value: _value, onChanged: (v) => setState(() => _value = v)),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            p == UiGallerySheetPreset.taskRail
                ? 'Preserve highlights'
                : 'Adaptive display',
          ),
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
        ),
      ],
    );
  }
}
