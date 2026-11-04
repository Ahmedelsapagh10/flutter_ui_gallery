import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_surfaces_example/gallery/notes.dart';
import 'notes_fonts.dart';

void main() {
  setUpAll(loadNotesFonts);
  for (final device in ['phone', 'tablet']) {
    for (final env in ['light', 'dark', 'rtl', 'large-text']) {
      testWidgets('$device $env Notes Pass B app specimen', (tester) async {
        verifyNotesPins();
        debugDisableShadows = false;
        tester.view.physicalSize = device == 'phone'
            ? const Size(420, 900)
            : const Size(1024, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: NotesExample(
                passB: true,
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
        const output = String.fromEnvironment('NOTES_REVIEW');
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
              'goldens/hero-calm-v1/notes-pass-b/app/$device-$env.png',
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
