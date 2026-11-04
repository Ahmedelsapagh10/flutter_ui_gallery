import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

class _NavigationHost extends StatefulWidget {
  const _NavigationHost({super.key, required this.preset});
  final UiGalleryBottomNavPreset preset;
  @override
  State<_NavigationHost> createState() => _NavigationHostState();
}

class _NavigationHostState extends State<_NavigationHost> {
  int selected = 0;
  int count = 5;
  bool acceptSelection = true;
  bool disabledLast = false;
  bool reduced = false;
  bool keyboard = false;
  bool dark = false;
  TextDirection direction = TextDirection.ltr;
  double textScale = 1;
  UiGalleryBottomNavOptions options = const UiGalleryBottomNavOptions();
  UiGallerySurfaceStyle? style;
  UiGalleryBottomNavItemBuilder? itemBuilder;
  Widget? centerAction;
  final callbacks = <int>[];
  final navigator = GlobalKey<NavigatorState>();

  void update(VoidCallback change) => setState(change);

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigator,
    theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
    builder: (context, child) => Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: const EdgeInsets.only(top: 24, bottom: 32),
          viewInsets: EdgeInsets.only(bottom: keyboard ? 260 : 0),
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reduced,
        ),
        child: child!,
      ),
    ),
    home: Scaffold(
      body: IndexedStack(
        index: selected,
        children: [
          for (var i = 0; i < count; i++)
            _CounterPage(key: ValueKey(i), index: i),
        ],
      ),
      bottomNavigationBar: UiGalleryBottomNav(
        preset: widget.preset,
        selectedIndex: selected,
        options: options,
        style: style,
        centerAction: centerAction,
        itemBuilder: itemBuilder,
        items: [
          for (var i = 0; i < count; i++)
            UiGalleryBottomNavItem(
              icon: Icon(Icons.circle_outlined, key: ValueKey('icon-$i')),
              selectedIcon: Icon(Icons.circle, key: ValueKey('selected-$i')),
              label: 'Tab $i',
              semanticLabel: 'Destination $i',
              enabled: !disabledLast || i != count - 1,
              badge: i == 1 ? const Text('3 unread') : null,
            ),
        ],
        onDestinationSelected: (index) => setState(() {
          callbacks.add(index);
          if (acceptSelection) selected = index;
        }),
      ),
    ),
  );
}

class _CounterPage extends StatefulWidget {
  const _CounterPage({super.key, required this.index});
  final int index;
  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  int value = 0;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Page ${widget.index}: $value'),
        TextButton(
          onPressed: () => setState(() => value++),
          child: Text('Increment ${widget.index}'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (context) =>
                  const Scaffold(body: Text('Host detail route')),
            ),
          ),
          child: Text('Open details ${widget.index}'),
        ),
      ],
    ),
  );
}

Future<_NavigationHostState> _pumpNav(
  WidgetTester tester, {
  UiGalleryBottomNavPreset preset = UiGalleryBottomNavPreset.floatingCove,
  Size size = const Size(400, 800),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final key = GlobalKey<_NavigationHostState>();
  await tester.pumpWidget(_NavigationHost(key: key, preset: preset));
  await tester.pumpAndSettle();
  return key.currentState!;
}

void main() {
  testWidgets('navigation selection belongs to the host and creates no route', (
    tester,
  ) async {
    final host = await _pumpNav(tester);
    host.update(() => host.acceptSelection = false);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tab 2'));
    await tester.pumpAndSettle();
    expect(host.callbacks, [2]);
    expect(find.text('Page 0: 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('selected-0')), findsOneWidget);
    expect(host.navigator.currentState!.canPop(), isFalse);
    host.update(() => host.selected = 2);
    await tester.pumpAndSettle();
    expect(find.text('Page 2: 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('selected-2')), findsOneWidget);
    expect(host.callbacks, [2]);
  });

  testWidgets(
    'destinations expose selection, disabled state and badge semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        final host = await _pumpNav(tester);
        host.update(() => host.disabledLast = true);
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(find.bySemanticsLabel('Destination 0')),
          matchesSemantics(
            label: 'Destination 0',
            isButton: true,
            hasSelectedState: true,
            isSelected: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
        );
        final badge = tester.getSemantics(
          find.bySemanticsLabel(RegExp('Destination 1')),
        );
        expect(badge.getSemanticsData().label, contains('3 unread'));
        final disabled = tester.getSemantics(
          find.bySemanticsLabel('Destination 4'),
        );
        expect(
          disabled.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
        );
        expect(
          disabled,
          matchesSemantics(
            label: 'Destination 4',
            isButton: true,
            hasSelectedState: true,
            hasEnabledState: true,
          ),
        );
        await tester.tap(find.byTooltip('Tab 4'));
        await tester.pumpAndSettle();
        expect(host.callbacks, isEmpty);
        expect(host.selected, 0);
      } finally {
        semantics.dispose();
      }
    },
  );

  for (final preset in UiGalleryBottomNavPreset.values) {
    testWidgets(
      '${preset.name} survives rapid selection, resizing and item changes',
      (tester) async {
        final host = await _pumpNav(tester, preset: preset);
        for (final target in [2, 1, 4, 0, 3]) {
          await tester.tap(find.byTooltip('Tab $target'));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await tester.pumpAndSettle();
        expect(host.selected, 3);
        expect(host.callbacks, [2, 1, 4, 0, 3]);
        host.update(() {
          host.count = 8;
          host.direction = TextDirection.rtl;
          host.textScale = 3;
          host.dark = true;
        });
        tester.view.physicalSize = const Size(280, 620);
        await tester.pumpAndSettle();
        if (preset == UiGalleryBottomNavPreset.overflowDock) {
          await tester.tap(find.byTooltip('More'));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Tab 7'));
          await tester.tap(find.text('Tab 7'));
        } else {
          await tester.ensureVisible(find.byTooltip('Tab 7'));
          await tester.tap(find.byTooltip('Tab 7'));
        }
        await tester.pump(const Duration(milliseconds: 40));
        host.update(() {
          host.count = 2;
          host.selected = 1;
        });
        await tester.pumpAndSettle();
        expect(find.text('Page 1: 0'), findsOneWidget);
        await tester.ensureVisible(find.byTooltip('Tab 0'));
        await tester.tap(find.byTooltip('Tab 0'));
        await tester.pumpAndSettle();
        expect(host.selected, 0);
        final target = tester.getRect(find.byTooltip('Tab 0'));
        expect(target.width, greaterThanOrEqualTo(48));
        expect(target.height, greaterThanOrEqualTo(48));
        expect(target.bottom, lessThanOrEqualTo(620 - 32));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  }

  testWidgets(
    'host IndexedStack retains pages and Navigator back restores the selected page',
    (tester) async {
      final host = await _pumpNav(tester);
      await tester.tap(find.text('Increment 0'));
      await tester.tap(find.byTooltip('Tab 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Increment 1'));
      await tester.tap(find.text('Increment 1'));
      await tester.tap(find.text('Open details 1'));
      await tester.pumpAndSettle();
      expect(find.text('Host detail route'), findsOneWidget);
      expect(host.navigator.currentState!.canPop(), isTrue);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Page 1: 2'), findsOneWidget);
      await tester.tap(find.byTooltip('Tab 0'));
      await tester.pumpAndSettle();
      expect(find.text('Page 0: 1'), findsOneWidget);
      expect(host.navigator.currentState!.canPop(), isFalse);
    },
  );

  testWidgets(
    'keyboard hiding is optional and reduced motion settles immediately',
    (tester) async {
      final host = await _pumpNav(
        tester,
        preset: UiGalleryBottomNavPreset.perspectiveDock,
      );
      host.update(() => host.keyboard = true);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Tab 0'), findsNothing);
      host.update(
        () => host.options = const UiGalleryBottomNavOptions(
          hideWhenKeyboard: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Tab 0'), findsOneWidget);
      host.update(() {
        host.keyboard = false;
        host.reduced = true;
        host.selected = 3;
      });
      await tester.pump();
      expect(find.byKey(const ValueKey('selected-3')), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'custom builders retain navigation callback and enabled semantics',
    (tester) async {
      final host = await _pumpNav(tester);
      host.update(() {
        host.itemBuilder = (context, item, index, selected) =>
            Text('Custom $index');
        host.disabledLast = true;
        host.style = const UiGallerySurfaceStyle(
          maxWidth: 340,
          padding: EdgeInsets.all(8),
          surfaceColor: Colors.amber,
          shape: UiGalleryCurvedBorder(curve: UiGalleryCurve.convex),
        );
      });
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom 2'));
      await tester.tap(find.text('Custom 4'));
      await tester.pumpAndSettle();
      expect(host.callbacks, [2]);
      expect(host.selected, 2);
      final material = find.byWidgetPredicate(
        (widget) => widget is Material && widget.color == Colors.amber,
      );
      expect(tester.getSize(material).width, lessThanOrEqualTo(340));
      expect(tester.takeException(), isNull);
    },
  );

  for (final preset in [
    UiGalleryBottomNavPreset.concaveNotch,
    UiGalleryBottomNavPreset.splitIsland,
  ]) {
    for (final direction in TextDirection.values) {
      testWidgets(
        '${preset.name} center action remains distinct in $direction',
        (tester) async {
          final host = await _pumpNav(tester, preset: preset);
          var actions = 0;
          host.update(() {
            host.count = 4;
            host.direction = direction;
            host.options = const UiGalleryBottomNavOptions(
              groupBreak: 1,
              notchWidth: 72,
            );
            host.centerAction = IconButton.filled(
              tooltip: 'Create item',
              onPressed: () => actions++,
              icon: const Icon(Icons.add),
            );
          });
          await tester.pumpAndSettle();
          final center = tester.getRect(find.byTooltip('Create item'));
          final before = tester.getRect(find.byTooltip('Tab 0'));
          final after = tester.getRect(find.byTooltip('Tab 1'));
          expect(center.width, greaterThanOrEqualTo(48));
          expect(center.height, greaterThanOrEqualTo(48));
          expect(center.overlaps(before), isFalse);
          expect(center.overlaps(after), isFalse);
          await tester.tap(find.byTooltip('Create item'));
          await tester.pumpAndSettle();
          expect(actions, 1);
          expect(host.callbacks, isEmpty);
          await tester.tap(find.byTooltip('Tab 1'));
          await tester.pumpAndSettle();
          expect(host.callbacks, [1]);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final curve in UiGalleryCurve.values) {
    for (final edge in UiGalleryCurveEdge.values) {
      test('$curve $edge paths remain bounded, closed and mirror in RTL', () {
        for (final rect in [
          const Rect.fromLTWH(10, 20, 300, 100),
          const Rect.fromLTWH(0, 0, 8, 4),
        ]) {
          for (final position in [0.0, .23, .5, 1.0]) {
            final shape = UiGalleryCurvedBorder(
              curve: curve,
              edge: edge,
              depth: 200,
              radius: 50,
              position: position,
              span: .6,
            );
            final ltr = shape.getOuterPath(
              rect,
              textDirection: TextDirection.ltr,
            );
            final rtl = shape.getOuterPath(
              rect,
              textDirection: TextDirection.rtl,
            );
            final bounds = ltr.getBounds();
            expect(bounds.left, greaterThanOrEqualTo(rect.left - .001));
            expect(bounds.right, lessThanOrEqualTo(rect.right + .001));
            expect(bounds.top, greaterThanOrEqualTo(rect.top - .001));
            expect(bounds.bottom, lessThanOrEqualTo(rect.bottom + .001));
            expect(ltr.computeMetrics().single.isClosed, isTrue);
            for (var x = 1; x < 20; x++) {
              for (var y = 1; y < 20; y++) {
                final point = Offset(
                  rect.left + rect.width * x / 20,
                  rect.top + rect.height * y / 20,
                );
                expect(
                  ltr.contains(point),
                  rtl.contains(
                    Offset(rect.left + rect.right - point.dx, point.dy),
                  ),
                );
              }
            }
          }
        }
      });
    }
  }

  testWidgets(
    'curved material excludes its transparent notch from hit testing',
    (tester) async {
      var taps = 0;
      const shape = UiGalleryCurvedBorder(
        curve: UiGalleryCurve.concave,
        depth: 32,
        radius: 0,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                height: 120,
                child: Material(
                  key: const ValueKey('curved-material'),
                  shape: shape,
                  clipBehavior: Clip.antiAlias,
                  color: Colors.amber,
                  child: InkWell(
                    onTap: () => taps++,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final rect = tester.getRect(
        find.byKey(const ValueKey('curved-material')),
      );
      await tester.tapAt(rect.topCenter + const Offset(0, 4));
      await tester.pumpAndSettle();
      expect(taps, 0);
      await tester.tapAt(rect.center);
      await tester.pumpAndSettle();
      expect(taps, 1);
    },
  );
  for (final preset in UiGalleryAppBarPreset.values.skip(8)) {
    testWidgets(
      '${preset.name} preserves safe controls and bottom while collapsing',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(360, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final scroll = ScrollController();
        addTearDown(scroll.dispose);
        var leading = 0;
        var trailing = 0;
        const shape = UiGalleryCurvedBorder(
          curve: UiGalleryCurve.wave,
          edge: UiGalleryCurveEdge.bottom,
          depth: 20,
        );
        const bottom = PreferredSize(
          preferredSize: Size.fromHeight(32),
          child: SizedBox(
            height: 32,
            child: Center(child: Text('Header tabs')),
          ),
        );
        const style = UiGallerySurfaceStyle(shape: shape);
        final bar = UiGalleryAppBar(
          preset: preset,
          title: const Text('Title'),
          bottom: bottom,
          style: style,
        );
        final defaultBar = UiGalleryAppBar(
          preset: preset,
          title: const Text('Title'),
        );
        expect(
          bar.preferredSize.height,
          defaultBar.preferredSize.height + 32 + shape.dimensions.vertical,
        );
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(padding: const EdgeInsets.only(top: 30)),
              child: child!,
            ),
            home: Scaffold(
              body: CustomScrollView(
                controller: scroll,
                slivers: [
                  UiGallerySliverAppBar(
                    preset: preset,
                    expandedHeight: 240,
                    style: style,
                    title: const Text('A long title that remains readable'),
                    subtitle: const Text('Additional workspace context'),
                    bottom: bottom,
                    leading: IconButton(
                      tooltip: 'Go back',
                      onPressed: () => leading++,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    actions: [
                      IconButton(
                        tooltip: 'More options',
                        onPressed: () => trailing++,
                        icon: const Icon(Icons.more_horiz),
                      ),
                    ],
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 1600)),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final headerSurface = find
            .descendant(
              of: find.byType(UiGallerySliverAppBar),
              matching: find.byType(LayoutBuilder),
            )
            .first;
        expect(tester.getSize(headerSurface).height, 270);
        for (final offset in [400.0, 0.0]) {
          scroll.jumpTo(offset);
          await tester.pumpAndSettle();
          final expectedHeight = offset == 0
              ? 270.0
              : kToolbarHeight + shape.dimensions.vertical + 32 + 30;
          expect(tester.getSize(headerSurface).height, expectedHeight);
          for (final tooltip in ['Go back', 'More options']) {
            final rect = tester.getRect(find.byTooltip(tooltip));
            expect(rect.top, greaterThanOrEqualTo(30));
            expect(rect.height, greaterThanOrEqualTo(48));
            expect(rect.width, greaterThanOrEqualTo(48));
            await tester.tap(find.byTooltip(tooltip));
          }
          await tester.pumpAndSettle();
          expect(find.text('Header tabs'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        expect(leading, 2);
        expect(trailing, 2);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  }

  testWidgets('transparent navigation notch lets the background receive taps', (
    tester,
  ) async {
    var backgroundTaps = 0;
    var navigationTaps = 0;
    const shape = UiGalleryCurvedBorder(
      curve: UiGalleryCurve.concave,
      depth: 32,
      radius: 0,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => backgroundTaps++,
                  child: const SizedBox.expand(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: UiGalleryBottomNav(
                  selectedIndex: 0,
                  onDestinationSelected: (_) => navigationTaps++,
                  style: const UiGallerySurfaceStyle(shape: shape),
                  items: const [
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.search),
                      label: 'Search',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final material = find.byWidgetPredicate(
      (widget) => widget is Material && widget.shape == shape,
    );
    final rect = tester.getRect(material);
    await tester.tapAt(rect.topCenter + const Offset(0, 4));
    await tester.pumpAndSettle();
    expect(backgroundTaps, 1);
    expect(navigationTaps, 0);
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    expect(navigationTaps, 1);
    expect(backgroundTaps, 1);
  });
}
