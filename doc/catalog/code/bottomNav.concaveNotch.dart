import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showBottomNavConcaveNotchTheme()).
ThemeData showBottomNavConcaveNotchTheme({
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

Widget showBottomNavConcaveNotch(
  int index,
  ValueChanged<int> onSelected,
  VoidCallback onCreate,
) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.concaveNotch,
    selectedIndex: index,
    onDestinationSelected: onSelected,
    items: const [
      UiGalleryBottomNavItem(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: 'Discover',
      ),
      UiGalleryBottomNavItem(
        icon: Icon(Icons.bookmark_border),
        selectedIcon: Icon(Icons.bookmark),
        label: 'Saved',
        badge: Text('3'),
      ),
      UiGalleryBottomNavItem(
        icon: Icon(Icons.inbox_outlined),
        selectedIcon: Icon(Icons.inbox),
        label: 'Inbox',
        badge: Text('2'),
      ),
      UiGalleryBottomNavItem(
        icon: Icon(Icons.timeline),
        label: 'Activity',
        enabled: false,
      ),
    ],
    centerAction: IconButton.filled(
      onPressed: onCreate,
      tooltip: 'Create a note',
      icon: const Icon(Icons.add_rounded),
    ),
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}
