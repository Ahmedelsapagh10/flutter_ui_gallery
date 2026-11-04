import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showSheetsDepthFrameTheme()).
ThemeData showSheetsDepthFrameTheme({
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

Future<void> showSheetsDepthFrame(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.depthFrame,
    header: const Text("Field notes"),
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('A quiet place for your next idea.'),
        SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.bookmark_outline),
          title: Text('Personal collection'),
          subtitle: Text('12 notes · Only you'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.groups_outlined),
          title: Text('Team workspace'),
          subtitle: Text('Shared with your team'),
        ),
      ],
    ),
    footer: Builder(
      builder: (sheetContext) => FilledButton(
        onPressed: () => Navigator.of(sheetContext).pop(),
        child: const Text('Done'),
      ),
    ),
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}
