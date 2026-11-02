import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

void main() {
  setUpAll(() async {
    final config = File('.dart_tool/package_config.json');
    final packages =
        (jsonDecode(config.readAsStringSync())
                as Map<String, dynamic>)['packages']
            as List<dynamic>;
    final flutter = packages.cast<Map<String, dynamic>>().singleWhere(
      (p) => p['name'] == 'flutter',
    );
    final fontRoot = config.absolute.uri
        .resolve(
          '${(flutter['rootUri'] as String).replaceFirst(RegExp(r"/+$"), "")}/',
        )
        .resolve('../../bin/cache/artifacts/material_fonts/');
    for (final font in {
      'Roboto': 'Roboto-Regular.ttf',
      'MaterialIcons': 'MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(font.key)
        ..addFont(
          File.fromUri(
            fontRoot.resolve(font.value),
          ).readAsBytes().then(ByteData.sublistView),
        );
      await loader.load();
    }
  });
  for (final environment in ['light', 'dark', 'rtl', 'large-text']) {
    for (final component in [
      'sheet',
      'dialog',
      'toast',
      'header',
      'navigation',
    ]) {
      testWidgets('$component / $environment family specimen', (tester) async {
        tester.view.physicalSize = const Size(400, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final boundary = GlobalKey();
        late BuildContext owner;
        final base = ThemeData(
          fontFamily: 'Roboto',
          colorSchemeSeed: Colors.indigo,
          brightness: environment == 'dark'
              ? Brightness.dark
              : Brightness.light,
        );
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: base.copyWith(
                extensions: [
                  UiGalleryTheme.family(
                    UiGalleryDesignFamily.values.firstWhere(
                      (family) =>
                          family.name ==
                          const String.fromEnvironment(
                            'PHASE1_FAMILY',
                            defaultValue: 'soft',
                          ),
                    ),
                    theme: base,
                    effects: const bool.fromEnvironment('PHASE1_CHEAP')
                        ? UiGalleryEffects.cheap
                        : UiGalleryEffects.full,
                  ).copyWith(motionIntensity: 0),
                ],
              ),
              builder: (context, child) => Directionality(
                textDirection: environment == 'rtl'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      environment == 'large-text' ? 2 : 1,
                    ),
                  ),
                  child: child!,
                ),
              ),
              home: Scaffold(
                extendBody: component == 'navigation',
                appBar: component == 'header'
                    ? UiGalleryAppBar(
                        preset: UiGalleryAppBarPreset.editorialTopbar,
                        title: const Text('Field notes'),
                        subtitle: const Text('YOUR WEEK IN VIEW'),
                        actions: [
                          IconButton(
                            tooltip: 'More',
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz),
                          ),
                        ],
                      )
                    : null,
                bottomNavigationBar: component == 'navigation'
                    ? UiGalleryBottomNav(
                        preset: UiGalleryBottomNavPreset.glassDock,
                        selectedIndex: 0,
                        onDestinationSelected: (_) {},
                        items: const [
                          UiGalleryBottomNavItem(
                            icon: Icon(Icons.home_outlined),
                            label: 'Home',
                          ),
                          UiGalleryBottomNavItem(
                            icon: Icon(Icons.bookmark_outline),
                            label: 'Saved',
                          ),
                          UiGalleryBottomNavItem(
                            icon: Icon(Icons.person_outline),
                            label: 'Account',
                          ),
                        ],
                      )
                    : null,
                body: Builder(
                  builder: (context) {
                    owner = context;
                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(
                          'A little room to think',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        for (final label in [
                          'New ideas',
                          'A place to return to',
                          'Small discoveries',
                          'Next steps',
                        ])
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.notes),
                              title: Text(label),
                              subtitle: const Text('Personal collection'),
                            ),
                          ),
                        const SizedBox(height: 300),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (component == 'sheet') {
          UiGallerySheet.show<void>(
            context: owner,
            preset: UiGallerySheetPreset.orbit,
            header: const Text('Make room for an idea'),
            child: const Text('Keep this thought in your personal collection.'),
            footer: FilledButton(
              onPressed: () {},
              child: const Text('Save idea'),
            ),
          );
        } else if (component == 'dialog') {
          UiGalleryDialog.confirm(
            context: owner,
            preset: UiGalleryDialogPreset.spotlight,
            title: 'Ready for what is next',
            message: 'Your collection is safely saved.',
            confirmLabel: 'Continue',
          );
        } else if (component == 'toast') {
          UiGalleryToast.show(
            owner,
            preset: UiGalleryToastPreset.ribbonActionBar,
            title: 'CONNECTION',
            message: 'Your changes are waiting to sync.',
            actionLabel: 'Retry',
            onAction: () {},
            duration: Duration.zero,
          );
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        const capture = String.fromEnvironment('PHASE1_CAPTURE');
        if (capture.isNotEmpty) {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await render.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '$capture/$component-$environment.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        } else {
          await expectLater(
            find.byKey(boundary),
            matchesGoldenFile('goldens/phase1/$component-$environment.png'),
          );
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      }, tags: 'golden');
    }
  }
}
