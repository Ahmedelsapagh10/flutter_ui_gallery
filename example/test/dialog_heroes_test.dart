import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'notes_fonts.dart';

const dialogHeroScenarios = [
  'light',
  'dark',
  'rtl',
  'large-text',
  'compact',
  'rtl-large',
  'keyboard',
  'wide',
  'rtl-wide',
  'landscape',
];

Future<BuildContext> hostDialogHero(
  WidgetTester tester,
  UiGalleryDesignFamily family,
  String scenario,
  GlobalKey boundary, {
  bool signature = true,
  double? textScale,
}) async {
  final ar = scenario.startsWith('rtl');
  tester.view.physicalSize = switch (scenario) {
    'compact' || 'rtl-large' => const Size(320, 640),
    'keyboard' => const Size(320, 640),
    'wide' || 'rtl-wide' => const Size(900, 1000),
    'landscape' => const Size(760, 420),
    _ => const Size(420, 800),
  };
  tester.view.devicePixelRatio = 1;
  tester.view.viewInsets = FakeViewPadding(
    bottom: scenario == 'keyboard' ? 250 : 0,
  );
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
  final base = ThemeData(
    fontFamily: ar ? 'MarginArabic' : 'Roboto',
    colorSchemeSeed: const Color(0xff455a64),
    brightness: scenario == 'dark' ? Brightness.dark : Brightness.light,
  );
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
              useSignature: signature,
            ).copyWith(motionIntensity: 0),
          ],
        ),
        locale: Locale(ar ? 'ar' : 'en'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(
              textScale ??
                  (['large-text', 'rtl-large', 'keyboard'].contains(scenario)
                      ? 2
                      : 1),
            ),
          ),
          child: child!,
        ),
        home: Builder(
          builder: (context) {
            owner = context;
            return const Scaffold();
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return owner;
}

Future<int?> openDialogHero(
  BuildContext context,
  UiGalleryDialogPreset preset, {
  bool ar = false,
  bool disabled = false,
  UiGalleryActionLayout? actionLayout,
  bool barrierDismissible = true,
}) {
  String t(String en, String arabic) => ar ? arabic : en;
  final split = preset == UiGalleryDialogPreset.split;
  return UiGalleryDialog.show<int>(
    context: context,
    preset: preset,
    title: split
        ? t('Leave this draft?', 'هل تريد مغادرة المسودة؟')
        : t('Choose your space', 'اختر مساحة عملك'),
    message: split
        ? t(
            'Your edits have not been saved in this session.',
            'لم تُحفظ تعديلاتك في هذه الجلسة بعد.',
          )
        : t(
            'Keep a personal collection or share with your team.',
            'احتفظ بمجموعة شخصية أو شاركها مع فريقك.',
          ),
    actionLayout: actionLayout,
    barrierDismissible: barrierDismissible,
    actions: [
      UiGalleryDialogAction(
        label: split
            ? t('Keep editing', 'متابعة الكتابة')
            : t('Personal', 'شخصي'),
        description: split
            ? t(
                'Return to your words. Nothing is lost.',
                'عُد إلى كلماتك دون فقدان أي تعديل.',
              )
            : t(
                'A private space for your own projects.',
                'مساحة خاصة لمشروعاتك الشخصية.',
              ),
        value: 1,
        enabled: !disabled,
        primary: split,
        icon: Icon(split ? Icons.edit_outlined : Icons.person_outline),
      ),
      UiGalleryDialogAction(
        label: split
            ? t('Discard changes', 'تجاهل التعديلات')
            : t('Team', 'فريق'),
        description: split
            ? t(
                'Only these unsaved edits will be removed.',
                'ستُحذف هذه التعديلات غير المحفوظة فقط.',
              )
            : t(
                'Share collections with collaborators.',
                'شارك مجموعاتك مع المتعاونين.',
              ),
        value: 2,
        destructive: split,
        primary: !split,
        icon: Icon(split ? Icons.undo : Icons.groups_outlined),
      ),
    ],
  );
}

void main() {
  setUpAll(loadNotesFonts);
  for (final preset in [
    UiGalleryDialogPreset.split,
    UiGalleryDialogPreset.sideBySideChoice,
  ]) {
    for (final family in UiGalleryDesignFamily.values) {
      for (final scenario in dialogHeroScenarios) {
        testWidgets(
          '${preset.name} ${family.name} $scenario reachable typed choice',
          (tester) async {
            final semantics = tester.ensureSemantics();
            try {
              final owner = await hostDialogHero(
                tester,
                family,
                scenario,
                GlobalKey(),
              );
              final ar = scenario.startsWith('rtl');
              final result = openDialogHero(owner, preset, ar: ar);
              await tester.pumpAndSettle();
              final first = find.text(
                preset == UiGalleryDialogPreset.split
                    ? (ar ? 'متابعة الكتابة' : 'Keep editing')
                    : (ar ? 'شخصي' : 'Personal'),
              );
              final second = find.text(
                preset == UiGalleryDialogPreset.split
                    ? (ar ? 'تجاهل التعديلات' : 'Discard changes')
                    : (ar ? 'فريق' : 'Team'),
              );
              if (scenario == 'wide' || scenario == 'rtl-wide') {
                Finder target(Finder label) => find
                    .ancestor(of: label, matching: find.byType(InkWell))
                    .first;
                final a = tester.getRect(target(first));
                final b = tester.getRect(target(second));
                expect(a.left < b.left, !ar);
                expect(a.width, closeTo(b.width, .01));
                if (preset == UiGalleryDialogPreset.sideBySideChoice) {
                  expect(a.height, closeTo(b.height, .01));
                  expect(a.top, closeTo(b.top, .01));
                }
              }
              if (scenario == 'light' || scenario == 'dark') {
                expect(first.hitTestable(), findsOneWidget);
                expect(second.hitTestable(), findsOneWidget);
              }
              await tester.ensureVisible(second);
              await tester.pumpAndSettle();
              final node = tester.getSemantics(second);
              expect(node.flagsCollection.isButton, isTrue);
              expect(node.flagsCollection.isEnabled, ui.Tristate.isTrue);
              final button = find
                  .ancestor(of: second, matching: find.byType(InkWell))
                  .first;
              final size = tester.getSize(button);
              expect(size.width, greaterThanOrEqualTo(48));
              expect(size.height, greaterThanOrEqualTo(48));
              await tester.tap(second);
              await tester.pumpAndSettle();
              expect(find.byType(Dialog), findsNothing);
              expect(await result, 2);
              expect(find.byType(Dialog), findsNothing);
              expect(tester.takeException(), isNull);
            } finally {
              semantics.dispose();
            }
          },
        );
      }
      testWidgets(
        '${preset.name} ${family.name} disabled and keyboard traversal',
        (tester) async {
          final owner = await hostDialogHero(
            tester,
            family,
            'rtl-large',
            GlobalKey(),
          );
          var result = openDialogHero(owner, preset, ar: true, disabled: true);
          await tester.pumpAndSettle();
          final disabled = find.text(
            preset == UiGalleryDialogPreset.split ? 'متابعة الكتابة' : 'شخصي',
          );
          await tester.ensureVisible(disabled);
          await tester.pumpAndSettle();
          await tester.tap(disabled);
          await tester.pumpAndSettle();
          expect(find.byType(Dialog), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(find.byType(Dialog), findsNothing);
          expect(await result, 2);
          result = openDialogHero(owner, preset, ar: true);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          final before = FocusManager.instance.primaryFocus;
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          expect(FocusManager.instance.primaryFocus, isNot(same(before)));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pumpAndSettle();
          expect(FocusManager.instance.primaryFocus, same(before));
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(find.byType(Dialog), findsNothing);
          expect(await result, isNull);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  for (final preset in [
    UiGalleryDialogPreset.split,
    UiGalleryDialogPreset.sideBySideChoice,
  ]) {
    for (final layout in [null, ...UiGalleryActionLayout.values]) {
      testWidgets(
        '${preset.name} signature-off layout=$layout and dismissal contract',
        (tester) async {
          final owner = await hostDialogHero(
            tester,
            UiGalleryDesignFamily.soft,
            'light',
            GlobalKey(),
            signature: false,
          );
          final result = openDialogHero(
            owner,
            preset,
            actionLayout: layout,
            barrierDismissible: false,
          );
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(find.byType(Dialog), findsOneWidget);
          final first = find.text(
            preset == UiGalleryDialogPreset.split ? 'Keep editing' : 'Personal',
          );
          await tester.ensureVisible(first);
          await tester.pumpAndSettle();
          await tester.tap(first);
          await tester.pumpAndSettle();
          expect(await result, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  for (final family in UiGalleryDesignFamily.values) {
    for (final env in ['light', 'dark', 'rtl', 'large-text']) {
      testWidgets('Choice ${family.name} $env versioned specimen', (
        tester,
      ) async {
        verifyNotesPins();
        debugDisableShadows = false;
        try {
          final key = GlobalKey();
          final owner = await hostDialogHero(tester, family, env, key);
          openDialogHero(
            owner,
            UiGalleryDialogPreset.sideBySideChoice,
            ar: env == 'rtl',
          );
          await tester.pumpAndSettle();
          await expectLater(
            find.byKey(key),
            matchesGoldenFile(
              'goldens/dialog-calm-v1/sideBySideChoice/${family.name}-$env.png',
            ),
          );
          expect(tester.takeException(), isNull);
        } finally {
          debugDisableShadows = true;
        }
      }, tags: 'golden');
    }
  }
}
