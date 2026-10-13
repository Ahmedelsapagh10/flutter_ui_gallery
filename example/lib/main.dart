import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

import 'gallery/catalog.dart';
import 'gallery/demo.dart';

void main() => runApp(const FlutterUiGalleryApp());

class FlutterUiGalleryApp extends StatefulWidget {
  const FlutterUiGalleryApp({super.key});
  @override
  State<FlutterUiGalleryApp> createState() => _FlutterUiGalleryAppState();
}

/// Backwards-compatible alias for tests and previous imports.
typedef NovaGallery = FlutterUiGalleryApp;

class _FlutterUiGalleryAppState extends State<FlutterUiGalleryApp> {
  bool _dark = false;
  bool _rtl = false;
  bool _reduced = false;
  Color _accent = const Color(0xff315ee8);
  double _previewWidth = 390;

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: brightness,
    );
    final dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        surface: dark ? const Color(0xff15181d) : const Color(0xfffaf9f6),
      ),
      scaffoldBackgroundColor: dark
          ? const Color(0xff0d1014)
          : const Color(0xfff2f1ed),
      extensions: [
        UiGalleryTheme(accentColor: _accent, motionIntensity: _reduced ? 0 : 1),
      ],
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter UI Gallery — Extraordinary UI. Effortless Flutter.',
    debugShowCheckedModeBanner: false,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
    locale: Locale(_rtl ? 'ar' : 'en'),
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    builder: (context, child) => _Preferences(
      dark: _dark,
      rtl: _rtl,
      reduced: _reduced,
      accent: _accent,
      previewWidth: _previewWidth,
      onDark: (v) => setState(() => _dark = v),
      onRtl: (v) => setState(() => _rtl = v),
      onReduced: (v) => setState(() => _reduced = v),
      onAccent: (v) => setState(() => _accent = v),
      onWidth: (v) => setState(() => _previewWidth = v),
      child: child!,
    ),
    home: const _GalleryHome(),
  );
}

class _Preferences extends InheritedWidget {
  const _Preferences({
    required super.child,
    required this.dark,
    required this.rtl,
    required this.reduced,
    required this.accent,
    required this.previewWidth,
    required this.onDark,
    required this.onRtl,
    required this.onReduced,
    required this.onAccent,
    required this.onWidth,
  });
  final bool dark, rtl, reduced;
  final Color accent;
  final double previewWidth;
  final ValueChanged<bool> onDark, onRtl, onReduced;
  final ValueChanged<Color> onAccent;
  final ValueChanged<double> onWidth;
  static _Preferences of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Preferences>()!;
  @override
  bool updateShouldNotify(_Preferences oldWidget) =>
      dark != oldWidget.dark ||
      rtl != oldWidget.rtl ||
      reduced != oldWidget.reduced ||
      accent != oldWidget.accent ||
      previewWidth != oldWidget.previewWidth;
}

class _GalleryHome extends StatefulWidget {
  const _GalleryHome();
  @override
  State<_GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<_GalleryHome> {
  DesignCategory? _category;
  int? _selected;
  final _collectionKey = GlobalKey();
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _Preferences.of(context);
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: _selected == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selected != null) setState(() => _selected = null);
      },
      child: Scaffold(
        endDrawer: const _SettingsPanel(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: SafeArea(
            bottom: false,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  if (_selected != null)
                    IconButton(
                      tooltip: 'Back to collection',
                      onPressed: () => setState(() => _selected = null),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  Icon(
                    Icons.blur_circular_rounded,
                    color: prefs.accent,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'ui gallery',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (MediaQuery.sizeOf(context).width > 480)
                    Text(
                      '/ flutter',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: prefs.dark ? 'Use light theme' : 'Use dark theme',
                    onPressed: () => prefs.onDark(!prefs.dark),
                    icon: Icon(
                      prefs.dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Customize gallery',
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _selected != null
            ? _Showcase(key: ValueKey(_selected), index: _selected!)
            : CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1280),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
                          child: _Hero(
                            onExplore: () {
                              final target = _collectionKey.currentContext;
                              if (target != null) {
                                Scrollable.ensureVisible(
                                  target,
                                  duration: prefs.reduced
                                      ? Duration.zero
                                      : const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                );
                              }
                            },
                            onPreview: () => setState(() => _selected = 0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1280),
                        child: Padding(
                          key: _collectionKey,
                          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'The collection',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -1,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    '01 — 12',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Different by design. Connected by a common language.',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: const Text('All surfaces · 12'),
                                    selected: _category == null,
                                    onSelected: (_) =>
                                        setState(() => _category = null),
                                  ),
                                  for (final category in DesignCategory.values)
                                    ChoiceChip(
                                      label: Text(switch (category) {
                                        DesignCategory.sheets => 'Sheets · 4',
                                        DesignCategory.dialogs => 'Dialogs · 4',
                                        DesignCategory.toasts => 'Toasts · 3',
                                        DesignCategory.header => 'Header · 1',
                                      }),
                                      selected: _category == category,
                                      onSelected: (_) =>
                                          setState(() => _category = category),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1280),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final count = constraints.maxWidth >= 1050
                                  ? 3
                                  : constraints.maxWidth >= 650
                                  ? 2
                                  : 1;
                              final indices = [
                                for (var i = 0; i < designs.length; i++)
                                  if (_category == null ||
                                      designs[i].category == _category)
                                    i,
                              ];
                              return Wrap(
                                spacing: 20,
                                runSpacing: 20,
                                children: [
                                  for (final index in indices)
                                    SizedBox(
                                      width:
                                          (constraints.maxWidth -
                                              (count - 1) * 20) /
                                          count,
                                      child: _DesignCard(
                                        index: index,
                                        onTap: () =>
                                            setState(() => _selected = index),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 48,
                      ),
                      child: Center(
                        child: Text(
                          'FLUTTER NATIVE  /  THEME AWARE  /  MADE TO FIT YOUR APP',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(letterSpacing: 1.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onExplore, required this.onPreview});
  final VoidCallback onExplore, onPreview;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 900;
        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'THE NEXT CHAPTER OF FLUTTER UI',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Interfaces\nwith intent.',
              style: TextStyle(
                fontSize: wide
                    ? 76
                    : constraints.maxWidth < 400
                    ? 48
                    : 64,
                fontWeight: FontWeight.w500,
                letterSpacing: -3.2,
                height: 1.02,
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Text(
                'Twelve expressive surfaces. Thoughtful motion.\nA little more possibility for the apps you build.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onExplore,
              icon: const Icon(Icons.arrow_downward_rounded, size: 18),
              label: const Text('Explore the collection'),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 28,
              runSpacing: 12,
              children: [
                _Metric('12', 'distinct surfaces'),
                _Metric('0', 'extra dependencies'),
                _Metric('1–3', 'lines to integrate'),
              ],
            ),
          ],
        );
        final featured = Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPreview,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'IN FOCUS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'A1 / ORBIT DOCK',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: CustomPaint(painter: _SurfaceSketch(0, colors)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Space for your next move.',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Icon(Icons.arrow_outward_rounded, color: colors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: intro),
                  const SizedBox(width: 48),
                  Expanded(flex: 5, child: featured),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [intro, const SizedBox(height: 36), featured],
              );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.number, this.label);
  final String number, label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        number,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _DesignCard extends StatelessWidget {
  const _DesignCard({required this.index, required this.onTap});
  final int index;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final design = designs[index];
    return Semantics(
      button: true,
      label: 'Explore ${design.name}',
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: .5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${(index + 1).toString().padLeft(2, '0')} / ${design.category.name.toUpperCase()}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: CustomPaint(painter: _SurfaceSketch(index, colors)),
                ),
                const SizedBox(height: 16),
                Text(
                  design.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  design.tagline,
                  style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();
  @override
  Widget build(BuildContext context) {
    final p = _Preferences.of(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Make it yours',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Close settings',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('One collection. Your visual language.'),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark appearance'),
              value: p.dark,
              onChanged: p.onDark,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Arabic / RTL'),
              value: p.rtl,
              onChanged: p.onRtl,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reduced motion'),
              value: p.reduced,
              onChanged: p.onReduced,
            ),
            const SizedBox(height: 28),
            Text(
              'ACCENT COLOR',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(letterSpacing: 1.6),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in const [
                  Color(0xff315ee8),
                  Color(0xff16816f),
                  Color(0xffa25327),
                  Color(0xff935cbb),
                  Color(0xffdf6673),
                ])
                  Semantics(
                    label: 'Accent ${color.toARGB32().toRadixString(16)}',
                    selected: p.accent == color,
                    child: IconButton(
                      tooltip:
                          'Set accent ${color.toARGB32().toRadixString(16)}',
                      onPressed: () => p.onAccent(color),
                      style: IconButton.styleFrom(backgroundColor: color),
                      icon: Icon(
                        p.accent == color ? Icons.check : Icons.circle,
                        size: p.accent == color ? 20 : 8,
                        color:
                            ThemeData.estimateBrightnessForColor(color) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: ValueKey(p.accent),
              initialValue: p.accent.toARGB32().toRadixString(16).substring(2),
              decoration: const InputDecoration(
                labelText: 'Custom hex color',
                prefixText: '#',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: (value) {
                if (value.length == 6) {
                  p.onAccent(Color(int.parse('ff$value', radix: 16)));
                }
              },
            ),
            const SizedBox(height: 28),
            Text(
              'PREVIEW DEVICE',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(letterSpacing: 1.6),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final device in [
                  (390.0, 'Phone'),
                  (768.0, 'Tablet'),
                  (1200.0, 'Wide'),
                ])
                  ChoiceChip(
                    label: Text(device.$2),
                    selected: p.previewWidth == device.$1,
                    onSelected: (_) => p.onWidth(device.$1),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'System accessibility settings always take priority. Previews use the same public components as your app.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _Showcase extends StatefulWidget {
  const _Showcase({super.key, required this.index});
  final int index;
  @override
  State<_Showcase> createState() => _ShowcaseState();
}

class _ShowcaseState extends State<_Showcase> {
  late final TextEditingController _title = TextEditingController(
    text: switch (widget.index) {
      0 => 'Make it your space',
      1 => 'A closer look',
      2 => 'Your next escape',
      3 => 'A few details',
      4 => 'Ready to continue?',
      5 => 'Discard this draft?',
      6 => 'Your verification',
      7 => 'Everything is in place',
      _ => designs[widget.index].name,
    },
  );
  late final TextEditingController _message = TextEditingController(
    text: widget.index == 5
        ? 'Your unsaved changes will be removed. You can also keep editing.'
        : widget.index >= 8 && widget.index <= 10
        ? 'Your changes have been saved.'
        : 'A thoughtful next step, with room for what matters.',
  );
  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  String get _code {
    final title = jsonEncode(_title.text).replaceAll(r'$', r'\$');
    final message = jsonEncode(_message.text).replaceAll(r'$', r'\$');
    final i = widget.index;
    if (i < 4) {
      return 'await UiGallerySheet.show<String>(\n  context: context,\n  preset: UiGallerySheetPreset.${UiGallerySheetPreset.values[i].name},\n  header: const Text($title),\n  child: const Text($message),\n);';
    }
    if (i == 6) {
      return 'final progress = ValueNotifier(UiGalleryTimelineState(\n  steps: ["Review", "Verify", "Complete"], currentStep: 0,\n));\nawait UiGalleryDialog.timeline(context: context,\n  title: $title, progress: progress);\nprogress.dispose();';
    }
    if (i == 7) {
      return 'await UiGalleryDialog.show<bool>(\n  context: context, title: $title,\n  message: $message,\n  preset: UiGalleryDialogPreset.spotlight,\n  result: UiGalleryResult.success,\n  actions: const [UiGalleryDialogAction(\n    label: "Continue", value: true, primary: true)],\n);';
    }
    if (i < 8) {
      return 'final confirmed = await UiGalleryDialog.confirm(\n  context: context, title: $title,\n  message: $message,\n  preset: UiGalleryDialogPreset.${UiGalleryDialogPreset.values[i - 4].name},\n);';
    }
    if (i < 11) {
      return 'UiGalleryToast.show(context,\n  message: $message,\n  preset: UiGalleryToastPreset.${UiGalleryToastPreset.values[i - 8].name},\n${i == 10 ? '  actionLabel: "Undo", onAction: () { /* restore your item */ },\n  showProgress: true,\n' : ''});';
    }
    return 'Scaffold(\n  appBar: UiGalleryAppBar(\n    title: Text($title), scrollAware: true,\n  ),\n  body: ListView(children: yourItems),\n);';
  }

  @override
  Widget build(BuildContext context) {
    final p = _Preferences.of(context);
    final design = designs[widget.index];
    final theme = Theme.of(context);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${design.category.name.toUpperCase()} / ${(widget.index + 1).toString().padLeft(2, '0')}',
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 2,
            color: p.accent,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          design.name,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          design.useCase,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.7,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'PLAY WITH THE CONTENT',
          style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.6),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Title'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _message,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Message'),
          onChanged: (_) => setState(() {}),
        ),
        if (p.rtl)
          TextButton(
            onPressed: () => setState(() {
              _title.text = 'مساحة لاختياراتك';
              _message.text = 'تم حفظ تغييراتك. كل شيء جاهز للخطوة التالية.';
            }),
            child: const Text('استخدم محتوى عربي'),
          ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'USE IT IN YOUR APP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy code',
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _code));
                      if (context.mounted) {
                        UiGalleryToast.success(
                          context,
                          message: 'Code copied.',
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Directionality(
                textDirection: TextDirection.ltr,
                child: SelectableText(
                  _code,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.7,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Import package:flutter_ui_gallery/flutter_ui_gallery.dart.\nNo theme wrapper, controllers or services required for basic usage.',
          style: theme.textTheme.bodySmall?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 1050;
        final frameWidth = wide
            ? (constraints.maxWidth * .55).clamp(0.0, p.previewWidth)
            : p.previewWidth;
        final preview = Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    p.previewWidth > 600
                        ? Icons.tablet_outlined
                        : Icons.smartphone_outlined,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE PREVIEW / ${p.previewWidth.toInt()} DP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: frameWidth),
              child: Container(
                height: 700,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 6,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: LayoutBuilder(
                    builder: (context, constraints) => MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: constraints.biggest,
                        padding: EdgeInsets.zero,
                        viewPadding: EdgeInsets.zero,
                      ),
                      child: Navigator(
                        onGenerateRoute: (_) => MaterialPageRoute<void>(
                          builder: (_) => AnimatedBuilder(
                            animation: Listenable.merge([_title, _message]),
                            builder: (_, _) => SurfaceDemo(
                              key: ValueKey(widget.index),
                              index: widget.index,
                              title: _title.text,
                              message: _message.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: details),
                        const SizedBox(width: 56),
                        Expanded(flex: 6, child: preview),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [details, const SizedBox(height: 32), preview],
                    ),
            ),
          ),
        );
      },
    );
  }
}

/// Small editorial diagrams introduce each composition; the showcase above
/// always renders the real interactive component.
class _SurfaceSketch extends CustomPainter {
  const _SurfaceSketch(this.index, this.colors);
  final int index;
  final ColorScheme colors;
  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / 320).clamp(.7, 1.4);
    canvas.save();
    canvas.translate(
      (size.width - 320 * scale) / 2,
      (size.height - 170 * scale) / 2,
    );
    canvas.scale(scale);
    final ink = colors.onSurface;
    final accent = colors.primary;
    final line = colors.outlineVariant;
    final fill = colors.surfaceContainerLow;
    void box(
      Rect rect, {
      double radius = 12,
      Color? color,
      bool stroke = false,
    }) => canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()
        ..color = color ?? fill
        ..style = stroke ? PaintingStyle.stroke : PaintingStyle.fill
        ..strokeWidth = 1,
    );
    void text(
      String value,
      Offset offset, {
      double fontSize = 10,
      Color? color,
      FontWeight weight = FontWeight.w500,
    }) {
      final painter = TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(
            fontSize: fontSize,
            color: color ?? ink,
            fontWeight: weight,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 250);
      painter.paint(canvas, offset);
    }

    void rule(double x, double y, double width, {Color? color}) =>
        box(Rect.fromLTWH(x, y, width, 3), radius: 2, color: color ?? line);
    if (index < 4) {
      final surface = Rect.fromLTWH(
        index == 0 ? 38 : 28,
        index == 1 ? 50 : 20,
        index == 0 ? 248 : 264,
        index == 1 ? 100 : 140,
      );
      if (index == 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            surface,
            topLeft: const Radius.circular(32),
            topRight: const Radius.circular(12),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(24),
          ),
          Paint()..color = fill,
        );
      } else {
        box(surface, radius: index == 2 ? 4 : 18);
      }
      box(surface, radius: index == 0 ? 24 : 12, color: line, stroke: true);
      if (index == 0) {
        rule(148, 28, 28);
        text('Make it your space', const Offset(58, 46), fontSize: 13);
        for (var i = 0; i < 3; i++) {
          box(
            Rect.fromLTWH(56 + i * 73, 80, 64, 56),
            color: colors.primaryContainer,
            radius: i == 0 ? 18 : 12,
          );
          canvas.drawCircle(
            Offset(88 + i * 73, 98),
            5,
            Paint()..color = accent,
          );
          text(
            ['Share', 'Save', 'Adjust'][i],
            Offset(73 + i * 73, 115),
            fontSize: 8,
          );
        }
      } else if (index == 1) {
        rule(142, 57, 34);
        text('A closer look', const Offset(48, 77), fontSize: 13);
        rule(48, 104, 180);
        rule(48, 116, 145);
        rule(48, 128, 165);
        box(
          const Rect.fromLTWH(62, 22, 196, 16),
          radius: 8,
          color: line.withValues(alpha: .4),
        );
      } else if (index == 2) {
        box(
          const Rect.fromLTWH(40, 32, 106, 110),
          color: colors.primaryContainer,
          radius: 2,
        );
        final path = Path()
          ..moveTo(48, 114)
          ..lineTo(81, 66)
          ..lineTo(106, 101)
          ..lineTo(129, 77)
          ..lineTo(138, 114)
          ..close();
        canvas.drawPath(path, Paint()..color = accent.withValues(alpha: .5));
        text('The quiet retreat', const Offset(160, 46), fontSize: 11);
        rule(160, 70, 104);
        rule(160, 80, 75);
        box(const Rect.fromLTWH(160, 110, 112, 26), color: accent, radius: 6);
        text(
          'Reserve a place',
          const Offset(172, 119),
          color: colors.onPrimary,
          fontSize: 8,
        );
      } else {
        for (var i = 0; i < 3; i++) {
          rule(48 + i * 74, 34, 64, color: i == 0 ? accent : line);
        }
        text('Choose your delivery', const Offset(48, 52), fontSize: 13);
        box(
          const Rect.fromLTWH(48, 82, 222, 30),
          color: colors.primaryContainer,
          radius: 8,
        );
        text('Standard', const Offset(60, 93), fontSize: 9);
        text('Continue  →', const Offset(214, 136), fontSize: 9, color: accent);
      }
    } else if (index < 8) {
      box(const Rect.fromLTWH(52, 16, 216, 144), radius: index == 7 ? 30 : 18);
      box(
        const Rect.fromLTWH(52, 16, 216, 144),
        radius: index == 7 ? 30 : 18,
        color: line,
        stroke: true,
      );
      if (index == 4) {
        rule(74, 36, 20, color: accent);
        text('Ready to continue?', const Offset(74, 54), fontSize: 14);
        rule(74, 83, 160);
        rule(74, 95, 123);
        text(
          'Cancel',
          const Offset(85, 133),
          color: colors.onSurfaceVariant,
          fontSize: 9,
        );
        box(
          const Rect.fromLTWH(170, 117, 76, 30),
          color: accent.withValues(alpha: .18),
          radius: 11,
        );
        box(const Rect.fromLTWH(174, 121, 68, 22), color: accent, radius: 8);
        text(
          'Confirm',
          const Offset(191, 128),
          color: colors.onPrimary,
          fontSize: 8,
        );
      } else if (index == 5) {
        box(
          const Rect.fromLTWH(177, 28, 80, 120),
          radius: 8,
          color: colors.primaryContainer,
        );
        text('Discard', const Offset(69, 54), fontSize: 16);
        text('this draft?', const Offset(69, 74), fontSize: 16);
        rule(70, 109, 86);
        rule(70, 120, 67);
        text('Keep editing', const Offset(188, 78), fontSize: 8);
        box(
          const Rect.fromLTWH(185, 110, 64, 25),
          radius: 8,
          color: colors.error,
        );
        text(
          'Discard',
          const Offset(201, 119),
          fontSize: 8,
          color: colors.onError,
        );
      } else if (index == 6) {
        text('Your verification', const Offset(74, 36), fontSize: 13);
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(82, 73 + i * 29),
            6,
            Paint()..color = i < 2 ? accent : line,
          );
          if (i < 2) {
            canvas.drawLine(
              Offset(82, 81 + i * 29),
              Offset(82, 93 + i * 29),
              Paint()..color = line,
            );
          }
          text(
            ['Review details', 'Verify identity', 'Ready to continue'][i],
            Offset(101, 68 + i * 29),
            fontSize: 10,
            color: i == 2 ? colors.onSurfaceVariant : ink,
          );
        }
      } else {
        canvas.drawCircle(
          const Offset(160, 65),
          30,
          Paint()..color = accent.withValues(alpha: .08),
        );
        canvas.drawCircle(
          const Offset(160, 65),
          35,
          Paint()
            ..color = line
            ..style = PaintingStyle.stroke,
        );
        canvas.drawArc(
          const Rect.fromLTWH(125, 30, 70, 70),
          -1.57,
          2.1,
          false,
          Paint()
            ..color = accent
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
        final check = Path()
          ..moveTo(147, 65)
          ..lineTo(156, 74)
          ..lineTo(174, 56);
        canvas.drawPath(
          check,
          Paint()
            ..color = accent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
        text('Everything is in place', const Offset(98, 114), fontSize: 12);
        rule(131, 140, 58, color: accent);
      }
    } else if (index < 11) {
      final rect = Rect.fromLTWH(
        index == 8 ? 42 : 20,
        61,
        index == 8 ? 236 : 280,
        52,
      );
      box(
        rect,
        radius: index == 8
            ? 26
            : index == 9
            ? 5
            : 16,
      );
      box(
        rect,
        radius: index == 8
            ? 26
            : index == 9
            ? 5
            : 16,
        color: line,
        stroke: true,
      );
      if (index == 9) {
        box(
          const Rect.fromLTWH(20, 61, 4, 52),
          radius: 2,
          color: colors.tertiary,
        );
      }
      canvas.drawCircle(
        Offset(index == 8 ? 63 : 44, 87),
        5,
        Paint()..color = accent,
      );
      text(
        index == 10
            ? 'Item removed'
            : index == 9
            ? 'Connection interrupted'
            : 'Your changes are saved',
        Offset(index == 8 ? 78 : 59, 81),
        fontSize: 11,
      );
      if (index == 10) {
        canvas.drawLine(
          const Offset(220, 74),
          const Offset(220, 100),
          Paint()..color = line,
        );
        text('Undo', const Offset(239, 81), fontSize: 11, color: accent);
        rule(33, 111, 192, color: accent);
      }
    } else {
      box(const Rect.fromLTWH(20, 24, 280, 67), radius: 4);
      text('Your workspace', const Offset(40, 44), fontSize: 18);
      text('A quieter kind of interface', const Offset(40, 69), fontSize: 8);
      canvas.drawCircle(const Offset(274, 57), 5, Paint()..color = accent);
      canvas.drawLine(
        const Offset(255, 38),
        const Offset(255, 76),
        Paint()..color = line,
      );
      box(const Rect.fromLTWH(20, 116, 280, 37), radius: 4);
      text('Your workspace', const Offset(40, 128), fontSize: 12);
      canvas.drawCircle(const Offset(274, 134), 4, Paint()..color = accent);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SurfaceSketch oldDelegate) =>
      index != oldDelegate.index || colors != oldDelegate.colors;
}
