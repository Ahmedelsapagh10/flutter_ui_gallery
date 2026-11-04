import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showDialogsStatusBeaconTheme()).
ThemeData showDialogsStatusBeaconTheme({
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

Future<String?> showDialogsStatusBeacon(
  BuildContext context,
  UiGalleryResult result,
) {
  return UiGalleryDialog.show<String>(
    context: context,
    useRootNavigator: false,
    preset: UiGalleryDialogPreset.statusBeacon,
    title: "Collection ready",
    message: "Keep your ideas together. Choose how to continue.",
    result: result,
    actions: const [
      UiGalleryDialogAction(
        label: 'Continue',
        value: 'Continued',
        primary: true,
      ),
    ],
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}
