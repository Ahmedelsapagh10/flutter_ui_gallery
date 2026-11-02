import 'dart:io';
import 'package:flutter/services.dart';
import 'notes_fonts.dart';

Future<void> loadStillFonts() async {
  final result = Process.runSync('python3', ['../tool/check_still_pins.py']);
  if (result.exitCode != 0) {
    throw StateError('${result.stdout} ${result.stderr}');
  }
  await loadNotesFonts();
  for (final e in {
    'StillSerif': 'SourceSerif4.ttf',
    'StillSerifStatic': 'SourceSerif4-300-60.ttf',
    'StillSans': 'SourceSans3.ttf',
    'StillNaskh': 'NotoNaskhArabic.ttf',
  }.entries) {
    await (FontLoader(e.key)..addFont(
          File(
            'assets/fonts/still/${e.value}',
          ).readAsBytes().then(ByteData.sublistView),
        ))
        .load();
  }
}
