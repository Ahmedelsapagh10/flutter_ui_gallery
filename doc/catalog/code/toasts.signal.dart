import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showToastsSignalTheme()).
ThemeData showToastsSignalTheme({Brightness brightness = Brightness.light}) {
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

void showToastsSignal(BuildContext context) {
  UiGalleryToast.show(
    context,
    preset: UiGalleryToastPreset.signal,
    message: "Your changes are saved and ready.",
    kind: UiGalleryToastKind.success,
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}
