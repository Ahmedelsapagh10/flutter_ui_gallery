import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showDialogsSplitTheme()).
ThemeData showDialogsSplitTheme({Brightness brightness = Brightness.light}) {
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

Future<bool?> showDialogsSplit(BuildContext context) {
  return UiGalleryDialog.confirm(
    context: context,
    useRootNavigator: false,
    preset: UiGalleryDialogPreset.split,
    title: "Discard this draft?",
    message: "Keep your ideas together. Choose how to continue.",
    destructive: true,
    confirmLabel: 'Discard draft',
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}
