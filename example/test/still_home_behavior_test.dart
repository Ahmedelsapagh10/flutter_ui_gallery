import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_surfaces_example/gallery/wallet.dart';
import 'package:nova_surfaces_example/gallery/still_home.dart';
import 'still_home_fonts.dart';

void main() {
  setUpAll(loadStillFonts);
  for (final scale in [1.29, 1.3, 2.0]) {
    for (final ar in [false, true]) {
      testWidgets('small home footer at $scale Arabic $ar', (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(360, 640),
                textScaler: TextScaler.linear(scale),
              ),
              child: StillExample(arabic: ar, reducedMotion: true),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final list = find.byKey(const ValueKey('still-home-scroll'));
        final action = find.byKey(const ValueKey('still-home-action'));
        if (scale >= 1.3) {
          expect(tester.getSize(list).height, greaterThan(400));
          await tester.scrollUntilVisible(
            action,
            350,
            scrollable: find.descendant(
              of: list,
              matching: find.byType(Scrollable),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.ancestor(of: action, matching: find.byType(ListView)),
            findsOneWidget,
          );
        } else {
          expect(
            find.ancestor(of: action, matching: find.byType(ListView)),
            findsNothing,
          );
          final before = tester.getTopLeft(action);
          await tester.drag(list, const Offset(0, -300));
          await tester.pumpAndSettle();
          expect(tester.getTopLeft(action), before);
        }
        expect(tester.getSize(action).height, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
      });
    }
  }
  test('secondary roles reach five to one on their surfaces', () {
    for (final dark in [false, true]) {
      final c = stillHomeTheme(dark, false).colorScheme;
      for (final bg in [c.surface, c.surfaceContainerLow]) {
        final a = c.onSurfaceVariant.computeLuminance(),
            b = bg.computeLuminance();
        final ratio = a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
        expect(ratio, greaterThanOrEqualTo(5));
      }
    }
  });
}
