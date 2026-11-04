import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_surfaces_example/gallery/wallet.dart';
import 'still_home_fonts.dart';
import 'notes_fonts.dart' show verifyNotesPins;

void main() {
  setUpAll(loadStillFonts);
  for (final env in ['light', 'dark', 'rtl', 'large-light', 'large-rtl']) {
    testWidgets('Still refined home $env', (tester) async {
      verifyNotesPins();
      tester.view.physicalSize = const Size(426, 926);
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
              arabic: env.contains('rtl'),
              dark: env == 'dark' || env == 'rtl' || env == 'large-rtl',
              largeText: env.startsWith('large'),
              reducedMotion: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/still-home-refined/$env.png'),
      );
      const out = String.fromEnvironment('STILL_REVIEW');
      if (out.isNotEmpty) {
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('$out/$env.png').writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      // Large-text footer must be in the scroll flow, reachable without pinning.
      final action = find.byKey(const ValueKey('still-home-action'));
      if (env.startsWith('large')) {
        await tester.scrollUntilVisible(
          action,
          400,
          scrollable: find.descendant(
            of: find.byKey(const ValueKey('still-home-scroll')),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.getSize(action).height, greaterThanOrEqualTo(48));
        final scroll = tester.state<ScrollableState>(
          find.descendant(
            of: find.byKey(const ValueKey('still-home-scroll')),
            matching: find.byType(Scrollable),
          ),
        );
        scroll.position.jumpTo(scroll.position.maxScrollExtent);
        await tester.pumpAndSettle();
        await expectLater(
          find.byKey(key),
          matchesGoldenFile('goldens/still-home-refined/$env-scrolled.png'),
        );
        if (out.isNotEmpty) {
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '$out/$env-scrolled.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    }, tags: 'golden');
  }
}
