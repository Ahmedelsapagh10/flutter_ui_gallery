import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

const _titleKey = ValueKey('header-title');
const _actionKey = ValueKey('header-action');

void _expectTrailingAction(
  WidgetTester tester,
  UiGalleryAppBarPreset preset,
  TextDirection direction, {
  bool compact = false,
}) {
  final action = find.byKey(_actionKey);
  final rows = <Element>[];
  Element? toolbar;
  tester.element(action).visitAncestorElements((element) {
    if (element.widget is Row) rows.add(element);
    if (element.widget is NavigationToolbar) toolbar = element;
    return rows.length < 2 && toolbar == null;
  });
  final row = tester.getRect(
    find.byElementPredicate((e) => e == (toolbar ?? rows.last)),
  );
  final button = tester.getRect(action);
  final endInset = preset == UiGalleryAppBarPreset.compactRail
      ? 15.0
      : preset == UiGalleryAppBarPreset.orbitCommand && !compact
      ? 5.0
      : 0.0;
  expect(
    direction == TextDirection.ltr
        ? row.right - button.right
        : button.left - row.left,
    closeTo(endInset, .01),
    reason: '${preset.name} / $direction must anchor actions at the row end',
  );
  expect(button.width, greaterThanOrEqualTo(48));
  expect(button.height, greaterThanOrEqualTo(48));
  expect(
    tester.getSize(find.byKey(_titleKey)).width,
    greaterThanOrEqualTo(
      row.width - (preset == UiGalleryAppBarPreset.searchSwitch ? 200 : 148),
    ),
    reason: 'A single action should leave the remaining width for the title',
  );
  expect(tester.takeException(), isNull);
}

Widget _host(Widget child, TextDirection direction) => MaterialApp(
  theme: ThemeData(extensions: const [UiGalleryTheme(motionIntensity: 0)]),
  builder: (context, child) =>
      Directionality(textDirection: direction, child: child!),
  home: child,
);

void main() {
  for (final preset in UiGalleryAppBarPreset.values) {
    testWidgets('${preset.name} anchors a single action at the trailing edge', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      var notifications = 0;
      var back = 0;
      for (final width in [320.0, 390.0]) {
        tester.view.physicalSize = Size(width, 800);
        for (final direction in TextDirection.values) {
          await tester.pumpWidget(
            _host(
              Scaffold(
                appBar: UiGalleryAppBar(
                  preset: preset,
                  scrollAware: true,
                  title: const Text(
                    'Make it your space with a longer workspace title',
                    key: _titleKey,
                  ),
                  subtitle: const Text('Choose what happens next.'),
                  leading: IconButton(
                    tooltip: 'Go back',
                    onPressed: () => back++,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  actions: [
                    IconButton(
                      key: _actionKey,
                      tooltip: 'Notifications',
                      onPressed: () => notifications++,
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                  ],
                ),
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
          _expectTrailingAction(tester, preset, direction);
          await tester.tap(find.byKey(_actionKey));
          await tester.tap(find.byTooltip('Go back'));
        }
      }
      expect(notifications, 4);
      expect(back, 4);
    });

    testWidgets('${preset.name} keeps overflowing actions reachable', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(240, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      var lastAction = 0;
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          _host(
            Scaffold(
              appBar: UiGalleryAppBar(
                preset: preset,
                title: const Text('Your workspace'),
                leading: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu),
                ),
                actions: [
                  for (var i = 0; i < 6; i++)
                    IconButton(
                      tooltip: 'Action $i',
                      onPressed: () {
                        if (i == 5) lastAction++;
                      },
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                ],
              ),
            ),
            direction,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byType(SingleChildScrollView),
          Offset(direction == TextDirection.ltr ? -600 : 600, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Action 5'));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
      expect(lastAction, 2);
    });

    testWidgets(
      '${preset.name} keeps sliver actions aligned while collapsing',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        for (final direction in TextDirection.values) {
          await tester.pumpWidget(
            _host(
              Scaffold(
                body: CustomScrollView(
                  slivers: [
                    UiGallerySliverAppBar(
                      preset: preset,
                      title: const Text(
                        'Make it your space with a longer workspace title',
                        key: _titleKey,
                      ),
                      subtitle: const Text('Choose what happens next.'),
                      actions: [
                        IconButton(
                          key: _actionKey,
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_outlined),
                        ),
                      ],
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 1600)),
                  ],
                ),
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
          _expectTrailingAction(tester, preset, direction);
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -500),
          );
          await tester.pumpAndSettle();
          _expectTrailingAction(tester, preset, direction, compact: true);
          await tester.pumpWidget(const SizedBox());
        }
      },
    );
  }
}
