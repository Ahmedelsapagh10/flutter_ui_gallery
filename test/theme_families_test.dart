import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:flutter_ui_gallery/src/core/gallery_theme.dart';

void main() {
  test('partial style overrides retain geometry, colors and typography', () {
    const base = UiGallerySurfaceStyle(
      accentColor: Colors.teal,
      padding: EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      titleStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    );
    final changed = base.copyWith(
      titleStyle: const TextStyle(color: Colors.red),
    );
    expect(changed.padding, base.padding);
    expect(changed.shape, base.shape);
    expect(changed.accentColor, Colors.teal);
    expect(changed.titleStyle!.fontSize, 22);
    expect(changed.titleStyle!.fontWeight, FontWeight.w600);
    expect(changed.titleStyle!.color, Colors.red);
    expect(base.merge(null), same(base));
  });

  test(
    'motion overrides preserve inherited timings, including explicit default values',
    () {
      const motion = UiGalleryMotion(
        entrance: Duration(milliseconds: 600),
        change: Duration(milliseconds: 400),
      );
      final changed = motion.merge(const UiGalleryMotion(intensity: .5));
      expect(changed.entrance, motion.entrance);
      expect(changed.change, motion.change);
      expect(changed.intensity, .5);
      expect(
        motion.copyWith(change: const Duration(milliseconds: 240)).change,
        const Duration(milliseconds: 240),
      );
      expect(
        const UiGalleryMotion().entrance,
        const Duration(milliseconds: 340),
      );
      expect(const UiGalleryMotion().exit, const Duration(milliseconds: 220));
    },
  );

  test(
    'theme interpolation is continuous for surfaces, geometry and motion',
    () {
      const a = UiGalleryTheme(
        surfaceStyle: UiGallerySurfaceStyle(
          surfaceColor: Colors.black,
          padding: EdgeInsets.all(10),
          elevation: 0,
          maxWidth: 300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        motion: UiGalleryMotion(
          change: Duration(milliseconds: 200),
          curve: Curves.linear,
        ),
      );
      const b = UiGalleryTheme(
        surfaceStyle: UiGallerySurfaceStyle(
          surfaceColor: Colors.white,
          padding: EdgeInsets.all(30),
          elevation: 6,
          maxWidth: 500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        motion: UiGalleryMotion(
          change: Duration(milliseconds: 400),
          curve: Curves.easeIn,
        ),
      );
      final middle = a.lerp(b, .5);
      expect(
        middle.surfaceStyle!.surfaceColor,
        Color.lerp(Colors.black, Colors.white, .5),
      );
      expect(middle.surfaceStyle!.padding, const EdgeInsets.all(20));
      expect(middle.surfaceStyle!.maxWidth, 400);
      expect(middle.surfaceStyle!.elevation, 3);
      expect(
        (middle.surfaceStyle!.shape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(20),
      );
      expect(middle.motion!.change, const Duration(milliseconds: 300));
      expect(
        middle.motion!.curve.transform(.3),
        closeTo((.3 + Curves.easeIn.transform(.3)) / 2, .0001),
      );
      final before = a.lerp(b, .499).surfaceStyle!.surfaceColor!.r;
      final after = a.lerp(b, .501).surfaceStyle!.surfaceColor!.r;
      expect((after - before).abs(), lessThan(.01));
      expect(a.lerp(b, 0).surfaceStyle, same(a.surfaceStyle));
      expect(a.lerp(b, 1).surfaceStyle, same(b.surfaceStyle));
    },
  );

  test('missing interpolation endpoints do not create zero-width surfaces', () {
    const style = UiGallerySurfaceStyle(
      maxWidth: 500,
      padding: EdgeInsets.all(24),
    );
    final between = UiGallerySurfaceStyle.lerp(
      const UiGallerySurfaceStyle(),
      style,
      .001,
    )!;
    expect(between.maxWidth, 500);
    expect(between.padding, style.padding);
    expect(UiGallerySurfaceStyle.lerp(null, null, .5), isNull);
  });

  testWidgets(
    'global, component, appearance and call overrides inherit field by field',
    (tester) async {
      late UiGalleryStyle resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              UiGalleryTheme(
                surfaceStyle: UiGallerySurfaceStyle(
                  accentColor: Colors.teal,
                  padding: EdgeInsets.all(10),
                  elevation: 2,
                ),
                dialogStyle: UiGallerySurfaceStyle(padding: EdgeInsets.all(24)),
                motion: UiGalleryMotion(change: Duration(milliseconds: 500)),
              ),
            ],
          ),
          home: Builder(
            builder: (context) {
              resolved = UiGalleryStyle.of(
                context,
                const UiGalleryTheme(
                  surfaceStyle: UiGallerySurfaceStyle(
                    surfaceColor: Colors.orange,
                  ),
                  dialogStyle: UiGallerySurfaceStyle(elevation: 4),
                ),
                const UiGallerySurfaceStyle(accentColor: Colors.purple),
                const UiGalleryMotion(intensity: .5),
                UiGallerySurface.dialog,
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(resolved.visual.padding, const EdgeInsets.all(24));
      expect(resolved.visual.elevation, 4);
      expect(resolved.accent, Colors.purple);
      expect(resolved.surface, Colors.orange);
      expect(resolved.motion.change, const Duration(milliseconds: 500));
      expect(
        resolved.duration(resolved.motion.change),
        const Duration(milliseconds: 250),
      );
    },
  );

  testWidgets('legacy appearance colors override the inherited family', (
    tester,
  ) async {
    late UiGalleryStyle resolved;
    final base = ThemeData();
    await tester.pumpWidget(
      MaterialApp(
        theme: base.copyWith(
          extensions: [
            UiGalleryTheme.family(UiGalleryDesignFamily.soft, theme: base),
          ],
        ),
        home: Builder(
          builder: (context) {
            resolved = UiGalleryStyle.of(
              context,
              const UiGalleryTheme(accentColor: Colors.orange),
            );
            return const SizedBox();
          },
        ),
      ),
    );
    expect(resolved.accent, Colors.orange);
  });

  testWidgets('local color overrides retain global reduced motion', (
    tester,
  ) async {
    late UiGalleryStyle resolved;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const [UiGalleryTheme(motionIntensity: 0)],
        ),
        home: Builder(
          builder: (context) {
            resolved = UiGalleryStyle.of(
              context,
              const UiGalleryTheme(accentColor: Colors.orange),
            );
            return const SizedBox();
          },
        ),
      ),
    );
    expect(resolved.accent, Colors.orange);
    expect(resolved.reduceMotion, isTrue);
    expect(resolved.duration(const Duration(seconds: 1)), Duration.zero);
  });

  for (final family in UiGalleryDesignFamily.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${family.name} ${brightness.name} keeps five surfaces usable in narrow RTL',
        (tester) async {
          tester.view.physicalSize = const Size(320, 760);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final base = ThemeData(brightness: brightness);
          final recipe = UiGalleryTheme.family(family, theme: base);
          expect(recipe.appBarStyle!.shape, isNull);
          expect(recipe.bottomNavStyle!.shape, isNull);
          late BuildContext owner;
          await tester.pumpWidget(
            MaterialApp(
              theme: base.copyWith(extensions: [recipe]),
              builder: (context, child) => Directionality(
                textDirection: TextDirection.rtl,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(2),
                    disableAnimations: true,
                  ),
                  child: child!,
                ),
              ),
              home: Scaffold(
                appBar: UiGalleryAppBar(
                  preset: UiGalleryAppBarPreset.centeredTitle,
                  title: const Text('Workspace'),
                  actions: [
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                  ],
                ),
                bottomNavigationBar: UiGalleryBottomNav(
                  selectedIndex: 0,
                  onDestinationSelected: (_) {},
                  preset: UiGalleryBottomNavPreset.adaptiveMinimal,
                  items: const [
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.home_outlined),
                      label: 'Home',
                    ),
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.bookmark_outline),
                      label: 'Saved',
                    ),
                  ],
                ),
                body: Builder(
                  builder: (context) {
                    owner = context;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.getSize(find.byTooltip('Notifications')).shortestSide,
            greaterThanOrEqualTo(48),
          );
          final sheet = UiGallerySheet.show<void>(
            context: owner,
            header: const Text('Review'),
            child: const Text('A longer message for review'),
          );
          await tester.pumpAndSettle();
          Navigator.of(tester.element(find.text('Review'))).pop();
          await tester.pumpAndSettle();
          await sheet;
          final dialog = UiGalleryDialog.confirm(
            context: owner,
            title: 'Continue?',
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
          expect(await dialog, true);
          final toast = UiGalleryToast.success(owner, message: 'Saved');
          await tester.pumpAndSettle();
          toast.dismiss();
          await tester.pumpAndSettle();
          await toast.closed;
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
