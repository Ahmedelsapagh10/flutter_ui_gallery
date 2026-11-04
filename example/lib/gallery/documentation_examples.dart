import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:flutter/foundation.dart';

// Apply this theme to MaterialApp(theme: showSheetsOrbitTheme()).
ThemeData showSheetsOrbitTheme({Brightness brightness = Brightness.light}) {
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

// Apply this theme to MaterialApp(theme: showSheetsFoldTheme()).
ThemeData showSheetsFoldTheme({Brightness brightness = Brightness.light}) {
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

Future<void> showSheetsFold(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.fold,
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

// Apply this theme to MaterialApp(theme: showSheetsPrismTheme()).
ThemeData showSheetsPrismTheme({Brightness brightness = Brightness.light}) {
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

Future<void> showSheetsPrism(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.prism,
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

// Apply this theme to MaterialApp(theme: showSheetsFlowTheme()).
ThemeData showSheetsFlowTheme({Brightness brightness = Brightness.light}) {
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

Future<void> showSheetsFlow(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.flow,
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

// Apply this theme to MaterialApp(theme: showDialogsHaloTheme()).
ThemeData showDialogsHaloTheme({Brightness brightness = Brightness.light}) {
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

Future<bool?> showDialogsHalo(BuildContext context) {
  return UiGalleryDialog.confirm(
    context: context,
    useRootNavigator: false,
    preset: UiGalleryDialogPreset.halo,
    title: "Make room for your next idea",
    message: "Keep your ideas together. Choose how to continue.",
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

// Apply this theme to MaterialApp(theme: showDialogsSplitTheme()).
ThemeData showDialogsSplitTheme({Brightness brightness = Brightness.light}) {
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

Future<bool?> showDialogsSplit(BuildContext context) {
  return UiGalleryDialog.confirm(
    context: context,
    useRootNavigator: false,
    preset: UiGalleryDialogPreset.split,
    title: "Discard this draft?",
    message: "Keep your ideas together. Choose how to continue.",
    destructive: true,
    confirmLabel: 'Discard draft',
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

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

// Apply this theme to MaterialApp(theme: showDialogsSpotlightTheme()).
ThemeData showDialogsSpotlightTheme({
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

Future<String?> showDialogsSpotlight(
  BuildContext context,
  UiGalleryResult result,
) {
  return UiGalleryDialog.show<String>(
    context: context,
    useRootNavigator: false,
    preset: UiGalleryDialogPreset.spotlight,
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

// Apply this theme to MaterialApp(theme: showToastsRibbonTheme()).
ThemeData showToastsRibbonTheme({Brightness brightness = Brightness.light}) {
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

void showToastsRibbon(BuildContext context) {
  UiGalleryToast.show(
    context,
    preset: UiGalleryToastPreset.ribbon,
    message: "Your changes are saved and ready.",
    kind: UiGalleryToastKind.warning,
    position: UiGalleryToastPosition.top,
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

// Apply this theme to MaterialApp(theme: showToastsActionTheme()).
ThemeData showToastsActionTheme({Brightness brightness = Brightness.light}) {
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

// Apply this theme to MaterialApp(theme: showHeaderAdaptiveHorizonTheme()).
ThemeData showHeaderAdaptiveHorizonTheme({
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

Widget showHeaderAdaptiveHorizon(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.adaptiveHorizon,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showSheetsEdgeLiftTheme()).
ThemeData showSheetsEdgeLiftTheme({Brightness brightness = Brightness.light}) {
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

Future<void> showSheetsEdgeLift(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.edgeLift,
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

// Apply this theme to MaterialApp(theme: showSheetsStackPanelTheme()).
ThemeData showSheetsStackPanelTheme({
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

Future<void> showSheetsStackPanel(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.stackPanel,
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

// Apply this theme to MaterialApp(theme: showSheetsNeoTrayTheme()).
ThemeData showSheetsNeoTrayTheme({Brightness brightness = Brightness.light}) {
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

Future<void> showSheetsNeoTray(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.neoTray,
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

// Apply this theme to MaterialApp(theme: showSheetsSplitLayerTheme()).
ThemeData showSheetsSplitLayerTheme({
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

Future<void> showSheetsSplitLayer(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.splitLayer,
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

// Apply this theme to MaterialApp(theme: showSheetsPulseDockTheme()).
ThemeData showSheetsPulseDockTheme({Brightness brightness = Brightness.light}) {
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

Future<void> showSheetsPulseDock(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.pulseDock,
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

// Apply this theme to MaterialApp(theme: showSheetsHorizonPeekTheme()).
ThemeData showSheetsHorizonPeekTheme({
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

Future<void> showSheetsHorizonPeek(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.horizonPeek,
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

// Apply this theme to MaterialApp(theme: showSheetsTaskRailTheme()).
ThemeData showSheetsTaskRailTheme({Brightness brightness = Brightness.light}) {
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

Future<void> showSheetsTaskRail(BuildContext context) async {
  await UiGallerySheet.show<void>(
    context: context,
    preset: UiGallerySheetPreset.taskRail,
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

// Apply this theme to MaterialApp(theme: showDialogsOrbitConfirmTheme()).
ThemeData showDialogsOrbitConfirmTheme({
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

Future<bool?> showDialogsOrbitConfirm(BuildContext context) {
  return UiGalleryDialog.confirm(
    context: context,
    useRootNavigator: false,
    preset: UiGalleryDialogPreset.orbitConfirm,
    title: "Make room for your next idea",
    message: "Keep your ideas together. Choose how to continue.",
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

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

// Apply this theme to MaterialApp(theme: showDialogsAlertCapsuleTheme()).
ThemeData showDialogsAlertCapsuleTheme({
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

Future<bool?> showDialogsAlertCapsule(BuildContext context) {
  return UiGalleryDialog.confirm(
    context: context,
    useRootNavigator: false,
    preset: UiGalleryDialogPreset.alertCapsule,
    title: "Make room for your next idea",
    message: "Keep your ideas together. Choose how to continue.",
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

// Apply this theme to MaterialApp(theme: showDialogsMilestoneTheme()).
ThemeData showDialogsMilestoneTheme({
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

Future<String?> showDialogsMilestone(
  BuildContext context,
  ValueListenable<UiGalleryTimelineState> progress,
  VoidCallback onCompleteStep,
) {
  return UiGalleryDialog.show<String>(
    context: context,
    useRootNavigator: false,
    preset: UiGalleryDialogPreset.milestone,
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

// Apply this theme to MaterialApp(theme: showDialogsPanelDecisionTheme()).
ThemeData showDialogsPanelDecisionTheme({
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

Future<bool?> showDialogsPanelDecision(BuildContext context) {
  return UiGalleryDialog.confirm(
    context: context,
    useRootNavigator: false,
    preset: UiGalleryDialogPreset.panelDecision,
    title: "Make room for your next idea",
    message: "Keep your ideas together. Choose how to continue.",
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

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

// Apply this theme to MaterialApp(theme: showToastsStackTagTheme()).
ThemeData showToastsStackTagTheme({Brightness brightness = Brightness.light}) {
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

void showToastsStackTag(BuildContext context) {
  UiGalleryToast.show(
    context,
    preset: UiGalleryToastPreset.stackTag,
    message: "Your changes are saved and ready.",
    kind: UiGalleryToastKind.success,
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

// Apply this theme to MaterialApp(theme: showToastsInlinePulseTheme()).
ThemeData showToastsInlinePulseTheme({
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

void showToastsInlinePulse(BuildContext context) {
  UiGalleryToast.show(
    context,
    preset: UiGalleryToastPreset.inlinePulse,
    message: "Your changes are saved and ready.",
    kind: UiGalleryToastKind.success,
    position: UiGalleryToastPosition.top,
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

// Apply this theme to MaterialApp(theme: showToastsBeaconTheme()).
ThemeData showToastsBeaconTheme({Brightness brightness = Brightness.light}) {
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

void showToastsBeacon(BuildContext context) {
  UiGalleryToast.show(
    context,
    preset: UiGalleryToastPreset.beacon,
    message: "Your changes are saved and ready.",
    kind: UiGalleryToastKind.success,
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

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

// Apply this theme to MaterialApp(theme: showToastsDockTheme()).
ThemeData showToastsDockTheme({Brightness brightness = Brightness.light}) {
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

void showToastsDock(BuildContext context, VoidCallback onUndo) {
  UiGalleryToast.show(
    context,
    preset: UiGalleryToastPreset.dock,
    message: "Your changes are saved and ready.",
    kind: UiGalleryToastKind.success,
    actionLabel: 'Undo',
    onAction: onUndo,
    showProgress: true,
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

// Apply this theme to MaterialApp(theme: showToastsSnapNoticeTheme()).
ThemeData showToastsSnapNoticeTheme({
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

void showToastsSnapNotice(BuildContext context) {
  UiGalleryToast.show(
    context,
    preset: UiGalleryToastPreset.snapNotice,
    message: "Your changes are saved and ready.",
    kind: UiGalleryToastKind.success,
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

// Apply this theme to MaterialApp(theme: showToastsMiniConsoleTheme()).
ThemeData showToastsMiniConsoleTheme({
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

void showToastsMiniConsole(BuildContext context) {
  UiGalleryToast.show(
    context,
    preset: UiGalleryToastPreset.miniConsole,
    message: "Your changes are saved and ready.",
    kind: UiGalleryToastKind.success,
    title: 'WORKSPACE / STATUS',
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

// Apply this theme to MaterialApp(theme: showHeaderFloatingArcTheme()).
ThemeData showHeaderFloatingArcTheme({
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

Widget showHeaderFloatingArc(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.floatingArc,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showHeaderCompactRailTheme()).
ThemeData showHeaderCompactRailTheme({
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

Widget showHeaderCompactRail(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.compactRail,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showHeaderSplitHeaderTheme()).
ThemeData showHeaderSplitHeaderTheme({
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

Widget showHeaderSplitHeader(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.splitHeader,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showHeaderFocusBarTheme()).
ThemeData showHeaderFocusBarTheme({Brightness brightness = Brightness.light}) {
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

Widget showHeaderFocusBar(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.focusBar,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showHeaderPanoramaBarTheme()).
ThemeData showHeaderPanoramaBarTheme({
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

Widget showHeaderPanoramaBar(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.panoramaBar,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showHeaderLayeredNavTheme()).
ThemeData showHeaderLayeredNavTheme({
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

Widget showHeaderLayeredNav(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.layeredNav,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showHeaderEditorialTopbarTheme()).
ThemeData showHeaderEditorialTopbarTheme({
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

Widget showHeaderEditorialTopbar(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.editorialTopbar,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showHeaderSculptedWaveTheme()).
ThemeData showHeaderSculptedWaveTheme({
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

Widget showHeaderSculptedWave(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.sculptedWave,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showHeaderFoldedCanopyTheme()).
ThemeData showHeaderFoldedCanopyTheme({
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

Widget showHeaderFoldedCanopy(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.foldedCanopy,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showHeaderParallaxCrestTheme()).
ThemeData showHeaderParallaxCrestTheme({
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

Widget showHeaderParallaxCrest(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.parallaxCrest,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showHeaderOrbitCommandTheme()).
ThemeData showHeaderOrbitCommandTheme({
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

Widget showHeaderOrbitCommand(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.orbitCommand,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showBottomNavFloatingCoveTheme()).
ThemeData showBottomNavFloatingCoveTheme({
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

Widget showBottomNavFloatingCove(int index, ValueChanged<int> onSelected) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.floatingCove,
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

// Apply this theme to MaterialApp(theme: showBottomNavConvexWaveTheme()).
ThemeData showBottomNavConvexWaveTheme({
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

Widget showBottomNavConvexWave(int index, ValueChanged<int> onSelected) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.convexWave,
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

// Apply this theme to MaterialApp(theme: showBottomNavOrbitDockTheme()).
ThemeData showBottomNavOrbitDockTheme({
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

Widget showBottomNavOrbitDock(int index, ValueChanged<int> onSelected) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.orbitDock,
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

// Apply this theme to MaterialApp(theme: showBottomNavRibbonCurveTheme()).
ThemeData showBottomNavRibbonCurveTheme({
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

Widget showBottomNavRibbonCurve(int index, ValueChanged<int> onSelected) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.ribbonCurve,
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

// Apply this theme to MaterialApp(theme: showBottomNavLayeredShelfTheme()).
ThemeData showBottomNavLayeredShelfTheme({
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

Widget showBottomNavLayeredShelf(int index, ValueChanged<int> onSelected) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.layeredShelf,
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

// Apply this theme to MaterialApp(theme: showBottomNavSplitIslandTheme()).
ThemeData showBottomNavSplitIslandTheme({
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

Widget showBottomNavSplitIsland(
  int index,
  ValueChanged<int> onSelected,
  VoidCallback onCreate,
) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.splitIsland,
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

// Apply this theme to MaterialApp(theme: showBottomNavPerspectiveDockTheme()).
ThemeData showBottomNavPerspectiveDockTheme({
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

Widget showBottomNavPerspectiveDock(int index, ValueChanged<int> onSelected) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.perspectiveDock,
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

// Apply this theme to MaterialApp(theme: showBottomNavMorphingCapsuleTheme()).
ThemeData showBottomNavMorphingCapsuleTheme({
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

// Apply this theme to MaterialApp(theme: showBottomNavAdaptiveMinimalTheme()).
ThemeData showBottomNavAdaptiveMinimalTheme({
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

Widget showBottomNavAdaptiveMinimal(int index, ValueChanged<int> onSelected) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.adaptiveMinimal,
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

// Apply this theme to MaterialApp(theme: showHeaderCenteredTitleTheme()).
ThemeData showHeaderCenteredTitleTheme({
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

Widget showHeaderCenteredTitle(VoidCallback onNotifications) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.centeredTitle,
      title: const Text("Notebook"),
      subtitle: const Text("Ideas worth keeping"),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showHeaderBreadcrumbTrailTheme()).
ThemeData showHeaderBreadcrumbTrailTheme({
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

Widget showHeaderBreadcrumbTrail(
  VoidCallback onNotifications,
  VoidCallback onOpenWorkspace,
) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.breadcrumbTrail,
      title: const Text("Notebook"),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: onOpenWorkspace,
            child: const Text('Workspace'),
          ),
          const Icon(Icons.chevron_right_rounded, size: 16),
          const Text("Ideas worth keeping"),
        ],
      ),
      scrollAware: true,
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

// Apply this theme to MaterialApp(theme: showBottomNavGlassDockTheme()).
ThemeData showBottomNavGlassDockTheme({
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

Widget showBottomNavGlassDock(int index, ValueChanged<int> onSelected) {
  return Scaffold(
    extendBody: true,
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
    bottomNavigationBar: UiGalleryBottomNav(
      preset: UiGalleryBottomNavPreset.glassDock,
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
    ),
  );
}

// Apply this theme to MaterialApp(theme: showBottomNavLiquidDropTheme()).
ThemeData showBottomNavLiquidDropTheme({
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

Widget showBottomNavLiquidDrop(int index, ValueChanged<int> onSelected) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.liquidDrop,
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

// Apply this theme to MaterialApp(theme: showBottomNavScrollDockTheme()).
ThemeData showBottomNavScrollDockTheme({
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

Widget showBottomNavScrollDock(int index, ValueChanged<int> onSelected) {
  return Scaffold(
    extendBody: false,
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
    bottomNavigationBar: UiGalleryBottomNav(
      preset: UiGalleryBottomNavPreset.scrollDock,
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
    ),
  );
}

// Apply this theme to MaterialApp(theme: showBottomNavFlipTilesTheme()).
ThemeData showBottomNavFlipTilesTheme({
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

Widget showBottomNavFlipTiles(int index, ValueChanged<int> onSelected) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.flipTiles,
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

// Apply this theme to MaterialApp(theme: showDialogsCommandPaletteTheme()).
ThemeData showDialogsCommandPaletteTheme({
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

Future<String?> showDialogsCommandPalette(BuildContext context) {
  return UiGalleryDialog.commands<String>(
    context: context,
    title: "Find a command",
    useRootNavigator: false,
    emptyLabel: 'No matching commands',
    commands: const [
      UiGalleryDialogAction(
        label: 'New note',
        value: 'create',
        icon: Icon(Icons.add),
      ),
      UiGalleryDialogAction(
        label: 'Saved ideas',
        value: 'saved',
        icon: Icon(Icons.bookmark_outline),
      ),
      UiGalleryDialogAction(label: 'Archive', value: 'archive', enabled: false),
    ],
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

// Apply this theme to MaterialApp(theme: showHeaderSelectionBarTheme()).
ThemeData showHeaderSelectionBarTheme({
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

Widget showHeaderSelectionBar(
  Set<int> selected,
  ValueChanged<int> onToggle,
  VoidCallback onClear,
  VoidCallback onArchive,
) {
  return Scaffold(
    appBar: UiGalleryAppBar(
      preset: UiGalleryAppBarPreset.selectionBar,
      title: const Text("Notebook"),
      selectionCount: selected.length,
      onSelectionCleared: onClear,
      actions: [
        if (selected.isNotEmpty)
          IconButton(
            onPressed: onArchive,
            tooltip: 'Archive selected',
            icon: const Icon(Icons.archive_outlined),
          ),
      ],
      style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
    ),
    body: ListView(
      children: [
        for (var i = 0; i < 8; i++)
          CheckboxListTile(
            title: Text('Note ${i + 1}'),
            value: selected.contains(i),
            onChanged: (_) => onToggle(i),
          ),
      ],
    ),
  );
}

// Apply this theme to MaterialApp(theme: showToastsProgressCardTheme()).
ThemeData showToastsProgressCardTheme({
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

UiGalleryToastHandle showToastsProgressCard(
  BuildContext context,
  ValueListenable<double> progress,
  VoidCallback onCancel,
) {
  return UiGalleryToast.progress(
    context,
    title: "Uploading collection",
    message: "Your changes are saved and ready.",
    progress: progress,
    actionLabel: 'Cancel',
    onAction: onCancel,
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}

// Apply this theme to MaterialApp(theme: showBottomNavOverflowDockTheme()).
ThemeData showBottomNavOverflowDockTheme({
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

Widget showBottomNavOverflowDock(int index, ValueChanged<int> onSelected) {
  return UiGalleryBottomNav(
    preset: UiGalleryBottomNavPreset.overflowDock,
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
      UiGalleryBottomNavItem(
        icon: Icon(Icons.collections_bookmark_outlined),
        label: 'Collections',
      ),
      UiGalleryBottomNavItem(icon: Icon(Icons.notes), label: 'Notes'),
    ],
    style: const UiGallerySurfaceStyle(accentColor: Color(0xff007f88)),
  );
}
