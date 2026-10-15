import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

void main() {
  for (final specimen in [
    'depth-frame',
    'choice-dark-rtl',
    'console',
    'focus-header',
  ]) {
    testWidgets('$specimen visual baseline', (tester) async {
      tester.view.physicalSize = const Size(400, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      late BuildContext context;
      final dark = specimen == 'choice-dark-rtl';
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              brightness: dark ? Brightness.dark : Brightness.light,
              colorSchemeSeed: Colors.indigo,
              extensions: const [UiGalleryTheme(motionIntensity: 0)],
            ),
            builder: (context, child) => Directionality(
              textDirection: dark ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            ),
            home: Scaffold(
              appBar: specimen == 'focus-header'
                  ? const UiGalleryAppBar(
                      preset: UiGalleryAppBarPreset.focusBar,
                      title: Text('Explore'),
                      subtitle: Text('Your workspace'),
                    )
                  : null,
              body: Builder(
                builder: (c) {
                  context = c;
                  return const Center(child: Text('Workspace'));
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (specimen == 'depth-frame') {
        UiGallerySheet.show<void>(
          context: context,
          preset: UiGallerySheetPreset.depthFrame,
          header: const Text('Review membership'),
          footer: FilledButton(onPressed: () {}, child: const Text('Continue')),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workspace plan'),
              SizedBox(height: 16),
              Text('Monthly access to your collections.'),
            ],
          ),
        );
      } else if (specimen == 'choice-dark-rtl') {
        UiGalleryDialog.show<String>(
          context: context,
          title: 'Choose your space',
          message: 'Keep a personal collection or share with your team.',
          preset: UiGalleryDialogPreset.sideBySideChoice,
          actions: const [
            UiGalleryDialogAction(
              label: 'Personal',
              description: 'Just for you.',
              value: 'personal',
            ),
            UiGalleryDialogAction(
              label: 'Team',
              description: 'Create together.',
              value: 'team',
              primary: true,
            ),
          ],
        );
      } else if (specimen == 'console') {
        UiGalleryToast.show(
          context,
          preset: UiGalleryToastPreset.miniConsole,
          title: 'WORKSPACE / STATUS',
          message: 'Changes synchronized.',
          duration: Duration.zero,
        );
      }
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('goldens/$specimen.png'),
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    }, tags: 'golden');
  }
}
