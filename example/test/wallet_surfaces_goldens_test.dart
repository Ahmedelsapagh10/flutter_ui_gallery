import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:nova_surfaces_example/gallery/wallet.dart';
import 'notes_fonts.dart';

void main() {
  setUpAll(loadNotesFonts);
  for (final preset in [
    'splitLayer',
    'taskRail',
    'halo',
    'statusBeacon',
    'progressCard',
  ]) {
    for (final env in ['light', 'dark', 'rtl', 'large-text']) {
      testWidgets('Still $preset $env specimen', (tester) async {
        verifyNotesPins();
        debugDisableShadows = false;
        tester.view.physicalSize = const Size(640, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final ar = env == 'rtl';
        String t(String en, String arabic) => ar ? arabic : en;
        final base = ThemeData(
          fontFamily: ar ? 'MarginArabic' : 'Roboto',
          colorSchemeSeed: const Color(0xff276354),
          brightness: env == 'dark' ? Brightness.dark : Brightness.light,
        );
        final key = GlobalKey();
        late BuildContext owner;
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: base.copyWith(
                extensions: [
                  UiGalleryTheme.family(
                    UiGalleryDesignFamily.soft,
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
                    appBar: UiGalleryAppBar(
                      preset: UiGalleryAppBarPreset.centeredTitle,
                      title: const Text('Still'),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        t(
                          'Sample money. No bank connection.',
                          'أموال تجريبية. لا يوجد اتصال بأي بنك.',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        ValueNotifier<double>? progress;
        if (preset == 'splitLayer') {
          UiGallerySheet.show<void>(
            context: owner,
            preset: UiGallerySheetPreset.splitLayer,
            header: Text(t('Plan a transfer', 'إعداد مسودة تحويل')),
            secondary: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('Personal account', 'الحساب الشخصي')),
                Text(stillAmount(1248050, 'EGP', arabic: ar)),
                const SizedBox(height: 16),
                Text(
                  t(
                    'Local draft only. No money moves.',
                    'مسودة محلية فقط. لن تُنقل أموال.',
                  ),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: t('To account', 'إلى الحساب'),
                  ),
                  initialValue: t('Shared', 'مشترك'),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: t('Amount (EGP)', 'المبلغ (EGP)'),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {},
                  child: Text(t('Review local plan', 'مراجعة الخطة المحلية')),
                ),
              ],
            ),
          );
        } else if (preset == 'taskRail') {
          UiGallerySheet.show<void>(
            context: owner,
            preset: UiGallerySheetPreset.taskRail,
            header: Text(t('Category for this entry', 'فئة هذا القيد')),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t('Groceries', 'مشتريات المنزل')),
                Text(stillAmount(-46875, 'EGP', arabic: ar)),
                const SizedBox(height: 16),
                for (final label in [
                  t('Home', 'المنزل'),
                  t('Transport', 'المواصلات'),
                  t('Other', 'أخرى'),
                ])
                  ListTile(
                    leading: const Icon(Icons.radio_button_off),
                    title: Text(label),
                    onTap: () {},
                  ),
              ],
            ),
          );
        } else if (preset == 'halo') {
          UiGalleryDialog.show<void>(
            context: owner,
            preset: UiGalleryDialogPreset.halo,
            title: t('Keep this transfer plan?', 'حفظ خطة التحويل؟'),
            message:
                '${t('Personal → Shared', 'شخصي ← مشترك')}\n${stillAmount(12550, 'EGP', arabic: ar)}',
            child: Text(
              t(
                'Local draft only. No money moves.',
                'مسودة محلية فقط. لن تُنقل أموال.',
              ),
            ),
            actions: [
              UiGalleryDialogAction(label: t('Cancel', 'إلغاء'), value: null),
              UiGalleryDialogAction(
                label: t('Save local plan', 'حفظ الخطة محليًا'),
                value: null,
                primary: true,
              ),
            ],
          );
        } else if (preset == 'statusBeacon') {
          UiGalleryDialog.show<void>(
            context: owner,
            preset: UiGalleryDialogPreset.statusBeacon,
            result: UiGalleryResult.failure,
            title: t('Could not build the statement', 'تعذّر إعداد الكشف'),
            message: t(
              'The local generator failed. No file was saved.',
              'تعذّر إنشاء المعاينة محليًا. لم يُحفظ أي ملف.',
            ),
            actions: [
              UiGalleryDialogAction(
                label: t('Close and retry export', 'إغلاق وإعادة التصدير'),
                value: null,
                primary: true,
              ),
            ],
          );
        } else {
          progress = ValueNotifier(.5);
          UiGalleryToast.progress(
            owner,
            message: t('Building a local statement', 'إعداد كشف محلي'),
            progress: progress,
            actionLabel: t('Cancel export', 'إلغاء التصدير'),
            onAction: () {},
            progressLabelBuilder: (_) => t('50% of rows', '٥٠٪ من الصفوف'),
          );
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(key),
          matchesGoldenFile('goldens/wallet-pass-a/surfaces/$preset-$env.png'),
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        progress?.dispose();
        debugDisableShadows = true;
      }, tags: 'golden');
    }
  }
}
