import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

Future<void> loadNotesFonts() async {
  final config = File('.dart_tool/package_config.json');
  final data = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
  final flutter = (data['packages'] as List)
      .cast<Map<String, dynamic>>()
      .singleWhere((p) => p['name'] == 'flutter');
  final root = config.absolute.uri
      .resolve(
        '${(flutter['rootUri'] as String).replaceFirst(RegExp(r'/+$'), '')}/',
      )
      .resolve('../../bin/cache/artifacts/material_fonts/');
  for (final entry in {
    'Roboto': File.fromUri(root.resolve('Roboto-Regular.ttf')),
    'MaterialIcons': File.fromUri(root.resolve('MaterialIcons-Regular.otf')),
    'Alexandria': File('assets/fonts/Alexandria.ttf'),
    'MarginArabic': File('assets/fonts/Alexandria.ttf'),
  }.entries) {
    await (FontLoader(
      entry.key,
    )..addFont(entry.value.readAsBytes().then(ByteData.sublistView))).load();
  }
}

void verifyNotesPins() {
  final pins = Process.runSync('python3', ['../tool/check_notes_pins.py']);
  if (pins.exitCode != 0) throw StateError('${pins.stdout} ${pins.stderr}');
}
