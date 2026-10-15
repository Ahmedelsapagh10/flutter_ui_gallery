import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

import 'catalog.dart';

String playgroundSnippet({
  required SurfaceDesign design,
  required String title,
  required String message,
  required Color accent,
  UiGalleryDesignFamily? family,
  Brightness brightness = Brightness.light,
  bool reduced = false,
  double? transitionMs,
  double? curveDepth,
  double depthIntensity = 1,
  String functionName = 'example',
}) {
  String literal(String value) => jsonEncode(value).replaceAll(r'$', r'\$');
  final color =
      'Color(0x${accent.toARGB32().toRadixString(16).padLeft(8, '0')})';
  final shaped =
      design.appBar == UiGalleryAppBarPreset.sculptedWave && curveDepth != null;
  final style =
      '    style: const UiGallerySurfaceStyle(\n'
      '      accentColor: $color,\n'
      '${shaped ? '      shape: UiGalleryCurvedBorder(edge: UiGalleryCurveEdge.bottom, depth: ${curveDepth.toStringAsFixed(0)}),\n' : ''}'
      '    ),\n';
  final changedMotion =
      reduced ||
      transitionMs != null ||
      (design.appBar != null && depthIntensity != 1);
  final duration = transitionMs?.round();
  final motion = changedMotion
      ? '    motion: const UiGalleryMotion(\n'
            '${duration == null ? '' : '      entrance: Duration(milliseconds: $duration),\n      exit: Duration(milliseconds: $duration),\n      change: Duration(milliseconds: $duration),\n'}'
            '${reduced
                ? '      intensity: 0,\n'
                : design.appBar != null && depthIntensity != 1
                ? '      intensity: ${depthIntensity.toStringAsFixed(1)},\n'
                : ''}'
            '    ),\n'
      : '';
  const baseImports =
      "import 'package:flutter/material.dart';\nimport 'package:flutter_ui_gallery/flutter_ui_gallery.dart';\n\n";
  final imports =
      '$baseImports${family == null ? '' : "ThemeData ${functionName}Theme({Brightness brightness = Brightness.${brightness.name}}) {\n"
                "  final base = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: $color, brightness: brightness));\n"
                "  final recipe = UiGalleryTheme.family(UiGalleryDesignFamily.${family.name}, theme: base);\n"
                "  return base.copyWith(extensions: [recipe.copyWith(surfaceStyle: recipe.surfaceStyle!.copyWith(accentColor: $color), motionIntensity: ${reduced ? 0 : 1})]);\n}\n\n"}';
  if (design.sheet != null) {
    return '${imports}Future<void> $functionName(BuildContext context) async {\n'
        '  await UiGallerySheet.show<void>(\n    context: context,\n'
        '    preset: UiGallerySheetPreset.${design.sheet!.name},\n'
        '    header: const Text(${literal(title)}),\n'
        '    child: const Text(${literal(message)}),\n$style$motion  );\n}';
  }
  if (design.dialog == UiGalleryDialogPreset.commandPalette) {
    return '${imports}Future<String?> $functionName(BuildContext context) {\n'
        '  return UiGalleryDialog.commands<String>(\n    context: context,\n'
        '    title: ${literal(title)}, useRootNavigator: false,\n'
        "    emptyLabel: 'No matching commands',\n"
        '    commands: const [\n'
        "      UiGalleryDialogAction(label: 'New note', value: 'create', icon: Icon(Icons.add)),\n"
        "      UiGalleryDialogAction(label: 'Saved ideas', value: 'saved', icon: Icon(Icons.bookmark_outline)),\n"
        "      UiGalleryDialogAction(label: 'Archive', value: 'archive', enabled: false),\n"
        '    ],\n$style$motion  );\n}';
  }
  if (design.dialog != null) {
    return '${imports}Future<bool?> $functionName(BuildContext context) {\n'
        '  return UiGalleryDialog.confirm(\n    context: context,\n'
        '    useRootNavigator: false,\n'
        '    preset: UiGalleryDialogPreset.${design.dialog!.name},\n'
        '    title: ${literal(title)},\n    message: ${literal(message)},\n$style$motion  );\n}';
  }
  if (design.toast == UiGalleryToastPreset.progressCard) {
    return "import 'package:flutter/foundation.dart';\n"
        '${imports}UiGalleryToastHandle $functionName(BuildContext context,\n'
        '    ValueListenable<double> progress, VoidCallback onCancel) {\n'
        '  return UiGalleryToast.progress(\n    context,\n'
        '    title: ${literal(title)}, message: ${literal(message)},\n'
        "    progress: progress, actionLabel: 'Cancel', onAction: onCancel,\n"
        '$style$motion  );\n}';
  }
  if (design.toast != null) {
    final actionable = const {
      UiGalleryToastPreset.action,
      UiGalleryToastPreset.ribbonActionBar,
      UiGalleryToastPreset.dock,
    }.contains(design.toast);
    final top =
        design.toast == UiGalleryToastPreset.ribbon ||
        design.toast == UiGalleryToastPreset.inlinePulse;
    return '${imports}void $functionName(BuildContext context${actionable ? ', VoidCallback onUndo' : ''}) {\n'
        '  UiGalleryToast.show(\n    context,\n'
        '    preset: UiGalleryToastPreset.${design.toast!.name},\n'
        '    message: ${literal(message)},\n'
        '    kind: UiGalleryToastKind.${design.toast == UiGalleryToastPreset.ribbon ? 'warning' : 'success'},\n'
        '${top ? '    position: UiGalleryToastPosition.top,\n' : ''}'
        '${design.toast == UiGalleryToastPreset.miniConsole ? "    title: 'WORKSPACE / STATUS',\n" : ''}'
        '${actionable ? "    actionLabel: 'Undo', onAction: onUndo,\n    showProgress: true,\n" : ''}'
        '$style$motion  );\n}';
  }
  if (design.appBar == UiGalleryAppBarPreset.selectionBar) {
    return '${imports}Widget $functionName(Set<int> selected, ValueChanged<int> onToggle,\n'
        '    VoidCallback onClear, VoidCallback onArchive) {\n'
        '  return Scaffold(\n    appBar: UiGalleryAppBar(\n'
        '      preset: UiGalleryAppBarPreset.selectionBar,\n'
        '      title: const Text(${literal(title)}),\n'
        '      selectionCount: selected.length, onSelectionCleared: onClear,\n'
        "      actions: [if (selected.isNotEmpty) IconButton(onPressed: onArchive,\n"
        "        tooltip: 'Archive selected', icon: const Icon(Icons.archive_outlined))],\n"
        '${style.replaceAll('    ', '      ')}${motion.replaceAll('    ', '      ')}'
        '    ),\n    body: ListView(children: [\n'
        '      for (var i = 0; i < 8; i++) CheckboxListTile(\n'
        "        title: Text('Note \${i + 1}'), value: selected.contains(i),\n"
        '        onChanged: (_) => onToggle(i)),\n'
        '    ]),\n  );\n}';
  }
  if (design.appBar != null) {
    final search = design.appBar == UiGalleryAppBarPreset.searchSwitch;
    final breadcrumb = design.appBar == UiGalleryAppBarPreset.breadcrumbTrail;
    final tabs = design.appBar == UiGalleryAppBarPreset.sectionTabs;
    final subtitle = breadcrumb
        ? "      subtitle: Row(mainAxisSize: MainAxisSize.min, children: [\n"
              "        TextButton(onPressed: onOpenWorkspace, child: const Text('Workspace')),\n"
              "        const Icon(Icons.chevron_right_rounded, size: 16),\n"
              "        const Text(${literal(message)}),\n      ]),\n"
        : '      subtitle: const Text(${literal(message)}),\n';
    final body = tabs
        ? "    body: TabBarView(children: [\n"
              "      for (final section in ['Overview', 'Saved', 'Shared'])\n"
              "        ListView(children: List.generate(16,\n"
              "          (i) => ListTile(title: Text('\$section note \${i + 1}')))),\n"
              "    ]),\n"
        : '    body: ListView(\n      children: List.generate(16,\n'
              "        (i) => ListTile(title: Text('Note \${i + 1}'))),\n    ),\n";
    return '${imports}Widget $functionName(VoidCallback onNotifications'
        '${search ? ', ValueChanged<String> onSearchChanged' : ''}'
        '${breadcrumb ? ', VoidCallback onOpenWorkspace' : ''}) {\n'
        '${tabs ? '  return DefaultTabController(length: 3, child: Scaffold(\n' : '  return Scaffold(\n'}'
        '    appBar: UiGalleryAppBar(\n'
        '      preset: UiGalleryAppBarPreset.${design.appBar!.name},\n'
        '      title: const Text(${literal(title)}),\n'
        '$subtitle      scrollAware: true,\n'
        '${search ? '      onSearchChanged: onSearchChanged,\n' : ''}'
        '${tabs ? "      bottom: const TabBar(tabs: [Tab(text: 'Overview'), Tab(text: 'Saved'), Tab(text: 'Shared')]),\n" : ''}'
        '      actions: [IconButton(onPressed: onNotifications,\n'
        '        icon: const Icon(Icons.notifications_none_rounded))],\n'
        '${style.replaceAll('    ', '      ')}${motion.replaceAll('    ', '      ')}'
        '    ),\n$body'
        '${tabs ? '  ));\n}' : '  );\n}'}';
  }
  final notch = design.bottomNav == UiGalleryBottomNavPreset.concaveNotch;
  final hasCenter =
      notch || design.bottomNav == UiGalleryBottomNavPreset.splitIsland;
  final scaffoldNav =
      design.bottomNav == UiGalleryBottomNavPreset.glassDock ||
      design.bottomNav == UiGalleryBottomNavPreset.scrollDock;
  final options = curveDepth != null || depthIntensity != 1
      ? '    options: const UiGalleryBottomNavOptions(\n'
            '${curveDepth == null ? '' : '      ${notch ? 'notchDepth' : 'curveDepth'}: ${curveDepth.toStringAsFixed(0)},\n'}'
            '${depthIntensity == 1 ? '' : '      depthIntensity: ${depthIntensity.toStringAsFixed(1)},\n'}'
            '    ),\n'
      : '';
  return '${imports}Widget $functionName(int index, ValueChanged<int> onSelected${hasCenter ? ', VoidCallback onCreate' : ''}) {\n'
      '${scaffoldNav ? "  return Scaffold(\n    extendBody: ${design.bottomNav == UiGalleryBottomNavPreset.glassDock},\n    body: ListView(children: List.generate(16,\n      (i) => ListTile(title: Text('Note \${i + 1}')))),\n    bottomNavigationBar: UiGalleryBottomNav(\n" : '  return UiGalleryBottomNav(\n'}'
      '    preset: UiGalleryBottomNavPreset.${design.bottomNav!.name},\n'
      '    selectedIndex: index,\n    onDestinationSelected: onSelected,\n'
      '    items: const [\n'
      "      UiGalleryBottomNavItem(icon: Icon(Icons.explore_outlined),\n        selectedIcon: Icon(Icons.explore), label: 'Discover'),\n"
      "      UiGalleryBottomNavItem(icon: Icon(Icons.bookmark_border),\n        selectedIcon: Icon(Icons.bookmark), label: 'Saved', badge: Text('3')),\n"
      "      UiGalleryBottomNavItem(icon: Icon(Icons.inbox_outlined),\n        selectedIcon: Icon(Icons.inbox), label: 'Inbox', badge: Text('2')),\n"
      "      UiGalleryBottomNavItem(icon: Icon(Icons.timeline), label: 'Activity', enabled: false),\n"
      '${design.bottomNav == UiGalleryBottomNavPreset.overflowDock ? "      UiGalleryBottomNavItem(icon: Icon(Icons.collections_bookmark_outlined), label: 'Collections'),\n      UiGalleryBottomNavItem(icon: Icon(Icons.notes), label: 'Notes'),\n" : ''}'
      '    ],\n'
      '${hasCenter ? "    centerAction: IconButton.filled(onPressed: onCreate,\n      tooltip: 'Create a note', icon: const Icon(Icons.add_rounded)),\n" : ''}'
      '$style$motion$options${scaffoldNav ? '  ));\n}' : '  );\n}'}';
}

/// Small lexer for readable snippets; copying always uses the original source.
List<TextSpan> highlightedDart(String source, ColorScheme colors) {
  final pattern = RegExp(
    r'''('(\\.|[^'\\])*'|"(\\.|[^"\\])*"|\b(?:import|const|final|return|await|async|void|int|bool|false|true)\b|\b\d+(?:\.\d+)?\b|\b[A-Z][A-Za-z0-9_]*\b)''',
  );
  final spans = <TextSpan>[];
  var offset = 0;
  for (final match in pattern.allMatches(source)) {
    if (match.start > offset) {
      spans.add(TextSpan(text: source.substring(offset, match.start)));
    }
    final token = match.group(0)!;
    final color = token.startsWith("'") || token.startsWith('"')
        ? colors.tertiary
        : RegExp(r'^[A-Z]').hasMatch(token)
        ? colors.primary
        : colors.secondary;
    spans.add(
      TextSpan(
        text: token,
        style: TextStyle(color: color),
      ),
    );
    offset = match.end;
  }
  if (offset < source.length) {
    spans.add(TextSpan(text: source.substring(offset)));
  }
  return spans;
}
