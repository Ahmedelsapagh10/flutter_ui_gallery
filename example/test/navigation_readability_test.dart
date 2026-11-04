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
  for (final preset in [
    UiGalleryBottomNavPreset.adaptiveMinimal,
    UiGalleryBottomNavPreset.layeredShelf,
  ]) {
    for (final family in UiGalleryDesignFamily.values) {
      for (final scene in [
        'light',
        'dark',
        'rtl-large',
        'rtl-extreme',
        'large-text',
      ]) {
        testWidgets('${preset.name} ${family.name} $scene scaled labels', (
          tester,
        ) async {
          final ar = scene.startsWith('rtl');
          final labels = ar
              ? ['ملاحظات', 'الدفاتر', 'الأرشيف']
              : ['Notes', 'Notebooks', 'Archive'];
          final key = GlobalKey();
          var calls = 0;
          await host.hostDialogHero(
            tester,
            family,
            scene == 'rtl-extreme' ? 'rtl-large' : scene,
            key,
            textScale: scene == 'rtl-extreme' ? 3 : null,
            home: (_) => Scaffold(
              body: const Center(child: Text('Navigation reading specimen')),
              bottomNavigationBar: UiGalleryBottomNav(
                preset: preset,
                selectedIndex: 0,
                onDestinationSelected: (_) => calls++,
                options: const UiGalleryBottomNavOptions(
                  labels: UiGalleryNavLabels.always,
                ),
                items: [
                  for (var i = 0; i < labels.length; i++)
                    UiGalleryBottomNavItem(
                      icon: Icon(
                        [
                          Icons.notes,
                          Icons.book_outlined,
                          Icons.archive_outlined,
                        ][i],
                      ),
                      label: labels[i],
                    ),
                ],
              ),
            ),
          );
          const capture = String.fromEnvironment('NAV_CAPTURE');
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
                '$capture/${preset.name}-${family.name}-$scene.png',
              ).writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          } else {
            for (final label in labels) {
              final paragraph = tester.renderObject<RenderParagraph>(
                find.text(label),
              );
              expect(paragraph.didExceedMaxLines, isFalse, reason: label);
            }
            final nav = find.byType(UiGalleryBottomNav);
            final track = tester
                .stateList<ScrollableState>(
                  find.descendant(of: nav, matching: find.byType(Scrollable)),
                )
                .single;
            if (track.position.maxScrollExtent > 0) {
              await tester.drag(
                find.byWidget(track.widget),
                Offset(ar ? 250 : -250, 0),
              );
              await tester.pumpAndSettle();
              expect(track.position.pixels, greaterThan(0));
            }
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
            await tester.pumpAndSettle();
            expect(calls, 1);
            await tester.ensureVisible(find.text(labels.last));
            await tester.pumpAndSettle();
            await tester.tap(find.text(labels.last));
            expect(calls, 2);
            expect(
              tester
                  .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
                  .selectedIndex,
              0,
            );
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        });
      }
    }
  }
}
