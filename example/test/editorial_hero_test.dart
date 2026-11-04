import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

import 'dialog_heroes_test.dart' as host;
import 'notes_fonts.dart';

const _title = ValueKey('editorial-hero-title');
const _subtitle = ValueKey('editorial-hero-subtitle');

UiGalleryAppBar editorialHero({
  bool ar = false,
  VoidCallback? onAction,
  VoidCallback? onBack,
  UiGallerySurfaceStyle? style,
}) => UiGalleryAppBar(
  preset: UiGalleryAppBarPreset.editorialTopbar,
  style: style,
  title: Text(ar ? 'ملاحظات ميدانية' : 'Field notes', key: _title),
  subtitle: Text(ar ? 'أسبوعك في لمحة' : 'YOUR WEEK IN VIEW', key: _subtitle),
  leading: onBack == null
      ? null
      : IconButton(
          tooltip: 'Back to collection',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
  actions: [
    IconButton(
      tooltip: 'New note',
      onPressed: onAction ?? () {},
      icon: const Icon(Icons.add),
    ),
  ],
);

void main() {
  setUpAll(loadNotesFonts);
  for (final family in UiGalleryDesignFamily.values) {
    for (final scenario in [
      'light',
      'dark',
      'compact',
      'rtl-large',
      'rtl-extreme',
    ]) {
      testWidgets(
        'Editorial ${family.name} $scenario readable copy and stable action',
        (tester) async {
          final semantics = tester.ensureSemantics();
          try {
            final ar = scenario.startsWith('rtl');
            var callbacks = 0;
            await host.hostDialogHero(
              tester,
              family,
              scenario == 'rtl-extreme' ? 'rtl-large' : scenario,
              GlobalKey(),
              textScale: scenario == 'rtl-extreme' ? 3 : null,
              home: (_) => Scaffold(
                appBar: editorialHero(ar: ar, onAction: () => callbacks++),
              ),
            );
            final bar = find.byType(UiGalleryAppBar);
            if (scenario == 'rtl-large') {
              final titleRect = tester.getRect(find.byKey(_title));
              final barRect = tester.getRect(bar);
              expect(titleRect.top, greaterThanOrEqualTo(barRect.top));
              expect(titleRect.bottom, lessThanOrEqualTo(barRect.bottom));
            }
            expect(
              tester.widget<UiGalleryAppBar>(bar).preferredSize.height,
              128,
            );
            final paragraph = tester.renderObject<RenderParagraph>(
              find.byKey(_title),
            );
            expect(paragraph.didExceedMaxLines, isFalse);
            expect(paragraph.overflow, isNot(TextOverflow.ellipsis));
            expect(
              paragraph.text.toPlainText(),
              ar ? 'ملاحظات ميدانية' : 'Field notes',
            );
            final subtitle = tester.renderObject<RenderParagraph>(
              find.byKey(_subtitle),
            );
            expect(subtitle.didExceedMaxLines, isFalse);
            for (final word in paragraph.text.toPlainText().split(' ')) {
              final painter = TextPainter(
                text: TextSpan(text: word, style: paragraph.text.style),
                textDirection: paragraph.textDirection,
                textScaler: paragraph.textScaler,
              )..layout();
              expect(
                paragraph.size.width + .01,
                greaterThanOrEqualTo(painter.width),
              );
              painter.dispose();
            }
            final heading = tester.getSemantics(find.byKey(_title));
            expect(heading.flagsCollection.isHeader, isTrue);
            expect(heading.label, ar ? 'ملاحظات ميدانية' : 'Field notes');
            final action = find.byTooltip('New note');
            expect(action.hitTestable(), findsOneWidget);
            final actionRect = tester.getRect(action);
            expect(actionRect.width, greaterThanOrEqualTo(48));
            expect(actionRect.height, greaterThanOrEqualTo(48));
            expect(actionRect.top, greaterThanOrEqualTo(0));
            expect(actionRect.bottom, lessThanOrEqualTo(128));
            await tester.tap(action);
            await tester.pumpAndSettle();
            expect(callbacks, 1);
            if (scenario == 'rtl-extreme') {
              final vertical = tester
                  .stateList<ScrollableState>(
                    find.descendant(of: bar, matching: find.byType(Scrollable)),
                  )
                  .where((state) => state.position.axis == Axis.vertical)
                  .single;
              expect(vertical.position.maxScrollExtent, greaterThan(0));
              final before = vertical.position.pixels;
              await tester.drag(
                find.byWidget(vertical.widget),
                const Offset(0, -100),
              );
              await tester.pumpAndSettle();
              expect(vertical.position.pixels, greaterThan(before));
              expect(tester.getRect(action), actionRect);
            }
            expect(tester.takeException(), isNull);
          } finally {
            semantics.dispose();
          }
        },
      );
    }
  }

  testWidgets('Editorial explicit typography and shape remain authoritative', (
    tester,
  ) async {
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(9)),
    );
    await host.hostDialogHero(
      tester,
      UiGalleryDesignFamily.soft,
      'light',
      GlobalKey(),
      home: (_) => Scaffold(
        appBar: editorialHero(
          style: const UiGallerySurfaceStyle(
            titleStyle: TextStyle(
              fontSize: 19,
              color: Colors.deepPurple,
              fontFamily: 'MarginArabic',
            ),
            messageStyle: TextStyle(fontSize: 15, color: Colors.teal),
            padding: EdgeInsets.all(8),
            maxWidth: 280,
            shape: shape,
          ),
        ),
      ),
    );
    final title = tester.renderObject<RenderParagraph>(find.byKey(_title));
    final subtitle = tester.renderObject<RenderParagraph>(
      find.byKey(_subtitle),
    );
    expect(title.text.style!.fontSize, 19);
    expect(title.text.style!.color, Colors.deepPurple);
    expect(title.text.style!.fontFamily, 'MarginArabic');
    expect(subtitle.text.style!.fontSize, 15);
    expect(subtitle.text.style!.color, Colors.teal);
    expect(
      tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .any(
            (widget) =>
                widget.decoration is ShapeDecoration &&
                (widget.decoration! as ShapeDecoration).shape == shape,
          ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editorial signature-off keeps its existing headline role', (
    tester,
  ) async {
    final owner = await host.hostDialogHero(
      tester,
      UiGalleryDesignFamily.soft,
      'light',
      GlobalKey(),
      signature: false,
      home: (_) => Scaffold(appBar: editorialHero()),
    );
    final title = tester.renderObject<RenderParagraph>(find.byKey(_title));
    expect(
      title.text.style!.fontSize,
      Theme.of(owner).textTheme.headlineMedium!.fontSize,
    );
    expect(title.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Editorial copy scrolling stays separate from the primary page controller',
    (tester) async {
      final pageController = ScrollController();
      addTearDown(pageController.dispose);
      await host.hostDialogHero(
        tester,
        UiGalleryDesignFamily.soft,
        'rtl-large',
        GlobalKey(),
        textScale: 3,
        home: (_) => PrimaryScrollController(
          controller: pageController,
          child: Scaffold(
            appBar: const UiGalleryAppBar(
              preset: UiGalleryAppBarPreset.editorialTopbar,
              scrollAware: true,
              title: Text('ملاحظات ميدانية', key: _title),
              subtitle: Text('أسبوعك في لمحة', key: _subtitle),
            ),
            body: ListView(
              primary: true,
              children: const [SizedBox(height: 2000)],
            ),
          ),
        ),
      );
      expect(pageController.positions, hasLength(1));
      final pageOffset = pageController.offset;
      final initialTitle = tester.renderObject<RenderParagraph>(
        find.byKey(_title),
      );
      final initialTitleSize = initialTitle.text.style!.fontSize;
      final bar = find.byType(UiGalleryAppBar);
      final copyScroll = tester
          .stateList<ScrollableState>(
            find.descendant(of: bar, matching: find.byType(Scrollable)),
          )
          .where((state) => state.position.axis == Axis.vertical)
          .single;
      expect(copyScroll.position.maxScrollExtent, greaterThan(0));
      await tester.drag(
        find.byWidget(copyScroll.widget),
        const Offset(0, -120),
      );
      await tester.pumpAndSettle();
      expect(copyScroll.position.pixels, greaterThan(0));
      expect(pageController.positions, hasLength(1));
      expect(pageController.offset, pageOffset);
      expect(find.byKey(_subtitle), findsOneWidget);
      final afterCopyScroll = tester.renderObject<RenderParagraph>(
        find.byKey(_title),
      );
      expect(afterCopyScroll.text.style!.fontSize, initialTitleSize);
      expect(afterCopyScroll.overflow, isNot(TextOverflow.ellipsis));

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(pageController.offset, greaterThan(100));
      expect(pageController.positions, hasLength(1));
      expect(find.byKey(_subtitle), findsNothing);
      expect(
        tester.renderObject<RenderParagraph>(find.byKey(_title)).overflow,
        TextOverflow.ellipsis,
      );
      pageController.jumpTo(0);
      await tester.pumpAndSettle();
      expect(find.byKey(_subtitle), findsOneWidget);
      expect(
        tester
            .renderObject<RenderParagraph>(find.byKey(_title))
            .text
            .style!
            .fontSize,
        initialTitleSize,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(pageController.hasClients, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Editorial keyboard navigation, sliver collapse and reopening remain usable',
    (tester) async {
      var actions = 0;
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await host.hostDialogHero(
        tester,
        UiGalleryDesignFamily.spatial,
        'rtl-large',
        GlobalKey(),
        home: (_) => Scaffold(
          body: CustomScrollView(
            controller: controller,
            slivers: [
              UiGallerySliverAppBar(
                preset: UiGalleryAppBarPreset.editorialTopbar,
                title: const Text('ملاحظات ميدانية'),
                subtitle: const Text('أسبوعك في لمحة'),
                actions: [
                  IconButton(
                    tooltip: 'New note',
                    onPressed: () => actions++,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 1600)),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(actions, 1);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.byTooltip('New note').hitTestable(), findsOneWidget);
      await tester.tap(find.byTooltip('New note'));
      expect(actions, 2);
      expect(controller.hasClients, isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(controller.hasClients, isFalse);
      for (var iteration = 0; iteration < 2; iteration++) {
        await host.hostDialogHero(
          tester,
          UiGalleryDesignFamily.soft,
          'light',
          GlobalKey(),
          home: (_) => Scaffold(
            appBar: UiGalleryAppBar(
              preset: UiGalleryAppBarPreset.editorialTopbar,
              scrollAware: true,
              title: const Text('Field notes'),
              actions: [
                IconButton(
                  tooltip: 'New note',
                  onPressed: () => actions++,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            body: ListView(children: const [SizedBox(height: 1500)]),
          ),
        );
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('New note'));
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(actions, 4);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
}
