import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:nova_surfaces_example/gallery/catalog.dart';
import 'package:nova_surfaces_example/gallery/snippet.dart';

Iterable<
  ({String name, String source, UiGalleryDesignFamily family, bool custom})
>
allFamilySnippets() sync* {
  for (var i = 0; i < designs.length; i++) {
    for (final family in UiGalleryDesignFamily.values) {
      for (final custom in [false, true]) {
        final name =
            'example$i${family.name[0].toUpperCase()}${family.name.substring(1)}${custom ? 'Custom' : 'Default'}';
        yield (
          name: name,
          family: family,
          custom: custom,
          source: playgroundSnippet(
            design: designs[i],
            title: 'A "quote", \$variable and مرحبا',
            message: 'Line one\nLine two',
            accent: Colors.teal,
            family: family,
            brightness: custom ? Brightness.dark : Brightness.light,
            functionName: name,
            transitionMs: custom ? 360 : null,
            reduced: custom,
            curveDepth: custom ? 20 : null,
            depthIntensity: custom ? .6 : 1,
          ),
        );
      }
    }
  }
}

void main() {
  test(
    'highlighting preserves source and customization uses public options',
    () {
      for (final design in designs) {
        final source = playgroundSnippet(
          design: design,
          title: 'A "quote", \$variable and مرحبا',
          message: 'Line one\nLine two',
          accent: Colors.teal,
          reduced: true,
          transitionMs: 360,
          curveDepth: 20,
          depthIntensity: .6,
        );
        expect(
          TextSpan(
            children: highlightedDart(
              source,
              ColorScheme.fromSeed(seedColor: Colors.teal),
            ),
          ).toPlainText(),
          source,
        );
        expect(source, contains('intensity: 0'));
        expect(source, contains('Duration(milliseconds: 360)'));
        expect(source, isNot(contains('MyContent')));
        expect(source, isNot(contains('yourItems')));
      }
    },
  );

  test('all 396 family snippets are standalone with unique theme helpers', () {
    final snippets = allFamilySnippets().toList();
    expect(snippets, hasLength(396));
    expect(snippets.map((snippet) => snippet.name).toSet(), hasLength(396));
    final colors = ColorScheme.fromSeed(seedColor: Colors.teal);
    for (final snippet in snippets) {
      final source = snippet.source;
      expect(source, contains("import 'package:flutter/material.dart';"));
      expect(
        source,
        contains(
          "import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';",
        ),
      );
      expect(source, contains('ThemeData ${snippet.name}Theme('));
      expect(source, contains('UiGalleryDesignFamily.${snippet.family.name}'));
      expect(
        source,
        contains('Brightness.${snippet.custom ? 'dark' : 'light'}'),
      );
      expect(source, contains('accentColor: Color(0xff009688)'));
      expect(source, contains('motionIntensity: ${snippet.custom ? 0 : 1}'));
      expect(
        TextSpan(children: highlightedDart(source, colors)).toPlainText(),
        source,
        reason: snippet.name,
      );
      if (snippet.custom) {
        expect(source, contains('intensity: 0'));
        expect(source, contains('Duration(milliseconds: 360)'));
      }
      expect(source, isNot(contains('MyContent')));
      expect(source, isNot(contains('yourItems')));
    }
  });

  if (const bool.fromEnvironment('WRITE_SNIPPET_FIXTURE')) {
    test('write reproducible analyzer fixture for all 396 family snippets', () {
      final source = StringBuffer(
        "import 'package:flutter/foundation.dart';\nimport 'package:flutter/material.dart';\nimport 'package:flutter_ui_gallery/flutter_ui_gallery.dart';\n\n",
      );
      for (final snippet in allFamilySnippets()) {
        source.writeln(
          snippet.source
              .split('\n')
              .where((line) => !line.startsWith('import '))
              .join('\n'),
        );
      }
      File(
        'lib/gallery/snippet_validation.dart',
      ).writeAsStringSync(source.toString());
    });
  }
}
