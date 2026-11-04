import 'package:flutter/material.dart';

typedef StillHomeAccount = ({
  String id,
  String name,
  String amount,
  String currency,
});
typedef StillHomeEntry = ({
  String name,
  String amount,
  String currency,
  String metadata,
  String day,
  String month,
  bool income,
  VoidCallback onTap,
});

/// Typography belongs only to this example screen until its visual review.
class StillHomeType extends ThemeExtension<StillHomeType> {
  const StillHomeType({required this.display, required this.figures});
  final TextStyle display, figures;
  @override
  StillHomeType copyWith({TextStyle? display, TextStyle? figures}) =>
      StillHomeType(
        display: display ?? this.display,
        figures: figures ?? this.figures,
      );
  @override
  StillHomeType lerp(covariant StillHomeType? other, double t) => other == null
      ? this
      : StillHomeType(
          display: TextStyle.lerp(display, other.display, t)!,
          figures: TextStyle.lerp(figures, other.figures, t)!,
        );
}

ThemeData stillHomeTheme(bool dark, bool arabic) {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xff0f2a24),
        brightness: dark ? Brightness.dark : Brightness.light,
      ).copyWith(
        surface: Color(dark ? 0xff0e1412 : 0xfff6f3ee),
        surfaceContainerLow: Color(dark ? 0xff151d1a : 0xfff6f3ee),
        onSurface: Color(dark ? 0xffede8df : 0xff14201c),
        onSurfaceVariant: Color(dark ? 0xff848e88 : 0xff636a66),
        primary: const Color(0xff0f2a24),
        onPrimary: const Color(0xffede8df),
        secondary: Color(dark ? 0xffc9a96e : 0xff9c7a45),
        tertiary: Color(dark ? 0xff7fa68e : 0xff4d7861),
        error: Color(dark ? 0xffc98a7e : 0xffa5574a),
        outlineVariant: Color(dark ? 0xff25302c : 0xffe3ded5),
      );
  final base = ThemeData(
    colorScheme: scheme,
    fontFamily: arabic ? 'MarginArabic' : 'StillSans',
    scaffoldBackgroundColor: scheme.surface,
  );
  return base.copyWith(
    extensions: [
      StillHomeType(
        display: TextStyle(
          fontFamily: arabic ? 'StillNaskh' : 'StillSerif',
          fontSize: arabic ? 68 : 65,
          fontWeight: arabic ? FontWeight.w400 : FontWeight.w300,
          fontVariations: [
            FontVariation('wght', arabic ? 400 : 300),
            if (!arabic) const FontVariation('opsz', 60),
          ],
          fontFeatures: const [
            FontFeature.tabularFigures(),
            FontFeature.liningFigures(),
          ],
          letterSpacing: arabic ? 0 : -1.8,
          height: 1.16,
          color: scheme.onSurface,
        ),
        figures: TextStyle(
          fontFamily: arabic ? 'StillNaskh' : 'StillSans',
          fontSize: arabic ? 23 : 20,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: scheme.onSurface,
        ),
      ),
    ],
  );
}

class StillHome extends StatelessWidget {
  const StillHome({
    super.key,
    required this.arabic,
    required this.dark,
    required this.accounts,
    required this.entries,
    required this.selected,
    required this.onAccount,
    required this.onDestination,
    required this.onPlan,
    required this.onSettings,
    required this.onExport,
  });
  final bool arabic, dark;
  final List<StillHomeAccount> accounts;
  final List<StillHomeEntry> entries;
  final int selected;
  final ValueChanged<int> onAccount, onDestination;
  final VoidCallback? onPlan;
  final VoidCallback onSettings, onExport;
  String t(String en, String ar) => arabic ? ar : en;
  @override
  Widget build(BuildContext context) => Theme(
    data: stillHomeTheme(dark, arabic),
    child: Builder(builder: _build),
  );
  Widget _build(BuildContext context) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    final type = theme.extension<StillHomeType>()!;
    final large = MediaQuery.textScalerOf(context).scale(1) >= 1.3;
    Text secondary(String value, {double size = 12}) => Text(
      value,
      style: TextStyle(fontSize: size, color: colors.onSurfaceVariant),
    );
    Widget rule() => Divider(height: 1, color: colors.outlineVariant);
    Widget picker() => Column(
      children: [
        if (!large)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < accounts.length; i++)
                Expanded(child: accountTile(context, i, false)),
            ],
          )
        else
          for (var i = 0; i < accounts.length; i++)
            accountTile(context, i, true),
        const SizedBox(height: 18),
        rule(),
      ],
    );
    Widget nav() {
      final labels = [
        t('Activity', 'الحركة'),
        t('Accounts', 'الحسابات'),
        t('Plans', 'الخطط'),
      ];
      final buttons = [
        for (var i = 0; i < 3; i++)
          Tooltip(
            message: labels[i],
            child: Semantics(
              selected: i == 0,
              child: TextButton(
                onPressed: () => onDestination(i),
                style: TextButton.styleFrom(
                  minimumSize: Size(large ? double.infinity : 48, 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  foregroundColor: i == 0
                      ? colors.onPrimary
                      : colors.onSurfaceVariant,
                  backgroundColor: i == 0 ? colors.primary : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      [
                        Icons.notes,
                        Icons.account_balance_wallet_outlined,
                        Icons.event_note_outlined,
                      ][i],
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        labels[i],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ];
      return Container(
        key: const ValueKey('still-home-nav'),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(32),
        ),
        child: large
            ? Column(mainAxisSize: MainAxisSize.min, children: buttons)
            : Row(
                children: [
                  for (final button in buttons) Expanded(child: button),
                ],
              ),
      );
    }

    Widget footer() => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Tooltip(
            message: t('Plan a transfer', 'إعداد مسودة تحويل'),
            child: FilledButton.icon(
              key: const ValueKey('still-home-action'),
              onPressed: onPlan,
              style: FilledButton.styleFrom(
                minimumSize: const Size(204, 52),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                t('Plan a transfer', 'خطّط لتحويل'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
          child: secondary(
            t(
              'Sample money · only on this device',
              'أموال تجريبية · على جهازك فقط',
            ),
          ),
        ),
        nav(),
        const SizedBox(height: 16),
      ],
    );
    final content = <Widget>[
      const SizedBox(height: 24),
      Center(child: secondary(t('Current balance', 'الرصيد الحالي'), size: 14)),
      const SizedBox(height: 6),
      Center(
        child: Text(
          accounts[selected].amount,
          textDirection: TextDirection.ltr,
          style: large
              ? type.display.copyWith(fontSize: arabic ? 42 : 38)
              : type.display,
        ),
      ),
      const SizedBox(height: 3),
      Center(child: secondary(accounts[selected].currency, size: 13)),
      Center(
        child: Container(
          width: 40,
          height: dark ? 2 : 1,
          margin: const EdgeInsets.only(top: 16, bottom: 24),
          color: colors.secondary,
        ),
      ),
      picker(),
      const SizedBox(height: 22),
      Row(
        children: [
          Expanded(
            child: Text(
              t('Your ledger', 'دفتر الحركة'),
              style: TextStyle(
                fontFamily: arabic ? 'StillNaskh' : 'StillSerif',
                fontSize: arabic ? 29 : 25,
              ),
            ),
          ),
          secondary(accounts[selected].currency),
          IconButton(
            tooltip: t('Export local statement', 'تصدير كشف محلي'),
            onPressed: onExport,
            icon: const Icon(Icons.file_download_outlined, size: 19),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (entries.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: secondary(
            t(
              'A quiet start. This sample account has no activity yet.',
              'بداية هادئة. لا توجد حركة لهذا الحساب التجريبي بعد.',
            ),
          ),
        ),
      for (var i = 0; i < entries.length; i++) ...[
        if (i > 0 &&
            '${entries[i].day}${entries[i].month}' !=
                '${entries[i - 1].day}${entries[i - 1].month}')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: rule(),
          ),
        entryTile(
          context,
          entries[i],
          large,
          i == 0 || entries[i].day != entries[i - 1].day,
        ),
      ],
      const SizedBox(height: 24),
      if (large) footer(),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 62),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t('Still', 'ستيل'),
                          style: TextStyle(
                            fontFamily: arabic ? 'StillNaskh' : 'StillSerif',
                            fontSize: arabic ? 30 : 28,
                          ),
                        ),
                        IconButton(
                          tooltip: t(
                            'Showcase controls',
                            'إعدادات العرض التوضيحي',
                          ),
                          onPressed: onSettings,
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                  ),
                  rule(),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 320),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: KeyedSubtree(
                  key: ValueKey(selected),
                  child: ListView(
                    key: const ValueKey('still-home-scroll'),
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    children: content,
                  ),
                ),
              ),
            ),
            if (!large) ...[rule(), footer()],
          ],
        ),
      ),
    );
  }

  Widget accountTile(BuildContext context, int i, bool detailed) {
    final colors = Theme.of(context).colorScheme;
    final account = accounts[i];
    final active = i == selected;
    return InkWell(
      key: ValueKey('still-home-account-${account.id}'),
      onTap: () => onAccount(i),
      child: Semantics(
        selected: active,
        button: true,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: detailed ? 18 : 0,
            horizontal: 4,
          ),
          child: Column(
            crossAxisAlignment: detailed
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(
                account.name,
                style: TextStyle(
                  fontSize: arabic ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: active ? colors.onSurface : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                account.amount,
                textDirection: TextDirection.ltr,
                style: Theme.of(context)
                    .extension<StillHomeType>()!
                    .figures
                    .copyWith(
                      fontSize: arabic ? 19 : 15,
                      color: detailed || active
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    ),
              ),
              Text(
                account.currency,
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: detailed
                    ? AlignmentDirectional.centerStart
                    : Alignment.center,
                child: SizedBox(
                  height: dark ? 3 : 2,
                  width: dark ? 44 : 36,
                  child: active ? ColoredBox(color: colors.secondary) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget entryTile(
    BuildContext context,
    StillHomeEntry e,
    bool large,
    bool showDay,
  ) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).extension<StillHomeType>()!;
    final amount = Text(
      e.amount,
      textDirection: TextDirection.ltr,
      style: type.figures.copyWith(
        color: e.income ? colors.tertiary : colors.error,
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          e.name,
          style: TextStyle(
            fontSize: arabic ? 14 : 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          e.metadata,
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        if (large) ...[const SizedBox(height: 10), amount],
        if (e.currency != accounts[selected].currency)
          Text(
            e.currency,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
      ],
    );
    return InkWell(
      onTap: e.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: large
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDay)
                    Text(
                      '${e.day} ${e.month}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 8),
                  copy,
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: showDay
                        ? Column(
                            children: [
                              Text(
                                e.day,
                                style: TextStyle(
                                  fontFamily: arabic
                                      ? 'StillNaskh'
                                      : 'StillSerif',
                                  fontSize: 27,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                e.month,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: copy),
                  const SizedBox(width: 10),
                  amount,
                ],
              ),
      ),
    );
  }
}
