import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:nova_surfaces_example/gallery/demo.dart';
import 'package:nova_surfaces_example/main.dart';

Future<void> openPlayground(
  WidgetTester tester, {
  Size size = const Size(1280, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const FlutterUiGalleryApp());
  await tester.pumpAndSettle();
}

Future<void> showMore(WidgetTester tester) async {
  await tester.ensureVisible(find.text('More'));
  await tester.tap(find.text('More'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tablet keeps the two-column playground', (tester) async {
    await openPlayground(tester, size: const Size(768, 1024));
    expect(
      tester.getRect(find.byKey(const ValueKey('code-panel'))).right,
      lessThan(tester.getRect(find.byKey(const ValueKey('phone-frame'))).left),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('desktop opens with code beside one scoped preview', (
    tester,
  ) async {
    await openPlayground(tester);
    expect(find.byType(SurfaceDemo), findsOneWidget);
    expect(find.text('Interfaces\nwith intent.'), findsNothing);
    final frame = tester.getRect(find.byKey(const ValueKey('phone-frame')));
    final code = tester.getRect(find.byKey(const ValueKey('code-panel')));
    expect(code.right, lessThan(frame.left));
    expect(find.widgetWithText(TextField, 'Title'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('launch-preview')));
    await tester.pumpAndSettle();
    expect(find.text('Copy link'), findsOneWidget);
    expect(frame.contains(tester.getCenter(find.text('Copy link'))), isTrue);
    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    expect(find.text('Returned: Copy link'), findsOneWidget);
  });

  testWidgets('mobile shows the phone before code without overflow', (
    tester,
  ) async {
    await openPlayground(tester, size: const Size(390, 844));
    final frame = tester.getRect(find.byKey(const ValueKey('phone-frame')));
    final code = tester.getRect(find.byKey(const ValueKey('dart-snippet')));
    expect(frame.bottom, lessThan(code.top));
    expect(frame.width, lessThanOrEqualTo(358));
    await tester.tap(find.text('Dialogs'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('launch-preview')));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.byType(Dialog))).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('switching clears modal and toast overlays', (tester) async {
    await openPlayground(tester);
    await tester.tap(find.byKey(const ValueKey('launch-preview')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next preset'));
    await tester.pumpAndSettle();
    expect(find.text('Copy link'), findsNothing);
    expect(tester.widget<SurfaceDemo>(find.byType(SurfaceDemo)).index, 1);
    await tester.tap(find.text('Toasts'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('launch-preview')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('launch-preview')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('AppBars'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('launch-preview')), findsNothing);
    await tester.drag(
      find.descendant(
        of: find.byType(SurfaceDemo),
        matching: find.byType(ListView),
      ),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme and RTL retain navigation selection and draft', (
    tester,
  ) async {
    await openPlayground(tester);
    await tester.tap(find.text('Bottom Navigation'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('navigation-draft')),
      'Keep my draft',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('3 saved ideas'), findsOneWidget);
    await tester.tap(find.byTooltip('Dark mode'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
          .selectedIndex,
      1,
    );
    await showMore(tester);
    await tester.ensureVisible(find.text('RTL'));
    await tester.tap(find.text('RTL'));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(UiGalleryBottomNav));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(Directionality.of(context), TextDirection.rtl);
    expect(
      tester
          .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
          .selectedIndex,
      1,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('nav-tab-0')));
    await tester.tap(find.byKey(const ValueKey('nav-tab-0')));
    await tester.pumpAndSettle();
    expect(find.text('Keep my draft'), findsOneWidget);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
          .selectedIndex,
      0,
    );
    expect(find.text('Keep my draft'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('copy sends displayed valid public API source', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await openPlayground(tester);
    await showMore(tester);
    await tester.ensureVisible(find.widgetWithText(TextField, 'Title'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'A title with \$ and "quotes"',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Copy Code'));
    await tester.tap(find.text('Copy Code'));
    await tester.pumpAndSettle();
    final source = tester
        .widget<SelectableText>(find.byKey(const ValueKey('dart-snippet')))
        .textSpan!
        .toPlainText();
    expect(copied, source);
    expect(copied, contains(r'\$'));
    expect(copied, contains('UiGallerySheet.show<void>'));
    expect(find.text('Copied'), findsOneWidget);
  });

  testWidgets('curve controls only appear for supported presets', (
    tester,
  ) async {
    await openPlayground(tester);
    expect(find.text('Curve'), findsNothing);
    await tester.tap(find.text('Bottom Navigation'));
    await tester.pumpAndSettle();
    expect(find.text('Curve'), findsOneWidget);
    await tester.drag(find.byType(Slider), const Offset(30, 0));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
          .options
          .curveDepth,
      greaterThan(14),
    );
    await tester.tap(find.byTooltip('Next preset'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav)).preset,
      UiGalleryBottomNavPreset.concaveNotch,
    );
    expect(tester.takeException(), isNull);
  });
}
