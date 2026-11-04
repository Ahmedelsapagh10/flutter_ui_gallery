import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

import 'gallery/documentation_calls.dart';
import 'gallery/documentation_examples.dart';

void main() => runApp(
  const ShowcaseApp(
    preset: String.fromEnvironment('PRESET', defaultValue: 'sheets.orbit'),
  ),
);

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({
    super.key,
    required this.preset,
    this.dark = false,
    this.autoOpen = false,
    this.still = false,
  });
  final String preset;
  final bool dark, autoOpen, still;

  @override
  Widget build(BuildContext context) {
    final base = showSheetsOrbitTheme(
      brightness: dark ? Brightness.dark : Brightness.light,
    );
    final recipe = base.extension<UiGalleryTheme>()!;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        extensions: [
          if (still) recipe.copyWith(motionIntensity: 0) else recipe,
        ],
      ),
      home: ShowcasePage(preset: preset, autoOpen: autoOpen),
    );
  }
}

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key, required this.preset, this.autoOpen = false});
  final String preset;
  final bool autoOpen;

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  final _progress = ValueNotifier<double>(.68);
  final _timeline = ValueNotifier(
    const UiGalleryTimelineState(
      steps: ['Prepare', 'Review', 'Finish'],
      currentStep: 1,
    ),
  );
  final _selected = <int>{0, 1};
  UiGalleryToastHandle? _toast;
  int _index = 0;
  bool _opening = false;
  String _status = 'Your next chapter';

  @override
  void initState() {
    super.initState();
    if (widget.autoOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _open();
      });
    }
  }

  @override
  void dispose() {
    _toast?.dismiss();
    _progress.dispose();
    _timeline.dispose();
    super.dispose();
  }

  void _select(int index) => setState(() {
    if (widget.preset == 'header.selectionBar') {
      if (!_selected.remove(index)) _selected.add(index);
    } else {
      _index = index;
    }
  });

  void _action() {
    if (!mounted) return;
    final value = _timeline.value;
    final next = (value.currentStep + 1).clamp(0, value.steps.length - 1);
    _timeline.value = UiGalleryTimelineState(
      steps: value.steps,
      currentStep: next,
      completed: next == value.steps.length - 1,
    );
    if (widget.preset == 'toasts.progressCard') _toast?.dismiss();
    setState(() {
      _selected.clear();
      _status = widget.preset.startsWith('toasts.')
          ? 'Action received'
          : 'Workspace updated';
    });
  }

  Widget? _component() => showcaseCalls[widget.preset]!(
    context,
    _timeline,
    _progress,
    _index,
    _selected,
    _select,
    _action,
  );

  Future<void> _open() async {
    if (_opening || !mounted) return;
    final overlay = showcaseOverlays[widget.preset];
    if (overlay != null) {
      setState(() => _opening = true);
      final result = await overlay(context, _timeline, _progress, _action);
      if (!mounted) return;
      setState(() {
        _opening = false;
        _status = result == null ? 'Closed' : 'Selected: $result';
      });
    } else if (widget.preset == 'toasts.progressCard') {
      _toast?.dismiss();
      _toast = showToastsProgressCard(context, _progress, _action);
    } else if (widget.preset.startsWith('toasts.')) {
      _component();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!showcaseCalls.containsKey(widget.preset)) {
      return const Scaffold(body: Center(child: Text('Unknown preset')));
    }
    if (widget.preset.startsWith('header.')) return _component()!;
    if (widget.preset.startsWith('bottomNav.')) {
      final nav = _component()!;
      return nav is Scaffold
          ? nav
          : Scaffold(body: _body(context), bottomNavigationBar: nav);
    }
    return Scaffold(
      body: widget.autoOpen && widget.preset.startsWith('toasts.')
          ? const SizedBox.expand()
          : _body(context),
    );
  }

  Widget _body(BuildContext context) => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      Text(
        _status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
      const SizedBox(height: 20),
      Text(
        'Small ideas.\nRoom to grow.',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 24),
      if (!widget.autoOpen && !widget.preset.startsWith('bottomNav.')) ...[
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _opening ? null : _open,
          child: const Text('Show component'),
        ),
        if (widget.preset == 'toasts.progressCard')
          FilledButton.tonal(
            onPressed: () => _progress.value = 1,
            child: const Text('Complete upload'),
          ),
      ],
      const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.edit_note),
        title: Text('Field notes'),
        subtitle: Text('Personal collection · 12 notes'),
      ),
      const Divider(),
      const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.lightbulb_outline),
        title: Text('The next good idea'),
        subtitle: Text('Team workspace · 8 notes'),
      ),
    ],
  );
}
