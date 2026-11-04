import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:nova_surfaces_example/gallery/notes.dart';
import 'notes_fonts.dart';

Future<void> host(
  WidgetTester tester, {
  bool ar = false,
  bool large = false,
  bool wide = false,
}) async {
  tester.view.physicalSize = Size(wide ? 1024 : 420, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: NotesExample(
        passB: true,
        arabic: ar,
        largeText: large,
        reducedMotion: true,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadNotesFonts);
  testWidgets(
    'draft exit keeps edits, discard is explicit, save produces local status',
    (tester) async {
      await host(tester);
      await tester.tap(find.byTooltip('New note'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('margin-title')),
        'A guarded thought',
      );
      await tester.enterText(
        find.byKey(const ValueKey('margin-body')),
        'Keep my draft',
      );
      await tester.tap(find.text('Close editor'));
      await tester.pumpAndSettle();
      expect(find.text('Leave this draft?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('A guarded thought'), findsOneWidget);
      await tester.tap(find.text('Save note'));
      await tester.pumpAndSettle();
      expect(find.text('Note saved in this session'), findsOneWidget);
      expect(find.text('A guarded thought'), findsOneWidget);
      await tester.tap(find.byTooltip('New note'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('margin-title')),
        'Throw away',
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();
      expect(find.text('Throw away'), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Edge Lift moves just one note into a real notebook', (
    tester,
  ) async {
    await host(tester);
    await tester.tap(find.byTooltip('Actions for The quiet parts of a day'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<Material>(find.byType(Material))
          .any(
            (m) =>
                m.shape is RoundedRectangleBorder &&
                (m.shape! as RoundedRectangleBorder).borderRadius ==
                    BorderRadius.zero,
          ),
      isTrue,
    );
    await tester.tap(find.text('Move to notebook'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Product notes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All notebooks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Product notes'));
    await tester.pumpAndSettle();
    expect(find.text('The quiet parts of a day'), findsOneWidget);
    expect(find.text('A product worth returning to'), findsOneWidget);
    expect(find.text('Lines to keep'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final style in ['Layered Shelf', 'Scroll Dock']) {
    testWidgets('$style keeps persistent query and controlled destinations', (
      tester,
    ) async {
      await host(tester);
      expect(
        tester.widget<UiGalleryAppBar>(find.byType(UiGalleryAppBar)).preset,
        UiGalleryAppBarPreset.focusBar,
      );
      await tester.enterText(find.byType(TextField).first, 'quiet');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Showcase controls'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(style).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('quiet'), findsOneWidget);
      expect(find.text('The quiet parts of a day'), findsOneWidget);
      expect(
        tester
            .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
            .preset,
        style == 'Layered Shelf'
            ? UiGalleryBottomNavPreset.layeredShelf
            : UiGalleryBottomNavPreset.scrollDock,
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Scroll Dock responds to actual Notes reading scroll', (
    tester,
  ) async {
    await host(tester, large: true);
    await tester.tap(find.byTooltip('Showcase controls'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scroll Dock').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    final list = find.byType(ListView).first;
    await tester.drag(list, const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(UiGalleryBottomNav)).height, 0);
    expect(find.byTooltip('Saved').hitTestable(), findsNothing);
    await tester.drag(list, const Offset(0, 220));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(UiGalleryBottomNav)).height,
      greaterThanOrEqualTo(48),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Arabic large draft exit has real translated consequences', (
    tester,
  ) async {
    await host(tester, ar: true, large: true);
    await tester.tap(find.byTooltip('ملاحظة جديدة'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('margin-title')),
      'فكرة جديدة',
    );
    await tester.tap(find.text('إغلاق المحرر'));
    await tester.pumpAndSettle();
    expect(find.text('هل تريد مغادرة المسودة؟'), findsOneWidget);
    expect(find.text('ستُحذف هذه التعديلات غير المحفوظة فقط.'), findsOneWidget);
    await tester.ensureVisible(find.text('متابعة الكتابة'));
    await tester.tap(find.text('متابعة الكتابة'));
    await tester.pumpAndSettle();
    expect(find.text('فكرة جديدة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
