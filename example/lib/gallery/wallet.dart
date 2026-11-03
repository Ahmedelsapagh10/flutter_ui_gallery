import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'still_home.dart';

/// Export injection follows the existing recipe's caller-owned operation pattern.
typedef StillStatementExporter =
    Future<String> Function(
      List<List<String>> rows,
      ValueChanged<double> progress,
      bool Function() cancelled,
    );

Future<String> buildStillStatement(
  List<List<String>> rows,
  ValueChanged<double> progress,
  bool Function() cancelled,
) async {
  final out = StringBuffer();
  for (var i = 0; i < rows.length; i++) {
    if (cancelled()) return '';
    out.writeln(rows[i].map((v) => '"${v.replaceAll('"', '""')}"').join(','));
    progress((i + 1) / rows.length);
    // Yield between actual rows so cancellation/owner disposal can be observed.
    await Future<void>.delayed(Duration.zero);
  }
  return out.toString();
}

/// Integer minor units; explicit single-currency formatting, never an FX total.
String stillAmount(int minor, String currency, {bool arabic = false}) {
  final whole = (minor.abs() ~/ 100).toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => arabic ? '٬' : ',',
  );
  final amount =
      '${minor < 0 ? '−' : ''}$whole${arabic ? '٫' : '.'}${(minor.abs() % 100).toString().padLeft(2, '0')}';
  final digits = arabic ? _arabicDigits(amount) : amount;
  final unit = arabic
      ? (currency == 'EGP' ? 'ج.م.' : 'دولار أمريكي')
      : currency;
  return '$digits $unit';
}

int? stillParseMinor(String input) {
  var value = input.trim();
  for (var i = 0; i < 10; i++) {
    value = value.replaceAll('٠١٢٣٤٥٦٧٨٩'[i], '$i');
  }
  value = value.replaceAll('٫', '.');
  // Grouping, signs, exponents and >2 decimals are intentionally not accepted.
  if (!RegExp(r'^\d{1,9}(?:\.\d{1,2})?$').hasMatch(value)) return null;
  final parts = value.split('.');
  return int.parse(parts.first) * 100 +
      (parts.length == 1 ? 0 : int.parse(parts.last.padRight(2, '0')));
}

String _arabicDigits(String value) => value.replaceAllMapped(
  RegExp(r'\d'),
  (m) => '٠١٢٣٤٥٦٧٨٩'[int.parse(m[0]!)],
);

class StillExample extends StatefulWidget {
  const StillExample({
    super.key,
    this.arabic,
    this.dark,
    this.largeText = false,
    this.reducedMotion = false,
    this.exporter = buildStillStatement,
  });
  final bool? arabic, dark;
  final bool largeText, reducedMotion;
  final StillStatementExporter exporter;
  @override
  State<StillExample> createState() => _StillExampleState();
}

class _StillExampleState extends State<StillExample> {
  final _accounts = const [
    _Account(
      'personal',
      'Personal',
      'شخصي',
      'Everyday spending',
      'المصروفات اليومية',
      'EGP',
      1248050,
    ),
    _Account(
      'shared',
      'Shared',
      'مشترك',
      'Home, together',
      'شؤون المنزل معًا',
      'EGP',
      620000,
    ),
    _Account(
      'savings',
      'Savings',
      'الادخار',
      'A little further ahead',
      'خطوة للمستقبل',
      'USD',
      380000,
    ),
  ];
  final _entries = [
    _Entry(
      'personal',
      'Groceries',
      'مشتريات المنزل',
      -46875,
      DateTime(2026, 11, 2),
      'home',
    ),
    _Entry(
      'personal',
      'November income',
      'دخل نوفمبر',
      850000,
      DateTime(2026, 11, 1),
      'income',
    ),
    _Entry(
      'personal',
      'Metro pass',
      'اشتراك المترو',
      -25000,
      DateTime(2026, 10, 31),
      'travel',
    ),
    _Entry(
      'personal',
      'Nile Books',
      'مكتبة النيل',
      -32000,
      DateTime(2026, 10, 30),
      'other',
    ),
    _Entry(
      'personal',
      'Home internet',
      'إنترنت المنزل',
      -41000,
      DateTime(2026, 10, 29),
      'home',
    ),
    _Entry(
      'personal',
      'Linen Studio refund',
      'مبلغ مسترد من استوديو الكتّان',
      125000,
      DateTime(2026, 10, 28),
      'income',
    ),
    _Entry(
      'personal',
      'Neighborhood café',
      'مقهى الحي',
      -8500,
      DateTime(2026, 10, 27),
      'other',
    ),
    _Entry(
      'personal',
      'Green Market',
      'السوق الأخضر',
      -21250,
      DateTime(2026, 10, 26),
      'home',
    ),
    _Entry(
      'shared',
      'Electricity',
      'الكهرباء',
      -72500,
      DateTime(2026, 11, 1),
      'home',
    ),
    _Entry(
      'shared',
      'Household contribution',
      'مساهمة المنزل',
      200000,
      DateTime(2026, 10, 30),
      'income',
    ),
  ];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _monthsAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  final _plans = <_Transfer>[];
  bool _configured = false,
      _ar = false,
      _dark = false,
      _large = false,
      _reduced = false;
  int _page = 0, _accountIndex = 0, _generation = 0;
  bool _busy = false, _cancelled = false;
  UiGalleryToastHandle? _handle;
  _Account get account => _accounts[_accountIndex];
  _StillWords get c => _StillWords(_ar);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_configured) {
      _configured = true;
      _ar =
          widget.arabic ?? Localizations.localeOf(context).languageCode == 'ar';
      _dark = widget.dark ?? Theme.of(context).brightness == Brightness.dark;
      _large = widget.largeText;
      _reduced = widget.reducedMotion;
    }
  }

  @override
  void dispose() {
    _cancelled = true;
    _generation++;
    final handle = _handle;
    // Overlay listeners must not rebuild while this owner is being unmounted.
    WidgetsBinding.instance.addPostFrameCallback((_) => handle?.dismiss());
    super.dispose();
  }

  ThemeData _theme() {
    final base = ThemeData(
      colorSchemeSeed: const Color(0xff276354),
      brightness: _dark ? Brightness.dark : Brightness.light,
      fontFamily: _ar ? 'MarginArabic' : null,
    );
    return base.copyWith(
      extensions: [
        UiGalleryTheme.family(
          UiGalleryDesignFamily.soft,
          theme: base,
          useSignature: true,
        ),
      ],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }

  String money(int n, [String? currency]) =>
      stillAmount(n, currency ?? account.currency, arabic: _ar);
  String date(BuildContext context, DateTime date) {
    final value = MaterialLocalizations.of(context).formatMediumDate(date);
    return _ar ? _arabicDigits(value) : value;
  }

  Future<void> _newTransfer(BuildContext owner) async {
    final source = account;
    final targets = _accounts
        .where((a) => a.id != source.id && a.currency == source.currency)
        .toList();
    if (targets.isEmpty) {
      await _status(
        owner,
        c.t('No matching account', 'لا يوجد حساب مناسب'),
        c.t(
          'This sample has no other account in ${source.currency}. Currency conversion is not available.',
          'لا يوجد حساب آخر بنفس العملة في هذه العينة. تحويل العملات غير متاح.',
        ),
        UiGalleryResult.warning,
      );
      return;
    }
    final draft = await UiGallerySheet.show<_Transfer>(
      context: owner,
      preset: UiGallerySheetPreset.splitLayer,
      header: Text(c.t('Plan a transfer', 'إعداد مسودة تحويل')),
      secondary: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.t('FROM THIS ACCOUNT', 'من هذا الحساب'),
            style: Theme.of(owner).textTheme.labelSmall,
          ),
          const SizedBox(height: 12),
          Text(source.name(_ar), style: Theme.of(owner).textTheme.titleLarge),
          const SizedBox(height: 8),
          _Amount(money(source.balance, source.currency)),
          const SizedBox(height: 16),
          Text(
            c.t(
              'Local draft only. Your balance will not change.',
              'مسودة محلية فقط. لن يتغير رصيدك.',
            ),
          ),
        ],
      ),
      child: Localizations.override(
        context: owner,
        locale: Locale(_ar ? 'ar' : 'en'),
        delegates: GlobalMaterialLocalizations.delegates,
        child: _TransferForm(source: source, targets: targets, words: c),
      ),
    );
    if (!mounted || !owner.mounted || draft == null) return;
    final target = _accounts.firstWhere((a) => a.id == draft.to);
    final confirmed = await UiGalleryDialog.show<bool>(
      context: owner,
      preset: UiGalleryDialogPreset.halo,
      title: c.t('Keep this transfer plan?', 'حفظ خطة التحويل؟'),
      message:
          '${source.name(_ar)} → ${target.name(_ar)}\n${money(draft.minor, source.currency)}\n${date(owner, draft.date)}',
      child: Text(
        c.t(
          'This creates a local draft. No payment is sent and no money moves.',
          'سيُحفظ هذا كمسودة محلية. لن يُرسل أي دفع ولن تُنقل أموال.',
        ),
      ),
      actions: [
        UiGalleryDialogAction(label: c.t('Cancel', 'إلغاء'), value: false),
        UiGalleryDialogAction(
          label: c.t('Save local plan', 'حفظ الخطة محليًا'),
          value: true,
          primary: true,
        ),
      ],
    );
    if (mounted && confirmed == true) setState(() => _plans.add(draft));
  }

  Future<void> _category(BuildContext owner, _Entry entry) async {
    final selected = await UiGallerySheet.show<String>(
      context: owner,
      preset: UiGallerySheetPreset.taskRail,
      header: Text(c.t('Category for this entry', 'فئة هذا القيد')),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(entry.name(_ar), style: Theme.of(owner).textTheme.titleLarge),
          const SizedBox(height: 8),
          _Amount(money(entry.minor)),
          const SizedBox(height: 20),
          Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final id in ['home', 'travel', 'income', 'other'])
                  ListTile(
                    title: Text(c.category(id)),
                    leading: Icon(
                      entry.category == id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    selected: entry.category == id,
                    onTap: () => Navigator.of(owner).pop(id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (mounted && selected != null) setState(() => entry.category = selected);
  }

  Future<void> _status(
    BuildContext owner,
    String title,
    String message,
    UiGalleryResult result, {
    String? csv,
  }) async {
    await UiGalleryDialog.show<void>(
      context: owner,
      preset: UiGalleryDialogPreset.statusBeacon,
      result: result,
      title: title,
      message: message,
      child: csv == null
          ? null
          : SelectableText(
              csv,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
      actions: [
        UiGalleryDialogAction(
          label: c.t('Close', 'إغلاق'),
          value: null,
          primary: true,
        ),
      ],
    );
  }

  Future<void> _export(BuildContext owner) async {
    if (_busy) return;
    final entries = _entries.where((e) => e.account == account.id).toList();
    if (entries.isEmpty) {
      await _status(
        owner,
        c.t('Nothing to export', 'لا توجد بيانات للتصدير'),
        c.t(
          'This account has no sample activity yet.',
          'لا توجد حركة تجريبية لهذا الحساب بعد.',
        ),
        UiGalleryResult.warning,
      );
      return;
    }
    final source = account;
    final rows = <List<String>>[
      [
        c.t('Date', 'التاريخ'),
        c.t('Entry', 'القيد'),
        c.t('Category', 'الفئة'),
        c.t('Amount', 'المبلغ'),
      ],
      for (final e in entries)
        [
          date(owner, e.date),
          e.name(_ar),
          c.category(e.category),
          money(e.minor, source.currency),
        ],
    ];
    final generation = ++_generation;
    final progress = ValueNotifier<double>(0);
    setState(() {
      _busy = true;
      _cancelled = false;
    });
    final handle = UiGalleryToast.progress(
      owner,
      message: c.t('Building a local statement', 'إعداد كشف محلي'),
      title: source.name(_ar),
      progress: progress,
      actionLabel: c.t('Cancel export', 'إلغاء التصدير'),
      progressLabelBuilder: (value) => c.t(
        '${(value * 100).round()}% of rows',
        '${_arabicDigits('${(value * 100).round()}')}٪ من الصفوف',
      ),
      onAction: () {
        _cancelled = true;
      },
    );
    _handle = handle;
    String? csv;
    bool failed = false;
    try {
      csv = await widget.exporter(rows, (value) {
        if (mounted && generation == _generation && !_cancelled) {
          progress.value = value.clamp(0, 1);
        }
      }, () => !mounted || generation != _generation || _cancelled);
      if (!_cancelled && csv.trim().isEmpty) {
        throw StateError('Empty statement');
      }
    } catch (_) {
      failed = true;
    } finally {
      handle.dismiss();
      await handle.closed;
      progress.dispose();
      if (mounted && generation == _generation) {
        setState(() {
          _busy = false;
          _handle = null;
        });
      }
    }
    if (!mounted || !owner.mounted || generation != _generation) return;
    if (_cancelled) {
      await _status(
        owner,
        c.t('Export cancelled', 'أُلغي التصدير'),
        c.t(
          'Your account and ledger are unchanged.',
          'لم يتغير الحساب أو سجل الحركة.',
        ),
        UiGalleryResult.warning,
      );
    } else if (failed) {
      await _status(
        owner,
        c.t('Could not build the statement', 'تعذّر إعداد الكشف'),
        c.t(
          'The local generator failed. Close this message and try Export again. No file was saved.',
          'تعذّر إنشاء المعاينة محليًا. أغلق الرسالة وحاول التصدير مجددًا. لم يُحفظ أي ملف.',
        ),
        UiGalleryResult.failure,
      );
    } else {
      await _status(
        owner,
        c.t('Statement preview ready', 'معاينة الكشف جاهزة'),
        c.t(
          'Selectable CSV for ${source.name(false)} only. No file has been downloaded or saved.',
          'كشف CSV قابل للتحديد لحساب ${source.name(true)} فقط. لم يُنزّل أو يُحفظ أي ملف.',
        ),
        UiGalleryResult.success,
        csv: csv,
      );
    }
  }

  Future<void> _settings(BuildContext owner) => showDialog<void>(
    context: owner,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, update) {
        void change(VoidCallback operation) {
          setState(operation);
          update(() {});
        }

        return Theme(
          data: _theme(),
          child: Localizations.override(
            context: context,
            locale: Locale(_ar ? 'ar' : 'en'),
            delegates: GlobalMaterialLocalizations.delegates,
            child: Directionality(
              textDirection: _ar ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
                title: Text(c.t('Showcase controls', 'إعدادات العرض التوضيحي')),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.t(
                          'Appearance only. Account data stays in this local session.',
                          'المظهر فقط. تظل بيانات الحساب في هذه الجلسة المحلية.',
                        ),
                      ),
                      SwitchListTile(
                        title: Text(c.t('Dark appearance', 'المظهر الداكن')),
                        value: _dark,
                        onChanged: (v) => change(() => _dark = v),
                      ),
                      SwitchListTile(
                        title: const Text('العربية / English'),
                        value: _ar,
                        onChanged: (v) => change(() => _ar = v),
                      ),
                      SwitchListTile(
                        title: Text(c.t('Text size ×2', 'حجم النص ×٢')),
                        value: _large,
                        onChanged: (v) => change(() => _large = v),
                      ),
                      SwitchListTile(
                        title: Text(c.t('Reduce motion', 'تقليل الحركة')),
                        value: _reduced,
                        onChanged: (v) => change(() => _reduced = v),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(c.t('Done', 'تم')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  @override
  Widget build(BuildContext context) => Theme(
    data: _theme(),
    child: Localizations.override(
      context: context,
      locale: Locale(_ar ? 'ar' : 'en'),
      delegates: GlobalMaterialLocalizations.delegates,
      child: Builder(
        builder: (context) {
          final media = MediaQuery.of(context);
          return Directionality(
            textDirection: _ar ? TextDirection.rtl : TextDirection.ltr,
            child: MediaQuery(
              data: media.copyWith(
                textScaler: _large && media.textScaler.scale(1) < 2
                    ? const TextScaler.linear(2)
                    : media.textScaler,
                disableAnimations: media.disableAnimations || _reduced,
              ),
              child: Builder(builder: _screen),
            ),
          );
        },
      ),
    ),
  );
  Widget _screen(BuildContext owner) {
    if (_page == 0) {
      String digits(int value) => _ar ? _arabicDigits('$value') : '$value';
      String unit(String currency) =>
          _ar ? (currency == 'EGP' ? 'ج.م.' : 'دولار أمريكي') : currency;
      String numeric(int value, String currency) =>
          stillAmount(value, currency, arabic: _ar).split(' ').first;
      return StillHome(
        arabic: _ar,
        dark: _dark,
        selected: _accountIndex,
        accounts: [
          for (final a in _accounts)
            (
              id: a.id,
              name: a.name(_ar),
              amount: numeric(a.balance, a.currency),
              currency: unit(a.currency),
            ),
        ],
        entries: [
          for (final e in _entries.where((e) => e.account == account.id))
            (
              name: e.name(_ar),
              amount:
                  '${e.minor > 0 ? '+' : ''}${numeric(e.minor, account.currency)}',
              currency: unit(account.currency),
              metadata: c.category(e.category),
              day: digits(e.date.day),
              month: _ar
                  ? (_monthsAr[e.date.month - 1])
                  : _months[e.date.month - 1],
              income: e.minor > 0,
              onTap: () => _category(owner, e),
            ),
        ],
        onAccount: (i) => setState(() => _accountIndex = i),
        onDestination: (i) => setState(() => _page = i),
        onPlan: _busy ? null : () => _newTransfer(owner),
        onSettings: () => _settings(owner),
        onExport: () => _export(owner),
      );
    }
    final theme = Theme.of(owner);
    final colors = theme.colorScheme;
    Widget accountPicker() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(c.t('YOUR SPACES', 'حساباتك'), style: theme.textTheme.labelSmall),
        const SizedBox(height: 12),
        for (var i = 0; i < _accounts.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: i == _accountIndex
                  ? colors.primaryContainer
                  : colors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colors.outlineVariant),
              ),
              child: ListTile(
                key: ValueKey('still-account-${_accounts[i].id}'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(_accounts[i].name(_ar)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_ar ? _accounts[i].arPurpose : _accounts[i].purpose),
                    const SizedBox(height: 8),
                    Text(
                      money(_accounts[i].balance, _accounts[i].currency),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                selected: i == _accountIndex,
                selectedColor: colors.onPrimaryContainer,
                onTap: _busy
                    ? null
                    : () => setState(() {
                        _accountIndex = i;
                        _page = 0;
                      }),
              ),
            ),
          ),
      ],
    );
    Widget plans() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          c.t('Planned, not paid', 'خطط لم تُنفّذ'),
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          c.t(
            'Drafts stay here until you remove them. Nothing executes automatically.',
            'تبقى المسودات هنا حتى تزيلها. لا يُنفّذ أي شيء تلقائيًا.',
          ),
        ),
        if (_plans.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(c.t('No local plans yet.', 'لا توجد خطط محلية بعد.')),
          ),
        for (final p in _plans)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            title: _Amount(
              money(
                p.minor,
                _accounts.firstWhere((a) => a.id == p.from).currency,
              ),
            ),
            subtitle: Text(
              '${_accounts.firstWhere((a) => a.id == p.from).name(_ar)} → ${_accounts.firstWhere((a) => a.id == p.to).name(_ar)}\n${date(owner, p.date)}',
            ),
            trailing: IconButton(
              tooltip: c.t('Remove local plan', 'إزالة الخطة المحلية'),
              onPressed: () => setState(() => _plans.remove(p)),
              icon: const Icon(Icons.close),
            ),
          ),
      ],
    );
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _page = 0);
      },
      child: Scaffold(
        appBar: UiGalleryAppBar(
          preset: UiGalleryAppBarPreset.centeredTitle,
          title: const Text('Still'),
          actions: [
            IconButton(
              tooltip: c.t('Showcase controls', 'إعدادات العرض التوضيحي'),
              onPressed: () => _settings(owner),
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        bottomNavigationBar: UiGalleryBottomNav(
          preset: UiGalleryBottomNavPreset.concaveNotch,
          selectedIndex: _page,
          onDestinationSelected: (i) => setState(() => _page = i),
          options: const UiGalleryBottomNavOptions(
            groupBreak: 2,
            notchWidth: 80,
          ),
          semanticLabel: c.t('Wallet destinations', 'وجهات المحفظة'),
          centerAction: IconButton.filled(
            tooltip: c.t('Plan a transfer', 'إعداد مسودة تحويل'),
            style: IconButton.styleFrom(minimumSize: const Size(56, 56)),
            onPressed: _busy ? null : () => _newTransfer(owner),
            icon: const Icon(Icons.add),
          ),
          items: [
            UiGalleryBottomNavItem(
              icon: const Icon(Icons.receipt_long_outlined),
              label: c.t('Activity', 'الحركة'),
            ),
            UiGalleryBottomNavItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: c.t('Accounts', 'الحسابات'),
            ),
            UiGalleryBottomNavItem(
              icon: const Icon(Icons.event_note_outlined),
              label: c.t('Plans', 'الخطط'),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, bounds) {
            final wide =
                bounds.maxWidth >= 1000 &&
                MediaQuery.textScalerOf(owner).scale(1) < 1.5;
            final content = ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
              children: [
                Text(
                  c.t('STILL / LOCAL MONEY JOURNAL', 'ستيل / سجل مالي محلي'),
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 20),
                Text(
                  _page == 1
                      ? c.t('A place for every purpose', 'حساب لكل غرض')
                      : account.name(_ar),
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  c.t(
                    'Sample money. No bank connection.',
                    'أموال تجريبية. لا يوجد اتصال بأي بنك.',
                  ),
                ),
                const SizedBox(height: 24),
                if (_page == 1) accountPicker() else plans(),
              ],
            );
            if (!wide) return content;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 280,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [accountPicker()],
                  ),
                ),
                VerticalDivider(width: 1, color: colors.outlineVariant),
                Expanded(child: content),
                SizedBox(
                  width: 220,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        c.t('Room to plan', 'مساحة للتخطيط'),
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        c.t(
                          'Keep each currency separate. Local plans do not reserve or move money.',
                          'كل عملة مستقلة. الخطط المحلية لا تحجز الأموال ولا تنقلها.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _busy ? null : () => _newTransfer(owner),
                        child: Text(
                          c.t('Plan a transfer', 'إعداد مسودة تحويل'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Account {
  const _Account(
    this.id,
    this.en,
    this.ar,
    this.purpose,
    this.arPurpose,
    this.currency,
    this.balance,
  );
  final String id, en, ar, purpose, arPurpose, currency;
  final int balance;
  String name(bool arabic) => arabic ? ar : en;
}

class _Entry {
  _Entry(this.account, this.en, this.ar, this.minor, this.date, this.category);
  final String account, en, ar;
  final int minor;
  final DateTime date;
  String category;
  String name(bool arabic) => arabic ? ar : en;
}

class _Transfer {
  const _Transfer(this.from, this.to, this.minor, this.date);
  final String from, to;
  final int minor;
  final DateTime date;
}

class _Amount extends StatelessWidget {
  const _Amount(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Text(
    value,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      fontWeight: FontWeight.w600,
    ),
  );
}

class _StillWords {
  const _StillWords(this.ar);
  final bool ar;
  String t(String en, String arabic) => ar ? arabic : en;
  String category(String id) => switch (id) {
    'home' => t('Home', 'المنزل'),
    'travel' => t('Transport', 'المواصلات'),
    'income' => t('Income', 'الدخل'),
    _ => t('Other', 'أخرى'),
  };
}

class _TransferForm extends StatefulWidget {
  const _TransferForm({
    required this.source,
    required this.targets,
    required this.words,
  });
  final _Account source;
  final List<_Account> targets;
  final _StillWords words;
  @override
  State<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<_TransferForm> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  late String _target = widget.targets.first.id;
  DateTime _date = DateTime(2026, 11, 3);
  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.words;
    final localDate = MaterialLocalizations.of(context).formatMediumDate(_date);
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _target,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: c.t('To account', 'إلى الحساب'),
            ),
            items: [
              for (final a in widget.targets)
                DropdownMenuItem(value: a.id, child: Text(a.name(c.ar))),
            ],
            onChanged: (v) {
              if (v != null) _target = v;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            key: const ValueKey('still-transfer-amount'),
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: c.t(
                'Amount (${widget.source.currency})',
                'المبلغ (${widget.source.currency})',
              ),
              helperText: c.t(
                'Use up to two decimal places, without grouping.',
                'منزلتان عشريتان كحد أقصى، دون فواصل آلاف.',
              ),
            ),
            validator: (value) {
              final minor = stillParseMinor(value ?? '');
              if (minor == null || minor <= 0) {
                return c.t(
                  'Enter a positive amount with up to two decimals.',
                  'أدخل مبلغًا موجبًا بمنزلتين عشريتين كحد أقصى.',
                );
              }
              if (minor > widget.source.balance) {
                return c.t(
                  'This exceeds the sample balance.',
                  'المبلغ أكبر من الرصيد التجريبي.',
                );
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              '${c.t('Sample date', 'التاريخ التجريبي')}: ${c.ar ? _arabicDigits(localDate) : localDate}',
            ),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                locale: Locale(c.ar ? 'ar' : 'en'),
                initialDate: _date,
                firstDate: DateTime(2026, 11, 3),
                lastDate: DateTime(2027, 11, 3),
              );
              if (mounted && date != null) setState(() => _date = date);
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (_form.currentState!.validate()) {
                Navigator.of(context).pop(
                  _Transfer(
                    widget.source.id,
                    _target,
                    stillParseMinor(_amount.text)!,
                    _date,
                  ),
                );
              }
            },
            child: Text(c.t('Review local plan', 'مراجعة الخطة المحلية')),
          ),
        ],
      ),
    );
  }
}
