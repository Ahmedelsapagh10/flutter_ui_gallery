import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_surfaces_example/main.dart';

void main() {
  testWidgets('gallery introduces the collection and opens a live preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterUiGalleryApp());
    await tester.pumpAndSettle();
    expect(find.text('Interfaces\nwith intent.'), findsOneWidget);
    await tester.ensureVisible(find.text('Space for your next move.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Space for your next move.'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Open live preview'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open live preview'));
    await tester.pumpAndSettle();
    expect(find.text('Copy link'), findsOneWidget);
    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    expect(find.text('Returned: Copy link'), findsOneWidget);
  });

  testWidgets('gallery settings change appearance and direction', (
    tester,
  ) async {
    await tester.pumpWidget(const FlutterUiGalleryApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Customize gallery'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark appearance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arabic / RTL'));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('Make it yours'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
