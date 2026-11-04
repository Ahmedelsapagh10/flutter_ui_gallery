import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

/// Margin evolves the Productivity recipe's page-owned create/search/archive flow.
/// Data is intentionally local to this example session.
class NotesExample extends StatefulWidget {
  const NotesExample({
    super.key,
    this.arabic,
    this.dark,
    this.largeText = false,
    this.reducedMotion = false,
    this.passB = false,
  });
  final bool? arabic, dark;
  final bool largeText, reducedMotion;
  final bool passB;
  @override
  State<NotesExample> createState() => _NotesExampleState();
}

class _NotesExampleState extends State<NotesExample> {
  final _search = TextEditingController();
  final _selected = <int>{};
  final _notes = <_Note>[
    _Note(
      1,
      'field',
      'The quiet parts of a day',
      'Leave a little room between one thing and the next.',
      DateTime(2026, 11, 2),
      arTitle: 'اللحظات الهادئة في اليوم',
      arBody: 'اترك مساحة صغيرة بين أمر وآخر.',
      saved: true,
    ),
    _Note(
      2,
      'work',
      'A product worth returning to',
      'Make the next useful action clear. Let the rest be quiet.',
      DateTime(2026, 11, 1),
      arTitle: 'منتج يستحق العودة إليه',
      arBody: 'اجعل الخطوة المفيدة التالية واضحة، واترك الباقي هادئًا.',
    ),
    _Note(
      3,
      'reading',
      'Lines to keep',
      'Collect the sentences that change how you see an ordinary day.',
      DateTime(2026, 10, 30),
      arTitle: 'سطور تستحق الاحتفاظ بها',
      arBody: 'اجمع الجمل التي تغيّر نظرتك إلى يوم عادي.',
      saved: true,
    ),
  ];
  bool _configured = false,
      _ar = false,
      _dark = false,
      _large = false,
      _reduced = false;
  String _query = '', _notebook = 'all', _navStyle = 'capsule';
  bool _persistentSearch = false;
  int _page = 0, _nextId = 4;
  int? _focused;
  _Words get c => _Words(_ar);
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
      _persistentSearch = widget.passB;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  ThemeData _theme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff455a64),
        brightness: _dark ? Brightness.dark : Brightness.light,
      ),
      fontFamily: _ar ? 'MarginArabic' : null,
    );
    return base.copyWith(
      extensions: [
        UiGalleryTheme.family(
          UiGalleryDesignFamily.minimal,
          theme: base,
          useSignature: true,
        ),
      ],
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }

  List<_Note> get _visible => _notes
      .where(
        (n) =>
            (_notebook == 'all' || n.notebook == _notebook) &&
            (_page != 2 || n.saved) &&
            '${n.title(_ar)} ${n.body(_ar)}'.toLowerCase().contains(
              _query.toLowerCase(),
            ),
      )
      .toList();

  Future<void> _edit(BuildContext owner, [_Note? note]) async {
    final result = await UiGallerySheet.show<_Draft>(
      context: owner,
      preset: UiGallerySheetPreset.orbit,
      header: Text(
        note == null
            ? c.t('New note', 'ملاحظة جديدة')
            : c.t('Edit note', 'تعديل الملاحظة'),
      ),
      secondary: Text(
        '${c.t('Notebook', 'الدفتر')}\n${c.notebook(note?.notebook ?? (_notebook == 'all' ? 'field' : _notebook))}',
      ),
      isDismissible: !widget.passB,
      enableDrag: !widget.passB,
      child: _Editor(words: c, note: note, guardChanges: widget.passB),
    );
    if (!mounted || result == null) return;
    setState(() {
      if (note == null) {
        final item = _Note(
          _nextId++,
          _notebook == 'all' ? 'field' : _notebook,
          result.title,
          result.body,
          DateTime.now(),
        );
        _notes.insert(0, item);
        _focused = item.id;
      } else {
        final i = _notes.indexWhere((n) => n.id == note.id);
        if (i >= 0) {
          _notes[i] = _Note(
            note.id,
            note.notebook,
            result.title,
            result.body,
            DateTime.now(),
            saved: note.saved,
          );
        }
      }
    });
    if (widget.passB && owner.mounted) {
      UiGalleryToast.show(
        owner,
        preset: UiGalleryToastPreset.inlinePulse,
        message: note == null
            ? c.t('Note saved in this session', 'حُفظت الملاحظة في هذه الجلسة')
            : c.t(
                'Changes saved in this session',
                'حُفظت التعديلات في هذه الجلسة',
              ),
      );
    }
  }

  Future<void> _noteActions(BuildContext owner, _Note note) async {
    final result = await UiGallerySheet.show<String>(
      context: owner,
      preset: UiGallerySheetPreset.edgeLift,
      header: Text(note.title(_ar)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(c.t('Current notebook', 'الدفتر الحالي')),
            subtitle: Text(c.notebook(note.notebook)),
            leading: const Icon(Icons.book_outlined),
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_move_outline),
            title: Text(c.t('Move to notebook', 'نقل إلى دفتر')),
            onTap: () => Navigator.of(owner).pop('move'),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline),
            title: Text(
              note.saved
                  ? c.t('Remove from saved', 'إزالة من المحفوظات')
                  : c.t('Save for later', 'حفظ لوقت لاحق'),
            ),
            onTap: () => Navigator.of(owner).pop('save'),
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: Text(c.t('Archive note', 'أرشفة الملاحظة')),
            onTap: () => Navigator.of(owner).pop('archive'),
          ),
        ],
      ),
    );
    if (!mounted || !owner.mounted || !_notes.contains(note)) return;
    if (result == 'save') setState(() => note.saved = !note.saved);
    if (result == 'archive') {
      setState(() {
        _selected.clear();
        _selected.add(note.id);
      });
      _archive(owner);
    }
    if (result == 'move') {
      final destination = await UiGallerySheet.show<String>(
        context: owner,
        preset: UiGallerySheetPreset.edgeLift,
        header: Text(c.t('Move to notebook', 'نقل إلى دفتر')),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final id in ['field', 'work', 'reading'])
              ListTile(
                title: Text(c.notebook(id)),
                selected: note.notebook == id,
                onTap: () => Navigator.of(owner).pop(id),
              ),
          ],
        ),
      );
      if (mounted && destination != null && _notes.contains(note)) {
        setState(() => note.notebook = destination);
      }
    }
  }

  Future<void> _chooseNotebook(BuildContext owner) async {
    final result = await UiGallerySheet.show<String>(
      context: owner,
      preset: UiGallerySheetPreset.stackPanel,
      header: Text(c.t('Your notebooks', 'دفاترك')),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final id in ['all', 'field', 'work', 'reading'])
            ListTile(
              minVerticalPadding: 16,
              leading: const Icon(Icons.book_outlined),
              title: Text(c.notebook(id)),
              subtitle: Text(
                c.noteCount(
                  _notes.where((n) => id == 'all' || n.notebook == id).length,
                ),
              ),
              trailing: Icon(
                _notebook == id
                    ? Icons.check_circle_outline
                    : Icons.chevron_right,
              ),
              onTap: () => Navigator.of(owner).pop(id),
            ),
        ],
      ),
    );
    if (mounted && result != null) {
      setState(() {
        _notebook = result;
        _page = 0;
        _selected.clear();
      });
    }
  }

  Future<void> _commands(BuildContext owner) async {
    final result = await UiGalleryDialog.commands<String>(
      context: owner,
      title: c.t('A useful next step', 'خطوة مفيدة تالية'),
      searchHint: c.t('Find a command', 'ابحث عن أمر'),
      emptyLabel: c.t('No matching commands', 'لا توجد أوامر مطابقة'),
      commands: [
        UiGalleryDialogAction(
          label: c.t('New note', 'ملاحظة جديدة'),
          description: c.t('Keep a fresh thought', 'احتفظ بفكرة جديدة'),
          value: 'create',
          icon: const Icon(Icons.edit_note),
        ),
        UiGalleryDialogAction(
          label: c.t('Choose notebook', 'اختر دفترًا'),
          description: c.t(
            'Change the collection in view',
            'غيّر الدفتر المعروض',
          ),
          value: 'notebook',
          icon: const Icon(Icons.book_outlined),
        ),
        UiGalleryDialogAction(
          label: c.t('Select visible notes', 'تحديد الملاحظات المعروضة'),
          value: 'select',
          enabled: _visible.isNotEmpty,
          icon: const Icon(Icons.select_all),
        ),
      ],
    );
    if (!mounted || !owner.mounted) return;
    if (result == 'create') await _edit(owner);
    if (result == 'notebook' && owner.mounted) await _chooseNotebook(owner);
    if (result == 'select') {
      setState(() => _selected.addAll(_visible.map((n) => n.id)));
    }
  }

  void _archive(BuildContext owner) {
    final removed = _notes.where((n) => _selected.contains(n.id)).toList();
    if (removed.isEmpty) return;
    setState(() {
      _notes.removeWhere((n) => _selected.contains(n.id));
      _selected.clear();
      if (removed.any((n) => n.id == _focused)) _focused = null;
    });
    UiGalleryToast.show(
      owner,
      preset: UiGalleryToastPreset.action,
      message: c.archived(removed.length),
      actionLabel: c.t('Undo', 'تراجع'),
      duration: const Duration(seconds: 8),
      duplicates: UiGalleryToastDuplicates.allow,
      onAction: () {
        if (mounted) {
          setState(() {
            _notes.addAll(
              removed.where(
                (n) => !_notes.any((current) => current.id == n.id),
              ),
            );
            _notes.sort((a, b) => b.updated.compareTo(a.updated));
          });
        }
      },
    );
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
                          'Appearance and navigation presentation. Your notes stay in this session.',
                          'تغيّر هذه الإعدادات مظهر التطبيق والتنقل. تبقى ملاحظاتك في هذه الجلسة.',
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(c.t('Dark appearance', 'المظهر الداكن')),
                        value: _dark,
                        onChanged: (v) => change(() => _dark = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('العربية / English'),
                        value: _ar,
                        onChanged: (v) => change(() => _ar = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(c.t('Text size ×2', 'حجم النص ×٢')),
                        value: _large,
                        onChanged: (v) => change(() => _large = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(c.t('Reduce motion', 'تقليل الحركة')),
                        value: _reduced,
                        onChanged: (v) => change(() => _reduced = v),
                      ),
                      if (widget.passB)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            c.t(
                              'Persistent search · showcase',
                              'بحث دائم · عرض توضيحي',
                            ),
                          ),
                          value: _persistentSearch,
                          onChanged: (v) => change(() => _persistentSearch = v),
                        ),
                      DropdownButtonFormField<String>(
                        key: ValueKey((_navStyle, _ar)),
                        initialValue: _navStyle,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: c.t(
                            'Navigation style · showcase',
                            'نمط التنقل · عرض توضيحي',
                          ),
                        ),
                        items: [
                          if (widget.passB) ...[
                            DropdownMenuItem(
                              value: 'shelf',
                              child: Text(c.t('Layered Shelf', 'رف الطبقات')),
                            ),
                            DropdownMenuItem(
                              value: 'scroll',
                              child: Text(c.t('Scroll Dock', 'شريط التمرير')),
                            ),
                          ],
                          DropdownMenuItem(
                            value: 'capsule',
                            child: Text(
                              c.t('Morphing Capsule', 'الكبسولة المتحركة'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'minimal',
                            child: Text(
                              c.t('Adaptive Minimal', 'التنقل البسيط المتكيف'),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) change(() => _navStyle = v);
                        },
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
    final colors = Theme.of(owner).colorScheme;
    return ScrollNotificationObserver(
      child: PopScope<void>(
        canPop: _selected.isEmpty && _page == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            setState(() {
              if (_selected.isNotEmpty) {
                _selected.clear();
              } else {
                _page = 0;
              }
            });
          }
        },
        child: Scaffold(
          appBar: UiGalleryAppBar(
            preset: _selected.isEmpty
                ? (_persistentSearch
                      ? UiGalleryAppBarPreset.focusBar
                      : UiGalleryAppBarPreset.searchSwitch)
                : UiGalleryAppBarPreset.selectionBar,
            title: Text(
              _selected.isEmpty
                  ? 'Margin'
                  : c.t('Selected notes', 'الملاحظات المحددة'),
            ),
            selectionCount: _selected.length,
            onSelectionCleared: () => setState(_selected.clear),
            searchField: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: c.t('Search your notes', 'ابحث في ملاحظاتك'),
              ),
              onChanged: (v) => setState(() {
                _query = v;
                _page = 0;
              }),
            ),
            actions: [
              if (_selected.isNotEmpty)
                IconButton(
                  tooltip: c.t(
                    'Archive selected notes',
                    'أرشفة الملاحظات المحددة',
                  ),
                  onPressed: () => _archive(owner),
                  icon: const Icon(Icons.archive_outlined),
                )
              else
                IconButton(
                  tooltip: c.t('Notebook commands', 'أوامر الدفتر'),
                  onPressed: () => _commands(owner),
                  icon: const Icon(Icons.keyboard_command_key),
                ),
              IconButton(
                tooltip: c.t('Showcase controls', 'إعدادات العرض التوضيحي'),
                onPressed: () => _settings(owner),
                icon: const Icon(Icons.tune),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: c.t('New note', 'ملاحظة جديدة'),
            onPressed: () => _edit(owner),
            child: const Icon(Icons.edit_outlined),
          ),
          bottomNavigationBar: UiGalleryBottomNav(
            preset: switch (_navStyle) {
              'shelf' => UiGalleryBottomNavPreset.layeredShelf,
              'scroll' => UiGalleryBottomNavPreset.scrollDock,
              'minimal' => UiGalleryBottomNavPreset.adaptiveMinimal,
              _ => UiGalleryBottomNavPreset.morphingCapsule,
            },
            selectedIndex: _page,
            onDestinationSelected: (v) => setState(() {
              _page = v;
              _selected.clear();
            }),
            semanticLabel: c.t('Notebook destinations', 'وجهات الدفتر'),
            items: [
              UiGalleryBottomNavItem(
                icon: const Icon(Icons.notes_outlined),
                label: c.t('Notes', 'الملاحظات'),
              ),
              UiGalleryBottomNavItem(
                icon: const Icon(Icons.book_outlined),
                label: c.t('Notebooks', 'الدفاتر'),
              ),
              UiGalleryBottomNavItem(
                icon: const Icon(Icons.bookmark_outline),
                label: c.t('Saved', 'المحفوظات'),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, bounds) {
              final wide =
                  bounds.maxWidth >= 1000 &&
                  MediaQuery.textScalerOf(context).scale(1) < 1.8;
              final notes = _visible;
              Widget list() => ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 96),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.t('MARGIN / LOCAL NOTEBOOK', 'مارجن / دفتر محلي'),
                          style: Theme.of(owner).textTheme.labelSmall?.copyWith(
                            letterSpacing: _ar ? 0 : 1.6,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _chooseNotebook(owner),
                        icon: const Icon(Icons.expand_more),
                        label: Text(c.notebook(_notebook)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _page == 2
                        ? c.t(
                            'Worth returning to.',
                            'أفكار تستحق العودة إليها.',
                          )
                        : c.t(
                            'Keep the thought.\nFind it later.',
                            'احتفظ بالفكرة.\nواعثر عليها لاحقًا.',
                          ),
                    style: Theme.of(owner).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    c.t(
                      'A little space for what matters. Saved in this session only.',
                      'مساحة صغيرة لما يهمك. تُحفظ الملاحظات في هذه الجلسة فقط.',
                    ),
                    style: Theme.of(owner).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_page == 1) ...[
                    for (final id in ['field', 'work', 'reading'])
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        leading: const Icon(Icons.book_outlined),
                        title: Text(c.notebook(id)),
                        subtitle: Text(
                          c.noteCount(
                            _notes.where((n) => n.notebook == id).length,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => setState(() {
                          _notebook = id;
                          _page = 0;
                        }),
                      ),
                  ] else if (notes.isEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      _query.isNotEmpty
                          ? c.t('No matching notes', 'لا توجد ملاحظات مطابقة')
                          : _page == 2
                          ? c.t('Nothing saved yet', 'لا توجد محفوظات بعد')
                          : c.t(
                              'A fresh page is waiting',
                              'صفحة جديدة بانتظارك',
                            ),
                      style: Theme.of(owner).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _query.isNotEmpty
                          ? c.t(
                              'Try another word or clear your search.',
                              'جرّب كلمة أخرى أو امسح البحث.',
                            )
                          : c.t(
                              'Create a note, or save one with the bookmark button.',
                              'أنشئ ملاحظة، أو احفظ إحداها باستخدام زر الإشارة المرجعية.',
                            ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: _query.isNotEmpty
                            ? () => setState(() {
                                _query = '';
                                _search.clear();
                              })
                            : () => _edit(owner),
                        child: Text(
                          _query.isNotEmpty
                              ? c.t('Clear search', 'مسح البحث')
                              : c.t('New note', 'ملاحظة جديدة'),
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      c.noteCount(notes.length),
                      style: Theme.of(owner).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final note in notes)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: colors.outlineVariant),
                          ),
                        ),
                        child: InkWell(
                          key: ValueKey('margin-note-${note.id}'),
                          onLongPress: () =>
                              setState(() => _selected.add(note.id)),
                          onTap: () => _selected.isNotEmpty
                              ? setState(() {
                                  if (!_selected.add(note.id)) {
                                    _selected.remove(note.id);
                                  }
                                })
                              : wide
                              ? setState(() => _focused = note.id)
                              : _edit(owner, note),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_selected.isNotEmpty)
                                  Checkbox(
                                    value: _selected.contains(note.id),
                                    semanticLabel: c.t(
                                      'Select ${note.title(_ar)}',
                                      'تحديد ${note.title(_ar)}',
                                    ),
                                    onChanged: (v) => setState(() {
                                      if (v == true) {
                                        _selected.add(note.id);
                                      } else {
                                        _selected.remove(note.id);
                                      }
                                    }),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.date(
                                          MaterialLocalizations.of(
                                            owner,
                                          ).formatMediumDate(note.updated),
                                        ),
                                        style: Theme.of(owner)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        note.title(_ar),
                                        style: Theme.of(owner)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        note.body(_ar),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(owner)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                              height: 1.5,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.passB)
                                  IconButton(
                                    tooltip: c.t(
                                      'Actions for ${note.title(_ar)}',
                                      'إجراءات ${note.title(_ar)}',
                                    ),
                                    onPressed: () => _noteActions(owner, note),
                                    icon: const Icon(Icons.more_horiz),
                                  ),
                                IconButton(
                                  tooltip: note.saved
                                      ? c.t(
                                          'Remove from saved',
                                          'إزالة من المحفوظات',
                                        )
                                      : c.t('Save for later', 'حفظ لوقت لاحق'),
                                  onPressed: () =>
                                      setState(() => note.saved = !note.saved),
                                  icon: Icon(
                                    note.saved
                                        ? Icons.bookmark
                                        : Icons.bookmark_outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              );
              if (!wide) return list();
              final current = _notes.where((n) => n.id == _focused).firstOrNull;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 190,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          c.t('COLLECTIONS', 'المجموعات'),
                          style: Theme.of(owner).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 20),
                        for (final id in ['all', 'field', 'work', 'reading'])
                          ListTile(
                            selected: _notebook == id,
                            title: Text(c.notebook(id)),
                            onTap: () => setState(() {
                              _notebook = id;
                              _page = 0;
                            }),
                          ),
                      ],
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.outlineVariant),
                  Expanded(child: list()),
                  VerticalDivider(width: 1, color: colors.outlineVariant),
                  SizedBox(
                    width: 300,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.t('READING SPACE', 'مساحة القراءة'),
                            style: Theme.of(owner).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            current?.title(_ar) ??
                                c.t('Choose a thought', 'اختر فكرة'),
                            style: Theme.of(owner).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            current?.body(_ar) ??
                                c.t(
                                  'Select a note to read it here. Your place in the list stays intact.',
                                  'اختر ملاحظة لقراءتها هنا، مع الاحتفاظ بموضعك في القائمة.',
                                ),
                            style: Theme.of(
                              owner,
                            ).textTheme.bodyLarge?.copyWith(height: 1.7),
                          ),
                          if (current != null) ...[
                            const SizedBox(height: 24),
                            TextButton.icon(
                              onPressed: () => _edit(owner, current),
                              icon: const Icon(Icons.edit_outlined),
                              label: Text(c.t('Edit note', 'تعديل الملاحظة')),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Note {
  _Note(
    this.id,
    this.notebook,
    this.enTitle,
    this.enBody,
    this.updated, {
    this.arTitle,
    this.arBody,
    this.saved = false,
  });
  final int id;
  String notebook;
  final String enTitle, enBody;
  final String? arTitle, arBody;
  final DateTime updated;
  bool saved;
  String title(bool ar) => ar ? (arTitle ?? enTitle) : enTitle;
  String body(bool ar) => ar ? (arBody ?? enBody) : enBody;
}

class _Draft {
  const _Draft(this.title, this.body);
  final String title, body;
}

class _Editor extends StatefulWidget {
  const _Editor({required this.words, this.note, this.guardChanges = false});
  final _Words words;
  final _Note? note;
  final bool guardChanges;
  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(
    text: widget.note?.title(widget.words.ar),
  );
  late final body = TextEditingController(
    text: widget.note?.body(widget.words.ar),
  );
  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  bool _allowExit = false, _asking = false;
  bool get _dirty =>
      title.text != (widget.note?.title(widget.words.ar) ?? '') ||
      body.text != (widget.note?.body(widget.words.ar) ?? '');
  Future<void> leave() async {
    if (_asking) return;
    if (!widget.guardChanges || !_dirty) {
      setState(() => _allowExit = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }
    _asking = true;
    final c = widget.words;
    final discard = await UiGalleryDialog.show<bool>(
      context: context,
      preset: UiGalleryDialogPreset.split,
      title: c.t('Leave this draft?', 'هل تريد مغادرة المسودة؟'),
      message: c.t(
        'Your edits have not been saved in this session.',
        'لم تُحفظ تعديلاتك في هذه الجلسة بعد.',
      ),
      actions: [
        UiGalleryDialogAction(
          label: c.t('Keep editing', 'متابعة الكتابة'),
          value: false,
          primary: true,
          icon: const Icon(Icons.edit_outlined),
          description: c.t(
            'Return to your words. Nothing is lost.',
            'عُد إلى كلماتك دون فقدان أي تعديل.',
          ),
        ),
        UiGalleryDialogAction(
          label: c.t('Discard changes', 'تجاهل التعديلات'),
          value: true,
          destructive: true,
          icon: const Icon(Icons.undo),
          description: c.t(
            'Only these unsaved edits will be removed.',
            'ستُحذف هذه التعديلات غير المحفوظة فقط.',
          ),
        ),
      ],
    );
    _asking = false;
    if (mounted && discard == true) {
      setState(() => _allowExit = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  void save() {
    if (form.currentState!.validate()) {
      Navigator.of(context).pop(_Draft(title.text.trim(), body.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.words;
    return PopScope(
      canPop: !widget.guardChanges || _allowExit,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) leave();
      },
      child: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.guardChanges)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: leave,
                  icon: const Icon(Icons.close),
                  label: Text(c.t('Close editor', 'إغلاق المحرر')),
                ),
              ),
            TextFormField(
              key: const ValueKey('margin-title'),
              controller: title,
              autofocus: true,
              maxLength: 120,
              decoration: InputDecoration(labelText: c.t('Title', 'العنوان')),
              validator: (v) => v == null || v.trim().isEmpty
                  ? c.t('Give this thought a title', 'أضف عنوانًا لهذه الفكرة')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('margin-body'),
              controller: body,
              minLines: 3,
              maxLines: 6,
              maxLength: 4000,
              decoration: InputDecoration(
                labelText: c.t('Your thought', 'فكرتك'),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? c.t('Write a little before saving', 'اكتب شيئًا قبل الحفظ')
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: save,
              child: Text(c.t('Save note', 'حفظ الملاحظة')),
            ),
          ],
        ),
      ),
    );
  }
}

class _Words {
  const _Words(this.ar);
  final bool ar;
  String t(String en, String arabic) => ar ? arabic : en;
  String number(int n) => date('$n');
  String date(String text) => !ar
      ? text
      : text.replaceAllMapped(
          RegExp(r'\d'),
          (m) => '٠١٢٣٤٥٦٧٨٩'[int.parse(m[0]!)],
        );
  String notebook(String id) => switch (id) {
    'field' => t('Field journal', 'دفتر اليوميات'),
    'work' => t('Product notes', 'ملاحظات المنتج'),
    'reading' => t('Weekend reading', 'قراءات نهاية الأسبوع'),
    _ => t('All notebooks', 'كل الدفاتر'),
  };
  String noteCount(int n) => !ar
      ? '$n ${n == 1 ? 'note' : 'notes'}'
      : switch (n) {
          0 => 'لا توجد ملاحظات',
          1 => 'ملاحظة واحدة',
          2 => 'ملاحظتان',
          _ => n <= 10 ? '${number(n)} ملاحظات' : '${number(n)} ملاحظة',
        };
  String archived(int n) => t(
    '$n ${n == 1 ? 'note' : 'notes'} archived',
    n == 1
        ? 'تمت أرشفة ملاحظة واحدة'
        : n == 2
        ? 'تمت أرشفة ملاحظتين'
        : 'تمت أرشفة ${number(n)} ملاحظات',
  );
}
