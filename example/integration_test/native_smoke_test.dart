import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nova_surfaces_example/gallery/catalog.dart';
import 'package:nova_surfaces_example/gallery/demo.dart';
import 'package:nova_surfaces_example/main.dart';

import 'support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native playground launches and a sheet returns its action', (
    tester,
  ) async {
    await tester.pumpWidget(const FlutterUiGalleryApp());
    await tester.pumpAndSettle();
    expect(find.byType(SurfaceDemo), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('launch-preview')));
    await tester.tap(find.byKey(const ValueKey('launch-preview')));
    await tester.pumpAndSettle();
    final action = find.text('Copy link');
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    expect(action.hitTestable(), findsOneWidget);
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.text('Returned: Copy link'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final preset in [
    UiGalleryBottomNavPreset.floatingCove,
    UiGalleryBottomNavPreset.glassDock,
  ]) {
    testWidgets('${preset.name} preserves native destination state', (
      tester,
    ) async {
      final design = designs.singleWhere(
        (design) => design.bottomNav == preset,
      );
      await pumpDesign(tester, design);
      await tester.enterText(
        find.byKey(const ValueKey('navigation-draft')),
        'Keep this native draft',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await selectDestination(tester, 1);
      await tester.ensureVisible(find.text('Save another idea'));
      await tester.tap(find.text('Save another idea'));
      await tester.pumpAndSettle();
      expect(find.text('4 saved ideas'), findsOneWidget);
      await selectDestination(tester, 2);
      await selectDestination(tester, 1);
      expect(find.text('4 saved ideas'), findsOneWidget);
      await tester.tapAt(
        tester.getCenter(find.byKey(const ValueKey('nav-tab-3'))),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
            .selectedIndex,
        1,
      );
      await selectDestination(tester, 0);
      expect(find.text('Keep this native draft'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await pumpDesign(tester, design, dark: true, rtl: true, reduced: true);
      await selectDestination(tester, 2);
      final context = tester.element(find.byType(UiGalleryBottomNav));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(Theme.of(context).extension<UiGalleryTheme>()!.motionIntensity, 0);
    });
  }
}
