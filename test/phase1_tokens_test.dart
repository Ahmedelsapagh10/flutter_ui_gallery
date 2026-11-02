import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:flutter_ui_gallery/src/core/gallery_theme.dart'
    show UiGalleryStyle;

Future<BuildContext> host(
  WidgetTester tester,
  UiGalleryDesignFamily family, {
  bool highContrast = false,
  bool reduced = false,
  UiGalleryEffects effects = UiGalleryEffects.full,
  UiGallerySurfaceStyle? style,
}) async {
  late BuildContext owner;
  final base = ThemeData(colorSchemeSeed: Colors.teal);
  await tester.pumpWidget(
    MaterialApp(
      key: ValueKey('host-$family-$effects-$highContrast-$reduced'),
      theme: base.copyWith(
        extensions: [
          UiGalleryTheme.family(family, theme: base, effects: effects).copyWith(
            surfaceStyle: UiGalleryTheme.family(
              family,
              theme: base,
            ).surfaceStyle!.merge(style),
          ),
        ],
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(highContrast: highContrast, disableAnimations: reduced),
        child: child!,
      ),
      home: Builder(
        builder: (context) {
          owner = context;
          return const Scaffold();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return owner;
}

Material surface(WidgetTester tester, String text) => tester.widget<Material>(
  find.ancestor(of: find.text(text), matching: find.byType(Material)).first,
);

void main() {
  test(
    'spacing scale, geometry, finite spring endpoints and timing tokens',
    () {
      expect(
        [
          UiGalleryTokens.space1,
          UiGalleryTokens.space2,
          UiGalleryTokens.space3,
          UiGalleryTokens.space4,
          UiGalleryTokens.space5,
          UiGalleryTokens.space6,
          UiGalleryTokens.space7,
          UiGalleryTokens.space8,
        ],
        [4, 8, 12, 16, 20, 24, 28, 32],
      );
      expect(UiGalleryTokens.glassBlur, greaterThan(0));
      expect(UiGalleryTokens.touchTarget, greaterThanOrEqualTo(48));
      for (final curve in [
        UiGalleryTokens.preciseCurve,
        UiGalleryTokens.softSpring,
        UiGalleryTokens.spatialSpring,
      ]) {
        expect(curve.transform(0), 0);
        expect(curve.transform(1), 1);
        for (var i = 0; i <= 100; i++) {
          expect(curve.transform(i / 100).isFinite, isTrue);
          expect(curve.transform(i / 100), inInclusiveRange(0, 1.1));
        }
      }
      expect(
        UiGalleryTokens.softSpring.transform(.3),
        isNot(UiGalleryTokens.spatialSpring.transform(.3)),
      );
      expect(const UiGalleryMotion().entrance, UiGalleryTokens.entrance);
      expect(
        UiGalleryTokens.minimalEntrance,
        lessThan(UiGalleryTokens.softEntrance),
      );
      expect(
        UiGalleryTokens.softEntrance,
        lessThan(UiGalleryTokens.spatialEntrance),
      );
    },
  );

  for (final family in UiGalleryDesignFamily.values) {
    testWidgets('$family refines asymmetric sheet corners and square edges', (
      tester,
    ) async {
      final owner = await host(tester, family);
      for (final preset in [
        UiGallerySheetPreset.orbit,
        UiGallerySheetPreset.prism,
        UiGallerySheetPreset.edgeLift,
      ]) {
        UiGallerySheet.show<void>(
          context: owner,
          preset: preset,
          header: const Text('Shape'),
          child: const Text('Content'),
        );
        await tester.pumpAndSettle();
        final shape = surface(tester, 'Shape').shape! as RoundedRectangleBorder;
        final radius = shape.borderRadius.resolve(TextDirection.ltr);
        if (preset == UiGallerySheetPreset.orbit) {
          expect(radius.topLeft.x / radius.topRight.x, closeTo(48 / 20, .001));
          expect(
            radius.bottomLeft.x / radius.bottomRight.x,
            closeTo(24 / 36, .001),
          );
        } else if (preset == UiGallerySheetPreset.prism) {
          expect(radius.topRight.x / radius.topLeft.x, closeTo(52 / 8, .001));
        } else {
          expect(radius, BorderRadius.zero);
        }
        Navigator.of(tester.element(find.text('Shape'))).pop();
        await tester.pumpAndSettle();
      }
    });

    testWidgets(
      '$family preserves bevel, pill, square console and monospace roles',
      (tester) async {
        final owner = await host(tester, family);
        for (final preset in [
          UiGalleryToastPreset.stackTag,
          UiGalleryToastPreset.signal,
          UiGalleryToastPreset.miniConsole,
        ]) {
          final handle = UiGalleryToast.show(
            owner,
            preset: preset,
            title: 'STATUS',
            message: 'Saved',
            duration: Duration.zero,
          );
          await tester.pumpAndSettle();
          final shape = surface(tester, 'Saved').shape!;
          if (preset == UiGalleryToastPreset.stackTag) {
            expect(shape, isA<BeveledRectangleBorder>());
            final radius = (shape as BeveledRectangleBorder).borderRadius
                .resolve(TextDirection.ltr);
            expect(radius.topRight.x, greaterThan(0));
            expect(radius.topLeft, Radius.zero);
            expect(radius.bottomLeft, Radius.zero);
          } else if (preset == UiGalleryToastPreset.signal) {
            final radius = (shape as RoundedRectangleBorder).borderRadius
                .resolve(TextDirection.ltr);
            expect(
              radius.topLeft.x,
              greaterThanOrEqualTo(UiGalleryTokens.radiusCapsule),
            );
          } else {
            expect(
              (shape as RoundedRectangleBorder).borderRadius,
              BorderRadius.zero,
            );
            expect(
              tester.widget<Text>(find.text('Saved')).style!.fontFamily,
              'monospace',
            );
            expect(
              tester.widget<Text>(find.text('STATUS')).style!.fontFamily,
              'monospace',
            );
          }
          handle.dismiss();
          await tester.pumpAndSettle();
          await handle.closed;
        }
      },
    );

    testWidgets(
      '$family retains editorial type hierarchy and family personality',
      (tester) async {
        final owner = await host(tester, family);
        final style = UiGalleryStyle.of(owner);
        final generic = style.heading(
          const TextStyle(fontWeight: FontWeight.w600),
        );
        final editorial = style.heading(
          const TextStyle(fontWeight: FontWeight.w400),
          editorial: true,
        );
        expect(
          editorial.fontWeight!.value,
          lessThan(generic.fontWeight!.value),
        );
        expect(style.gallery.radiusScale, [0.65, 1, 1.2][family.index]);
        expect(
          style.motion.curve,
          [
            UiGalleryTokens.preciseCurve,
            UiGalleryTokens.softSpring,
            UiGalleryTokens.spatialSpring,
          ][family.index],
        );
        expect(
          generic.fontWeight,
          [FontWeight.w500, FontWeight.w600, FontWeight.w700][family.index],
        );
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey('editorial-$family'),
            theme: Theme.of(owner),
            home: const Scaffold(
              appBar: UiGalleryAppBar(
                preset: UiGalleryAppBarPreset.editorialTopbar,
                title: Text('Editorial'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          DefaultTextStyle.of(
            tester.element(find.text('Editorial')),
          ).style.fontWeight,
          editorial.fontWeight,
        );
      },
    );

    testWidgets(
      '$family strengthens high-contrast lines and honors reduced motion',
      (tester) async {
        var owner = await host(tester, family);
        final normal = UiGalleryStyle.of(owner).line;
        owner = await host(tester, family, highContrast: true, reduced: true);
        final style = UiGalleryStyle.of(owner);
        expect(style.line.a, greaterThan(normal.a));
        expect(
          style.line.a,
          closeTo(UiGalleryTokens.highContrastDividerOpacity, .001),
        );
        expect(style.muted, style.content);
        expect(style.duration(style.motion.entrance), Duration.zero);
        const explicit = UiGallerySurfaceStyle(
          borderColor: Colors.orange,
          shape: StadiumBorder(),
          titleStyle: TextStyle(fontWeight: FontWeight.w900),
        );
        final custom = UiGalleryStyle.of(owner, null, explicit);
        expect(custom.line, Colors.orange);
        expect(
          custom.shape(const RoundedRectangleBorder()),
          isA<StadiumBorder>(),
        );
        expect(custom.heading(const TextStyle()).fontWeight, FontWeight.w900);
      },
    );
  }

  testWidgets(
    'cheap Glass Dock is opaque, contains no blur, and retains selection',
    (tester) async {
      for (final effects in UiGalleryEffects.values) {
        final owner = await host(
          tester,
          UiGalleryDesignFamily.spatial,
          effects: effects,
        );
        var selected = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: Theme.of(owner),
            home: StatefulBuilder(
              builder: (context, setState) => Scaffold(
                extendBody: true,
                bottomNavigationBar: UiGalleryBottomNav(
                  preset: UiGalleryBottomNavPreset.glassDock,
                  style: UiGallerySurfaceStyle(
                    surfaceColor: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: .2),
                  ),
                  selectedIndex: selected,
                  onDestinationSelected: (value) =>
                      setState(() => selected = value),
                  items: const [
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    UiGalleryBottomNavItem(
                      icon: Icon(Icons.search),
                      label: 'Search',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byType(BackdropFilter),
          effects == UiGalleryEffects.cheap ? findsNothing : findsOneWidget,
        );
        final face = tester
            .widgetList<Material>(find.byType(Material))
            .where((m) => m.shape != null)
            .first;
        if (effects == UiGalleryEffects.cheap) {
          expect(face.color!.a, 1);
          expect(
            face.elevation,
            lessThanOrEqualTo(UiGalleryTokens.cheapElevation),
          );
        }
        await tester.tap(find.byTooltip('Search'));
        await tester.pumpAndSettle();
        expect(selected, 1);
      }
    },
  );

  testWidgets(
    'Ribbon Action Bar has a separate action-first dock and stable accessible targets',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final family in UiGalleryDesignFamily.values) {
        for (final wide in [false, true]) {
          tester.view.physicalSize = Size(wide ? 600 : 320, 800);
          final owner = await host(tester, family, reduced: true);
          final handle = UiGalleryToast.show(
            owner,
            preset: UiGalleryToastPreset.ribbonActionBar,
            message: 'Waiting to sync',
            actionLabel: 'Retry',
            duration: Duration.zero,
            onAction: () {},
          );
          await tester.pumpAndSettle();
          final shape =
              surface(tester, 'Waiting to sync').shape!
                  as RoundedRectangleBorder;
          final radius = shape.borderRadius.resolve(TextDirection.ltr);
          expect(radius.topLeft.x, greaterThan(0));
          expect(radius.bottomLeft, Radius.zero);
          final action = find.widgetWithText(TextButton, 'Retry');
          expect(tester.getSize(action).shortestSide, greaterThanOrEqualTo(48));
          if (wide) {
            expect(
              tester.getRect(action).right,
              lessThan(tester.getRect(find.text('Waiting to sync')).left),
            );
          } else {
            expect(
              tester.getRect(action).bottom,
              lessThanOrEqualTo(
                tester.getRect(find.text('Waiting to sync')).top,
              ),
            );
          }
          final semantics = tester.ensureSemantics();
          expect(
            tester.getSemantics(action),
            matchesSemantics(
              label: 'Retry',
              isButton: true,
              hasEnabledState: true,
              isEnabled: true,
              isFocusable: true,
              hasTapAction: true,
              hasFocusAction: true,
            ),
          );
          semantics.dispose();
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          expect(
            FocusManager.instance.primaryFocus?.context
                ?.findAncestorWidgetOfExactType<TextButton>(),
            isNotNull,
          );
          handle.dismiss();
          await tester.pumpAndSettle();
          await handle.closed;
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'color roles, effects and geometry survive copy/merge/interpolation',
    (tester) async {
      final owner = await host(tester, UiGalleryDesignFamily.soft);
      final style = UiGalleryStyle.of(owner);
      final colors = Theme.of(owner).colorScheme;
      expect(style.foregroundFor(colors.primary), colors.onPrimary);
      expect(style.foregroundFor(colors.error), colors.onError);
      final a = style.gallery.copyWith(
        effects: UiGalleryEffects.cheap,
        radiusScale: .8,
      );
      final b = a.copyWith(effects: UiGalleryEffects.full, radiusScale: 1.2);
      expect(a.copyWith().effects, UiGalleryEffects.cheap);
      expect(a.lerp(b, .5).radiusScale, closeTo(1, .001));
      expect(a.lerp(b, 0).effects, UiGalleryEffects.cheap);
      expect(a.lerp(b, 1).effects, UiGalleryEffects.full);
      final local = UiGalleryStyle.of(
        owner,
        const UiGalleryTheme(effects: UiGalleryEffects.cheap),
      );
      expect(local.cheapEffects, isTrue);
      expect(local.gallery.designFamily, UiGalleryDesignFamily.soft);
    },
  );
}
