import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

// Apply this theme to MaterialApp(theme: showHeaderSectionTabsTheme()).
ThemeData showHeaderSectionTabsTheme({
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

Widget showHeaderSectionTabs(VoidCallback onNotifications) {
  return DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: UiGalleryAppBar(
        preset: UiGalleryAppBarPreset.sectionTabs,
        title: const Text("Notebook"),
        subtitle: const Text("Ideas worth keeping"),
        scrollAware: true,
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Saved'),
            Tab(text: 'Shared'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: onNotifications,
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
        style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
      ),
      body: TabBarView(
        children: [
          for (final section in ['Overview', 'Saved', 'Shared'])
            ListView(
              children: List.generate(
                16,
                (i) => ListTile(title: Text('$section note ${i + 1}')),
              ),
            ),
        ],
      ),
    ),
  );
}
