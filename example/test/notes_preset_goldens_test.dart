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
  for (final preset in ['orbit', 'action']) {
    for (final family in UiGalleryDesignFamily.values) {
      for (final env in ['light', 'dark', 'rtl', 'large-text']) {
        testWidgets('$preset ${family.name} $env redesigned specimen', (
          tester,
        ) async {
          verifyNotesPins();
          debugDisableShadows = false;
          tester.view.physicalSize = const Size(420, 760);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final ar = env == 'rtl';
          String t(String en, String arabic) => ar ? arabic : en;
          final base = ThemeData(
            fontFamily: ar ? 'Alexandria' : 'Roboto',
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
                    textScaler: TextScaler.linear(env == 'large-text' ? 2 : 1),
                    disableAnimations: true,
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
                            'Keep the thought. Find it later.',
                            'احتفظ بالفكرة، واعثر عليها لاحقًا.',
                          ),
                          style: base.textTheme.headlineSmall,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          if (preset == 'orbit') {
            UiGallerySheet.show<void>(
              context: owner,
              preset: UiGallerySheetPreset.orbit,
              header: Text(t('New note', 'ملاحظة جديدة')),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: t('Title', 'العنوان'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: t('Your thought', 'فكرتك'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(owner).pop(),
                    child: Text(t('Save note', 'حفظ الملاحظة')),
                  ),
                ],
              ),
            );
          } else {
            UiGalleryToast.show(
              owner,
              preset: UiGalleryToastPreset.action,
              message: t('1 note archived', 'تمت أرشفة ملاحظة واحدة'),
              actionLabel: t('Undo', 'تراجع'),
              onAction: () {},
              duration: Duration.zero,
            );
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          const capture = String.fromEnvironment('NOTES_CAPTURE');
          if (capture.isNotEmpty) {
            await tester.runAsync(() async {
              final image =
                  await (boundary.currentContext!.findRenderObject()!
                          as RenderRepaintBoundary)
                      .toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await File(
                '$capture/$preset-${family.name}-$env.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          } else {
            await expectLater(
              find.byKey(boundary),
              matchesGoldenFile(
                preset == 'orbit'
                    ? 'goldens/sheet-calm-v1/orbit-existing/${family.name}-$env.png'
                    : env == 'large-text'
                    ? 'goldens/feedback-calm-v1/action-existing/${family.name}-$env.png'
                    : family == UiGalleryDesignFamily.spatial
                    ? 'goldens/spatial-edge/$preset/${family.name}-$env.png'
                    : 'goldens/notes-pass-a/$preset/${family.name}-$env.png',
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
