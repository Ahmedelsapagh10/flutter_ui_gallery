import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

class _ObservedValue<T> extends ValueNotifier<T> {
  _ObservedValue(super.value);
  bool get listening => hasListeners;
}

Future<BuildContext> _host(
  WidgetTester tester, {
  PreferredSizeWidget? appBar,
}) async {
  late BuildContext owner;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        appBar: appBar,
        body: Builder(
          builder: (context) {
            owner = context;
            return const Text('Owner page');
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return owner;
}

const _commands = [
  UiGalleryDialogAction(label: 'Create note', value: 1),
  UiGalleryDialogAction(label: 'Archive', value: 2, enabled: false),
  UiGalleryDialogAction(
    label: 'Saved ideas',
    description: 'Your collection',
    value: 3,
  ),
];

void main() {
  testWidgets(
    'commands search descriptions and return a typed keyboard result',
    (tester) async {
      final context = await _host(tester);
      final result = UiGalleryDialog.commands<int>(
        context: context,
        title: 'Commands',
        commands: _commands,
        emptyLabel: 'Nothing found',
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'COLLECTION');
      await tester.pumpAndSettle();
      expect(find.text('Create note'), findsNothing);
      expect(find.text('Saved ideas'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(await result, 3);
      expect(find.text('Owner page'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );

  testWidgets('command arrows skip disabled entries and wrap', (tester) async {
    final context = await _host(tester);
    final result = UiGalleryDialog.commands<int>(
      context: context,
      title: 'Commands',
      commands: _commands,
      emptyLabel: 'Nothing found',
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(await result, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty search cannot run a command and Escape dismisses', (
    tester,
  ) async {
    final context = await _host(tester);
    final result = UiGalleryDialog.commands<int>(
      context: context,
      title: 'Commands',
      commands: _commands,
      emptyLabel: 'Nothing found',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('Nothing found'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });

  testWidgets(
    'duplicate command objects are safe and all-disabled commands stay open',
    (tester) async {
      final context = await _host(tester);
      const disabled = UiGalleryDialogAction(
        label: 'Unavailable',
        value: 1,
        enabled: false,
      );
      final result = UiGalleryDialog.commands<int>(
        context: context,
        title: 'Commands',
        commands: const [disabled, disabled],
        emptyLabel: 'Nothing found',
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Unavailable'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.byType(TextField))).pop();
      await tester.pumpAndSettle();
      expect(await result, isNull);
    },
  );

  testWidgets(
    'commands remain reachable with RTL, large text and a keyboard inset',
    (tester) async {
      tester.view.physicalSize = const Size(320, 620);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      late BuildContext owner;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(3),
                viewInsets: const EdgeInsets.only(bottom: 250),
              ),
              child: child!,
            ),
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
      final result = UiGalleryDialog.commands<int>(
        context: owner,
        title: 'Commands',
        commands: _commands,
        emptyLabel: 'Nothing found',
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Saved');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Saved ideas'));
      await tester.tap(find.text('Saved ideas'));
      await tester.pumpAndSettle();
      expect(await result, 3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dialogs use caller labels and disabled decisions do not pop', (
    tester,
  ) async {
    final context = await _host(tester);
    final result = UiGalleryDialog.show<int>(
      context: context,
      title: 'Choose',
      eyebrow: 'Workspace',
      actions: const [
        UiGalleryDialogAction(
          label: 'Unavailable',
          value: 1,
          primary: true,
          enabled: false,
        ),
        UiGalleryDialogAction(label: 'Available', value: 2),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('HALO'), findsNothing);
    expect(find.text('Workspace'), findsOneWidget);
    await tester.tap(find.text('Unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('Choose'), findsOneWidget);
    await tester.tap(find.text('Available'));
    await tester.pumpAndSettle();
    expect(await result, 2);
  });

  testWidgets(
    'selection header is controlled and retains trailing bulk actions',
    (tester) async {
      var clears = 0;
      var archives = 0;
      await _host(
        tester,
        appBar: UiGalleryAppBar(
          preset: UiGalleryAppBarPreset.selectionBar,
          title: const Text('Notes'),
          selectionCount: 2,
          onSelectionCleared: () => clears++,
          actions: [
            IconButton(
              tooltip: 'Archive',
              onPressed: () => archives++,
              icon: const Icon(Icons.archive),
            ),
          ],
        ),
      );
      expect(find.text('2 items selected'), findsOneWidget);
      expect(find.text('Notes'), findsNothing);
      await tester.tap(find.byTooltip('Close'));
      await tester.tap(find.byTooltip('Archive'));
      expect(clears, 1);
      expect(archives, 1);
      expect(find.text('2 items selected'), findsOneWidget);
      expect(tester.getRect(find.byTooltip('Archive')).right, greaterThan(740));
      expect(
        tester.getSize(find.byTooltip('Close')).shortestSide,
        greaterThanOrEqualTo(48),
      );
    },
  );

  testWidgets(
    'progress is real, bounded, persistent and releases its listener',
    (tester) async {
      final context = await _host(tester);
      final progress = _ObservedValue(.25);
      final handle = UiGalleryToast.progress(
        context,
        message: 'Uploading',
        progress: progress,
      );
      await tester.pumpAndSettle();
      expect(progress.listening, isTrue);
      expect(find.text('25%'), findsOneWidget);
      progress.value = .5;
      await tester.pump();
      expect(find.text('50%'), findsOneWidget);
      progress.value = double.nan;
      await tester.pump();
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0,
      );
      progress.value = 2;
      await tester.pump();
      expect(find.text('100%'), findsOneWidget);
      await tester.pump(const Duration(minutes: 2));
      await tester.pumpAndSettle();
      expect(find.text('Uploading'), findsOneWidget);
      handle.dismiss();
      await tester.pumpAndSettle();
      await handle.closed;
      expect(progress.listening, isFalse);
      progress.value = .1;
      progress.dispose();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'progress cancellation runs once and cleanup does not dispose caller state',
    (tester) async {
      final context = await _host(tester);
      final progress = _ObservedValue(.1);
      var cancelled = 0;
      final handle = UiGalleryToast.progress(
        context,
        message: 'Uploading',
        progress: progress,
        actionLabel: 'Cancel upload',
        onAction: () => cancelled++,
        progressLabelBuilder: (value) => '${(value * 10).round()} of 10',
      );
      await tester.pumpAndSettle();
      expect(find.text('1 of 10'), findsOneWidget);
      await tester.tap(find.text('Cancel upload'));
      await tester.tap(find.text('Cancel upload'));
      await tester.pumpAndSettle();
      await handle.closed;
      expect(cancelled, 1);
      expect(progress.listening, isFalse);
      progress.value = .5;
      progress.dispose();
    },
  );

  testWidgets('owner disposal cleans up a progress toast', (tester) async {
    final context = await _host(tester);
    final progress = _ObservedValue(.2);
    final handle = UiGalleryToast.progress(
      context,
      message: 'Uploading',
      progress: progress,
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await handle.closed;
    expect(progress.listening, isFalse);
    progress.dispose();
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('convenience methods preserve surface overrides', (tester) async {
    final context = await _host(tester);
    const style = UiGallerySurfaceStyle(
      surfaceColor: Colors.orange,
      messageStyle: TextStyle(fontSize: 19),
    );
    for (final show in [
      UiGalleryToast.success,
      UiGalleryToast.warning,
      UiGalleryToast.error,
    ]) {
      final handle = show(
        context,
        message: 'Styled',
        style: style,
        motion: const UiGalleryMotion(intensity: 0),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.text('Styled')).style?.fontSize, 19);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Material && widget.color == Colors.orange,
        ),
        findsWidgets,
      );
      handle.dismiss();
      await tester.pumpAndSettle();
      await handle.closed;
    }
    final state = _ObservedValue(
      const UiGalleryTimelineState(steps: ['Upload'], currentStep: 0),
    );
    final future = UiGalleryDialog.timeline(
      context: context,
      title: 'Processing',
      progress: state,
      style: style,
      motion: const UiGalleryMotion(intensity: 0),
    );
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Material && widget.color == Colors.orange,
      ),
      findsWidgets,
    );
    Navigator.of(tester.element(find.text('Processing'))).pop();
    await tester.pumpAndSettle();
    await future;
    expect(state.listening, isFalse);
    state.dispose();
  });

  testWidgets(
    'overflow selection uses original indexes without changing routes',
    (tester) async {
      var selected = 0;
      final callbacks = <int>[];
      late StateSetter update;
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          home: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Scaffold(
                body: Text('Page $selected'),
                bottomNavigationBar: UiGalleryBottomNav(
                  preset: UiGalleryBottomNavPreset.overflowDock,
                  selectedIndex: selected,
                  options: const UiGalleryBottomNavOptions(
                    maxVisibleItems: 3,
                    overflowLabel: 'Other',
                  ),
                  items: List.generate(
                    6,
                    (i) => UiGalleryBottomNavItem(
                      icon: const Icon(Icons.circle),
                      label: 'Tab $i',
                      enabled: i != 4,
                      semanticLabel: 'Destination $i',
                    ),
                  ),
                  onDestinationSelected: (index) => setState(() {
                    callbacks.add(index);
                    selected = index;
                  }),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tab 5'), findsNothing);
      await tester.tap(find.byTooltip('Other'));
      await tester.pumpAndSettle();
      expect(navigator.currentState!.canPop(), isFalse);
      expect(
        tester
            .widget<MenuItemButton>(
              find.widgetWithText(MenuItemButton, 'Tab 4'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Tab 5'));
      await tester.pumpAndSettle();
      expect(callbacks, [5]);
      expect(find.text('Page 5'), findsOneWidget);
      final semantics = tester.ensureSemantics();
      try {
        expect(
          tester
                  .getSemantics(find.byTooltip('Other'))
                  .getSemanticsData()
                  .flagsCollection
                  .isSelected ==
              Tristate.isTrue,
          isTrue,
        );
      } finally {
        semantics.dispose();
      }
      update(() => selected = 0);
      await tester.pumpAndSettle();
      expect(find.text('Page 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'overflow adapts to narrow RTL layouts and preserves disabled hidden choices',
    (tester) async {
      tester.view.physicalSize = const Size(180, 620);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final callbacks = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(3)),
              child: child!,
            ),
          ),
          home: Scaffold(
            bottomNavigationBar: UiGalleryBottomNav(
              preset: UiGalleryBottomNavPreset.overflowDock,
              selectedIndex: 5,
              onDestinationSelected: callbacks.add,
              items: List.generate(
                6,
                (i) => UiGalleryBottomNavItem(
                  icon: const Icon(Icons.circle),
                  label: 'Tab $i',
                  enabled: i != 4,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Tab 2'), findsNothing);
      expect(
        tester.getSize(find.byTooltip('More')).shortestSide,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tab 4'));
      await tester.tap(find.text('Tab 4'));
      await tester.pumpAndSettle();
      expect(callbacks, isEmpty);
      await tester.ensureVisible(find.text('Tab 5'));
      await tester.tap(find.text('Tab 5'));
      await tester.pumpAndSettle();
      expect(callbacks, [5]);
      tester.view.physicalSize = const Size(800, 620);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Tab 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
