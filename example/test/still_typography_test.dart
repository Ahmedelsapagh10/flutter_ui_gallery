import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'still_home_fonts.dart';

void main() {
  setUpAll(loadStillFonts);
  testWidgets('variable axes match static 300 optical 60', (tester) async {
    tester.view.physicalSize = const Size(426, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    const styles = [
      TextStyle(
        fontFamily: 'StillSerif',
        fontSize: 65,
        fontWeight: FontWeight.w300,
        fontVariations: [
          ui.FontVariation('wght', 300),
          ui.FontVariation('opsz', 60),
        ],
        fontFeatures: [
          ui.FontFeature.tabularFigures(),
          ui.FontFeature.liningFigures(),
        ],
        letterSpacing: -1.8,
        color: Color(0xff14201c),
      ),
      TextStyle(
        fontFamily: 'StillSerifStatic',
        fontSize: 65,
        fontWeight: FontWeight.w300,
        fontFeatures: [
          ui.FontFeature.tabularFigures(),
          ui.FontFeature.liningFigures(),
        ],
        letterSpacing: -1.8,
        color: Color(0xff14201c),
      ),
      TextStyle(
        fontFamily: 'StillNaskh',
        fontSize: 68,
        fontWeight: FontWeight.w400,
        fontVariations: [ui.FontVariation('wght', 400)],
        color: Color(0xff14201c),
      ),
    ];
    final widths = <double>[];
    for (final s in styles.take(2)) {
      final p = TextPainter(
        text: TextSpan(text: '12,480.50', style: s),
        textDirection: TextDirection.ltr,
      )..layout();
      widths.add(p.width);
      p.dispose();
    }
    expect((widths[0] - 229.46875).abs(), lessThan(.01));
    expect((widths[0] - widths[1]).abs(), lessThan(1));
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xfff6f3ee),
            body: Column(
              children: [
                for (var i = 0; i < 3; i++)
                  SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          [
                            'Flutter variable · 300 / 60',
                            'Flutter static · 300 / 60',
                            'Arabic Naskh · 400',
                          ][i],
                        ),
                        Text(
                          i == 2 ? '١٢٬٤٨٠٫٥٠' : '12,480.50',
                          style: styles[i],
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    const out = String.fromEnvironment('STILL_REVIEW');
    if (out.isNotEmpty) {
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '$out/flutter-typography.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
        await File('$out/flutter-type-metrics.txt').writeAsString(
          'Variable width: ${widths[0]}\nStatic width: ${widths[1]}\n',
        );
      });
    }
  });
}
