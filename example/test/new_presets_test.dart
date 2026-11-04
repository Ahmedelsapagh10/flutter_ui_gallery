import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:nova_surfaces_example/gallery/catalog.dart';
import 'package:nova_surfaces_example/gallery/demo.dart';
import 'package:nova_surfaces_example/main.dart';

Future<void> _show(WidgetTester tester, String name) async {
  tester.view.physicalSize = const Size(390, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: SurfaceDemo(
        index: designs.indexWhere((design) => design.name == name),
        title: 'My collection',
        message: 'Choose a section',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Scroll Dock follows wheel direction inside the phone preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(690, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const FlutterUiGalleryApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Bottom Navigation'));
    await tester.tap(find.text('Bottom Navigation'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('Previous preset'));
      await tester.pumpAndSettle();
    }
    final body = find
        .descendant(
          of: find.byType(SurfaceDemo),
          matching: find.byType(ListView),
        )
        .first;
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(body),
        scrollDelta: const Offset(0, 300),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(UiGalleryBottomNav)).height, 0);
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(body),
        scrollDelta: const Offset(0, -100),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(UiGalleryBottomNav)).height,
      greaterThanOrEqualTo(48),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Selection Bar archives caller-selected notes and clears selection',
    (tester) async {
      await _show(tester, 'Selection Bar');
      await tester.ensureVisible(find.text('Selectable note 1'));
      await tester.tap(find.text('Selectable note 1'));
      await tester.pumpAndSettle();
      expect(find.text('1 item selected'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('My collection'), findsOneWidget);
      await tester.tap(find.text('Selectable note 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Archive selected'));
      await tester.pumpAndSettle();
      expect(find.text('Selectable note 1'), findsNothing);
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(find.text('Returned: Archived 1 notes'), findsOneWidget);
    },
  );

  testWidgets('Command Palette searches and returns the selected action', (
    tester,
  ) async {
    await _show(tester, 'Command Palette');
    await tester.tap(find.byKey(const ValueKey('launch-preview')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Saved');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved ideas'));
    await tester.pumpAndSettle();
    expect(find.text('Returned: Saved ideas'), findsOneWidget);
  });

  testWidgets(
    'Progress Card reflects manual work and dismisses on completion',
    (tester) async {
      await _show(tester, 'Progress Card');
      await tester.tap(find.byKey(const ValueKey('launch-preview')));
      await tester.pumpAndSettle();
      for (var i = 1; i <= 4; i++) {
        await tester.tap(find.text('Complete next item'));
        await tester.pumpAndSettle();
        expect(find.text('${i * 25}%'), findsOneWidget);
      }
      await tester.tap(find.text('Dismiss completed'));
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsNothing);
      expect(find.text('Returned: Completed'), findsOneWidget);
    },
  );

  testWidgets(
    'Overflow Dock opens an additional destination and retains its page',
    (tester) async {
      await _show(tester, 'Overflow Dock');
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Collections'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
            .selectedIndex,
        4,
      );
      await tester.tap(find.byKey(const ValueKey('nav-tab-0')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
            .selectedIndex,
        0,
      );
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('overflow-note-draft')),
        'A lasting idea',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save note'));
      await tester.pumpAndSettle();
      expect(find.text('Saved note: A lasting idea'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-tab-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      expect(find.text('A lasting idea'), findsOneWidget);
      expect(find.text('Saved note: A lasting idea'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Glass Dock keeps the final item reachable above the overlay', (
    tester,
  ) async {
    await _show(tester, 'Glass Dock');
    tester.view.physicalSize = const Size(390, 500);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.text('A different perspective')).bottom,
      lessThan(tester.getRect(find.byType(UiGalleryBottomNav)).top),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Search Switch demo emits typed queries', (tester) async {
    await _show(tester, 'Search Switch');
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'landscape');
    await tester.pump();
    expect(find.text('Returned: Search: landscape'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('My collection'), findsOneWidget);
  });

  testWidgets('Breadcrumb Trail opens the parent page and returns', (
    tester,
  ) async {
    await _show(tester, 'Breadcrumb Trail');
    await tester.tap(find.text('Workspace'));
    await tester.pumpAndSettle();
    expect(find.text('Open collection'), findsOneWidget);
    await tester.tap(find.text('Open collection'));
    await tester.pumpAndSettle();
    expect(find.text('My collection'), findsOneWidget);
    expect(find.text('Choose a section'), findsOneWidget);
  });

  testWidgets('Section Tabs switches the visible collection', (tester) async {
    await _show(tester, 'Section Tabs');
    expect(find.text('Overview collection'), findsOneWidget);
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Saved collection'), findsOneWidget);
    expect(find.text('Overview collection').hitTestable(), findsNothing);
    await tester.tap(find.text('Shared'));
    await tester.pumpAndSettle();
    expect(find.text('Shared collection'), findsOneWidget);
    await tester.drag(find.byType(TabBarView), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(find.text('Saved collection'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
