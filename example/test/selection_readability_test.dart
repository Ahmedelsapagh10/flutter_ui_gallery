import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'dialog_heroes_test.dart' as host;
import 'notes_fonts.dart';

void main() {
  setUpAll(loadNotesFonts);
  for (final family in UiGalleryDesignFamily.values) {
    for (final scene in ['light', 'dark', 'rtl', 'rtl-large', 'rtl-extreme']) {
      testWidgets('Selection ${family.name} $scene visible localized count', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        try {
          final key = GlobalKey();
          var clears = 0, archives = 0;
          final owner = await host.hostDialogHero(
            tester,
            family,
            scene == 'rtl-extreme' ? 'rtl-large' : scene,
            key,
            textScale: scene == 'rtl-extreme' ? 3 : null,
            home: (_) => Scaffold(
              appBar: UiGalleryAppBar(
                preset: UiGalleryAppBarPreset.selectionBar,
                title: const Text('Notes'),
                selectionCount: 2,
                onSelectionCleared: () => clears++,
                actions: [
                  IconButton(
                    tooltip: 'Archive',
                    onPressed: () => archives++,
                    icon: const Icon(Icons.archive_outlined),
                  ),
                ],
              ),
            ),
          );
          const capture = String.fromEnvironment('SELECTION_CAPTURE');
          if (capture.isNotEmpty) {
            await tester.runAsync(() async {
              final image =
                  await (key.currentContext!.findRenderObject()!
                          as RenderRepaintBoundary)
                      .toImage(pixelRatio: 1);
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await File(
                '$capture/selection-${family.name}-$scene.png',
              ).writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          } else {
            final localizations = MaterialLocalizations.of(owner);
            final phrase = localizations.selectedRowCountTitle(2);
            final number = localizations.formatDecimal(2);
            final visible = find.text(number).evaluate().isNotEmpty
                ? find.text(number)
                : find.text(phrase);
            final paragraph = tester.renderObject<RenderParagraph>(visible);
            expect(paragraph.didExceedMaxLines, isFalse);
            final rect = tester.getRect(visible);
            expect(rect.top, greaterThanOrEqualTo(0));
            expect(rect.bottom, lessThanOrEqualTo(64));
            expect(find.bySemanticsLabel(phrase), findsOneWidget);
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
            await tester.pumpAndSettle();
            expect(clears, 1);
            await tester.tap(find.byTooltip('Archive'));
            expect(archives, 1);
            expect(
              tester
                  .widget<UiGalleryAppBar>(find.byType(UiGalleryAppBar))
                  .selectionCount,
              2,
            );
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        } finally {
          semantics.dispose();
        }
      });
    }
  }
}
