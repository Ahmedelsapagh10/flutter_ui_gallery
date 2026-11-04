import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showDialogsCommandPaletteTheme()).
ThemeData showDialogsCommandPaletteTheme({
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

Future<String?> showDialogsCommandPalette(BuildContext context) {
  return UiGalleryDialog.commands<String>(
    context: context,
    title: "Find a command",
    useRootNavigator: false,
    emptyLabel: 'No matching commands',
    commands: const [
      UiGalleryDialogAction(
        label: 'New note',
        value: 'create',
        icon: Icon(Icons.add),
      ),
      UiGalleryDialogAction(
        label: 'Saved ideas',
        value: 'saved',
        icon: Icon(Icons.bookmark_outline),
      ),
      UiGalleryDialogAction(label: 'Archive', value: 'archive', enabled: false),
    ],
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}
