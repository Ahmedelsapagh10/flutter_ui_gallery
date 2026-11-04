import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showHeaderSelectionBarTheme()).
ThemeData showHeaderSelectionBarTheme({
  Brightness brightness = Brightness.light,
}) {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xff007f88),
      brightness: brightness,
    ),
  );
  final recipe = UiGalleryTheme.family(
    UiGalleryDesignFamily.soft,
    theme: base,
    useSignature: true,
  );
  return base.copyWith(
    extensions: [
      recipe.copyWith(
        surfaceStyle: recipe.surfaceStyle!.copyWith(
          accentColor: Color(0xff007f88),
        ),
        motionIntensity: 1,
      ),
    ],
  );
}

Widget showHeaderSelectionBar(
  Set<int> selected,
  ValueChanged<int> onToggle,
  VoidCallback onClear,
  VoidCallback onArchive,
) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.selectionBar,
      title: const Text("Notebook"),
      selectionCount: selected.length,
      onSelectionCleared: onClear,
      actions: [
        if (selected.isNotEmpty)
          IconButton(
            onPressed: onArchive,
            tooltip: 'Archive selected',
            icon: const Icon(Icons.archive_outlined),
          ),
      ],
      style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
    ),
    body: ListView(
      children: [
        for (var i = 0; i < 8; i++)
          CheckboxListTile(
            title: Text('Note ${i + 1}'),
            value: selected.contains(i),
            onChanged: (_) => onToggle(i),
          ),
      ],
    ),
  );
}
