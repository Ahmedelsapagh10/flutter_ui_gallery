import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:nova_surfaces_example/gallery/catalog.dart';
import 'package:nova_surfaces_example/gallery/demo.dart';

Future<void> pumpDesign(
  WidgetTester tester,
  SurfaceDesign design, {
  bool dark = false,
  bool rtl = false,
  bool reduced = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      key: ValueKey('${design.id}-$dark-$rtl-$reduced'),
      theme: ThemeData(
        useMaterial3: true,
        brightness: dark ? Brightness.dark : Brightness.light,
        colorSchemeSeed: Colors.indigo,
        extensions: [UiGalleryTheme(motionIntensity: reduced ? 0 : 1)],
      ),
      builder: (context, child) => Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: SurfaceDemo(
        index: designs.indexOf(design),
        title: 'Native gallery',
        message: 'Explore your collection.',
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> selectDestination(WidgetTester tester, int index) async {
  final destination = find.byKey(ValueKey('nav-tab-$index'));
  // Platform keyboard metrics can arrive after Flutter's current frames settle.
  if (destination.hitTestable().evaluate().isEmpty) {
    for (
      var attempt = 0;
      attempt < 100 && destination.hitTestable().evaluate().isEmpty;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }
  expect(destination.hitTestable(), findsOneWidget);
  await tester.tap(destination);
  await tester.pumpAndSettle();
  expect(
    tester
        .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
        .selectedIndex,
    index,
  );
  expect(tester.takeException(), isNull);
}
