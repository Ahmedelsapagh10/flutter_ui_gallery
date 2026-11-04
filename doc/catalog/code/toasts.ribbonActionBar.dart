import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showToastsRibbonActionBarTheme()).
ThemeData showToastsRibbonActionBarTheme({
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

void showToastsRibbonActionBar(BuildContext context, VoidCallback onUndo) {
  UiGalleryToast.show(
    context,
    preset: UiGalleryToastPreset.ribbonActionBar,
    message: "Your changes are saved and ready.",
    kind: UiGalleryToastKind.success,
    actionLabel: 'Undo',
    onAction: onUndo,
    showProgress: true,
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}
