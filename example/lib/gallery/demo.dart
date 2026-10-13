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
  });
  final int index;
  final String title;
  final String message;
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

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _launch() async {
    if (_opening) return;
    final index = widget.index;
    final title = widget.title;
    final message = widget.message;
    if (index >= 8 && index <= 10) {
      if (index == 10) setState(() => _removed = true);
      UiGalleryToast.show(
        context,
        message: message,
        preset: UiGalleryToastPreset.values[index - 8],
        kind: index == 9
            ? UiGalleryToastKind.warning
            : UiGalleryToastKind.success,
        position: index == 9
            ? UiGalleryToastPosition.top
            : UiGalleryToastPosition.bottom,
        showProgress: index == 10,
        actionLabel: index == 10 ? 'Undo' : null,
        onAction: index == 10
            ? () {
                if (mounted) setState(() => _removed = false);
              }
            : null,
      );
      return;
    }
    if (index == 11) return;
    setState(() => _opening = true);
    Object? result;
    try {
      if (index < 4) {
        result = await UiGallerySheet.show<String>(
          context: context,
          preset: UiGallerySheetPreset.values[index],
          header: Text(title, style: Theme.of(context).textTheme.titleLarge),
          footer: index == 2
              ? Builder(
                  builder: (context) => FilledButton(
                    onPressed: () => Navigator.of(context).pop('Reserved'),
                    child: const Text('Reserve a place'),
                  ),
                )
              : null,
          child: switch (index) {
            0 => _OrbitActions(message: message),
            1 => _FoldDetails(message: message),
            2 => _PrismBooking(message: message),
            _ => _FlowSelection(message: message),
          },
        );
      } else if (index == 6) {
        _progress.value = UiGalleryTimelineState(
          steps: ['Review details', 'Verify identity', 'Ready to continue'],
          currentStep: 0,
        );
        result = await UiGalleryDialog.show<String>(
          context: context,
          title: title,
          message: message,
          preset: UiGalleryDialogPreset.timeline,
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
      } else if (index == 7) {
        result = await UiGalleryDialog.show<String>(
          context: context,
          title: title,
          message: message,
          preset: UiGalleryDialogPreset.spotlight,
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
      } else {
        result = await UiGalleryDialog.confirm(
          context: context,
          title: title,
          message: message,
          preset: UiGalleryDialogPreset.values[index - 4],
          destructive: index == 5,
          useRootNavigator: false,
          confirmLabel: index == 5 ? 'Discard draft' : 'Confirm',
        );
      }
      if (mounted) {
        setState(() => _lastResult = result?.toString() ?? 'Dismissed');
      }
    } finally {
      if (mounted) {
        setState(() => _opening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: UiGalleryAppBar(
        title: Text(widget.index == 11 ? widget.title : 'Your workspace'),
        subtitle: const Text('A quieter kind of interface'),
        scrollAware: true,
        actions: [
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          Text(
            'MAKE ROOM\nFOR WHAT MATTERS.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 2,
              height: 1.6,
              color: s.primary,
            ),
          ),
          const SizedBox(height: 28),
          Icon(designs[widget.index].icon, size: 52, color: s.primary),
          const SizedBox(height: 24),
          Text(
            designs[widget.index].name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
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
          const SizedBox(height: 28),
          if (widget.index == 7)
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
          if (widget.index != 11)
            FilledButton.icon(
              onPressed: _opening ? null : _launch,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Open live preview'),
            )
          else
            const Text('Scroll down to watch the title settle into place.'),
          if (_lastResult != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Returned: $_lastResult',
                style: TextStyle(color: s.primary),
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
          if (widget.index == 11) ...[
            for (var i = 0; i < 12; i++)
              _WorkspaceItem(
                title: 'Field note ${i + 1}',
                label: 'THOUGHTS · SAVED',
                icon: Icons.notes_rounded,
              ),
          ],
        ],
      ),
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
