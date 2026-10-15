import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

Future<BuildContext> _host(
  WidgetTester tester, {
  Widget? body,
  PreferredSizeWidget? bar,
  MediaQueryData? media,
}) async {
  late BuildContext context;
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data:
              media ??
              const MediaQueryData(
                size: Size(800, 600),
                textScaler: TextScaler.linear(2),
              ),
          child: child!,
        ),
      ),
      home: Scaffold(
        appBar: bar,
        body: Builder(
          builder: (c) {
            context = c;
            return body ?? const SizedBox();
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return context;
}

void main() {
  for (final reduced in [false, true]) {
    testWidgets('dialog uses independent exit duration (reduced: $reduced)', (
      tester,
    ) async {
      final context = await _host(
        tester,
        media: MediaQueryData(disableAnimations: reduced),
      );
      const motion = UiGalleryMotion(
        entrance: Duration(milliseconds: 600),
        exit: Duration(milliseconds: 180),
      );
      final result = UiGalleryDialog.show<bool>(
        context: context,
        title: 'Exit timing',
        motion: motion,
      );
      await tester.pumpAndSettle();
      final dialogContext = tester.element(find.text('Exit timing'));
      final route = ModalRoute.of(dialogContext)!;
      expect(
        route.transitionDuration,
        reduced ? Duration.zero : motion.entrance,
      );
      expect(
        route.reverseTransitionDuration,
        reduced ? Duration.zero : motion.exit,
      );
      Navigator.of(dialogContext).pop(true);
      await tester.pump();
      await tester.pump(motion.exit + const Duration(milliseconds: 1));
      expect(find.text('Exit timing'), findsNothing);
      expect(await result, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('accessible passive manual toast does not expire', (
    tester,
  ) async {
    final context = await _host(
      tester,
      media: const MediaQueryData(accessibleNavigation: true),
    );
    final handle = UiGalleryToast.show(
      context,
      message: 'Manual notification',
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(find.text('Manual notification'), findsOneWidget);
    handle.dismiss();
    await tester.pumpAndSettle();
    expect(find.text('Manual notification'), findsNothing);
    await handle.closed;
  });
  testWidgets(
    'enabling accessible navigation extends an active passive toast',
    (tester) async {
      var accessible = false;
      late StateSetter update;
      late BuildContext owner;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(accessibleNavigation: accessible),
                child: child!,
              );
            },
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                owner = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      final handle = UiGalleryToast.show(
        owner,
        message: 'Accessible timeout',
        duration: const Duration(seconds: 2),
      );
      await tester.pumpAndSettle();
      update(() => accessible = true);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Accessible timeout'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      expect(find.text('Accessible timeout'), findsNothing);
      await handle.closed;
      expect(tester.takeException(), isNull);
    },
  );
  test('66 presets with compatible descriptive aliases', () {
    expect(
      UiGallerySheetPreset.values.length +
          UiGalleryDialogPreset.values.length +
          UiGalleryToastPreset.values.length +
          UiGalleryAppBarPreset.values.length +
          UiGalleryBottomNavPreset.values.length,
      66,
    );
    expect(UiGallerySheetPreset.orbitDock, NovaSheetPreset.orbit);
    expect(UiGalleryDialogPreset.haloFocus, NovaDialogPreset.halo);
    expect(UiGalleryToastPreset.signalPill, NovaToastPreset.signal);
  });
  for (final preset in UiGalleryAppBarPreset.values) {
    testWidgets('${preset.name} header fits large RTL text and actions', (
      tester,
    ) async {
      final bar = UiGalleryAppBar(
        preset: preset,
        title: const Text('عنوان طويل جدا لاختبار حجم النص'),
        subtitle: const Text('وصف قصير'),
        actions: [
          for (var i = 0; i < 6; i++)
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: SizedBox(height: 24),
        ),
      );
      await _host(tester, bar: bar);
      expect(tester.takeException(), isNull);
      expect(bar.preferredSize.height, greaterThanOrEqualTo(80));
      expect(find.byType(UiGalleryAppBar), findsOneWidget);
    });
    testWidgets('${preset.name} sliver collapses without leaking', (
      tester,
    ) async {
      await _host(
        tester,
        body: CustomScrollView(
          slivers: [
            UiGallerySliverAppBar(
              preset: preset,
              title: const Text('استكشف'),
              subtitle: const Text('الواجهة'),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 1600)),
          ],
        ),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('استكشف'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Focus Bar emits real search input', (tester) async {
    String? query;
    await _host(
      tester,
      bar: UiGalleryAppBar(
        preset: UiGalleryAppBarPreset.focusBar,
        title: const Text('Search'),
        onSearchChanged: (value) => query = value,
      ),
    );
    await tester.enterText(find.byType(TextField), 'Flutter');
    expect(query, 'Flutter');
  });
  testWidgets('visual and motion overrides work on each modal category', (
    tester,
  ) async {
    final context = await _host(tester);
    const style = UiGallerySurfaceStyle(
      surfaceColor: Colors.amber,
      contentColor: Colors.black,
      accentColor: Colors.purple,
      maxWidth: 400,
      elevation: 0,
      padding: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(),
      titleStyle: TextStyle(fontSize: 18),
      messageStyle: TextStyle(fontSize: 14),
    );
    const motion = UiGalleryMotion(intensity: 0);
    UiGallerySheet.show<void>(
      context: context,
      preset: UiGallerySheetPreset.splitLayer,
      style: style,
      motion: motion,
      header: const Text('Custom sheet'),
      secondary: const Text('Secondary region'),
      footer: const Text('Sticky action'),
      child: const Text('Primary region'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Secondary region'), findsOneWidget);
    expect(
      tester
          .getSize(
            find
                .ancestor(
                  of: find.text('Custom sheet'),
                  matching: find.byType(Material),
                )
                .first,
          )
          .width,
      lessThanOrEqualTo(400),
    );
    Navigator.of(tester.element(find.text('Custom sheet'))).pop();
    await tester.pumpAndSettle();
    UiGalleryDialog.confirm(
      context: context,
      title: 'Custom dialog',
      style: style,
      motion: motion,
      barrierColor: Colors.black26,
      alignment: Alignment.topCenter,
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Dialog>(find.byType(Dialog)).backgroundColor,
      Colors.amber,
    );
    expect(tester.widget<Dialog>(find.byType(Dialog)).elevation, 0);
    Navigator.of(tester.element(find.text('Custom dialog'))).pop();
    await tester.pumpAndSettle();
    final toast = UiGalleryToast.show(
      context,
      message: 'Custom toast',
      preset: UiGalleryToastPreset.miniConsole,
      title: 'SYSTEM',
      style: style,
      motion: motion,
      duration: Duration.zero,
      leading: const Text('Leading'),
      trailing: const Text('Trailing'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Leading'), findsOneWidget);
    expect(find.text('Trailing'), findsOneWidget);
    expect(tester.takeException(), isNull);
    toast.dismiss();
    await tester.pumpAndSettle();
  });
  testWidgets('lowering toast visibility cap requeues excess entries', (
    tester,
  ) async {
    final context = await _host(tester);
    final first = UiGalleryToast.show(
      context,
      message: 'First',
      duration: Duration.zero,
      maxVisible: 2,
    );
    final second = UiGalleryToast.show(
      context,
      message: 'Second',
      duration: Duration.zero,
      maxVisible: 2,
    );
    await tester.pumpAndSettle();
    final third = UiGalleryToast.show(
      context,
      message: 'Third',
      duration: Duration.zero,
      maxVisible: 1,
    );
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsNothing);
    first.dismiss();
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);
    second.dismiss();
    await tester.pumpAndSettle();
    expect(find.text('Third'), findsOneWidget);
    third.dismiss();
    await tester.pumpAndSettle();
  });
  testWidgets('headers honor width and title typography overrides', (
    tester,
  ) async {
    await _host(
      tester,
      bar: const UiGalleryAppBar(
        preset: UiGalleryAppBarPreset.splitHeader,
        title: Text('Width override'),
        style: UiGallerySurfaceStyle(
          maxWidth: 360,
          titleStyle: TextStyle(fontSize: 18, color: Colors.purple),
        ),
      ),
    );
    expect(
      tester
          .getSize(
            find
                .ancestor(
                  of: find.text('Width override'),
                  matching: find.byType(Material),
                )
                .first,
          )
          .width,
      360,
    );
    expect(
      DefaultTextStyle.of(
        tester.element(find.text('Width override')),
      ).style.fontSize,
      18,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('switching reduced motion retains open sheet input', (
    tester,
  ) async {
    var reduced = false;
    late StateSetter update;
    late BuildContext owner;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
              child: child!,
            );
          },
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              owner = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    UiGallerySheet.show<void>(
      context: owner,
      preset: UiGallerySheetPreset.fold,
      child: const TextField(),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Retained');
    update(() => reduced = true);
    await tester.pumpAndSettle();
    expect(find.text('Retained'), findsOneWidget);
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.byType(TextField))).pop();
    await tester.pumpAndSettle();
  });
  testWidgets('Horizon truncates long titles before fitting their height', (
    tester,
  ) async {
    const title =
        'A very long workspace title that should keep its readable size';
    await _host(tester, bar: const UiGalleryAppBar(title: Text(title)));
    expect(
      tester.renderObject<RenderParagraph>(find.text(title)).didExceedMaxLines,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}
