# Runnable five-category example

Use this as `lib/main.dart` after installing the package. All data is local.

## Requirements and installation

Dart `^3.11.5` and Flutter `>=3.41.0` are required. The documentation captures and
examples are checked with Flutter 3.41.9. This checkout prepares the documentation
patch 0.2.1; it does not publish it.

```sh
flutter pub add flutter_ui_gallery
```

For an unpublished checkout, use a path dependency pointing at this package.
No extra Android or iOS setup is required for the gallery widgets.

## Run any pictured preset

From the repository:

```sh
cd example
flutter pub get
flutter run -t lib/showcase.dart --dart-define=PRESET=sheets.orbit
```

Use an exact ID from the [visual catalog](catalog/README.md). This app supplies
caller-owned navigation, selection, progress, typed dialog results, and resource
disposal. The full [gallery app](../example/lib/main.dart) remains available with
`flutter run`.

## A complete five-category app

<!-- quick-start-app -->
```dart
import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

void main() => runApp(const NotesApp());

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
```
<!-- /quick-start-app -->

See [integration](INTEGRATION.md) for connecting application state.
