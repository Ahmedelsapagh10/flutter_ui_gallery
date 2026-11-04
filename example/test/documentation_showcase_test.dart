import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:nova_surfaces_example/showcase.dart';

void main() {
  testWidgets('showcase owns destination selection', (tester) async {
    await tester.pumpWidget(
      const ShowcaseApp(preset: 'bottomNav.morphingCapsule'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Saved'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<UiGalleryBottomNav>(find.byType(UiGalleryBottomNav))
          .selectedIndex,
      1,
    );
  });

  testWidgets('showcase advances timeline state and handles its typed result', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp(preset: 'dialogs.timeline'));
    await tester.tap(find.text('Show component'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete current step'));
    await tester.pumpAndSettle();
    expect(find.text('Verified'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('SELECTED: CLOSED'), findsOneWidget);
  });

  testWidgets('choice returns a selected value and dismissal stays nullable', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ShowcaseApp(preset: 'dialogs.sideBySideChoice'),
    );
    await tester.tap(find.text('Show component'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Team'));
    await tester.pumpAndSettle();
    expect(find.text('SELECTED: TEAM'), findsOneWidget);
    await tester.tap(find.text('Show component'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Team'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('CLOSED'), findsOneWidget);
  });

  testWidgets(
    'progress notifier survives updates and is disposed with its owner',
    (tester) async {
      await tester.pumpWidget(const ShowcaseApp(preset: 'toasts.progressCard'));
      await tester.tap(find.text('Show component'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete upload'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('closing the owner while a sheet is open is safe', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp(preset: 'sheets.orbit'));
    await tester.tap(find.text('Show component'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
