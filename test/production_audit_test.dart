import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

const _customSurface = Color(0xffdce6c9);
const _customStyle = UiGallerySurfaceStyle(
  surfaceColor: _customSurface,
  contentColor: Colors.black,
  accentColor: Colors.deepPurple,
  shape: UiGalleryCurvedBorder(curve: UiGalleryCurve.concave, depth: 12),
  padding: EdgeInsets.all(12),
  elevation: 2,
);

Future<BuildContext> _host(
  WidgetTester tester, {
  required bool accessible,
  Widget? child,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(400, 800);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  late BuildContext owner;
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        brightness: accessible ? Brightness.dark : Brightness.light,
        colorSchemeSeed: Colors.indigo,
      ),
      builder: (context, child) => Directionality(
        textDirection: accessible ? TextDirection.rtl : TextDirection.ltr,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            textScaler: TextScaler.linear(accessible ? 2 : 1),
          ),
          child: child!,
        ),
      ),
      home: Builder(
        builder: (context) {
          owner = context;
          return child ?? const Scaffold();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return owner;
}

void _expectCustomSurface(WidgetTester tester) {
  expect(
    tester
            .widgetList<Material>(find.byType(Material))
            .any((material) => material.color == _customSurface) ||
        tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .any(
              (widget) => switch (widget.decoration) {
                BoxDecoration(:final color) ||
                ShapeDecoration(:final color) => color == _customSurface,
                _ => false,
              },
            ),
    isTrue,
  );
}

Future<void> _disposeHost(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  expect(tester.binding.transientCallbackCount, 0);
}

void main() {
  for (final accessible in [false, true]) {
    final environment = accessible ? 'dark RTL large text' : 'light LTR';
    for (final preset in UiGallerySheetPreset.values) {
      testWidgets('audit ${preset.name} sheet / $environment', (tester) async {
        final owner = await _host(tester, accessible: accessible);
        for (var cycle = 0; cycle < 2; cycle++) {
          final result = UiGallerySheet.show<int>(
            context: owner,
            preset: preset,
            style: cycle == 0 ? null : _customStyle,
            header: const Text('Review changes'),
            secondary: const Text('Related information'),
            child: const Text('Editable content belongs to the host.'),
            footer: Builder(
              builder: (context) => FilledButton(
                onPressed: () => Navigator.of(context).pop(cycle),
                child: const Text('Apply changes'),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Review changes'), findsOneWidget);
          if (cycle == 1) _expectCustomSurface(tester);
          await tester.tap(find.text('Apply changes'));
          await tester.pumpAndSettle();
          expect(await result, cycle);
          expect(find.text('Review changes'), findsNothing);
          expect(tester.takeException(), isNull);
        }
        await _disposeHost(tester);
      });
    }
    for (final preset in UiGalleryDialogPreset.values) {
      testWidgets('audit ${preset.name} dialog / $environment', (tester) async {
        final owner = await _host(tester, accessible: accessible);
        for (var cycle = 0; cycle < 2; cycle++) {
          final result = UiGalleryDialog.show<int>(
            context: owner,
            preset: preset,
            style: cycle == 0 ? null : _customStyle,
            title: 'Review changes',
            message: 'Confirm the changes for this workspace.',
            actions: [
              UiGalleryDialogAction(label: 'Apply changes', value: cycle),
            ],
          );
          await tester.pumpAndSettle();
          expect(find.text('Review changes'), findsOneWidget);
          if (cycle == 1) _expectCustomSurface(tester);
          await tester.ensureVisible(find.text('Apply changes'));
          await tester.tap(find.text('Apply changes'));
          await tester.pumpAndSettle();
          expect(await result, cycle);
          expect(find.text('Review changes'), findsNothing);
          expect(tester.takeException(), isNull);
        }
        await _disposeHost(tester);
      });
    }
    for (final preset in UiGalleryToastPreset.values) {
      testWidgets('audit ${preset.name} toast / $environment', (tester) async {
        final owner = await _host(tester, accessible: accessible);
        var actions = 0;
        for (var cycle = 0; cycle < 2; cycle++) {
          final handle = UiGalleryToast.show(
            owner,
            preset: preset,
            style: cycle == 0 ? null : _customStyle,
            message: 'Workspace has been updated.',
            actionLabel: 'Undo',
            onAction: () => actions++,
            duration: Duration.zero,
          );
          await tester.pumpAndSettle();
          if (cycle == 1) _expectCustomSurface(tester);
          await tester.ensureVisible(find.text('Undo'));
          await tester.tap(find.text('Undo'));
          await tester.pumpAndSettle();
          await handle.closed;
          expect(actions, cycle + 1);
          expect(find.text('Workspace has been updated.'), findsNothing);
          expect(tester.takeException(), isNull);
        }
        await _disposeHost(tester);
      });
    }
    for (final preset in UiGalleryAppBarPreset.values) {
      testWidgets('audit ${preset.name} header / $environment', (tester) async {
        var leading = 0;
        var actions = 0;
        late StateSetter update;
        var custom = false;
        await _host(
          tester,
          accessible: accessible,
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Scaffold(
                appBar: UiGalleryAppBar(
                  preset: preset,
                  style: custom ? _customStyle : null,
                  title: const Text('A workspace with a long dynamic title'),
                  subtitle: const Text('Project overview'),
                  leading: IconButton(
                    tooltip: 'Leading action',
                    onPressed: () => leading++,
                    icon: const Icon(Icons.menu),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Trailing action',
                      onPressed: () => actions++,
                      icon: const Icon(Icons.settings),
                    ),
                  ],
                ),
              );
            },
          ),
        );
        for (var cycle = 0; cycle < 2; cycle++) {
          if (cycle == 1) {
            update(() => custom = true);
            await tester.pumpAndSettle();
            _expectCustomSurface(tester);
          }
          await tester.tap(find.byTooltip('Leading action'));
          await tester.tap(find.byTooltip('Trailing action'));
          await tester.pumpAndSettle();
          expect(leading, cycle + 1);
          expect(actions, cycle + 1);
          expect(tester.takeException(), isNull);
        }
        await _disposeHost(tester);
      });
    }
    for (final preset in UiGalleryBottomNavPreset.values) {
      testWidgets('audit ${preset.name} navigation / $environment', (
        tester,
      ) async {
        var selected = 0;
        var custom = false;
        var callbacks = 0;
        late StateSetter update;
        await _host(
          tester,
          accessible: accessible,
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Scaffold(
                body: Center(child: Text('Page $selected')),
                bottomNavigationBar: UiGalleryBottomNav(
                  preset: preset,
                  style: custom ? _customStyle : null,
                  selectedIndex: selected,
                  onDestinationSelected: (index) => setState(() {
                    callbacks++;
                    selected = index;
                  }),
                  items: const [
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.search),
                      label: 'Explore',
                    ),
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              );
            },
          ),
        );
        for (var cycle = 0; cycle < 2; cycle++) {
          if (cycle == 1) {
            update(() => custom = true);
            await tester.pumpAndSettle();
            _expectCustomSurface(tester);
          }
          await tester.tap(find.byTooltip('Explore'));
          await tester.pumpAndSettle();
          expect(find.text('Page 1'), findsOneWidget);
          await tester.tap(find.byTooltip('Home'));
          await tester.pumpAndSettle();
          expect(find.text('Page 0'), findsOneWidget);
          expect(callbacks, (cycle + 1) * 2);
          expect(tester.takeException(), isNull);
        }
        await _disposeHost(tester);
      });
    }
  }
}
