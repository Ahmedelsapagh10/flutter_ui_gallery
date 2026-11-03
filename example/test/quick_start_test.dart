import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// BEGIN README APP
class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(colorSchemeSeed: Colors.teal);
    return MaterialApp(
      theme: base.copyWith(
        extensions: [
          UiGalleryTheme.family(
            UiGalleryDesignFamily.soft,
            theme: base,
            useSignature: true,
          ),
        ],
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  int _page = 0;
  bool _archived = false;

  Future<void> _manageNote() async {
    final review = await UiGallerySheet.show<bool>(
      context: context,
      preset: UiGallerySheetPreset.orbit,
      header: const Text('Field notes'),
      child: const Text('Archive this note to keep your notebook focused.'),
      footer: Builder(
        builder: (sheetContext) => FilledButton(
          onPressed: () => Navigator.of(sheetContext).pop(true),
          child: const Text('Review archive'),
        ),
      ),
    );
    if (!mounted || review != true) return;
    final archive = await UiGalleryDialog.show<bool>(
      context: context,
      preset: UiGalleryDialogPreset.split,
      title: 'Archive Field notes?',
      message: 'The note stays available in Archive.',
      actions: const [
        UiGalleryDialogAction(label: 'Keep note', value: false),
        UiGalleryDialogAction(
          label: 'Archive note',
          description: 'Move it out of your current notebook.',
          value: true,
          primary: true,
        ),
      ],
    );
    if (!mounted || archive != true) return;
    setState(() => _archived = true);
    UiGalleryToast.show(
      context,
      preset: UiGalleryToastPreset.action,
      position: UiGalleryToastPosition.top,
      message: 'Field notes archived',
      actionLabel: 'Undo',
      onAction: () {
        if (mounted) setState(() => _archived = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _page == (_archived ? 1 : 0);
    return Scaffold(
      appBar: UiGalleryAppBar(
        preset: UiGalleryAppBarPreset.focusBar,
        title: Text(_page == 0 ? 'Notebook' : 'Archive'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(visible ? 'Field notes' : 'No notes here yet.'),
          if (visible && !_archived)
            FilledButton(
              onPressed: _manageNote,
              child: const Text('Manage note'),
            ),
        ],
      ),
      bottomNavigationBar: UiGalleryBottomNav(
        preset: UiGalleryBottomNavPreset.morphingCapsule,
        selectedIndex: _page,
        onDestinationSelected: (index) => setState(() => _page = index),
        items: const [
          UiGalleryBottomNavItem(icon: Icon(Icons.notes), label: 'Notebook'),
          UiGalleryBottomNavItem(
            icon: Icon(Icons.archive_outlined),
            label: 'Archive',
          ),
        ],
      ),
    );
  }
}
// END README APP

void main() {
  test('README Quick Start matches this compiled fixture', () {
    final readme = File('../README.md').readAsStringSync();
    final source = readme
        .split('<!-- quick-start-app -->')
        .last
        .split('<!-- /quick-start-app -->')
        .first
        .split('```dart\n')
        .last
        .split('```')
        .first;
    final body = source.split('class NotesApp').last;
    final fixture = File('test/quick_start_test.dart')
        .readAsStringSync()
        .split('\n// BEGIN README APP\n')
        .last
        .split('\n// END README APP\n')
        .first;
    expect(
      body.replaceAll(RegExp(r'\s+'), ''),
      fixture.split('class NotesApp').last.replaceAll(RegExp(r'\s+'), ''),
    );
  });

  testWidgets('Quick Start owns navigation, typed archive and Undo', (
    tester,
  ) async {
    await tester.pumpWidget(const NotesApp());
    await tester.pumpAndSettle();
    expect(find.text('Field notes'), findsOneWidget);
    await tester.tap(find.text('Manage note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review archive'));
    await tester.pumpAndSettle();
    expect(find.text('Archive Field notes?'), findsOneWidget);
    await tester.tap(find.text('Archive note'));
    await tester.pumpAndSettle();
    expect(find.text('Field notes archived'), findsOneWidget);
    expect(find.text('No notes here yet.'), findsOneWidget);
    await tester.tap(find.byTooltip('Archive'));
    await tester.pumpAndSettle();
    expect(find.text('Field notes'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('No notes here yet.'), findsOneWidget);
    await tester.tap(find.byTooltip('Notebook'));
    await tester.pumpAndSettle();
    expect(find.text('Manage note'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
