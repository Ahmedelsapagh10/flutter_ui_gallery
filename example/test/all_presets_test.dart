import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:nova_surfaces_example/gallery/catalog.dart';
import 'package:nova_surfaces_example/gallery/demo.dart';

void main() {
  test('catalog covers all 66 public presets exactly once', () {
    expect(designs.length, 66);
    expect(
      designs.map((d) => d.sheet).whereType<UiGallerySheetPreset>().toSet(),
      UiGallerySheetPreset.values.toSet(),
    );
    expect(
      designs.map((d) => d.dialog).whereType<UiGalleryDialogPreset>().toSet(),
      UiGalleryDialogPreset.values.toSet(),
    );
    expect(
      designs.map((d) => d.toast).whereType<UiGalleryToastPreset>().toSet(),
      UiGalleryToastPreset.values.toSet(),
    );
    expect(
      designs.map((d) => d.appBar).whereType<UiGalleryAppBarPreset>().toSet(),
      UiGalleryAppBarPreset.values.toSet(),
    );
    expect(
      designs
          .map((d) => d.bottomNav)
          .whereType<UiGalleryBottomNavPreset>()
          .toSet(),
      UiGalleryBottomNavPreset.values.toSet(),
    );
  });
  for (var index = 0; index < designs.length; index++) {
    testWidgets(
      '${designs[index].category.name}: ${designs[index].name} has a working live example',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              extensions: const [UiGalleryTheme(motionIntensity: 0)],
            ),
            home: SurfaceDemo(
              index: index,
              title: 'Live example',
              message: 'Review your selection.',
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (designs[index].bottomNav != null) {
          await tester.tap(find.byKey(const ValueKey('nav-tab-1')));
          await tester.pumpAndSettle();
          expect(find.text('3 saved ideas'), findsOneWidget);
          await tester.tap(find.text('Save another idea'));
          await tester.pumpAndSettle();
          expect(find.text('4 saved ideas'), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('nav-tab-2')));
          await tester.pumpAndSettle();
          expect(find.text('Your collection is ready'), findsOneWidget);
          await tester.tapAt(
            tester.getCenter(find.byKey(const ValueKey('nav-tab-3'))),
          );
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
                .selectedIndex,
            2,
          );
          expect(find.text('Selection callbacks: 2'), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('nav-tab-1')));
          await tester.pumpAndSettle();
          expect(find.text('4 saved ideas'), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('nav-tab-0')));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const ValueKey('navigation-draft')),
            'Keep this thought',
          );
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('nav-tab-1')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('nav-tab-0')));
          await tester.pumpAndSettle();
          expect(find.text('Keep this thought'), findsOneWidget);
          if (designs[index].bottomNav ==
                  UiGalleryBottomNavPreset.concaveNotch ||
              designs[index].bottomNav ==
                  UiGalleryBottomNavPreset.splitIsland) {
            await tester.tap(find.byTooltip('Create a note'));
            await tester.pumpAndSettle();
            expect(find.text('Notes created: 1'), findsOneWidget);
          }
        } else if (designs[index].appBar == null) {
          await tester.ensureVisible(
            find.byKey(const ValueKey('launch-preview')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('launch-preview')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (designs[index].toast == null) {
            Navigator.of(tester.element(find.text('Live example').last)).pop();
            await tester.pumpAndSettle();
          }
        } else {
          await tester.drag(find.byType(ListView), const Offset(0, -400));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  }
}
