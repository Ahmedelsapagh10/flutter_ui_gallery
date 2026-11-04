import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

import 'dialog_heroes_test.dart' as host;
import 'notes_fonts.dart';

const _message =
    'Your archived note is kept safely. Undo to return it to this notebook.';
const _arabicMessage =
    'تم الاحتفاظ بالملاحظة المؤرشفة بأمان. تراجع لإعادتها إلى هذا الدفتر.';
const _action = 'Undo archive';
const _arabicAction = 'التراجع عن الأرشفة';

Color _background(WidgetTester tester, Finder text) {
  final colors = <Color>[];
  tester.element(text).visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is Material && widget.color != null) {
      colors.add(widget.color!);
    } else if (widget is DecoratedBox && widget.decoration is BoxDecoration) {
      final color = (widget.decoration as BoxDecoration).color;
      if (color != null) colors.add(color);
    }
    return true;
  });
  var background = Theme.of(tester.element(text)).colorScheme.surface;
  for (final color in colors.reversed) {
    background = Color.alphaBlend(color, background);
  }
  return background;
}

double _contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return (x > y ? x + .05 : y + .05) / (x > y ? y + .05 : x + .05);
}

void _expectWordsFit(WidgetTester tester, Finder text, String copy) {
  final paragraph = tester.renderObject<RenderParagraph>(text);
  expect(paragraph.didExceedMaxLines, isFalse);
  for (final word in copy.split(' ')) {
    final painter = TextPainter(
      text: TextSpan(text: word, style: paragraph.text.style),
      textDirection: paragraph.textDirection,
      textScaler: paragraph.textScaler,
    )..layout();
    expect(
      paragraph.size.width + .5,
      greaterThanOrEqualTo(painter.width),
      reason: 'The whole fixture word "$word" needs usable text width',
    );
    painter.dispose();
  }
  final background = _background(tester, text);
  final ink = Color.alphaBlend(paragraph.text.style!.color!, background);
  expect(_contrast(ink, background), greaterThanOrEqualTo(4.5));
}

void main() {
  setUpAll(loadNotesFonts);
  for (final family in UiGalleryDesignFamily.values) {
    for (final scene in [
      'light',
      'dark',
      'rtl-large',
      'rtl-extreme',
      'keyboard',
    ]) {
      testWidgets('Action $family $scene whole words, controls and semantics', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        try {
          final ar = scene.startsWith('rtl');
          final owner = await host.hostDialogHero(
            tester,
            family,
            scene == 'rtl-extreme' ? 'rtl-large' : scene,
            GlobalKey(),
            textScale: scene == 'rtl-extreme' ? 3 : null,
          );
          final message = ar ? _arabicMessage : _message;
          final action = ar ? _arabicAction : _action;
          var calls = 0;
          final toast = UiGalleryToast.show(
            owner,
            preset: UiGalleryToastPreset.action,
            message: message,
            actionLabel: action,
            onAction: () => calls++,
            duration: Duration.zero,
            semanticLabel: 'Archive feedback',
          );
          await tester.pumpAndSettle();
          _expectWordsFit(tester, find.text(message), message);
          await tester.ensureVisible(find.text(action));
          await tester.pumpAndSettle();
          _expectWordsFit(tester, find.text(action), action);
          final button = find.widgetWithText(TextButton, action);
          final node = tester.getSemantics(button);
          expect(node.flagsCollection.isButton, isTrue);
          expect(node.flagsCollection.isEnabled, ui.Tristate.isTrue);
          final size = tester.getSize(button);
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
          final close = find.byTooltip(
            MaterialLocalizations.of(owner).closeButtonTooltip,
          );
          await tester.ensureVisible(close);
          await tester.pumpAndSettle();
          expect(tester.getSize(close).shortestSide, greaterThanOrEqualTo(48));
          final live = tester
              .widgetList<Semantics>(find.byType(Semantics))
              .where((widget) => widget.properties.liveRegion == true);
          expect(live, isNotEmpty);
          expect(
            live.any((widget) => widget.properties.label == 'Archive feedback'),
            isTrue,
          );
          await tester.ensureVisible(button);
          await tester.pumpAndSettle();
          // Invoke twice in the same frame, before dismissal can rebuild controls.
          final onPressed = tester.widget<TextButton>(button).onPressed!;
          onPressed();
          onPressed();
          await tester.pumpAndSettle();
          await toast.closed;
          expect(calls, 1);
          expect(find.text(message), findsNothing);
          toast.dismiss();
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      });
    }
  }

  testWidgets(
    'Action keyboard result and long custom metadata survive reflow',
    (tester) async {
      final owner = await host.hostDialogHero(
        tester,
        UiGalleryDesignFamily.soft,
        'rtl-large',
        GlobalKey(),
        textScale: 3,
      );
      var calls = 0;
      final toast = UiGalleryToast.show(
        owner,
        preset: UiGalleryToastPreset.action,
        message: _arabicMessage,
        actionLabel: _arabicAction,
        onAction: () => calls++,
        duration: Duration.zero,
        leading: const Icon(
          Icons.archive_outlined,
          key: ValueKey('archive-status'),
        ),
        trailing: const Text('محلي', key: ValueKey('archive-detail')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('archive-status')), findsOneWidget);
      expect(find.byKey(const ValueKey('archive-detail')), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        Focus.of(tester.element(find.text(_arabicAction))).hasFocus,
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await toast.closed;
      expect(calls, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Action route disposal clears current and queued recovery', (
    tester,
  ) async {
    final owner = await host.hostDialogHero(
      tester,
      UiGalleryDesignFamily.soft,
      'light',
      GlobalKey(),
    );
    late BuildContext routeOwner;
    final route = Navigator.of(owner).push<void>(
      MaterialPageRoute(
        builder: (context) {
          routeOwner = context;
          return const Scaffold();
        },
      ),
    );
    await tester.pumpAndSettle();
    var calls = 0;
    final handles = [
      for (var i = 0; i < 3; i++)
        UiGalleryToast.show(
          routeOwner,
          preset: UiGalleryToastPreset.action,
          message: '$_message $i',
          actionLabel: _action,
          onAction: () => calls++,
          duration: const Duration(hours: 1),
          maxVisible: 1,
        ),
    ];
    await tester.pumpAndSettle();
    Navigator.of(routeOwner).pop();
    await tester.pumpAndSettle();
    await route;
    for (final handle in handles) {
      await handle.closed;
      handle.dismiss();
    }
    expect(calls, 0);
    expect(find.textContaining('Your archived note'), findsNothing);
    await tester.pump(const Duration(hours: 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Action Close does not execute recovery and advances FIFO', (
    tester,
  ) async {
    final owner = await host.hostDialogHero(
      tester,
      UiGalleryDesignFamily.soft,
      'keyboard',
      GlobalKey(),
    );
    var calls = 0;
    UiGalleryToastHandle show(String copy) => UiGalleryToast.show(
      owner,
      preset: UiGalleryToastPreset.action,
      message: copy,
      actionLabel: _action,
      onAction: () => calls++,
      duration: Duration.zero,
      maxVisible: 1,
    );
    final first = show(_message);
    final duplicate = show(_message);
    final second = show('Second recovery opportunity');
    expect(duplicate, same(first));
    await tester.pumpAndSettle();
    expect(find.text('Second recovery opportunity'), findsNothing);
    final close = find.byTooltip(
      MaterialLocalizations.of(owner).closeButtonTooltip,
    );
    await tester.ensureVisible(close);
    await tester.pumpAndSettle();
    await tester.tap(close);
    await tester.pumpAndSettle();
    await first.closed;
    expect(calls, 0);
    expect(find.text('Second recovery opportunity'), findsOneWidget);
    second.dismiss();
    await tester.pumpAndSettle();
    await second.closed;
    expect(tester.takeException(), isNull);
  });
}
