import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

import 'package:nova_surfaces_example/gallery/catalog.dart';
import 'package:nova_surfaces_example/gallery/snippet.dart';

// Documentation fixtures share the playground's verified snippet generator.
void main() {
  Directory.current = Directory.current.parent;
  test('export all public presets and compile-ready showcase helpers', () {
    final inventory = <Map<String, String>>[];
    final imports = <String>{};
    final helpers = <String>[];
    final calls = <String>[];
    final overlays = <String>[];
    for (final design in designs) {
      final id = design.id;
      final name =
          'show${id.split('.').map((part) => '${part[0].toUpperCase()}${part.substring(1)}').join()}';
      final title = switch (id) {
        'dialogs.commandPalette' => 'Find a command',
        'dialogs.spotlight' || 'dialogs.statusBeacon' => 'Collection ready',
        'dialogs.timeline' || 'dialogs.milestone' => 'Publish your collection',
        'dialogs.split' => 'Discard this draft?',
        'toasts.progressCard' => 'Uploading collection',
        _ => switch (design.category) {
          DesignCategory.sheets => 'Field notes',
          DesignCategory.dialogs => 'Make room for your next idea',
          DesignCategory.toasts => 'Your workspace',
          _ => 'Notebook',
        },
      };
      final message = switch (design.category) {
        DesignCategory.sheets => 'A quiet place for your next idea.',
        DesignCategory.dialogs =>
          'Keep your ideas together. Choose how to continue.',
        DesignCategory.toasts => 'Your changes are saved and ready.',
        _ => 'Ideas worth keeping',
      };
      var source = playgroundSnippet(
        design: design,
        title: title,
        message: message,
        accent: const Color(0xff007f88),
        family: UiGalleryDesignFamily.soft,
        useSignature: true,
        functionName: name,
      );
      if (design.sheet != null) {
        source = source.replaceFirst(
          '    child: const Text(${jsonEncode(message)}),',
          '''    child: const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('A quiet place for your next idea.'),
        SizedBox(height: 16),
        ListTile(contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.bookmark_outline),
          title: Text('Personal collection'), subtitle: Text('12 notes · Only you')),
        ListTile(contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.groups_outlined),
          title: Text('Team workspace'), subtitle: Text('Shared with your team')),
      ],
    ),
    footer: Builder(builder: (sheetContext) => FilledButton(
      onPressed: () => Navigator.of(sheetContext).pop(),
      child: const Text('Done'),
    )),''',
        );
      }
      source = source.replaceAll(
        "ListTile(title: Text('Note \${i + 1}'))",
        "ListTile(leading: const Icon(Icons.article_outlined), title: Text(const ['Field notes', 'A weekend by the coast', 'The next good idea', 'Spaces worth saving'][i % 4]), subtitle: const Text('Personal collection · Updated today'))",
      );
      inventory.add({
        'id': id,
        'name': design.name,
        'category': design.category.name,
        'purpose': design.useCase,
        'source': source,
      });
      final lines = source.split('\n');
      imports.addAll(lines.where((line) => line.startsWith('import ')));
      helpers.add(
        lines.where((line) => !line.startsWith('import ')).join('\n'),
      );
      final invocation = switch (design.category) {
        DesignCategory.sheets => '$name(context)',
        DesignCategory.dialogs =>
          design.dialog == UiGalleryDialogPreset.timeline ||
                  design.dialog == UiGalleryDialogPreset.milestone
              ? '$name(context, timeline, onAction)'
              : design.dialog == UiGalleryDialogPreset.spotlight ||
                    design.dialog == UiGalleryDialogPreset.statusBeacon
              ? '$name(context, UiGalleryResult.success)'
              : '$name(context)',
        DesignCategory.toasts =>
          design.toast == UiGalleryToastPreset.progressCard
              ? '$name(context, progress, onAction)'
              : const {
                  UiGalleryToastPreset.action,
                  UiGalleryToastPreset.ribbonActionBar,
                  UiGalleryToastPreset.dock,
                }.contains(design.toast)
              ? '$name(context, onAction)'
              : '$name(context)',
        DesignCategory.header =>
          design.appBar == UiGalleryAppBarPreset.selectionBar
              ? '$name(selected, onSelect, onAction, onAction)'
              : '$name(onAction${design.appBar == UiGalleryAppBarPreset.searchSwitch ? ', (_) => onAction()' : ''}${design.appBar == UiGalleryAppBarPreset.breadcrumbTrail ? ', onAction' : ''})',
        DesignCategory.bottomNav =>
          '$name(index, onSelect${const {UiGalleryBottomNavPreset.concaveNotch, UiGalleryBottomNavPreset.splitIsland}.contains(design.bottomNav) ? ', onAction' : ''})',
      };
      if (design.sheet != null || design.dialog != null) {
        overlays.add(
          "'$id': (context, timeline, progress, onAction) => $invocation,",
        );
      }
      final widget = design.appBar != null || design.bottomNav != null;
      calls.add(
        "    '$id': (context, timeline, progress, index, selected, onSelect, onAction) ${widget ? '=> $invocation' : '{ $invocation; return null; }'},",
      );
    }
    expect(inventory.map((item) => item['id']).toSet(), hasLength(66));
    expect(UiGalleryAppBarPreset.values, hasLength(17));
    expect(UiGallerySheetPreset.values, hasLength(12));
    expect(UiGalleryDialogPreset.values, hasLength(11));
    expect(UiGalleryToastPreset.values, hasLength(11));
    expect(UiGalleryBottomNavPreset.values, hasLength(15));
    File(
      'example/lib/gallery/documentation_examples.dart',
    ).writeAsStringSync('${imports.join('\n')}\n${helpers.join('\n\n')}\n');
    File('doc/catalog/inventory.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(inventory)}\n',
    );
    File('example/lib/gallery/documentation_calls.dart').writeAsStringSync(
      '''// Generated by export_showcase.dart. Do not edit.
import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'documentation_examples.dart';

typedef ShowcaseCall = Widget? Function(BuildContext, ValueNotifier<UiGalleryTimelineState>, ValueNotifier<double>, int, Set<int>, ValueChanged<int>, VoidCallback);
final Map<String, ShowcaseCall> showcaseCalls = {
${calls.join('\n')}
};
typedef ShowcaseOverlay = Future<Object?> Function(BuildContext, ValueNotifier<UiGalleryTimelineState>, ValueNotifier<double>, VoidCallback);
final Map<String, ShowcaseOverlay> showcaseOverlays = {
${overlays.join('\n')}
};
''',
    );
  });
}
