import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:nova_surfaces_example/gallery/catalog.dart';
import 'package:nova_surfaces_example/gallery/configuration.dart';
import 'package:nova_surfaces_example/gallery/demo.dart';
import 'package:nova_surfaces_example/gallery/recipes.dart';
import 'package:nova_surfaces_example/main.dart';

Future<void> _gallery(
  WidgetTester tester, {
  PlaygroundConfiguration configuration = const PlaygroundConfiguration(),
}) async {
  tester.view.physicalSize = const Size(1280, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(FlutterUiGalleryApp(configuration: configuration));
  await tester.pumpAndSettle();
}

Future<void> _recipe(
  WidgetTester tester,
  Widget example, {
  bool routed = false,
}) async {
  tester.view.physicalSize = const Size(800, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: const [UiGalleryTheme(motionIntensity: 0)]),
      home: routed
          ? Builder(
              builder: (context) => Scaffold(
                body: FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: (_) => example)),
                  child: const Text('Open example'),
                ),
              ),
            )
          : example,
    ),
  );
  if (routed) {
    await tester.tap(find.text('Open example'));
  }
  // Dashboard and injected operations can remain pending indefinitely.
  await _finishRouteTransition(tester);
}

Future<void> _finishRouteTransition(WidgetTester tester) async {
  await tester.pump();
  for (var frame = 0; frame < 4; frame++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _basket(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Add Everyday notebook'));
  await tester.pump();
  await tester.tap(find.text('Basket'));
  await tester.pumpAndSettle();
}

Future<void> _startPreparation(WidgetTester tester) async {
  await tester.tap(find.text('Prepare basket'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField), '  Sam  ');
  await tester.tap(find.text('Prepare order'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

DropdownButton<int> _presets(WidgetTester tester) =>
    tester.widget<DropdownButton<int>>(find.byType(DropdownButton<int>));

void main() {
  test('configuration round-trips all settings through a fragment link', () {
    const original = PlaygroundConfiguration(
      preset: 'header.sculptedWave',
      family: UiGalleryDesignFamily.spatial,
      dark: true,
      rtl: true,
      reduced: true,
      accent: Color(0xff0d9488),
      width: 768,
      title: 'A & B / مرحبا 👩🏽‍💻',
      message: 'First line\n"quoted" + \$value # fragment',
      transitionMs: 360,
      curveDepth: 20,
      depthIntensity: .6,
    );
    final uri = original.toUri(Uri.parse('https://example.com/gallery/?v=1'));
    expect(uri.path, '/gallery/');
    expect(uri.queryParameters, {'v': '1'});
    expect(uri.fragment, startsWith('/?'));
    final restored = PlaygroundConfiguration.fromUri(uri);
    expect(restored.preset, original.preset);
    expect(restored.family, original.family);
    expect(restored.dark, isTrue);
    expect(restored.rtl, isTrue);
    expect(restored.reduced, isTrue);
    expect(restored.accent, original.accent);
    expect(restored.width, original.width);
    expect(restored.title, original.title);
    expect(restored.message, original.message);
    expect(restored.transitionMs, original.transitionMs);
    expect(restored.curveDepth, original.curveDepth);
    expect(restored.depthIntensity, original.depthIntensity);
    expect(restored.toUri(uri), uri);
  });

  test(
    'configuration validates untrusted numeric, color and family values',
    () {
      for (final invalid in ['NaN', 'Infinity', '-1', '100000', 'text']) {
        final config = PlaygroundConfiguration.fromUri(
          Uri.https('example.com', '/', {
            'width': invalid,
            'duration': invalid,
            'curve': invalid,
            'depth': invalid,
            'accent': 'ff00ff00',
            'family': 'unknown',
            'dark': 'true',
          }),
        );
        expect(config.width, 390);
        expect(config.transitionMs, isNull);
        expect(config.curveDepth, isNull);
        expect(config.depthIntensity, 1);
        expect(config.accent, const Color(0xff4f46e5));
        expect(config.family, UiGalleryDesignFamily.soft);
        expect(config.dark, isFalse);
      }
      final malformed = PlaygroundConfiguration.fromUri(
        Uri(fragment: '/?family=%GG'),
      );
      expect(malformed.family, UiGalleryDesignFamily.soft);
      final fragmentWins = PlaygroundConfiguration.fromUri(
        Uri.parse('https://example.com/?family=minimal#/?family=spatial'),
      );
      expect(fragmentWins.family, UiGalleryDesignFamily.spatial);
    },
  );

  test(
    'configuration bounds text by grapheme and accepts numeric boundaries',
    () {
      const grapheme = '👩🏽‍💻';
      final config = PlaygroundConfiguration.fromUri(
        Uri.https('example.com', '/', {
          'title': List.filled(201, grapheme).join(),
          'message': List.filled(1001, grapheme).join(),
          'duration': '120',
          'curve': '28',
          'depth': '0',
          'width': '1200',
          'accent': 'aAbBcC',
        }),
      );
      expect(config.title, List.filled(200, grapheme).join());
      expect(config.message, List.filled(1000, grapheme).join());
      expect(config.transitionMs, 120);
      expect(config.curveDepth, 28);
      expect(config.depthIntensity, 0);
      expect(config.width, 1200);
      expect(config.accent, const Color(0xffaabbcc));
    },
  );

  test(
    'catalog IDs are public preset names and recommendations span tasks',
    () {
      final expected = {
        for (final preset in UiGallerySheetPreset.values)
          'sheets.${preset.name}',
        for (final preset in UiGalleryDialogPreset.values)
          'dialogs.${preset.name}',
        for (final preset in UiGalleryToastPreset.values)
          'toasts.${preset.name}',
        for (final preset in UiGalleryAppBarPreset.values)
          'header.${preset.name}',
        for (final preset in UiGalleryBottomNavPreset.values)
          'bottomNav.${preset.name}',
      };
      expect(designs.map((design) => design.id).toSet(), expected);
      expect(expected, hasLength(66));
      expect(
        designs
            .where((design) => design.recommended)
            .map((design) => design.id)
            .toSet(),
        {
          'sheets.orbit',
          'dialogs.halo',
          'dialogs.commandPalette',
          'toasts.signal',
          'toasts.progressCard',
          'header.searchSwitch',
          'header.selectionBar',
          'bottomNav.adaptiveMinimal',
        },
      );
      for (final purpose in DesignPurpose.values) {
        expect(
          designs.where((design) => design.purpose == purpose),
          isNotEmpty,
        );
        expect(purposeLabel(purpose), isNotEmpty);
      }
    },
  );

  testWidgets('gallery defaults to Soft and family changes keep the preset', (
    tester,
  ) async {
    await _gallery(tester);
    expect(find.text('Soft'), findsOneWidget);
    final before = tester.widget<SurfaceDemo>(find.byType(SurfaceDemo)).index;
    await tester.ensureVisible(find.byTooltip('Design family'));
    await tester.tap(find.byTooltip('Design family'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Minimal').last);
    await tester.pumpAndSettle();
    expect(tester.widget<SurfaceDemo>(find.byType(SurfaceDemo)).index, before);
    final theme = Theme.of(
      tester.element(find.byType(SurfaceDemo)),
    ).extension<UiGalleryTheme>()!;
    expect(theme.surfaceStyle!.elevation, 0);
    expect(theme.motion!.entrance, const Duration(milliseconds: 180));
    expect(
      tester
          .widget<SelectableText>(find.byKey(const ValueKey('dart-snippet')))
          .textSpan!
          .toPlainText(),
      contains('UiGalleryDesignFamily.minimal'),
    );
  });

  testWidgets(
    'seeded shared configuration restores preview and copies its link',
    (tester) async {
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
      final configuration = PlaygroundConfiguration.fromUri(
        Uri.parse(
          'https://example.com/#/?preset=header.sculptedWave&family=spatial&dark=1&rtl=1&reduced=1&accent=0d9488&width=768&title=Shared+title&message=Shared+message&duration=360&curve=20&depth=0.6',
        ),
      );
      await _gallery(tester, configuration: configuration);
      final demo = tester.widget<SurfaceDemo>(find.byType(SurfaceDemo));
      expect(designs[demo.index].id, 'header.sculptedWave');
      expect(demo.title, 'Shared title');
      expect(demo.message, 'Shared message');
      expect(demo.curveDepth, 20);
      expect(demo.depthIntensity, .6);
      final context = tester.element(find.byType(SurfaceDemo));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(Directionality.of(context), TextDirection.rtl);
      final theme = Theme.of(context).extension<UiGalleryTheme>()!;
      expect(theme.motionIntensity, 0);
      expect(theme.motion!.change, const Duration(milliseconds: 360));
      expect(theme.surfaceStyle!.accentColor, const Color(0xff0d9488));
      await tester.tap(find.byTooltip('Share configuration'));
      await tester.pumpAndSettle();
      expect(copied, isNotNull);
      final restored = PlaygroundConfiguration.fromUri(Uri.parse(copied!));
      expect(restored.preset, configuration.preset);
      expect(restored.family, configuration.family);
      expect(restored.title, configuration.title);
      expect(restored.message, configuration.message);
      expect(restored.width, configuration.width);
      expect(restored.dark && restored.rtl && restored.reduced, isTrue);
      expect(restored.curveDepth, 20);
      expect(restored.depthIntensity, .6);
      expect(find.text('Configuration link copied'), findsOneWidget);
    },
  );

  testWidgets('unknown shared preset safely opens the first design', (
    tester,
  ) async {
    await _gallery(
      tester,
      configuration: const PlaygroundConfiguration(preset: 'unknown.preset'),
    );
    expect(tester.widget<SurfaceDemo>(find.byType(SurfaceDemo)).index, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared initial route keeps its incoming configuration name', (
    tester,
  ) async {
    const route = '/?preset=dialogs.commandPalette&family=minimal';
    tester.platformDispatcher.defaultRouteNameTestValue = route;
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
    await _gallery(
      tester,
      configuration: PlaygroundConfiguration.fromUri(
        Uri.parse('https://example.com/#$route'),
      ),
    );
    final context = tester.element(find.byTooltip('Share configuration'));
    expect(ModalRoute.of(context)!.settings.name, route);
    final demo = tester.widget<SurfaceDemo>(find.byType(SurfaceDemo));
    expect(designs[demo.index].id, 'dialogs.commandPalette');
    expect(find.text('Minimal'), findsOneWidget);
  });

  testWidgets('a new shared route updates an already open playground', (
    tester,
  ) async {
    await _gallery(tester);
    final context = tester.element(find.byTooltip('Share configuration'));
    unawaited(
      Navigator.of(context).pushNamed<void>(
        '/?preset=dialogs.commandPalette&family=spatial&dark=1&title=Shared%20again',
      ),
    );
    await tester.pumpAndSettle();
    final demo = tester.widget<SurfaceDemo>(find.byType(SurfaceDemo));
    expect(designs[demo.index].id, 'dialogs.commandPalette');
    expect(demo.title, 'Shared again');
    expect(find.text('Spatial'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(SurfaceDemo))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('recommended and task browsing expose matching presets', (
    tester,
  ) async {
    await _gallery(tester);
    await tester.tap(find.text('Recommended'));
    await tester.pumpAndSettle();
    expect(_presets(tester).items!.map((item) => designs[item.value!].id), [
      'sheets.orbit',
    ]);
    await tester.tap(find.byTooltip('Browse by task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bulk selection').last);
    await tester.pumpAndSettle();
    expect(_presets(tester).items!.map((item) => designs[item.value!].id), [
      'header.selectionBar',
    ]);
    expect(
      tester.widget<SurfaceDemo>(find.byType(SurfaceDemo)).index,
      designs.indexWhere((design) => design.id == 'header.selectionBar'),
    );
    await tester.tap(find.text('All tasks'));
    await tester.pumpAndSettle();
    expect(
      _presets(tester).items,
      hasLength(UiGalleryAppBarPreset.values.length),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('real app examples hub opens and returns from each recipe', (
    tester,
  ) async {
    await _gallery(tester);
    await tester.tap(find.byTooltip('Real app examples'));
    await tester.pumpAndSettle();
    expect(find.byType(RecipeGallery), findsOneWidget);
    for (final recipe in ['Productivity', 'Shopping', 'Dashboard']) {
      await tester.tap(find.text(recipe));
      await tester.pumpAndSettle();
      expect(
        find.text(switch (recipe) {
          'Productivity' => 'Workspace',
          'Shopping' => 'Field Store',
          _ => 'Team overview',
        }),
        findsOneWidget,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(find.byType(RecipeGallery), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'productivity validates note creation and retains its search query',
    (tester) async {
      await _recipe(tester, const ProductivityExample());
      await tester.tap(find.byTooltip('New note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create note'));
      await tester.pump();
      expect(find.text('Enter note title'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '  Review release  ');
      await tester.tap(find.text('Create note'));
      await tester.pumpAndSettle();
      expect(find.text('Review release'), findsOneWidget);
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Review release');
      await tester.pump();
      expect(find.byType(CheckboxListTile), findsOneWidget);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      expect(find.text('1 item selected'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Review release',
      );
      await tester.enterText(find.byType(TextField), 'missing note');
      await tester.pump();
      expect(find.text('No matching notes'), findsOneWidget);
    },
  );

  testWidgets(
    'typed productivity commands select, cancel, archive and undo notes',
    (tester) async {
      await _recipe(tester, const ProductivityExample());
      await tester.tap(find.byTooltip('Workspace commands'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'unmatched');
      await tester.pump();
      expect(find.text('No matching actions'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'select');
      await tester.pump();
      await tester.tap(find.text('Select all notes'));
      await tester.pumpAndSettle();
      expect(find.text('3 items selected'), findsOneWidget);
      await tester.tap(find.byTooltip('Archive selected notes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
      expect(find.text('3 items selected'), findsOneWidget);
      await tester.tap(find.byTooltip('Archive selected notes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();
      expect(
        find.text('Your workspace is empty. Create a note to begin.'),
        findsOneWidget,
      );
      expect(find.text('3 notes archived'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
      expect(find.text('Workspace'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('back clears productivity selection before leaving its route', (
    tester,
  ) async {
    await _recipe(tester, const ProductivityExample(), routed: true);
    await tester.tap(find.byKey(const ValueKey('recipe-note-1')));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ProductivityExample), findsOneWidget);
    expect(find.text('Workspace'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(find.byKey(const ValueKey('recipe-note-1')))
          .value,
      isFalse,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Open example'), findsOneWidget);
  });

  testWidgets(
    'shopping retains quantities across pages and validates its recipient',
    (tester) async {
      var calls = 0;
      await _recipe(
        tester,
        ShoppingExample(
          prepare: (_, _) async {
            calls++;
          },
        ),
      );
      await _basket(tester);
      expect(find.text('Quantity: 1'), findsOneWidget);
      await tester.tap(find.text('Shop'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Add Everyday notebook'));
      await tester.tap(find.byTooltip('Add Pocket planner'));
      await tester.pump();
      await tester.tap(find.text('Basket'));
      await tester.pumpAndSettle();
      expect(find.text('Quantity: 2'), findsOneWidget);
      expect(find.text('Total: \$42.00'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove Everyday notebook'));
      await tester.pump();
      expect(find.text('Total: \$30.00'), findsOneWidget);
      await tester.tap(find.text('Prepare basket'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prepare order'));
      await tester.pump();
      expect(find.text('Enter recipient name'), findsOneWidget);
      expect(calls, 0);
      await tester.enterText(find.byType(TextFormField), '  Sam  ');
      await tester.tap(find.text('Prepare order'));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('Basket ready for Sam'), findsOneWidget);
      expect(find.text('Total: \$30.00'), findsOneWidget);
    },
  );

  testWidgets(
    'shopping reports injected progress and waits for actual completion',
    (tester) async {
      final operation = Completer<void>();
      late ValueChanged<double> progress;
      late bool Function() cancelled;
      await _recipe(
        tester,
        ShoppingExample(
          prepare: (update, isCancelled) {
            progress = update;
            cancelled = isCancelled;
            return operation.future;
          },
        ),
      );
      await _basket(tester);
      await _startPreparation(tester);
      expect(find.text('Preparing…'), findsOneWidget);
      expect(find.text('Basket ready for Sam'), findsNothing);
      expect(cancelled(), isFalse);
      progress(.5);
      await tester.pump();
      expect(find.text('50%'), findsOneWidget);
      progress(1);
      await tester.pump();
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Basket ready for Sam'), findsNothing);
      operation.complete();
      await tester.pumpAndSettle();
      expect(find.text('Basket ready for Sam'), findsOneWidget);
      expect(find.text('Cancel preparation'), findsNothing);
      expect(find.text('Prepare basket'), findsOneWidget);
    },
  );

  testWidgets(
    'shopping retries a failed operation without losing the basket or recipient',
    (tester) async {
      final first = Completer<void>();
      final retry = Completer<void>();
      var calls = 0;
      await _recipe(
        tester,
        ShoppingExample(
          prepare: (_, _) => ++calls == 1 ? first.future : retry.future,
        ),
      );
      await _basket(tester);
      await _startPreparation(tester);
      first.completeError(StateError('network unavailable'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not prepare your basket. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Quantity: 1'), findsOneWidget);
      await tester.tap(find.text('Retry preparation'));
      await tester.pump();
      expect(calls, 2);
      expect(find.byType(TextFormField), findsNothing);
      retry.complete();
      await tester.pumpAndSettle();
      expect(find.text('Basket ready for Sam'), findsOneWidget);
      expect(
        find.text('Could not prepare your basket. Please try again.'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'shopping cancellation preserves the basket until the operation acknowledges it',
    (tester) async {
      final operation = Completer<void>();
      late ValueChanged<double> progress;
      late bool Function() cancelled;
      await _recipe(
        tester,
        ShoppingExample(
          prepare: (update, isCancelled) {
            progress = update;
            cancelled = isCancelled;
            return operation.future;
          },
        ),
      );
      await _basket(tester);
      await _startPreparation(tester);
      await tester.tap(find.text('Cancel preparation'));
      await tester.pump();
      expect(cancelled(), isTrue);
      expect(
        find.text('Preparation cancelled. Your basket is preserved.'),
        findsOneWidget,
      );
      expect(find.text('Preparing…'), findsOneWidget);
      progress(.75);
      operation.complete();
      await tester.pumpAndSettle();
      expect(find.text('Quantity: 1'), findsOneWidget);
      expect(find.text('Prepare basket'), findsOneWidget);
      expect(find.text('Basket ready for Sam'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'shopping route disposal cancels pending work and removes its progress toast',
    (tester) async {
      final operation = Completer<void>();
      late ValueChanged<double> progress;
      late bool Function() cancelled;
      await _recipe(
        tester,
        ShoppingExample(
          prepare: (update, isCancelled) {
            progress = update;
            cancelled = isCancelled;
            return operation.future;
          },
        ),
        routed: true,
      );
      await _basket(tester);
      await _startPreparation(tester);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(
        tester
            .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
            .selectedIndex,
        0,
      );
      await tester.binding.handlePopRoute();
      await _finishRouteTransition(tester);
      expect(find.byType(ShoppingExample), findsNothing);
      expect(cancelled(), isTrue);
      expect(find.text('Cancel preparation'), findsNothing);
      progress(.9);
      operation.complete();
      await tester.pumpAndSettle();
      expect(find.text('Open example'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dashboard renders loading, injected data and an empty refresh', (
    tester,
  ) async {
    final first = Completer<List<ExampleMetric>>();
    final second = Completer<List<ExampleMetric>>();
    var calls = 0;
    await _recipe(
      tester,
      DashboardExample(load: () => ++calls == 1 ? first.future : second.future),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.refresh))
          .onPressed,
      isNull,
    );
    first.complete(const [ExampleMetric('Open reviews', '7')]);
    await tester.pumpAndSettle();
    expect(find.text('Open reviews'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    await tester.tap(find.byTooltip('Refresh overview'));
    await tester.pump();
    expect(calls, 2);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    second.complete(const []);
    await tester.pumpAndSettle();
    expect(find.text('No activity yet'), findsOneWidget);
    expect(find.text('Open reviews'), findsNothing);
    expect(find.text('Refresh overview'), findsOneWidget);
  });

  testWidgets('dashboard exposes load errors and retries its injected loader', (
    tester,
  ) async {
    final first = Completer<List<ExampleMetric>>();
    final retry = Completer<List<ExampleMetric>>();
    var calls = 0;
    await _recipe(
      tester,
      DashboardExample(load: () => ++calls == 1 ? first.future : retry.future),
    );
    first.completeError(StateError('unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load the overview'), findsOneWidget);
    await tester.tap(find.text('Retry overview'));
    await tester.pump();
    expect(calls, 2);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    retry.complete(const [ExampleMetric('Recovered tasks', '9')]);
    await tester.pumpAndSettle();
    expect(find.text('Recovered tasks'), findsOneWidget);
    expect(find.text('Could not load the overview'), findsNothing);
  });

  testWidgets('dashboard ignores completion after the route is disposed', (
    tester,
  ) async {
    final pending = Completer<List<ExampleMetric>>();
    await _recipe(
      tester,
      DashboardExample(load: () => pending.future),
      routed: true,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.binding.handlePopRoute();
    await _finishRouteTransition(tester);
    expect(find.byType(DashboardExample), findsNothing);
    pending.complete(const [ExampleMetric('Late result', '1')]);
    await tester.pumpAndSettle();
    expect(find.text('Open example'), findsOneWidget);
    expect(find.text('Late result'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
