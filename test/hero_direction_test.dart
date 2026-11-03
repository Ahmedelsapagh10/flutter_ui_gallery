import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:flutter_ui_gallery/src/core/gallery_signature.dart';
import 'package:flutter_ui_gallery/src/core/gallery_theme.dart'
    show UiGalleryStyle, UiGallerySurface;

Future<BuildContext> _host(
  WidgetTester tester, {
  UiGalleryDesignFamily family = UiGalleryDesignFamily.soft,
  Brightness brightness = Brightness.light,
  Color seed = Colors.blueGrey,
  bool signature = true,
  bool rtl = false,
  double scale = 1,
  double keyboard = 0,
  ValueNotifier<double>? liveScale,
  Widget Function(BuildContext)? home,
}) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
  final base = ThemeData(
    colorSchemeSeed: seed,
    brightness: brightness,
    fontFamily: rtl ? 'HeroArabic' : 'Roboto',
  );
  late BuildContext owner;
  await tester.pumpWidget(
    MaterialApp(
      theme: base.copyWith(
        extensions: [
          UiGalleryTheme.family(family, theme: base, useSignature: signature),
        ],
      ),
      builder: (context, child) {
        Widget media(double value) => Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(value)),
            child: child!,
          ),
        );
        return liveScale == null
            ? media(scale)
            : ValueListenableBuilder<double>(
                valueListenable: liveScale,
                builder: (context, value, _) => media(value),
              );
      },
      home: Builder(
        builder: (context) {
          owner = context;
          return home?.call(context) ?? const Scaffold();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return owner;
}

List<UiGalleryBottomNavItem> _items({
  bool rtl = false,
  bool disabled = false,
}) => [
  UiGalleryBottomNavItem(
    icon: const Icon(Icons.notes),
    label: rtl ? 'الملاحظات' : 'Notes',
  ),
  UiGalleryBottomNavItem(
    icon: const Icon(Icons.book),
    label: rtl ? 'الدفاتر' : 'Notebooks',
  ),
  UiGalleryBottomNavItem(
    icon: const Icon(Icons.bookmark_outline),
    label: rtl ? 'المحفوظات' : 'Saved',
    enabled: !disabled,
  ),
];

UiGalleryBottomNav _nav({
  int selected = 1,
  bool rtl = false,
  bool disabled = false,
  ValueChanged<int>? changed,
  UiGalleryBottomNavOptions options = const UiGalleryBottomNavOptions(),
}) => UiGalleryBottomNav(
  preset: UiGalleryBottomNavPreset.morphingCapsule,
  selectedIndex: selected,
  onDestinationSelected: changed ?? (_) {},
  items: _items(rtl: rtl, disabled: disabled),
  options: options,
);

List<UiGalleryDialogAction<String>> _commands({bool rtl = false}) => [
  UiGalleryDialogAction(
    label: rtl ? 'ملاحظة جديدة' : 'New note',
    description: rtl ? 'ابدأ مسودة' : 'Start a draft',
    value: 'new',
    icon: const Icon(Icons.add),
  ),
  UiGalleryDialogAction(
    label: rtl ? 'الأفكار المحفوظة' : 'Saved ideas',
    description: rtl ? 'افتح مجموعتك' : 'Open your collection',
    value: 'saved',
    icon: const Icon(Icons.bookmark_outline),
  ),
  UiGalleryDialogAction(
    label: rtl ? 'أرشفة المجموعة' : 'Archive collection',
    value: 'archive',
    enabled: false,
  ),
];
Future<String?> _launch(BuildContext context, {bool rtl = false}) =>
    UiGalleryDialog.commands<String>(
      context: context,
      title: rtl ? 'ابحث عن أمر' : 'Find a command',
      searchHint: rtl ? 'البحث في الأوامر' : 'Search commands',
      emptyLabel: rtl ? 'لا توجد أوامر مطابقة' : 'No matching commands',
      commands: _commands(rtl: rtl),
    );

double _contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return (x > y ? x + .05 : y + .05) / (x > y ? y + .05 : x + .05);
}

Color _background(WidgetTester tester, Finder text, Color surface) {
  Color? fill;
  tester.element(text).visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is DecoratedBox && widget.decoration is BoxDecoration) {
      final color = (widget.decoration as BoxDecoration).color;
      if (color != null && color.a > 0) {
        fill = color;
        return false;
      }
    }
    return true;
  });
  expect(fill, isNotNull);
  return Color.alphaBlend(fill!, surface);
}

SemanticsNode _node(WidgetTester tester, String label, {bool button = true}) {
  SemanticsNode? result;
  void visit(SemanticsNode node) {
    if (node.label.split('\n').first == label &&
        (!button || node.flagsCollection.isButton)) {
      result = node;
    }
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  expect(result, isNotNull, reason: 'Button semantics for $label');
  return result!;
}

void main() {
  setUpAll(() async {
    await (FontLoader('HeroArabic')..addFont(
          File(
            'example/assets/fonts/Alexandria.ttf',
          ).readAsBytes().then(ByteData.sublistView),
        ))
        .load();
    final config = File('.dart_tool/package_config.json');
    final packages =
        (jsonDecode(config.readAsStringSync())
                as Map<String, dynamic>)['packages']
            as List;
    final flutter = packages.cast<Map<String, dynamic>>().singleWhere(
      (p) => p['name'] == 'flutter',
    );
    final root = config.absolute.uri
        .resolve('${flutter['rootUri']}/')
        .resolve('../../bin/cache/artifacts/material_fonts/');
    await (FontLoader('Roboto')..addFont(
          File.fromUri(
            root.resolve('Roboto-Regular.ttf'),
          ).readAsBytes().then(ByteData.sublistView),
        ))
        .load();
  });
  for (final family in UiGalleryDesignFamily.values) {
    for (final brightness in Brightness.values) {
      for (final seed in [Colors.blueGrey, Colors.teal, Colors.deepPurple]) {
        testWidgets('Capsule contrast $family $brightness $seed', (
          tester,
        ) async {
          final owner = await _host(
            tester,
            family: family,
            brightness: brightness,
            seed: seed,
            home: (_) => Scaffold(bottomNavigationBar: _nav()),
          );
          final label = find.text('Notebooks');
          final paragraph = tester.renderObject<RenderParagraph>(label);
          final colors = UiGalleryStyle.of(
            owner,
            null,
            null,
            null,
            UiGallerySurface.bottomNav,
          );
          final background = _background(tester, label, colors.surface);
          expect(
            _contrast(
              Color.alphaBlend(paragraph.text.style!.color!, background),
              background,
            ),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            paragraph.text.style!.fontSize,
            Theme.of(owner).textTheme.labelMedium!.fontSize,
          );
          expect(find.byType(GalleryFamilyWell), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  for (final rtl in [false, true]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      testWidgets('Capsule compact text and semantics rtl=$rtl scale=$scale', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        try {
          await _host(
            tester,
            rtl: rtl,
            scale: scale,
            home: (_) => Scaffold(bottomNavigationBar: _nav(rtl: rtl)),
          );
          final label = find.text(rtl ? 'الدفاتر' : 'Notebooks');
          final paragraph = tester.renderObject<RenderParagraph>(label);
          expect(paragraph.didExceedMaxLines, isFalse);
          final painter = TextPainter(
            text: paragraph.text,
            textDirection: paragraph.textDirection,
            textScaler: paragraph.textScaler,
          )..layout();
          expect(paragraph.size.width + 1, greaterThanOrEqualTo(painter.width));
          painter.dispose();
          final target = find.byTooltip(rtl ? 'الدفاتر' : 'Notebooks');
          final node = _node(tester, rtl ? 'الدفاتر' : 'Notebooks');
          expect(node.flagsCollection.isSelected, ui.Tristate.isTrue);
          expect(node.label, rtl ? 'الدفاتر' : 'Notebooks');
          expect(tester.getSize(target).width, greaterThanOrEqualTo(48));
          expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      });
    }
  }
  testWidgets(
    'Capsule controlled state, disabled target and interrupted animation',
    (tester) async {
      var selected = 1;
      var disabled = false;
      final events = <int>[];
      late StateSetter update;
      final semantics = tester.ensureSemantics();
      try {
        await _host(
          tester,
          home: (_) => StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Scaffold(
                bottomNavigationBar: _nav(
                  selected: selected,
                  disabled: disabled,
                  changed: events.add,
                ),
              );
            },
          ),
        );
        await tester.tap(find.byTooltip('Saved'));
        await tester.pumpAndSettle();
        expect(events, [2]);
        expect(
          _node(tester, 'Notebooks').flagsCollection.isSelected,
          ui.Tristate.isTrue,
        );
        update(() => selected = 0);
        await tester.pump(const Duration(milliseconds: 60));
        update(() => selected = 2);
        await tester.pump(const Duration(milliseconds: 60));
        update(() {
          selected = 1;
          disabled = true;
        });
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Saved'));
        expect(events, [2]);
        expect(
          _node(tester, 'Saved').flagsCollection.isEnabled,
          ui.Tristate.isFalse,
        );
        expect(
          _node(tester, 'Notebooks').flagsCollection.isSelected,
          ui.Tristate.isTrue,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(events.length, 2);
        expect(events.last, isIn([0, 1]));
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );
  testWidgets('Capsule explicit colors and typography remain authoritative', (
    tester,
  ) async {
    await _host(
      tester,
      home: (_) => Scaffold(
        bottomNavigationBar: _nav(
          options: const UiGalleryBottomNavOptions(
            selectedColor: Colors.purple,
            selectedLabelStyle: TextStyle(color: Colors.orange, fontSize: 19),
          ),
        ),
      ),
    );
    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('Notebooks'),
    );
    expect(paragraph.text.style!.color, Colors.orange);
    expect(paragraph.text.style!.fontSize, 19);
    final icons = tester.widgetList<IconTheme>(find.byType(IconTheme));
    expect(
      icons.any(
        (icon) => icon.data.color?.toARGB32() == Colors.purple.toARGB32(),
      ),
      isTrue,
    );
  });
  for (final signature in [false, true]) {
    testWidgets('Capsule legacy branch is explicit signature=$signature', (
      tester,
    ) async {
      await _host(
        tester,
        signature: signature,
        home: (_) => Scaffold(bottomNavigationBar: _nav()),
      );
      expect(
        find.byType(GalleryFamilyWell),
        signature ? findsNothing : findsOneWidget,
      );
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text('Notebooks'),
      );
      expect(paragraph.text.style!.fontSize, signature ? 12 : 11);
    });
  }
  for (final brightness in Brightness.values) {
    for (final scale in [2.0, 3.0]) {
      for (final keyboard in [0.0, 250.0, 300.0]) {
        testWidgets(
          'Commands readable RTL $brightness scale=$scale keyboard=$keyboard',
          (tester) async {
            final semantics = tester.ensureSemantics();
            try {
              final owner = await _host(
                tester,
                rtl: true,
                brightness: brightness,
                scale: scale,
                keyboard: keyboard,
              );
              final result = _launch(owner, rtl: true);
              await tester.pumpAndSettle();
              expect(
                _node(tester, 'ملاحظة جديدة').flagsCollection.isSelected,
                ui.Tristate.isTrue,
              );
              final label = find.text('ملاحظة جديدة');
              final paragraph = tester.renderObject<RenderParagraph>(label);
              final painter = TextPainter(
                text: paragraph.text,
                textDirection: paragraph.textDirection,
                textScaler: paragraph.textScaler,
              )..layout(maxWidth: paragraph.size.width);
              expect(painter.computeLineMetrics().length, lessThanOrEqualTo(2));
              painter.dispose();
              for (final word in ['ملاحظة', 'جديدة']) {
                final wordPainter = TextPainter(
                  text: TextSpan(text: word, style: paragraph.text.style),
                  textDirection: TextDirection.rtl,
                  textScaler: paragraph.textScaler,
                )..layout();
                expect(
                  paragraph.size.width + 1,
                  greaterThanOrEqualTo(wordPainter.width),
                );
                wordPainter.dispose();
              }
              expect(find.text('ابدأ مسودة'), findsOneWidget);
              await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
              await tester.pumpAndSettle();
              final saved = find.text('الأفكار المحفوظة');
              await tester.ensureVisible(saved);
              await tester.pumpAndSettle();
              expect(tester.getRect(saved).top, greaterThanOrEqualTo(0));
              expect(
                tester.getRect(saved).bottom,
                lessThanOrEqualTo(640 - keyboard),
              );
              await tester.sendKeyEvent(LogicalKeyboardKey.numpadEnter);
              await tester.pumpAndSettle();
              expect(await result, 'saved');
              expect(tester.takeException(), isNull);
            } finally {
              semantics.dispose();
            }
          },
        );
      }
    }
  }
  testWidgets(
    'Commands retain query, active selection and focus through reflow',
    (tester) async {
      final scale = ValueNotifier(1.0);
      addTearDown(scale.dispose);
      final owner = await _host(tester, liveScale: scale);
      final result = _launch(owner);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), ' COLLECTION ');
      await tester.pumpAndSettle();
      expect(find.text('Saved ideas'), findsOneWidget);
      expect(find.text('New note'), findsNothing);
      scale.value = 3;
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
        isTrue,
      );
      expect(find.text('Saved ideas'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(await result, 'saved');
    },
  );
  testWidgets('Opt-in commands preserve disabled, empty and touch results', (
    tester,
  ) async {
    final owner = await _host(tester, rtl: true, scale: 2, keyboard: 250);
    final result = _launch(owner, rtl: true);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'أرشفة');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('أرشفة المجموعة'));
    await tester.tap(find.text('أرشفة المجموعة'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('لا توجد أوامر مطابقة'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'المحفوظة');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('الأفكار المحفوظة'));
    await tester.tap(find.text('الأفكار المحفوظة'));
    await tester.pumpAndSettle();
    expect(await result, 'saved');
    expect(tester.takeException(), isNull);
  });
  for (final signature in [false, true]) {
    for (final scenario in ['light', 'dark', 'rtl-2x', 'rtl-3x-keyboard']) {
      testWidgets(
        'Commands keyboard agreement signature=$signature $scenario',
        (tester) async {
          final semantics = tester.ensureSemantics();
          try {
            final rtl = scenario.startsWith('rtl');
            final owner = await _host(
              tester,
              signature: signature,
              brightness: scenario == 'dark'
                  ? Brightness.dark
                  : Brightness.light,
              rtl: rtl,
              scale: scenario == 'rtl-3x-keyboard' ? 3 : (rtl ? 2 : 1),
              keyboard: scenario == 'rtl-3x-keyboard' ? 250 : 0,
            );
            final labels = _commands(rtl: rtl).map((c) => c.label).toList();
            Future<void> key(LogicalKeyboardKey key) async {
              await tester.sendKeyEvent(key);
              await tester.pumpAndSettle();
            }

            String agreement() {
              Finder row(String label) => find
                  .ancestor(
                    of: find.text(label),
                    matching: find.byType(InkWell),
                  )
                  .first;
              final hint = find.byIcon(Icons.keyboard_return_rounded);
              expect(hint, findsOneWidget);
              final activeRow = find
                  .ancestor(of: hint, matching: find.byType(InkWell))
                  .first;
              final active = labels
                  .take(2)
                  .singleWhere(
                    (label) => find
                        .descendant(of: activeRow, matching: find.text(label))
                        .evaluate()
                        .isNotEmpty,
                  );
              expect(
                _node(tester, active).flagsCollection.isSelected,
                ui.Tristate.isTrue,
              );
              final focused = labels
                  .take(2)
                  .where(
                    (label) =>
                        find.text(label).evaluate().isNotEmpty &&
                        tester.widget<InkWell>(row(label)).focusNode!.hasFocus,
                  );
              if (focused.isNotEmpty) {
                expect(focused, [active], reason: 'Focus must match selection');
              } else {
                expect(
                  tester
                      .widget<TextField>(find.byType(TextField))
                      .focusNode!
                      .hasFocus,
                  isTrue,
                );
              }

              return active == labels.first ? 'new' : 'saved';
            }

            var result = _launch(owner, rtl: rtl);
            await tester.pumpAndSettle();
            expect(agreement(), 'new');
            await key(LogicalKeyboardKey.arrowDown);
            expect(agreement(), 'saved');
            await key(LogicalKeyboardKey.tab);
            final tabValue = agreement();
            await key(LogicalKeyboardKey.arrowDown);
            expect(agreement(), tabValue == 'new' ? 'saved' : 'new');
            await key(LogicalKeyboardKey.arrowUp);
            expect(agreement(), tabValue);
            final priorFocus = FocusManager.instance.primaryFocus;
            await key(LogicalKeyboardKey.tab);
            agreement();
            await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
            await key(LogicalKeyboardKey.tab);
            await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
            await tester.pumpAndSettle();
            expect(FocusManager.instance.primaryFocus, same(priorFocus));
            expect(agreement(), tabValue);
            await key(LogicalKeyboardKey.enter);
            expect(await result, tabValue);

            result = _launch(owner, rtl: rtl);
            await tester.pumpAndSettle();
            await key(LogicalKeyboardKey.arrowUp);
            expect(agreement(), 'saved', reason: 'Wrap skips disabled command');
            await key(LogicalKeyboardKey.arrowDown);
            expect(agreement(), 'new');
            await key(LogicalKeyboardKey.tab);
            agreement();
            await key(LogicalKeyboardKey.escape);
            expect(await result, isNull);

            result = _launch(owner, rtl: rtl);
            await tester.pumpAndSettle();
            await tester.enterText(
              find.byType(TextField),
              rtl ? 'افتح مجموعتك' : ' COLLECTION ',
            );
            await tester.pumpAndSettle();
            expect(find.text(labels.first), findsNothing);
            await key(LogicalKeyboardKey.arrowDown);
            await key(LogicalKeyboardKey.tab);
            expect(
              _node(tester, labels[1]).flagsCollection.isSelected,
              ui.Tristate.isTrue,
            );
            await key(LogicalKeyboardKey.enter);
            expect(await result, 'saved');

            result = _launch(owner, rtl: rtl);
            await tester.pumpAndSettle();
            await tester.enterText(
              find.byType(TextField),
              rtl ? 'أرشفة' : 'Archive',
            );
            await tester.pumpAndSettle();
            await tester.ensureVisible(find.text(labels.last));
            await tester.pumpAndSettle();
            expect(
              _node(
                tester,
                labels.last,
                button: false,
              ).flagsCollection.isEnabled,
              ui.Tristate.isFalse,
            );
            expect(
              _node(
                tester,
                labels.last,
                button: false,
              ).flagsCollection.isSelected,
              ui.Tristate.isFalse,
            );
            expect(find.byIcon(Icons.keyboard_return_rounded), findsNothing);
            await key(LogicalKeyboardKey.arrowDown);
            await key(LogicalKeyboardKey.arrowUp);
            await key(LogicalKeyboardKey.enter);
            expect(find.byType(TextField), findsOneWidget);
            await tester.enterText(find.byType(TextField), 'no-match');
            await tester.pumpAndSettle();
            expect(
              find.text(rtl ? 'لا توجد أوامر مطابقة' : 'No matching commands'),
              findsOneWidget,
            );
            await key(LogicalKeyboardKey.enter);
            expect(find.byType(TextField), findsOneWidget);
            await key(LogicalKeyboardKey.escape);
            expect(await result, isNull);
            expect(tester.takeException(), isNull);
          } finally {
            semantics.dispose();
          }
        },
      );
    }
  }
  testWidgets('Repeated enabled command objects have independent row focus', (
    tester,
  ) async {
    final owner = await _host(tester);
    const command = UiGalleryDialogAction(label: 'Repeated', value: 7);
    final result = UiGalleryDialog.commands<int>(
      context: owner,
      title: 'Commands',
      emptyLabel: 'Empty',
      commands: const [command, command],
    );
    await tester.pumpAndSettle();
    InkWell row(int index) => tester.widget<InkWell>(
      find
          .ancestor(
            of: find.text('Repeated').at(index),
            matching: find.byType(InkWell),
          )
          .first,
    );
    expect(row(0).focusNode, isNot(same(row(1).focusNode)));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(row(0).focusNode!.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(row(1).focusNode!.hasFocus, isTrue);
    expect(
      find.descendant(
        of: find
            .ancestor(
              of: find.text('Repeated').at(1),
              matching: find.byType(InkWell),
            )
            .first,
        matching: find.byIcon(Icons.keyboard_return_rounded),
      ),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(await result, 7);
    expect(tester.takeException(), isNull);
  });
}
