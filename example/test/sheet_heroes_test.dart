import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'dialog_heroes_test.dart' as host;
import 'notes_fonts.dart';

const sheetHeroScenarios = [
  'light',
  'dark',
  'rtl',
  'large-text',
  'compact',
  'rtl-large',
  'keyboard',
  'wide',
  'landscape',
];

Future<String?> openSheetHero(
  BuildContext owner,
  UiGallerySheetPreset preset, {
  bool ar = false,
  bool scrollingList = false,
}) {
  String t(String en, String arabic) => ar ? arabic : en;
  return UiGallerySheet.show<String>(
    context: owner,
    preset: preset,
    semanticLabel: t('Edit saved idea', 'تعديل الفكرة المحفوظة'),
    header: Text(t('Keep this thought', 'احتفظ بهذه الفكرة')),
    secondary: preset == UiGallerySheetPreset.splitLayer
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('Personal notebook', 'دفتر شخصي'),
                style: Theme.of(owner).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                t(
                  'Local draft. Nothing is shared.',
                  'مسودة محلية. لا تتم مشاركة شيء.',
                ),
              ),
            ],
          )
        : null,
    scrollable: !scrollingList,
    footer: Builder(
      builder: (context) => FilledButton(
        onPressed: () => Navigator.of(context).pop('saved'),
        child: Text(t('Save draft', 'حفظ المسودة')),
      ),
    ),
    child: scrollingList
        ? ListView.builder(
            itemCount: 40,
            itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
          )
        : _Draft(ar: ar),
  );
}

class _Draft extends StatefulWidget {
  const _Draft({required this.ar});
  final bool ar;
  @override
  State<_Draft> createState() => _DraftState();
}

class _DraftState extends State<_Draft> {
  late final controller = TextEditingController(
    text: widget.ar ? 'فكرة تستحق الاحتفاظ بها' : 'A thought worth keeping',
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        widget.ar
            ? 'احفظ فكرة مفيدة في مجموعتك الشخصية.'
            : 'Save a useful idea to your personal collection.',
      ),
      const SizedBox(height: 16),
      TextField(
        key: const ValueKey('sheet-draft'),
        controller: controller,
        decoration: InputDecoration(
          labelText: widget.ar ? 'عنوان الملاحظة' : 'Note title',
        ),
      ),
      const SizedBox(height: 16),
      Text(
        widget.ar
            ? 'تبقى المسودة على هذا الجهاز حتى تحفظها.'
            : 'Your draft stays on this device until you save it.',
      ),
    ],
  );
}

void main() {
  setUpAll(loadNotesFonts);
  for (final preset in [
    UiGallerySheetPreset.orbit,
    UiGallerySheetPreset.splitLayer,
  ]) {
    for (final family in UiGalleryDesignFamily.values) {
      testWidgets(
        '${preset.name} ${family.name} extreme RTL and focus traversal',
        (tester) async {
          final owner = await host.hostDialogHero(
            tester,
            family,
            'rtl-large',
            GlobalKey(),
            textScale: 3,
          );
          tester.view.physicalSize = const Size(320, 620);
          tester.view.viewInsets = const FakeViewPadding(bottom: 250);
          final result = openSheetHero(owner, preset, ar: true);
          await tester.pumpAndSettle();
          final field = find.byKey(const ValueKey('sheet-draft'));
          await tester.ensureVisible(field);
          await tester.pumpAndSettle();
          await tester.tap(field);
          await tester.pumpAndSettle();
          await tester.enterText(field, 'Retained through keyboard change');
          tester.view.viewInsets = const FakeViewPadding();
          await tester.pumpAndSettle();
          expect(find.text('Retained through keyboard change'), findsOneWidget);
          tester.view.viewInsets = const FakeViewPadding(bottom: 250);
          await tester.pumpAndSettle();
          expect(find.text('Retained through keyboard change'), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(find.byType(TextField), findsNothing);
          expect(await result, 'saved');
          expect(tester.takeException(), isNull);
        },
      );
      for (final scenario in sheetHeroScenarios) {
        testWidgets(
          '${preset.name} ${family.name} $scenario retains draft and result',
          (tester) async {
            final owner = await host.hostDialogHero(
              tester,
              family,
              scenario,
              GlobalKey(),
            );
            final ar = scenario.startsWith('rtl');
            final result = openSheetHero(owner, preset, ar: ar);
            await tester.pumpAndSettle();
            final save = find.text(ar ? 'حفظ المسودة' : 'Save draft');
            expect(save.hitTestable(), findsOneWidget);
            await tester.ensureVisible(
              find.byKey(const ValueKey('sheet-draft')),
            );
            await tester.pumpAndSettle();
            await tester.enterText(find.byType(TextField), 'Retained draft');
            tester.view.physicalSize = const Size(900, 1000);
            await tester.pumpAndSettle();
            expect(find.text('Retained draft'), findsOneWidget);
            tester.view.physicalSize = const Size(320, 640);
            await tester.pumpAndSettle();
            expect(find.text('Retained draft'), findsOneWidget);
            await tester.ensureVisible(save);
            await tester.pumpAndSettle();
            await tester.tap(save);
            await tester.pumpAndSettle();
            expect(await result, 'saved');
            final again = openSheetHero(owner, preset, ar: ar);
            await tester.pumpAndSettle();
            expect(find.text('Retained draft'), findsNothing);
            await tester.binding.handlePopRoute();
            await tester.pumpAndSettle();
            expect(await again, isNull);
            expect(tester.takeException(), isNull);
          },
        );
      }
      testWidgets(
        '${preset.name} ${family.name} self-scrolling content and keyboard',
        (tester) async {
          final owner = await host.hostDialogHero(
            tester,
            family,
            'keyboard',
            GlobalKey(),
          );
          final result = openSheetHero(owner, preset, scrollingList: true);
          await tester.pumpAndSettle();
          await tester.drag(find.byType(ListView), const Offset(0, -700));
          await tester.pumpAndSettle();
          expect(find.text('Item 0'), findsNothing);
          final position = tester
              .state<ScrollableState>(
                find.descendant(
                  of: find.byType(ListView),
                  matching: find.byType(Scrollable),
                ),
              )
              .position;
          final offset = position.pixels;
          tester.view.physicalSize = const Size(900, 1000);
          await tester.pumpAndSettle();
          expect(
            tester
                .state<ScrollableState>(
                  find.descendant(
                    of: find.byType(ListView),
                    matching: find.byType(Scrollable),
                  ),
                )
                .position,
            same(position),
          );
          expect(position.pixels, offset);
          tester.view.physicalSize = const Size(320, 640);
          await tester.pumpAndSettle();
          expect(position.pixels, offset);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Save draft'));
          await tester.pumpAndSettle();
          expect(await result, 'saved');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  for (final preset in [
    UiGallerySheetPreset.orbit,
    UiGallerySheetPreset.splitLayer,
  ]) {
    for (final family in UiGalleryDesignFamily.values) {
      for (final env in ['light', 'dark', 'rtl', 'large-text']) {
        testWidgets('${preset.name} ${family.name} $env sheet calm specimen', (
          tester,
        ) async {
          verifyNotesPins();
          debugDisableShadows = false;
          try {
            final key = GlobalKey();
            final owner = await host.hostDialogHero(tester, family, env, key);
            openSheetHero(owner, preset, ar: env == 'rtl');
            await tester.pumpAndSettle();
            await expectLater(
              find.byKey(key),
              matchesGoldenFile(
                'goldens/sheet-calm-v1/${preset.name}/${family.name}-$env.png',
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
}
