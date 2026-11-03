import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

Future<BuildContext> host(
  WidgetTester tester,
  UiGalleryDesignFamily family, {
  required bool rtl,
  required double scale,
  bool signature = true,
}) async {
  tester.view.physicalSize = const Size(480, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  late BuildContext owner;
  final theme = ThemeData(colorSchemeSeed: Colors.teal);
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: theme.copyWith(
        extensions: [
          UiGalleryTheme.family(
            family,
            theme: theme,
            useSignature: signature,
            effects: UiGalleryEffects.cheap,
          ).copyWith(motionIntensity: 0),
        ],
      ),
      builder: (context, child) => Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: child!,
        ),
      ),
      home: Builder(
        builder: (context) {
          owner = context;
          return const Scaffold();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return owner;
}

List<BoxDecoration> boxes(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(find.byType(DecoratedBox))
    .map((w) => w.decoration)
    .whereType<BoxDecoration>()
    .toList();

void main() {
  for (final family in UiGalleryDesignFamily.values) {
    for (final rtl in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        final name = '${family.name} ${rtl ? 'RTL' : 'LTR'} $scale';
        testWidgets('Split Decision consequence lanes / $name', (tester) async {
          final owner = await host(tester, family, rtl: rtl, scale: scale);
          final semantics = tester.ensureSemantics();
          await tester.pump();
          final keep = rtl ? 'متابعة الكتابة' : 'Keep editing';
          final discard = rtl ? 'تجاهل التعديلات' : 'Discard edits';
          final keepOutcome = rtl ? 'لن تفقد كلماتك' : 'Your words stay here';
          final discardOutcome = rtl
              ? 'حذف التعديلات فقط'
              : 'Only unsaved edits are removed';
          final result = UiGalleryDialog.show<String>(
            context: owner,
            preset: UiGalleryDialogPreset.split,
            title: rtl ? 'مغادرة المسودة؟' : 'Leave draft?',
            actions: [
              UiGalleryDialogAction(
                label: keep,
                value: 'keep',
                primary: true,
                description: keepOutcome,
              ),
              UiGalleryDialogAction(
                label: discard,
                value: 'discard',
                destructive: true,
                description: discardOutcome,
              ),
            ],
          );
          await tester.pumpAndSettle();
          expect(find.text(keepOutcome), findsOneWidget);
          expect(find.text(discardOutcome), findsOneWidget);
          final safe = find.widgetWithText(TextButton, keep);
          final destructive = find.widgetWithText(TextButton, discard);
          expect(tester.getSemantics(safe).flagsCollection.isButton, isTrue);
          expect(
            tester
                .getSemantics(safe)
                .getSemanticsData()
                .hasAction(ui.SemanticsAction.tap),
            isTrue,
          );
          expect(
            tester.getSemantics(destructive).flagsCollection.isEnabled ==
                ui.Tristate.isTrue,
            isTrue,
          );
          final colors = Theme.of(owner).colorScheme;
          final lanes = boxes(tester)
              .where(
                (b) =>
                    b.border is BorderDirectional &&
                    (b.border! as BorderDirectional).start.width ==
                        UiGalleryTokens.lineWidth * 2,
              )
              .toList();
          expect(lanes.length, 2);
          expect(lanes.any((b) => b.color == colors.errorContainer), isFalse);
          expect(
            lanes.where(
              (b) =>
                  (b.border! as BorderDirectional).start.color == colors.error,
            ),
            hasLength(1),
          );
          expect(
            tester
                .widget<TextButton>(destructive)
                .style!
                .foregroundColor!
                .resolve({}),
            colors.error,
          );
          expect(lanes.every((b) => b.boxShadow == null), isTrue);
          await tester.ensureVisible(destructive);
          await tester.pumpAndSettle();
          expect(
            tester.getRect(destructive).top,
            greaterThan(tester.getRect(safe).bottom),
          );
          await tester.tap(destructive);
          await tester.pumpAndSettle();
          expect(await result, 'discard');
          expect(tester.takeException(), isNull);
          semantics.dispose();
        });
        testWidgets('Layered Shelf destination bays / $name', (tester) async {
          final owner = await host(tester, family, rtl: rtl, scale: scale);
          final theme = Theme.of(owner);
          final media = MediaQuery.of(owner);
          final labels = rtl
              ? ['الملاحظات', 'الدفاتر', 'المحفوظات']
              : ['Notes', 'Notebooks', 'Saved'];
          var selected = 0;
          await tester.pumpWidget(
            MaterialApp(
              key: UniqueKey(),
              theme: theme,
              builder: (context, child) => Directionality(
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                child: MediaQuery(data: media, child: child!),
              ),
              home: StatefulBuilder(
                builder: (context, update) => Scaffold(
                  bottomNavigationBar: UiGalleryBottomNav(
                    preset: UiGalleryBottomNavPreset.layeredShelf,
                    selectedIndex: selected,
                    onDestinationSelected: (i) => update(() => selected = i),
                    items: [
                      for (var i = 0; i < labels.length; i++)
                        UiGalleryBottomNavItem(
                          icon: const Icon(Icons.book_outlined),
                          label: labels[i],
                          enabled: i != 2,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final semantics = tester.ensureSemantics();
          await tester.pump();
          Finder target(int i) => find.byTooltip(labels[i]);
          SemanticsNode node(int i) {
            SemanticsNode? found;
            void visit(SemanticsNode n) {
              if (n.label == labels[i]) found = n;
              n.visitChildren((child) {
                visit(child);
                return true;
              });
            }

            visit(tester.getSemantics(target(i)));
            return found!;
          }

          expect(
            node(0).flagsCollection.isSelected == ui.Tristate.isTrue,
            isTrue,
          );
          expect(node(1).flagsCollection.isButton, isTrue);
          expect(
            node(2).flagsCollection.isEnabled == ui.Tristate.isTrue,
            isFalse,
          );
          expect(
            tester.getCenter(target(0)).dx < tester.getCenter(target(1)).dx,
            !rtl,
          );
          for (var i = 0; i < 3; i++) {
            expect(
              tester.getSize(target(i)).shortestSide,
              greaterThanOrEqualTo(48),
            );
          }
          final bays = boxes(tester)
              .where(
                (b) =>
                    b.border is Border &&
                    (b.border! as Border).left.width ==
                        UiGalleryTokens.lineWidth &&
                    b.borderRadius == null &&
                    b.color != null,
              )
              .toList();
          expect(bays.length, 3);
          expect(
            bays
                .where(
                  (b) =>
                      (b.border! as Border).top.width ==
                      UiGalleryTokens.accentWidth,
                )
                .length,
            1,
          );
          // The registered top rule and exposed rear shelf exist without shadows.
          expect(bays.every((b) => b.boxShadow == null), isTrue);
          expect(
            boxes(tester).any(
              (b) =>
                  b.color == theme.colorScheme.primary.withValues(alpha: .14),
            ),
            isTrue,
          );
          await tester.tap(target(1));
          await tester.pumpAndSettle();
          expect(selected, 1);
          expect(
            node(1).flagsCollection.isSelected == ui.Tristate.isTrue,
            isTrue,
          );
          expect(
            node(0).flagsCollection.isSelected == ui.Tristate.isTrue,
            isFalse,
          );
          await tester.tap(target(2));
          await tester.pumpAndSettle();
          expect(selected, 1);
          expect(tester.takeException(), isNull);
          semantics.dispose();
        });
      }
    }
  }
  testWidgets('Split Decision opt-out preserves the old action composition', (
    tester,
  ) async {
    final owner = await host(
      tester,
      UiGalleryDesignFamily.soft,
      rtl: false,
      scale: 1,
      signature: false,
    );
    UiGalleryDialog.show<void>(
      context: owner,
      preset: UiGalleryDialogPreset.split,
      title: 'Choice',
      actions: const [
        UiGalleryDialogAction(
          label: 'Continue',
          value: null,
          description: 'Consequence copy for opted-in lanes',
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Consequence copy for opted-in lanes'), findsNothing);
    expect(find.widgetWithText(TextButton, 'Continue'), findsOneWidget);
  });
  testWidgets('Layered Shelf opt-out has no destination-bay borders', (
    tester,
  ) async {
    final owner = await host(
      tester,
      UiGalleryDesignFamily.soft,
      rtl: false,
      scale: 1,
      signature: false,
    );
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        theme: Theme.of(owner),
        home: Scaffold(
          bottomNavigationBar: UiGalleryBottomNav(
            preset: UiGalleryBottomNavPreset.layeredShelf,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            items: const [
              UiGalleryBottomNavItem(icon: Icon(Icons.home), label: 'Home'),
              UiGalleryBottomNavItem(icon: Icon(Icons.book), label: 'Books'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      boxes(tester).where(
        (b) =>
            b.border is Border &&
            (b.border! as Border).top.width == UiGalleryTokens.accentWidth,
      ),
      isEmpty,
    );
  });
}
