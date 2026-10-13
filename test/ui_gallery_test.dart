import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

Future<BuildContext> host(
  WidgetTester tester, {
  MediaQueryData? media,
  TextDirection direction = TextDirection.ltr,
  ThemeData? theme,
  Widget? body,
}) async {
  late BuildContext context;
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? ThemeData(colorSchemeSeed: Colors.indigo),
      builder: (context, child) => Directionality(
        textDirection: direction,
        child: MediaQuery(
          data: media ?? const MediaQueryData(size: Size(800, 600)),
          child: child!,
        ),
      ),
      home: Scaffold(
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
  testWidgets('UiGallerySheet displays orbit preset and returns result', (
    tester,
  ) async {
    final context = await host(tester);
    final result = UiGallerySheet.show<String>(
      context: context,
      preset: UiGallerySheetPreset.orbit,
      header: const Text('Header'),
      footer: Builder(
        builder: (c) => ElevatedButton(
          onPressed: () => Navigator.pop(c, 'orbit_selected'),
          child: const Text('Confirm'),
        ),
      ),
      child: const Text('Orbit Body Content'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Orbit Body Content'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(await result, 'orbit_selected');
  });

  testWidgets('UiGalleryDialog confirm dialog works with true result', (
    tester,
  ) async {
    final context = await host(tester);
    final result = UiGalleryDialog.confirm(
      context: context,
      preset: UiGalleryDialogPreset.halo,
      title: 'Confirm Operation',
      message: 'Are you sure?',
      confirmLabel: 'Proceed',
    );
    await tester.pumpAndSettle();
    expect(find.text('Confirm Operation'), findsOneWidget);
    await tester.tap(find.text('Proceed'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('UiGalleryToast success displays and dismisses cleanly', (
    tester,
  ) async {
    final context = await host(tester);
    final handle = UiGalleryToast.success(
      context,
      message: 'Saved successfully',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Saved successfully'), findsOneWidget);
    handle.dismiss();
    await tester.pumpAndSettle();
    expect(find.text('Saved successfully'), findsNothing);
  });

  testWidgets('UiGalleryAppBar renders and supports scroll awareness', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: const UiGalleryAppBar(
            title: Text('Gallery Header'),
            subtitle: Text('Subtitle'),
            scrollAware: true,
          ),
          body: ListView(
            children: List.generate(
              50,
              (i) => ListTile(title: Text('Item $i')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gallery Header'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Gallery Header'), findsOneWidget);
  });
}
