import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_surfaces_example/gallery/wallet.dart';
import 'still_home_fonts.dart';

Future<void> host(
  WidgetTester tester, {
  bool ar = false,
  StillStatementExporter exporter = buildStillStatement,
}) async {
  tester.view.physicalSize = const Size(480, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: StillExample(arabic: ar, reducedMotion: true, exporter: exporter),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadStillFonts);
  test(
    'minor-unit formatting and parsing never use floating money or mix currencies',
    () {
      expect(stillAmount(1248050, 'EGP'), '12,480.50 EGP');
      expect(stillAmount(-46875, 'EGP', arabic: true), '−٤٦٨٫٧٥ ج.م.');
      expect(stillAmount(380000, 'USD', arabic: true), '٣٬٨٠٠٫٠٠ دولار أمريكي');
      expect(stillParseMinor('١٢٣٫٤٥'), 12345);
      expect(stillParseMinor('0.1'), 10);
      for (final s in ['1,000', '١٬٠٠٠', '1e3', '-10', '12.345', 'NaN', '']) {
        expect(stillParseMinor(s), isNull, reason: s);
      }
    },
  );
  testWidgets(
    'transfer validates, creates one local draft and does not change balances',
    (tester) async {
      await host(tester);
      await tester.tap(find.byTooltip('Plan a transfer'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Review local plan'));
      await tester.tap(find.text('Review local plan'));
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a positive amount with up to two decimals.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const ValueKey('still-transfer-amount')),
        '999999',
      );
      await tester.tap(find.text('Review local plan'));
      await tester.pumpAndSettle();
      expect(find.text('This exceeds the sample balance.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('still-transfer-amount')),
        '125.50',
      );
      await tester.tap(find.text('Review local plan'));
      await tester.pumpAndSettle();
      expect(find.text('Keep this transfer plan?'), findsOneWidget);
      await tester.tap(find.text('Save local plan'));
      await tester.pumpAndSettle();
      expect(find.text('12,480.50'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Plans'));
      await tester.pumpAndSettle();
      expect(find.text('125.50 EGP'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove local plan'));
      await tester.pumpAndSettle();
      expect(find.text('No local plans yet.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'category change affects one entry; savings has no mixed-currency transfer',
    (tester) async {
      await host(tester);
      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Other'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Groceries'),
            matching: find.byType(InkWell),
          ),
          matching: find.text('Other'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Accounts'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('still-account-savings')),
      );
      await tester.tap(find.byKey(const ValueKey('still-account-savings')));
      await tester.pumpAndSettle();
      expect(find.text('3,800.00'), findsNWidgets(2));
      expect(
        find.text('A quiet start. This sample account has no activity yet.'),
        findsOneWidget,
      );
      expect(find.text('USD'), findsWidgets);
      await tester.tap(find.byTooltip('Plan a transfer'));
      await tester.pumpAndSettle();
      expect(find.text('No matching account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'real local statement preview includes only the selected account',
    (tester) async {
      await host(tester);
      await tester.tap(find.byTooltip('Export local statement'));
      await tester.pumpAndSettle();
      expect(find.text('Statement preview ready'), findsOneWidget);
      final text = tester
          .widget<SelectableText>(find.byType(SelectableText))
          .data!;
      expect(text, contains('Groceries'));
      expect(text, contains('−468.75 EGP'));
      expect(text, isNot(contains('Electricity')));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'export cancellation is caller-owned and failure supports retry',
    (tester) async {
      final pending = Completer<String>();
      var calls = 0;
      await host(
        tester,
        exporter: (rows, progress, cancelled) async {
          calls++;
          progress(.5);
          if (calls == 1) return pending.future;
          if (calls == 2) throw StateError('Injected local generator failure');
          return buildStillStatement(rows, progress, cancelled);
        },
      );
      await tester.tap(find.byTooltip('Export local statement'));
      await tester.pumpAndSettle();
      expect(find.text('Building a local statement'), findsOneWidget);
      await tester.tap(find.text('Cancel export'));
      await tester.pumpAndSettle();
      pending.complete('partial output must not be shown');
      await tester.pumpAndSettle();
      expect(find.text('Export cancelled'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Export local statement'));
      await tester.pumpAndSettle();
      expect(find.text('Could not build the statement'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'pending export completion after disposal cannot write or open a dialog',
    (tester) async {
      final pending = Completer<String>();
      await host(
        tester,
        exporter: (rows, progress, cancelled) => pending.future,
      );
      await tester.tap(find.byTooltip('Export local statement'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();
      pending.complete('late');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('showcase changes retain account state and sample amounts', (
    tester,
  ) async {
    await host(tester);
    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('still-account-shared')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Showcase controls'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية / English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('المظهر الداكن'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تم'));
    await tester.pumpAndSettle();
    expect(find.text('٦٬٢٠٠٫٠٠'), findsNWidgets(2));
    expect(find.text('الكهرباء'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Arabic amount validation and local plan use actual Arabic copy',
    (tester) async {
      await host(tester, ar: true);
      expect(find.text('١٢٬٤٨٠٫٥٠'), findsNWidgets(2));
      await tester.tap(find.byTooltip('إعداد مسودة تحويل'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('مراجعة الخطة المحلية'));
      await tester.tap(find.text('مراجعة الخطة المحلية'));
      await tester.pumpAndSettle();
      expect(
        find.text('أدخل مبلغًا موجبًا بمنزلتين عشريتين كحد أقصى.'),
        findsOneWidget,
      );
      await tester.tap(find.textContaining('التاريخ التجريبي:'));
      await tester.pumpAndSettle();
      expect(
        Localizations.localeOf(
          tester.element(find.byType(DatePickerDialog)),
        ).languageCode,
        'ar',
      );
      final pickerContext = tester.element(find.byType(DatePickerDialog));
      final cancel = MaterialLocalizations.of(pickerContext).cancelButtonLabel;
      expect(cancel, 'الإلغاء');
      await tester.tap(find.text(cancel));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('still-transfer-amount')),
        '١٢٣٫٤٥',
      );
      await tester.tap(find.text('مراجعة الخطة المحلية'));
      await tester.pumpAndSettle();
      expect(find.textContaining('١٢٣٫٤٥ ج.م.'), findsOneWidget);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(find.text('١٢٬٤٨٠٫٥٠'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );
}
