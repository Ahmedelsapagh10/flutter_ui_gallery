import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'notes_fonts.dart';

void main() {
  setUpAll(loadNotesFonts);
  for (final preset in ['split', 'layeredShelf']) {
    for (final family in UiGalleryDesignFamily.values) {
      for (final env in ['light', 'dark', 'rtl', 'large-text']) {
        testWidgets('$preset ${family.name} $env Pass B specimen', (
          tester,
        ) async {
          verifyNotesPins();
          debugDisableShadows = false;
          tester.view.physicalSize = const Size(420, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final ar = env == 'rtl';
          String t(String en, String arabic) => ar ? arabic : en;
          final base = ThemeData(
            fontFamily: ar ? 'MarginArabic' : 'Roboto',
            colorSchemeSeed: const Color(0xff455a64),
            brightness: env == 'dark' ? Brightness.dark : Brightness.light,
          );
          final boundary = GlobalKey();
          late BuildContext owner;
          await tester.pumpWidget(
            RepaintBoundary(
              key: boundary,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: base.copyWith(
                  extensions: [
                    UiGalleryTheme.family(
                      family,
                      theme: base,
                      useSignature: true,
                    ).copyWith(motionIntensity: 0),
                  ],
                ),
                locale: Locale(ar ? 'ar' : 'en'),
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    disableAnimations: true,
                    textScaler: TextScaler.linear(env == 'large-text' ? 2 : 1),
                  ),
                  child: child!,
                ),
                home: Builder(
                  builder: (context) {
                    owner = context;
                    return Scaffold(
                      body: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          t(
                            'A little space for what matters.',
                            'مساحة صغيرة لما يهمك.',
                          ),
                        ),
                      ),
                      bottomNavigationBar: preset == 'layeredShelf'
                          ? UiGalleryBottomNav(
                              preset: UiGalleryBottomNavPreset.layeredShelf,
                              selectedIndex: 1,
                              onDestinationSelected: (_) {},
                              semanticLabel: t(
                                'Notebook workspace',
                                'مساحة عمل الدفتر',
                              ),
                              items: [
                                UiGalleryBottomNavItem(
                                  icon: const Icon(Icons.notes_outlined),
                                  label: t('Notes', 'الملاحظات'),
                                ),
                                UiGalleryBottomNavItem(
                                  icon: const Icon(Icons.book_outlined),
                                  label: t('Notebooks', 'الدفاتر'),
                                ),
                                UiGalleryBottomNavItem(
                                  icon: const Icon(Icons.bookmark_outline),
                                  label: t('Saved', 'المحفوظات'),
                                ),
                              ],
                            )
                          : null,
                    );
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          if (preset == 'split') {
            UiGalleryDialog.show<String>(
              context: owner,
              preset: UiGalleryDialogPreset.split,
              title: t('Leave this draft?', 'هل تريد مغادرة المسودة؟'),
              message: t(
                'Your edits have not been saved in this session.',
                'لم تُحفظ تعديلاتك في هذه الجلسة بعد.',
              ),
              actions: [
                UiGalleryDialogAction(
                  label: t('Keep editing', 'متابعة الكتابة'),
                  value: 'keep',
                  primary: true,
                  icon: const Icon(Icons.edit_outlined),
                  description: t(
                    'Return to your words. Nothing is lost.',
                    'عُد إلى كلماتك دون فقدان أي تعديل.',
                  ),
                ),
                UiGalleryDialogAction(
                  label: t('Discard changes', 'تجاهل التعديلات'),
                  value: 'discard',
                  destructive: true,
                  icon: const Icon(Icons.undo),
                  description: t(
                    'Only these unsaved edits will be removed.',
                    'ستُحذف هذه التعديلات غير المحفوظة فقط.',
                  ),
                ),
              ],
            );
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          const output = String.fromEnvironment('NOTES_B_CAPTURE');
          if (output.isNotEmpty) {
            await tester.runAsync(() async {
              final image =
                  await (boundary.currentContext!.findRenderObject()!
                          as RenderRepaintBoundary)
                      .toImage();
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await File(
                '$output/$preset-${family.name}-$env.png',
              ).writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          } else {
            await expectLater(
              find.byKey(boundary),
              matchesGoldenFile(
                'goldens/notes-pass-b/$preset/${family.name}-$env.png',
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
}
