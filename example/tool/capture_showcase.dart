import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_surfaces_example/showcase.dart';
import '../../tool/showcase_boards.dart';

const output = 'doc/assets/showcase-v021';

Future<void> save(WidgetTester tester, GlobalKey key, String name) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: name);
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('$output/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  Directory.current = Directory.current.parent;
  setUpAll(() async {
    await Directory(output).create(recursive: true);
    final root =
        Platform.environment['FLUTTER_ROOT'] ??
        File(Platform.resolvedExecutable).parent.parent.parent.parent.path;
    for (final entry in {
      'Roboto': 'Roboto-Regular.ttf',
      'MaterialIcons': 'MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(
          File(
            '$root/bin/cache/artifacts/material_fonts/${entry.value}',
          ).readAsBytes().then(ByteData.sublistView),
        );
      await loader.load();
    }
    final monoPath =
        Platform.environment['SHOWCASE_MONO_FONT'] ??
        (Platform.isMacOS ? '/System/Library/Fonts/Menlo.ttc' : null);
    if (monoPath == null || !File(monoPath).existsSync()) {
      throw StateError('Set SHOWCASE_MONO_FONT to a real monospace font file.');
    }
    final mono = FontLoader('monospace')
      ..addFont(File(monoPath).readAsBytes().then(ByteData.sublistView));
    await mono.load();
    final bold = FontLoader('Roboto')
      ..addFont(
        File(
          '$root/bin/cache/artifacts/material_fonts/Roboto-Bold.ttf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await bold.load();
  });

  testWidgets('capture all 66 canonical presets and useful states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final inventory =
        jsonDecode(File('doc/catalog/inventory.json').readAsStringSync())
            as List;
    for (final entry in inventory) {
      final id = entry['id'] as String;
      for (final dark in [false, if (recommended.contains(id)) true]) {
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: ShowcaseApp(
              key: ValueKey('$id-$dark'),
              preset: id,
              dark: dark,
              autoOpen: true,
              still: true,
            ),
          ),
        );
        await save(tester, key, '$id${dark ? '-dark' : ''}');
        if (!dark) {
          switch (id) {
            case 'header.searchSwitch':
              await tester.tap(find.byTooltip('Search'));
              await tester.pumpAndSettle();
              await tester.enterText(find.byType(TextField), 'Field notes');
              await save(tester, key, '$id-expanded');
            case 'sheets.fold':
              await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
              await save(tester, key, '$id-expanded');
            case 'dialogs.commandPalette':
              await tester.enterText(find.byType(TextField), 'Saved');
              await save(tester, key, '$id-filtered');
            case 'dialogs.timeline' || 'dialogs.milestone':
              await tester.tap(find.text('Complete current step'));
              await save(tester, key, '$id-completed');
            case 'bottomNav.morphingCapsule':
              await tester.tap(find.byTooltip('Saved'));
              await save(tester, key, '$id-selected');
          }
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    }
  });

  testWidgets('compose editorial boards from unaltered Flutter captures', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final group in showcaseGroups.entries) {
      final hero = group.key == 'hero';
      final tile = group.key.startsWith('tile-');
      tester.view.physicalSize = Size(
        tile
            ? 220
            : hero
            ? 1400
            : 1200,
        tile
            ? 180
            : hero
            ? 760
            : switch (group.key) {
                'app-bars' => 500,
                'toasts' => 380,
                'bottom-navigation' => 340,
                _ => 610,
              },
      );
      final images = <String, ui.Image>{};
      await tester.runAsync(() async {
        for (final id in group.value) {
          final codec = await ui.instantiateImageCodec(
            await File('$output/$id.png').readAsBytes(),
          );
          images[id] = (await codec.getNextFrame()).image;
          codec.dispose();
        }
      });
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Roboto'),
            home: ShowcaseBoard(group: group.key, images: images),
          ),
        ),
      );
      await save(tester, key, group.key);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      for (final image in images.values) {
        image.dispose();
      }
    }
  });
}
