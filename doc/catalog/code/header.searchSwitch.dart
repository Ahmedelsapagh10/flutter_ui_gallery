import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showHeaderSearchSwitchTheme()).
ThemeData showHeaderSearchSwitchTheme({
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

Widget showHeaderSearchSwitch(
  VoidCallback onNotifications,
  ValueChanged<String> onSearchChanged,
) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.searchSwitch,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
      onSearchChanged: onSearchChanged,
      actions: [
        IconButton(
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
      style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
    ),
    body: ListView(
      children: List.generate(
        16,
        (i) => ListTile(
          leading: const Icon(Icons.article_outlined),
          title: Text(
            const [
              'Field notes',
              'A weekend by the coast',
              'The next good idea',
              'Spaces worth saving',
            ][i % 4],
          ),
          subtitle: const Text('Personal collection · Updated today'),
        ),
      ),
    ),
  );
}
