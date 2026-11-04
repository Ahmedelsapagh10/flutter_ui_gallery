import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

import '../tool/readme_examples.dart' as readme;

void main() {
  test('all canonical presets have one generated, copyable source', () {
    final inventory =
        (jsonDecode(File('doc/catalog/inventory.json').readAsStringSync())
                as List)
            .cast<Map<String, dynamic>>();
    final expected = {
      for (final value in UiGalleryAppBarPreset.values) 'header.${value.name}',
      for (final value in UiGalleryToastPreset.values) 'toasts.${value.name}',
      for (final value in UiGallerySheetPreset.values) 'sheets.${value.name}',
      for (final value in UiGalleryDialogPreset.values) 'dialogs.${value.name}',
      for (final value in UiGalleryBottomNavPreset.values)
        'bottomNav.${value.name}',
    };
    expect(inventory.map((e) => e['id']).toSet(), expected);
    expect(inventory, hasLength(66));
    for (final entry in inventory) {
      final code = File(
        'doc/catalog/code/${entry['id']}.dart',
      ).readAsStringSync();
      expect(
        code.replaceAll(RegExp(r'\s+'), ''),
        (entry['source'] as String).replaceAll(RegExp(r'\s+'), ''),
      );
    }
  });

  test('README Dart fences exactly match the compiled fixture', () {
    final blocks = RegExp(r'```dart\n(.*?)```', dotAll: true)
        .allMatches(File('README.md').readAsStringSync())
        .map((m) => m.group(1)!)
        .toList();
    expect(blocks, hasLength(6));
    final fixture = File('tool/readme_examples.dart').readAsStringSync();
    for (final block in blocks) {
      final body = block
          .split('\n')
          .where((line) => !line.startsWith('import '))
          .join('\n');
      expect(
        fixture.replaceAll(RegExp(r'\s+'), ''),
        contains(body.replaceAll(RegExp(r'\s+'), '')),
      );
    }
    expect(readme.galleryTheme().extension<UiGalleryTheme>(), isNotNull);
  });
}
