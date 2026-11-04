import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_surfaces_example/gallery/wallet.dart';
import 'notes_fonts.dart';
import 'still_home_fonts.dart';

void main() {
  setUpAll(loadStillFonts);
  for (final device in ['phone', 'tablet']) {
    for (final env in ['light', 'dark', 'rtl', 'large-text']) {
      testWidgets('Still $device $env app specimen', (tester) async {
        verifyNotesPins();
        debugDisableShadows = false;
        tester.view.physicalSize = device == 'phone'
            ? const Size(420, 900)
            : const Size(1200, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: StillExample(
                arabic: env == 'rtl',
                dark: env == 'dark',
                largeText: env == 'large-text',
                reducedMotion: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        const output = String.fromEnvironment('STILL_CAPTURE');
        if (output.isNotEmpty) {
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '$output/$device-$env.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        } else {
          await expectLater(
            find.byKey(key),
            matchesGoldenFile(
              'goldens/still-home-refined/dimensions/$device-$env.png',
            ),
          );
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        debugDisableShadows = true;
      }, tags: 'golden');
    }
  }
}
