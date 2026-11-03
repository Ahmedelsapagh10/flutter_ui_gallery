import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'dialog_heroes_test.dart' as host;
import 'notes_fonts.dart';

void main() {
  setUpAll(loadNotesFonts);
  for (final kind in ['action', 'editorialTopbar']) {
    for (final family in UiGalleryDesignFamily.values) {
      for (final scene in ['light', 'dark', 'rtl', 'large-text']) {
        testWidgets('$kind ${family.name} $scene strict specimen', (
          tester,
        ) async {
          verifyNotesPins();
          final ar = scene.startsWith('rtl');
          String t(String en, String arabic) => ar ? arabic : en;
          debugDisableShadows = false;
          try {
            final key = GlobalKey();
            final owner = await host.hostDialogHero(
              tester,
              family,
              scene,
              key,
              home: (context) => Scaffold(
                appBar: kind == 'editorialTopbar'
                    ? UiGalleryAppBar(
                        preset: UiGalleryAppBarPreset.editorialTopbar,
                        title: Text(t('Field notes', 'ملاحظات ميدانية')),
                        subtitle: Text(
                          t('YOUR WEEK IN VIEW', 'أسبوعك في لمحة'),
                        ),
                        actions: [
                          IconButton(
                            tooltip: t('New note', 'ملاحظة جديدة'),
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      )
                    : null,
                body: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    t(
                      'A little space for what matters.',
                      'مساحة صغيرة لما يهمك.',
                    ),
                  ),
                ),
              ),
            );
            UiGalleryToastHandle? toast;
            if (kind == 'action') {
              toast = UiGalleryToast.show(
                owner,
                preset: UiGalleryToastPreset.action,
                message: t(
                  'Your archived note is kept safely. Undo to return it to this notebook.',
                  'تم الاحتفاظ بالملاحظة المؤرشفة بأمان. تراجع لإعادتها إلى هذا الدفتر.',
                ),
                actionLabel: t('Undo archive', 'التراجع عن الأرشفة'),
                onAction: () {},
                duration: Duration.zero,
              );
            }
            await tester.pumpAndSettle();
            await expectLater(
              find.byKey(key),
              matchesGoldenFile(
                'goldens/feedback-calm-v1/$kind/${family.name}-$scene.png',
              ),
            );
            expect(tester.takeException(), isNull);
            toast?.dismiss();
            await tester.pumpAndSettle();
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
          } finally {
            debugDisableShadows = true;
          }
        }, tags: 'golden');
      }
    }
  }
}
