import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:nova_surfaces_example/gallery/notes.dart';
import 'notes_fonts.dart';

Future<void> host(
  WidgetTester tester, {
  bool ar = false,
  bool dark = false,
  bool large = false,
  bool wide = false,
}) async {
  tester.view.physicalSize = Size(wide ? 1280 : 420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: const ValueKey('margin-capture'),
        child: NotesExample(
          arabic: ar,
          dark: dark,
          largeText: large,
          reducedMotion: true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadNotesFonts);
  testWidgets('create validates, saves and can be searched', (tester) async {
    await host(tester);
    await tester.tap(find.byTooltip('New note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();
    expect(find.text('Give this thought a title'), findsOneWidget);
    expect(find.text('Write a little before saving'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('margin-title')),
      'A test thought',
    );
    await tester.enterText(
      find.byKey(const ValueKey('margin-body')),
      'Keep the actual body',
    );
    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();
    expect(find.text('A test thought'), findsOneWidget);
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'zz-no-match');
    await tester.pumpAndSettle();
    expect(find.text('No matching notes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('archive selected set, undo and switch navigation presentation', (
    tester,
  ) async {
    await host(tester);
    await tester.longPress(find.byKey(const ValueKey('margin-note-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Archive selected notes'));
    await tester.pumpAndSettle();
    expect(find.text('The quiet parts of a day'), findsNothing);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('The quiet parts of a day'), findsOneWidget);
    await tester.tap(find.byTooltip('Showcase controls'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adaptive Minimal').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav)).preset,
      UiGalleryBottomNavPreset.adaptiveMinimal,
    );
    expect(find.text('The quiet parts of a day'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Arabic editor validation and commands are translated', (
    tester,
  ) async {
    await host(tester, ar: true);
    await tester.tap(find.byTooltip('ملاحظة جديدة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ الملاحظة'));
    await tester.pumpAndSettle();
    expect(find.text('أضف عنوانًا لهذه الفكرة'), findsOneWidget);
    Navigator.of(tester.element(find.text('حفظ الملاحظة'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('أوامر الدفتر'));
    await tester.pumpAndSettle();
    expect(find.text('اختر دفترًا'), findsOneWidget);
    expect(find.text('ملاحظة جديدة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('commands choose a real notebook and Saved reflects bookmarks', (
    tester,
  ) async {
    await host(tester);
    await tester.tap(find.byTooltip('Notebook commands'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose notebook'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Product notes'));
    await tester.pumpAndSettle();
    expect(find.text('The quiet parts of a day'), findsNothing);
    expect(find.text('A product worth returning to'), findsOneWidget);
    await tester.tap(find.byTooltip('Save for later'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('A product worth returning to'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('wide reading pane is selectable and selection clears on Back', (
    tester,
  ) async {
    await host(tester, wide: true);
    await tester.tap(find.byKey(const ValueKey('margin-note-1')));
    await tester.pumpAndSettle();
    expect(find.text('The quiet parts of a day'), findsNWidgets(2));
    await tester.longPress(find.byKey(const ValueKey('margin-note-1')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Archive selected notes'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Archive selected notes'), findsNothing);
    final navContext = tester.element(find.byType(UiGalleryBottomNav));
    expect(MediaQuery.of(navContext).disableAnimations, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'editor draft survives Orbit rail changing from stacked to wide',
    (tester) async {
      await host(tester);
      await tester.tap(find.byTooltip('New note'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('margin-title')),
        'Retained through resize',
      );
      await tester.enterText(
        find.byKey(const ValueKey('margin-body')),
        'The form owns this draft',
      );
      tester.view.physicalSize = const Size(1280, 900);
      await tester.pumpAndSettle();
      expect(find.text('Retained through resize'), findsOneWidget);
      expect(find.text('The form owns this draft'), findsOneWidget);
      await tester.tap(find.text('Save note'));
      await tester.pumpAndSettle();
      expect(find.text('Retained through resize'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
  for (final env in ['light', 'dark', 'rtl', 'large-text', 'wide']) {
    testWidgets('Margin $env app specimen', (tester) async {
      verifyNotesPins();
      debugDisableShadows = false;
      await host(
        tester,
        ar: env == 'rtl',
        dark: env == 'dark',
        large: env == 'large-text',
        wide: env == 'wide',
      );
      expect(tester.takeException(), isNull);
      final boundary = find.byKey(const ValueKey('margin-capture'));
      const output = String.fromEnvironment('NOTES_APP_CAPTURE');
      if (output.isNotEmpty) {
        final render = tester.renderObject<RenderRepaintBoundary>(boundary);
        final bytes = await (await render.toImage()).toByteData(
          format: ui.ImageByteFormat.png,
        );
        await tester.runAsync(
          () => File(
            '$output/$env.png',
          ).writeAsBytes(bytes!.buffer.asUint8List()),
        );
      } else {
        await expectLater(
          boundary,
          matchesGoldenFile('goldens/notes-pass-a/app-$env.png'),
        );
      }
      debugDisableShadows = true;
    }, tags: 'golden');
  }
}
