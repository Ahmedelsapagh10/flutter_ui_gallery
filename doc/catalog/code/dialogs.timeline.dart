import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showDialogsTimelineTheme()).
ThemeData showDialogsTimelineTheme({Brightness brightness = Brightness.light}) {
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

Future<String?> showDialogsTimeline(
  BuildContext context,
  ValueListenable<UiGalleryTimelineState> progress,
  VoidCallback onCompleteStep,
) {
  return UiGalleryDialog.show<String>(
    context: context,
    useRootNavigator: false,
    preset: UiGalleryDialogPreset.timeline,
    title: "Publish your collection",
    message: "Keep your ideas together. Choose how to continue.",
    child: ValueListenableBuilder<UiGalleryTimelineState>(
      valueListenable: progress,
      builder: (context, value, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UiGalleryTimeline(state: value),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: value.completed ? null : onCompleteStep,
            child: Text(value.completed ? 'Verified' : 'Complete current step'),
          ),
        ],
      ),
    ),
    actions: const [UiGalleryDialogAction(label: 'Close', value: 'Closed')],
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}
