import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showDialogsSideBySideChoiceTheme()).
ThemeData showDialogsSideBySideChoiceTheme({
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

Future<String?> showDialogsSideBySideChoice(BuildContext context) {
  return UiGalleryDialog.show<String>(
    context: context,
    useRootNavigator: false,
    preset: UiGalleryDialogPreset.sideBySideChoice,
    title: "Make room for your next idea",
    message: "Keep your ideas together. Choose how to continue.",
    actions: const [
      UiGalleryDialogAction(
        label: 'Personal',
        value: 'Personal',
        description: 'A private space for your own projects.',
        icon: Icon(Icons.person_outline),
      ),
      UiGalleryDialogAction(
        label: 'Team',
        value: 'Team',
        primary: true,
        description: 'Share collections with collaborators.',
        icon: Icon(Icons.groups_outlined),
      ),
    ],
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}
