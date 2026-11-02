import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

const fontRoot =
    '/Users/ahmedelsapagh/development/flutter/bin/cache/artifacts/material_fonts';

ThemeData theme(bool dark) => ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',
  brightness: dark ? Brightness.dark : Brightness.light,
  colorSchemeSeed: const Color(0xff6254db),
  extensions: const [UiGalleryTheme(motionIntensity: 0)],
);

Widget scene({
  required bool dark,
  required String title,
  required String subtitle,
  required WidgetBuilder builder,
  double height = 500,
}) => Expanded(
  child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme(dark),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(size: Size(500, height)),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 2),
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: Builder(builder: builder)),
            ],
          ),
        ),
      ),
    ),
  ),
);

Widget board(GlobalKey key, List<Widget> children) => RepaintBoundary(
  key: key,
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: const Color(0xffe9eaf0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [children[0], const SizedBox(width: 20), children[1]],
        ),
      ),
    ),
  ),
);

Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      'doc/assets/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    for (final entry in {
      'Roboto': 'Roboto-Regular.ttf',
      'MaterialIcons': 'MaterialIcons-Regular.otf',
      'monospace': 'Roboto-Regular.ttf',
    }.entries) {
      final file = File('$fontRoot/${entry.value}');
      if (file.existsSync()) {
        final loader = FontLoader(entry.key)
          ..addFont(
            file.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        await loader.load();
      }
    }
  });
  testWidgets('capture actual components for README', (tester) async {
    tester.view.physicalSize = const Size(1060, 540);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var key = GlobalKey();
    late BuildContext sheetContextLight, sheetContextDark;
    await tester.pumpWidget(
      board(key, [
        scene(
          dark: false,
          title: 'Bottom sheets',
          subtitle: 'Orbit Dock',
          builder: (context) {
            sheetContextLight = context;
            return const SizedBox.expand();
          },
        ),
        scene(
          dark: true,
          title: 'Bottom sheets',
          subtitle: 'Depth Frame',
          builder: (context) {
            sheetContextDark = context;
            return const SizedBox.expand();
          },
        ),
      ]),
    );
    await tester.pumpAndSettle();
    if (!sheetContextLight.mounted) {
      throw StateError(
        'The sheetContextLight capture scene is no longer mounted.',
      );
    }
    if (!sheetContextDark.mounted) {
      throw StateError(
        'The sheetContextDark capture scene is no longer mounted.',
      );
    }
    UiGallerySheet.show<void>(
      context: sheetContextLight,
      preset: UiGallerySheetPreset.orbitDock,
      barrierColor: Colors.transparent,
      header: const Text('Make it yours'),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose where your next idea belongs.'),
          SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.auto_awesome_outlined),
            title: Text('Personal space'),
            subtitle: Text('A place for your best ideas'),
            trailing: Icon(Icons.check_circle_rounded),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.people_outline_rounded),
            title: Text('Team workspace'),
            subtitle: Text('Build something together'),
          ),
        ],
      ),
      footer: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {},
          child: const Text('Create workspace'),
        ),
      ),
    );
    UiGallerySheet.show<void>(
      context: sheetContextDark,
      preset: UiGallerySheetPreset.depthFrame,
      barrierColor: Colors.transparent,
      header: const Text('Project Overview'),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review team allocations and milestones.'),
          SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.layers_outlined),
            title: Text('Mobile Core Architecture'),
            subtitle: Text('Sprint 4 · In Progress'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.bolt_outlined),
            title: Text('Design System Tokens'),
            subtitle: Text('Completed · 66 presets'),
          ),
        ],
      ),
      footer: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {},
          child: const Text('Approve & Continue'),
        ),
      ),
    );
    await capture(tester, key, 'preview-sheets');

    tester.view.physicalSize = const Size(1060, 560);
    key = GlobalKey();
    late BuildContext dialogContextLight, dialogContextDark;
    await tester.pumpWidget(
      board(key, [
        scene(
          dark: false,
          title: 'Choice Dialogs',
          subtitle: 'Side-by-Side Choice',
          height: 540,
          builder: (context) {
            dialogContextLight = context;
            return const SizedBox.expand();
          },
        ),
        scene(
          dark: true,
          title: 'Results & Success',
          subtitle: 'Spotlight Result',
          height: 540,
          builder: (context) {
            dialogContextDark = context;
            return const SizedBox.expand();
          },
        ),
      ]),
    );
    await tester.pumpAndSettle();
    if (!dialogContextLight.mounted) {
      throw StateError(
        'The dialogContextLight capture scene is no longer mounted.',
      );
    }
    if (!dialogContextDark.mounted) {
      throw StateError(
        'The dialogContextDark capture scene is no longer mounted.',
      );
    }
    UiGalleryDialog.show<String>(
      context: dialogContextLight,
      preset: UiGalleryDialogPreset.sideBySideChoice,
      barrierColor: Colors.transparent,
      alignment: const Alignment(0, 0.25),
      title: 'Room for your next idea',
      message: 'Start a private collection or invite your team to collaborate.',
      icon: const Icon(Icons.auto_awesome_rounded),
      actions: const [
        UiGalleryDialogAction(
          label: 'Personal',
          description: 'Just for you',
          value: 'personal',
          icon: Icon(Icons.person_outline),
        ),
        UiGalleryDialogAction(
          label: 'Team',
          description: 'Better together',
          value: 'team',
          primary: true,
          icon: Icon(Icons.people_outline),
        ),
      ],
    );
    UiGalleryDialog.show<void>(
      context: dialogContextDark,
      preset: UiGalleryDialogPreset.spotlight,
      barrierColor: Colors.transparent,
      alignment: const Alignment(0, 0.25),
      result: UiGalleryResult.success,
      title: 'Payment Complete',
      message: 'Receipt #4829 has been emailed to you. Your plan is active.',
      actions: const [
        UiGalleryDialogAction(label: 'Done', value: null, primary: true),
      ],
    );
    await capture(tester, key, 'preview-dialogs');

    tester.view.physicalSize = const Size(1060, 460);
    key = GlobalKey();
    late BuildContext lightToast, darkToast;
    await tester.pumpWidget(
      board(key, [
        scene(
          dark: false,
          title: 'A little feedback. A clear next step.',
          subtitle: 'Signal Pill · Action Capsule · Progress Card',
          builder: (context) {
            lightToast = context;
            return const SizedBox.expand();
          },
        ),
        scene(
          dark: true,
          title: 'Made for dark mode, too.',
          subtitle: 'Edge Ribbon · Stack Tag · Mini Console',
          builder: (context) {
            darkToast = context;
            return const SizedBox.expand();
          },
        ),
      ]),
    );
    await tester.pumpAndSettle();
    if (!lightToast.mounted) {
      throw StateError('The lightToast capture scene is no longer mounted.');
    }
    if (!darkToast.mounted) {
      throw StateError('The darkToast capture scene is no longer mounted.');
    }
    final progress = ValueNotifier<double>(.68);
    UiGalleryToast.show(
      lightToast,
      message: 'All changes saved',
      kind: UiGalleryToastKind.success,
      duration: Duration.zero,
      maxVisible: 3,
    );
    UiGalleryToast.show(
      lightToast,
      message: 'Note moved to archive',
      preset: UiGalleryToastPreset.actionCapsule,
      actionLabel: 'Undo',
      onAction: () {},
      duration: Duration.zero,
      maxVisible: 3,
    );
    UiGalleryToast.show(
      lightToast,
      title: 'Uploading your collection',
      message: '12 photos · Keep creating',
      preset: UiGalleryToastPreset.progressCard,
      progressValue: progress,
      duration: Duration.zero,
      maxVisible: 3,
    );
    UiGalleryToast.show(
      darkToast,
      message: 'You are back online',
      preset: UiGalleryToastPreset.edgeRibbon,
      kind: UiGalleryToastKind.success,
      duration: Duration.zero,
      maxVisible: 3,
    );
    UiGalleryToast.show(
      darkToast,
      message: 'New comment from Maya',
      preset: UiGalleryToastPreset.stackTag,
      duration: Duration.zero,
      maxVisible: 3,
    );
    UiGalleryToast.show(
      darkToast,
      title: 'WORKSPACE / STATUS',
      message: 'Everything is up to date.',
      preset: UiGalleryToastPreset.miniConsole,
      duration: Duration.zero,
      maxVisible: 3,
    );
    await capture(tester, key, 'preview-toasts');
    progress.dispose();

    tester.view.physicalSize = const Size(1060, 510);
    key = GlobalKey();
    await tester.pumpWidget(
      board(key, [
        for (final dark in [false, true])
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: theme(dark),
                home: Scaffold(
                  appBar: UiGalleryAppBar(
                    preset: dark
                        ? UiGalleryAppBarPreset.sculptedWave
                        : UiGalleryAppBarPreset.focusBar,
                    title: const Text('Your daily inspiration'),
                    subtitle: const Text('Keep the ideas that move you.'),
                    actions: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none_rounded),
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dark
                              ? 'Sculpted Wave + Glass Dock'
                              : 'Focus Bar + Floating Cove',
                          style: TextStyle(
                            color: dark
                                ? const Color(0xffccc4fa)
                                : const Color(0xff6254db),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.landscape_outlined),
                          title: Text('A weekend in the mountains'),
                          subtitle: Text('Personal · 8 notes'),
                        ),
                        const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.lightbulb_outline_rounded),
                          title: Text('Small ideas, big possibilities'),
                          subtitle: Text('Workspace · 12 notes'),
                        ),
                      ],
                    ),
                  ),
                  bottomNavigationBar: UiGalleryBottomNav(
                    preset: dark
                        ? UiGalleryBottomNavPreset.glassDock
                        : UiGalleryBottomNavPreset.floatingCove,
                    selectedIndex: 0,
                    onDestinationSelected: (_) {},
                    items: const [
                      UiGalleryBottomNavItem(
                        icon: Icon(Icons.explore_outlined),
                        label: 'Discover',
                      ),
                      UiGalleryBottomNavItem(
                        icon: Icon(Icons.bookmark_border_rounded),
                        label: 'Saved',
                      ),
                      UiGalleryBottomNavItem(
                        icon: Icon(Icons.person_outline_rounded),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
    await capture(tester, key, 'preview-navigation');
  });
}
