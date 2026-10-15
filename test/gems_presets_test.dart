import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

void main() {
  testWidgets('Flip Tiles keeps a keyed custom icon mounted during selection', (
    tester,
  ) async {
    final key = GlobalKey();
    final icon = Icon(Icons.home, key: key);
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: UiGalleryBottomNav(
              preset: UiGalleryBottomNavPreset.flipTiles,
              selectedIndex: selected,
              onDestinationSelected: (value) =>
                  setState(() => selected = value),
              items: [
                UiGalleryBottomNavItem(icon: icon, label: 'Home'),
                const UiGalleryBottomNavItem(
                  icon: Icon(Icons.bookmark),
                  label: 'Saved',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final element = tester.element(find.byKey(key));
    await tester.tap(find.byTooltip('Saved'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(tester.element(find.byKey(key)), same(element));
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.element(find.byKey(key)), same(element));
  });
  testWidgets('Search Switch preserves query and trailing actions', (
    tester,
  ) async {
    var query = '';
    var notifications = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: UiGalleryAppBar(
            preset: UiGalleryAppBarPreset.searchSwitch,
            title: const Text('Collection'),
            onSearchChanged: (value) => query = value,
            actions: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => notifications++,
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.getTopLeft(find.text('Collection')).dx, 28);
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'design');
    expect(query, 'design');
    await tester.tap(find.byTooltip('Notifications'));
    expect(notifications, 1);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Collection'), findsOneWidget);
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'design',
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Centered Title stays centered with unequal action groups', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: UiGalleryAppBar(
            preset: UiGalleryAppBarPreset.centeredTitle,
            title: const Text('Notes', key: ValueKey('centered-title')),
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
            ],
          ),
        ),
      ),
    );
    expect(
      tester.getCenter(find.byKey(const ValueKey('centered-title'))).dx,
      closeTo(
        tester.view.physicalSize.width / tester.view.devicePixelRatio / 2,
        .01,
      ),
    );
  });

  for (final reduced in [false, true]) {
    testWidgets(
      'Scroll Dock hides and reveals without losing selection (reduced: $reduced)',
      (tester) async {
        var selected = 0;
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
              child: child!,
            ),
            home: StatefulBuilder(
              builder: (context, setState) => Scaffold(
                body: ListView.builder(
                  itemCount: 60,
                  itemBuilder: (_, i) => ListTile(title: Text('Note $i')),
                ),
                bottomNavigationBar: UiGalleryBottomNav(
                  preset: UiGalleryBottomNavPreset.scrollDock,
                  selectedIndex: selected,
                  onDestinationSelected: (value) =>
                      setState(() => selected = value),
                  items: const [
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.bookmark),
                      label: 'Saved',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Saved'));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(UiGalleryBottomNav)).height, 0);
        expect(find.text('Saved').hitTestable(), findsNothing);
        await tester.drag(find.byType(ListView), const Offset(0, 150));
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(UiGalleryBottomNav)).height,
          greaterThanOrEqualTo(48),
        );
        expect(selected, 1);
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
        expect(selected, 0);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final preset in UiGalleryBottomNavPreset.values.skip(10)) {
    testWidgets(
      '${preset.name} supports interrupted selection and disabled targets',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(240, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        var selected = 0;
        var callbacks = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: Brightness.dark),
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(2)),
                child: child!,
              ),
            ),
            home: StatefulBuilder(
              builder: (context, setState) => Scaffold(
                extendBody: preset == UiGalleryBottomNavPreset.glassDock,
                bottomNavigationBar: UiGalleryBottomNav(
                  preset: preset,
                  selectedIndex: selected,
                  onDestinationSelected: (value) => setState(() {
                    selected = value;
                    callbacks++;
                  }),
                  items: const [
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.bookmark),
                      label: 'Saved',
                    ),
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.inbox),
                      label: 'Inbox',
                    ),
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.settings),
                      label: 'Disabled',
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        for (final label in ['Saved', 'Inbox', 'Home']) {
          await tester.tap(find.byTooltip(label));
          await tester.pump(const Duration(milliseconds: 40));
        }
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Disabled'));
        expect(selected, 0);
        expect(callbacks, 3);
        expect(tester.takeException(), isNull);
        if (preset == UiGalleryBottomNavPreset.glassDock) {
          expect(find.byType(BackdropFilter), findsOneWidget);
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  }
}
