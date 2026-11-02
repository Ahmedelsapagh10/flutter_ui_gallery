import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:flutter_ui_gallery/src/core/gallery_signature.dart';
import 'package:flutter_ui_gallery/src/core/gallery_theme.dart'
    show UiGalleryStyle;
import 'phase1_tokens_test.dart' as tokens;
import 'package:flutter_ui_gallery/src/core/gallery_signature_exceptions.dart';

Future<BuildContext> host(
  WidgetTester tester,
  UiGalleryDesignFamily family, {
  UiGalleryEffects effects = UiGalleryEffects.cheap,
}) async {
  late BuildContext owner;
  final base = ThemeData(colorSchemeSeed: Colors.teal);
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: base.copyWith(
        extensions: [
          UiGalleryTheme.family(
            family,
            theme: base,
            useSignature: true,
            effects: effects,
          ).copyWith(motionIntensity: 0),
        ],
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

void main() {
  test('recipe is explicit and survives copy/interpolation', () {
    final base = UiGalleryTheme.family(
      UiGalleryDesignFamily.minimal,
      theme: ThemeData(),
    );
    expect(base.useSignature, isFalse);
    final on = base.copyWith(useSignature: true);
    expect(on.copyWith().useSignature, isTrue);
    expect(on.copyWith(useSignature: false).useSignature, isFalse);
    expect(base.lerp(on, 0).useSignature, isFalse);
    expect(base.lerp(on, 1).useSignature, isTrue);
  });
  testWidgets(
    'cheap Spatial keeps a flat cue and local recipe overrides compose',
    (tester) async {
      final owner = await host(tester, UiGalleryDesignFamily.spatial);
      final inherited = UiGalleryStyle.of(owner, const UiGalleryTheme());
      expect(inherited.signatureEnabled, isTrue);
      expect(
        UiGalleryStyle.of(
          owner,
          const UiGalleryTheme(useSignature: false),
        ).signatureEnabled,
        isFalse,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: GalleryFamilyRegion(
            style: inherited,
            child: const Text('Flat depth'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final boxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((w) => w.decoration)
          .whereType<BoxDecoration>()
          .toList();
      expect(find.byType(GalleryFamilyEdge), findsOneWidget);
      expect(
        boxes.any(
          (b) => b.color == inherited.theme.colorScheme.secondaryContainer,
        ),
        isFalse,
      );

      expect(boxes.every((b) => b.boxShadow == null), isTrue);
    },
  );
  test('softened exception registry fits every family budget', () {
    expect(GallerySignatureExceptions.minimal.length, 3);
    expect(GallerySignatureExceptions.soft.length, 3);
    expect(GallerySignatureExceptions.spatial.length, 10);
    final all = {
      ...GallerySignatureExceptions.minimal,
      ...GallerySignatureExceptions.soft,
      ...GallerySignatureExceptions.spatial,
    };
    expect(all.length, 14);
    expect(
      GallerySignatureExceptions.minimal.length / 66,
      lessThanOrEqualTo(.25),
    );
    expect(GallerySignatureExceptions.soft.length / 66, lessThanOrEqualTo(.25));
    expect(
      GallerySignatureExceptions.spatial.length / 66,
      lessThanOrEqualTo(.25),
    );
  });
  for (final family in UiGalleryDesignFamily.values) {
    for (final preset in UiGallerySheetPreset.values) {
      testWidgets('$family / $preset structural precedence', (tester) async {
        final owner = await host(tester, family);
        UiGallerySheet.show<void>(
          context: owner,
          preset: preset,
          header: const Text('Shape'),
          child: const Text('Body'),
        );
        await tester.pumpAndSettle();
        final region = tester.widget<GalleryFamilyRegion>(
          find.byType(GalleryFamilyRegion),
        );
        expect(region.framed, preset == UiGallerySheetPreset.neoTray);
        final shape =
            tokens.surface(tester, 'Shape').shape! as RoundedRectangleBorder;
        final radius = shape.borderRadius.resolve(TextDirection.ltr);
        if (preset == UiGallerySheetPreset.orbit) {
          expect(radius.topLeft.x / radius.topRight.x, closeTo(48 / 20, .001));
        }
        if (preset == UiGallerySheetPreset.edgeLift) {
          expect(radius, BorderRadius.zero);
        }
        if (preset == UiGallerySheetPreset.stackPanel) {
          // Exposed structural planes survive even Minimal's no-fill content rule.
          expect(
            find.byWidgetPredicate((w) => w is Positioned && w.top == 7),
            findsOneWidget,
          );
        }
        if (preset == UiGallerySheetPreset.neoTray) {
          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is Container &&
                  w.decoration is BoxDecoration &&
                  (w.decoration! as BoxDecoration).border != null &&
                  (w.decoration! as BoxDecoration).borderRadius == null,
            ),
            findsWidgets,
          );
          expect(
            region.framed,
            isTrue,
          ); // Soft cannot round away the framed well.
        }
        expect(tester.takeException(), isNull);
        Navigator.of(tester.element(find.text('Shape'))).pop();
        await tester.pumpAndSettle();
      });
    }
    for (final preset in UiGalleryDialogPreset.values) {
      testWidgets('$family / $preset dialog precedence', (tester) async {
        final owner = await host(tester, family);
        UiGalleryDialog.show<void>(
          context: owner,
          preset: preset,
          title: 'Decision',
          message: 'Body',
          actions: const [],
        );
        await tester.pumpAndSettle();
        final region = tester.widget<GalleryFamilyRegion>(
          find.byType(GalleryFamilyRegion),
        );
        expect(region.framed, preset == UiGalleryDialogPreset.panelDecision);
        expect(tester.takeException(), isNull);
        Navigator.of(tester.element(find.text('Decision'))).pop();
        await tester.pumpAndSettle();
      });
    }
    testWidgets('$family preserves toast bevel, capsule and console type', (
      tester,
    ) async {
      final owner = await host(tester, family);
      for (final preset in [
        UiGalleryToastPreset.stackTag,
        UiGalleryToastPreset.signal,
        UiGalleryToastPreset.miniConsole,
      ]) {
        final handle = UiGalleryToast.show(
          owner,
          preset: preset,
          message: 'Saved',
          duration: Duration.zero,
        );
        await tester.pumpAndSettle();
        final shape = tokens.surface(tester, 'Saved').shape!;
        if (preset == UiGalleryToastPreset.stackTag) {
          expect(shape, isA<BeveledRectangleBorder>());
        }
        if (preset == UiGalleryToastPreset.signal) {
          expect(
            (shape as RoundedRectangleBorder).borderRadius
                .resolve(TextDirection.ltr)
                .topLeft
                .x,
            greaterThanOrEqualTo(UiGalleryTokens.radiusCapsule),
          );
        }
        if (preset == UiGalleryToastPreset.miniConsole) {
          expect(
            (shape as RoundedRectangleBorder).borderRadius,
            BorderRadius.zero,
          );
          expect(
            tester.widget<Text>(find.text('Saved')).style!.fontFamily,
            'monospace',
          );
        }
        handle.dismiss();
        await tester.pumpAndSettle();
        await handle.closed;
      }
    });
    for (final preset in UiGalleryBottomNavPreset.values) {
      testWidgets('$family / $preset navigation path and targets survive', (
        tester,
      ) async {
        final owner = await host(tester, family);
        var selected = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: Theme.of(owner),
            home: StatefulBuilder(
              builder: (context, update) => Scaffold(
                bottomNavigationBar: UiGalleryBottomNav(
                  preset: preset,
                  selectedIndex: selected,
                  onDestinationSelected: (i) => update(() => selected = i),
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
        if (preset == UiGalleryBottomNavPreset.overflowDock) {
          expect(find.byType(GalleryFamilyEdge), findsNothing);
          expect(find.byTooltip('Search'), findsOneWidget);
        } else {
          final edge = tester.widget<GalleryFamilyEdge>(
            find.byType(GalleryFamilyEdge),
          );
          expect(edge.shape, isNotNull);
          expect(
            edge.ownsDepth,
            {
              UiGalleryBottomNavPreset.concaveNotch,
              UiGalleryBottomNavPreset.splitIsland,
              UiGalleryBottomNavPreset.orbitDock,
              UiGalleryBottomNavPreset.layeredShelf,
              UiGalleryBottomNavPreset.perspectiveDock,
            }.contains(preset),
          );
        }
        await tester.tap(find.byTooltip('Search'));
        await tester.pumpAndSettle();
        expect(selected, 1);
        expect(tester.takeException(), isNull);
      });
    }
    for (final preset in UiGalleryAppBarPreset.values) {
      testWidgets('$family / $preset header precedence', (tester) async {
        final owner = await host(tester, family);
        await tester.pumpWidget(
          MaterialApp(
            theme: Theme.of(owner),
            home: Scaffold(
              appBar: UiGalleryAppBar(
                preset: preset,
                title: const Text('Heading'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final edge = tester.widget<GalleryFamilyEdge>(
          find.byType(GalleryFamilyEdge),
        );
        expect(edge.ownsRule, preset == UiGalleryAppBarPreset.editorialTopbar);
        expect(
          edge.ownsDepth,
          {
            UiGalleryAppBarPreset.sculptedWave,
            UiGalleryAppBarPreset.foldedCanopy,
            UiGalleryAppBarPreset.parallaxCrest,
            UiGalleryAppBarPreset.orbitCommand,
          }.contains(preset),
        );
        if (preset == UiGalleryAppBarPreset.editorialTopbar) {
          expect(
            DefaultTextStyle.of(
              tester.element(find.text('Heading')),
            ).style.fontWeight,
            UiGalleryStyle.of(tester.element(find.text('Heading')))
                .heading(
                  const TextStyle(fontWeight: FontWeight.w400),
                  editorial: true,
                )
                .fontWeight,
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
