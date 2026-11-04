<p align="center">
  <img src="assets/flutter_ui_gallery.png" alt="Flutter UI Gallery" width="120">
</p>

# Flutter UI Gallery

66 Flutter presets for bottom sheets, dialogs, toasts, app bars and bottom
navigation. Use typed results and caller-owned state with coordinated surfaces
that adapt to your application's colors and typography. No external runtime
dependencies. This independent package is not affiliated with Flutter's Gallery demo.

**Version 0.2.0.** The Quick Start below is verified against this release's source.
See the [changelog](CHANGELOG.md) for changes and migration considerations.

## Install

For version 0.2.0:

```sh
flutter pub add flutter_ui_gallery:^0.2.0
```

For an unpublished source checkout, use a local path until the maintainer
publishes that version (adjust the path to the package's pubspec directory):

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_ui_gallery:
    path: ../flutter_ui_gallery
```

Then run `flutter pub get`. The declared constraints are Dart `^3.11.5` and
Flutter `>=3.41.0`. Pinned visual validation uses Flutter **3.41.9**; testing that
renderer does not establish that every SDK in the declared range was tested.

## Five-minute setup

Replace your app's `lib/main.dart` with the following example. It demonstrates
all five categories together: navigate between Notebook and Archive, open a
contextual sheet, confirm a typed decision, and undo the change from a toast.
The application owns the note and selected destination. Data is local to this
session; no storage or server is implied.

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

The example enables a coordinated recipe with the existing
`UiGalleryTheme.family(..., useSignature: true)` configuration. It does not require
another theme architecture or a new package API. Supply your own `ThemeData` to
retain your `ColorScheme` and `TextTheme`; configure `theme` and `darkTheme`
separately when your app supports both. System reduced motion still takes priority.

## Choose a useful starting point

- **Context and forms:** Orbit keeps item context visible; SplitLayer groups
  context, content and actions for structured edits.
- **Decisions:** Split pairs consequences with actions; SideBySideChoice compares
  alternatives; Command Palette provides filtering and keyboard selection.
- **Feedback:** Action offers Undo or Retry; Signal is compact status feedback.
- **Headers:** SearchSwitch exposes search; FocusBar supports focused work;
  EditorialTopbar emphasizes a page heading.
- **Navigation:** MorphingCapsule emphasizes selection; AdaptiveMinimal responds
  to available space; LayeredShelf separates destination bays.

These are starting points, not a promise that every native accessibility or
performance scenario is verified. All 66 presets remain available. Use the
[local example app](example/) to inspect the current implementation:

```sh
cd example
flutter pub get
flutter run
```

The [hosted playground](https://ahmedelsapagh10.github.io/flutter_ui_gallery/)
may show an older deployed revision. No deployment is part of this checkout.
See the [complete preset matrix](doc/PRESETS.md) for category counts and options.

## Family, preset, signature and overrides

A **preset** selects a component's structure and use case. A **family** coordinates
its geometry, typography and motion: Minimal is precise, Soft is comfortable and
Spatial uses restrained layered cues. A **signature** enables the opt-in
structural treatment while retaining distinctive preset silhouettes. Choosing a
family alone keeps signatures off. A **recipe** here means one family/signature
configuration shared by all five categories; existing users opt in explicitly.

Per-call `style` values override the corresponding inherited values. Shared theme
styles provide defaults; category styles refine them. Per-call `appearance`
can refine the ambient theme, and a per-call `motion` can refine inherited motion.
Explicit shape and typography overrides retain priority. Accessibility preferences
such as reduced motion still apply. See [full precedence and exceptions](doc/FAMILY_SIGNATURES.md).

```dart
// Inside a widget with a BuildContext named context:
UiGalleryToast.show(
  context,
  message: 'Draft saved',
  style: const UiGallerySurfaceStyle(maxWidth: 360),
);
```

Use `UiGalleryEffects.cheap` in the family factory to omit backdrop blur and
cap decorative elevation. GlassDock needs `Scaffold(extendBody: true, ...)` to
show body content through its blur. The caller still owns navigation and state.

## Real application examples

Under **Real app examples**, Margin Notes Pass A and Pass B demonstrate local
create/search/archive flows, Arabic, dark mode, text scaling and reduced motion.
Wallet · Still uses local sample accounts and transfer drafts; it does not connect
to a bank, execute payments or save files.

- [Margin Notes Pass A](doc/NOTES_PASS_A.md)
- [Margin Notes Pass B](doc/NOTES_PASS_B.md)
- [Wallet · Still](doc/WALLET_PASS_A.md)

## Compatibility and verification

The `UiGallery*` APIs, `Nova*` compatibility aliases and canonical preset identities
remain available. The 0.2.0 structural redesigns require `useSignature: true`.
Compared with published 0.1.0, family geometry, typography and motion have also
been refined with signatures disabled. Source compatibility does not imply
pixel-identical appearance: compare application screenshots and custom shape/
style assumptions when upgrading or enabling signatures. Historical golden
PNGs and hash manifests are preserved; intentional changes use named versioned
expectations with strict comparisons.

At compact widths, scaled navigation labels may require horizontal scrolling.
EditorialTopbar retains its fixed preferred height: at extreme **3× Arabic**, its
heading and supporting copy require reading gestures. Native screen-reader access
to that arrangement remains **unverified**, not fully accepted accessibility evidence.
Widget semantics and keyboard tests do not prove TalkBack or VoiceOver quality.

Run the repository's pinned checks with Flutter 3.41.9:

```sh
python3 tool/check_golden_hashes.py
python3 tool/check_notes_pins.py
python3 tool/check_still_pins.py
flutter test --no-pub
cd example
flutter test --no-pub test
flutter test --no-pub test/snippet_test.dart --dart-define=WRITE_SNIPPET_FIXTURE=true
flutter analyze --no-pub ..
```

Resolve package and example dependencies first. `check_notes_pins.py` reads
`flutter` from `PATH`, so activate the pinned SDK before running it. The snippet
command writes a temporary analyzer fixture; preserve it as evidence or remove
only that generated fixture after analysis. Current-stable behavior runs exclude
renderer-specific tests with `--exclude-tags golden`. Never regenerate historical
goldens to resolve failures. Remote CI, native builds, physical-device testing and
measured performance are separate evidence, not implied by local widget tests.

## Documentation and historical previews

- [Usage and advanced customization](doc/USAGE.md)
- [Integration and caller-owned state](doc/INTEGRATION.md)
- [Signature rules and baseline procedure](doc/FAMILY_SIGNATURES.md)
- [Release policy and CI requirements](doc/REDESIGN_RELEASE_POLICY.md)
- [Development and verification ledger](doc/DEVELOPMENT_PROGRESS.md)

The following repository previews document an earlier gallery revision; use the
local Flutter example for the current unreleased appearances.

![Toast presets](doc/assets/preview-toasts.png)
![Sheets](doc/assets/preview-sheets.png)
![Dialogs](doc/assets/preview-dialogs.png)
![Headers and navigation](doc/assets/preview-navigation.png)

## License and author

MIT © 2026 [Ahmed Mohamed Elsapagh](https://github.com/Ahmedelsapagh10).
See [LICENSE](LICENSE). Example font licenses are retained with the example assets.

[Portfolio](https://elsapagh.octopusteam.net/) ·
[Octopus Team](https://octopusteam.net/) ·
[Email](mailto:ahmedelsapagh@gmail.com)
