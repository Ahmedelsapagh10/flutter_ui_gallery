import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

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
  );
}

void showToastsAction(BuildContext context, VoidCallback onUndo) {
  UiGalleryToast.show(
    context,
    preset: UiGalleryToastPreset.action,
    message: "Your changes are saved and ready.",
    kind: UiGalleryToastKind.success,
    actionLabel: 'Undo',
    onAction: onUndo,
    showProgress: true,
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

Future<void> showSheetsOrbit(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.orbit,
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

Widget showBottomNavMorphingCapsule(int index, ValueChanged<int> onSelected) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.morphingCapsule,
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
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

ThemeData galleryTheme() {
  final base = ThemeData(colorSchemeSeed: const Color(0xff007f88));
  return base.copyWith(
    extensions: [
      UiGalleryTheme.family(
        UiGalleryDesignFamily.soft,
        theme: base,
        useSignature: true,
      ),
    ],
  );
}
