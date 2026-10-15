import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

import 'gallery/catalog.dart';
import 'gallery/demo.dart';
import 'gallery/snippet.dart';
import 'gallery/configuration.dart';
import 'gallery/recipes.dart';

void main() => runApp(const FlutterUiGalleryApp());

class FlutterUiGalleryApp extends StatefulWidget {
  const FlutterUiGalleryApp({super.key, this.configuration});
  final PlaygroundConfiguration? configuration;

  @override
  State<FlutterUiGalleryApp> createState() => _FlutterUiGalleryAppState();
}

/// Backwards-compatible alias for tests and previous imports.
typedef NovaGallery = FlutterUiGalleryApp;

class _FlutterUiGalleryAppState extends State<FlutterUiGalleryApp> {
  late final PlaygroundConfiguration _initial;
  UiGalleryDesignFamily _family = UiGalleryDesignFamily.soft;
  @override
  void initState() {
    super.initState();
    _initial =
        widget.configuration ?? PlaygroundConfiguration.fromUri(Uri.base);
    _restore(_initial);
  }

  void _restore(PlaygroundConfiguration configuration) {
    _family = configuration.family;
    _dark = configuration.dark;
    _rtl = configuration.rtl;
    _reduced = configuration.reduced;
    _accent = configuration.accent;
    _previewWidth = configuration.width;
    _transitionMs = configuration.transitionMs;
    _curveDepth = configuration.curveDepth;
    _depthIntensity = configuration.depthIntensity;
  }

  bool _dark = false;
  bool _rtl = false;
  bool _reduced = false;
  Color _accent = const Color(0xff4f46e5);
  double _previewWidth = 390;
  double? _transitionMs;
  double? _curveDepth;
  double _depthIntensity = 1;

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final fontFamily = _rtl ? 'Alexandria' : 'Plus Jakarta Sans';
    final headlineFont = _rtl ? 'Alexandria' : 'Outfit';

    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: brightness,
      surface: dark ? const Color(0xff12151f) : const Color(0xffffffff),
    );

    final baseText = (dark ? ThemeData.dark() : ThemeData.light()).textTheme;
    final customText = baseText
        .apply(fontFamily: fontFamily)
        .copyWith(
          displayLarge: TextStyle(
            fontFamily: headlineFont,
            letterSpacing: -1.5,
          ),
          displayMedium: TextStyle(
            fontFamily: headlineFont,
            letterSpacing: -1.2,
          ),
          displaySmall: TextStyle(
            fontFamily: headlineFont,
            letterSpacing: -1.0,
          ),
          headlineLarge: TextStyle(
            fontFamily: headlineFont,
            letterSpacing: -0.8,
          ),
          headlineMedium: TextStyle(
            fontFamily: headlineFont,
            letterSpacing: -0.6,
          ),
          headlineSmall: TextStyle(
            fontFamily: headlineFont,
            letterSpacing: -0.4,
          ),
          titleLarge: TextStyle(fontFamily: headlineFont, letterSpacing: -0.2),
          titleMedium: TextStyle(fontFamily: headlineFont),
          titleSmall: TextStyle(fontFamily: headlineFont),
        );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      textTheme: customText,
      colorScheme: scheme.copyWith(
        surface: dark ? const Color(0xff12151f) : const Color(0xffffffff),
        surfaceContainerLow: dark
            ? const Color(0xff161a27)
            : const Color(0xfff8fafc),
        surfaceContainer: dark
            ? const Color(0xff1b2030)
            : const Color(0xfff1f4f9),
        surfaceContainerHigh: dark
            ? const Color(0xff22283c)
            : const Color(0xffe8edf5),
        outlineVariant: dark
            ? const Color(0xff22293d)
            : const Color(0xffe2e8f0),
      ),
      scaffoldBackgroundColor: dark
          ? const Color(0xff090b10)
          : const Color(0xfff8fafc),
      extensions: [
        UiGalleryTheme(
          accentColor: _accent,
          motionIntensity: _reduced ? 0 : 1,
          motion: _transitionMs == null
              ? const UiGalleryMotion()
              : UiGalleryMotion(
                  entrance: Duration(milliseconds: _transitionMs!.round()),
                  exit: Duration(milliseconds: _transitionMs!.round()),
                  change: Duration(milliseconds: _transitionMs!.round()),
                ),
        ),
      ],
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xff161a27) : const Color(0xffffffff),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: dark ? const Color(0xff22293d) : const Color(0xffe2e8f0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: dark ? const Color(0xff22293d) : const Color(0xffe2e8f0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accent, width: 1.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(
          color: dark ? const Color(0xff22293d) : const Color(0xffe2e8f0),
        ),
      ),
    );
    final recipe = UiGalleryTheme.family(_family, theme: base);
    return base.copyWith(
      extensions: [
        recipe.copyWith(
          surfaceStyle: recipe.surfaceStyle!.copyWith(accentColor: _accent),
          motionIntensity: _reduced ? 0 : 1,
          motion: _transitionMs == null
              ? recipe.motion
              : recipe.motion!.copyWith(
                  entrance: Duration(milliseconds: _transitionMs!.round()),
                  exit: Duration(milliseconds: _transitionMs!.round()),
                  change: Duration(milliseconds: _transitionMs!.round()),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter UI Gallery — Playground',
    onGenerateInitialRoutes: (name) => [
      MaterialPageRoute<void>(
        settings: RouteSettings(name: name),
        builder: (_) => _GalleryHome(configuration: _initial),
      ),
    ],
    debugShowCheckedModeBanner: false,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
    locale: Locale(_rtl ? 'ar' : 'en'),
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    builder: (context, child) => _Preferences(
      family: _family,
      onFamily: (family) => setState(() => _family = family),
      dark: _dark,
      rtl: _rtl,
      reduced: _reduced,
      accent: _accent,
      previewWidth: _previewWidth,
      transitionMs: _transitionMs,
      curveDepth: _curveDepth,
      depthIntensity: _depthIntensity,
      onTransition: (v) => setState(() => _transitionMs = v),
      onCurveDepth: (v) => setState(() => _curveDepth = v),
      onDepthIntensity: (v) => setState(() => _depthIntensity = v),
      onDark: (v) {
        setState(() => _dark = v);
      },
      onRtl: (v) {
        setState(() => _rtl = v);
      },
      onReduced: (v) {
        setState(() => _reduced = v);
      },
      onAccent: (v) {
        setState(() => _accent = v);
      },
      onWidth: (v) {
        setState(() => _previewWidth = v);
      },
      child: child!,
    ),
    onGenerateRoute: (settings) {
      final configuration = settings.name == null
          ? _initial
          : PlaygroundConfiguration.fromUri(
              Uri.tryParse(settings.name!) ?? Uri(),
            );
      setState(() => _restore(configuration));
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => _GalleryHome(configuration: configuration),
      );
    },
  );
}

class _Preferences extends InheritedWidget {
  const _Preferences({
    required super.child,
    required this.family,
    required this.onFamily,
    required this.dark,
    required this.rtl,
    required this.reduced,
    required this.accent,
    required this.previewWidth,
    required this.transitionMs,
    required this.curveDepth,
    required this.depthIntensity,
    required this.onTransition,
    required this.onCurveDepth,
    required this.onDepthIntensity,
    required this.onDark,
    required this.onRtl,
    required this.onReduced,
    required this.onAccent,
    required this.onWidth,
  });

  final UiGalleryDesignFamily family;
  final ValueChanged<UiGalleryDesignFamily> onFamily;
  final bool dark, rtl, reduced;
  final Color accent;
  final double previewWidth, depthIntensity;
  final double? transitionMs, curveDepth;
  final ValueChanged<bool> onDark, onRtl, onReduced;
  final ValueChanged<Color> onAccent;
  final ValueChanged<double> onWidth, onDepthIntensity;
  final ValueChanged<double?> onTransition, onCurveDepth;

  static _Preferences of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Preferences>()!;

  @override
  bool updateShouldNotify(_Preferences oldWidget) =>
      family != oldWidget.family ||
      dark != oldWidget.dark ||
      rtl != oldWidget.rtl ||
      reduced != oldWidget.reduced ||
      accent != oldWidget.accent ||
      previewWidth != oldWidget.previewWidth ||
      transitionMs != oldWidget.transitionMs ||
      curveDepth != oldWidget.curveDepth ||
      depthIntensity != oldWidget.depthIntensity;
}

String _familyLabel(UiGalleryDesignFamily family) => switch (family) {
  UiGalleryDesignFamily.minimal => 'Minimal',
  UiGalleryDesignFamily.soft => 'Soft',
  UiGalleryDesignFamily.spatial => 'Spatial',
};

String _categoryLabel(DesignCategory category) => switch (category) {
  DesignCategory.sheets => 'Bottom Sheets',
  DesignCategory.dialogs => 'Dialogs',
  DesignCategory.toasts => 'Toasts',
  DesignCategory.header => 'AppBars',
  DesignCategory.bottomNav => 'Bottom Navigation',
};

bool _hasCurve(SurfaceDesign d) =>
    d.appBar == UiGalleryAppBarPreset.sculptedWave ||
    const {
      UiGalleryBottomNavPreset.floatingCove,
      UiGalleryBottomNavPreset.concaveNotch,
      UiGalleryBottomNavPreset.convexWave,
      UiGalleryBottomNavPreset.ribbonCurve,
    }.contains(d.bottomNav);
bool _hasDepth(SurfaceDesign d) =>
    const {
      UiGalleryAppBarPreset.sculptedWave,
      UiGalleryAppBarPreset.foldedCanopy,
      UiGalleryAppBarPreset.parallaxCrest,
      UiGalleryAppBarPreset.orbitCommand,
    }.contains(d.appBar) ||
    const {
      UiGalleryBottomNavPreset.orbitDock,
      UiGalleryBottomNavPreset.perspectiveDock,
      UiGalleryBottomNavPreset.liquidDrop,
      UiGalleryBottomNavPreset.flipTiles,
    }.contains(d.bottomNav);

class _GalleryHome extends StatefulWidget {
  const _GalleryHome({required this.configuration});
  final PlaygroundConfiguration configuration;
  @override
  State<_GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<_GalleryHome> {
  int _selected = 0;
  bool _recommended = false;
  DesignPurpose? _purpose;
  @override
  void initState() {
    super.initState();
    final index = designs.indexWhere(
      (design) => design.id == widget.configuration.preset,
    );
    _selected = index < 0 ? 0 : index;
    _title.text = widget.configuration.title;
    _message.text = widget.configuration.message;
  }

  List<int> _indices(DesignCategory category) => [
    for (var i = 0; i < designs.length; i++)
      if ((_purpose == null
              ? designs[i].category == category
              : designs[i].purpose == _purpose) &&
          (!_recommended || designs[i].recommended))
        i,
  ];
  void _browse({DesignPurpose? purpose, bool? recommended}) {
    setState(() {
      _purpose = purpose;
      _recommended = recommended ?? _recommended;
      var indices = _indices(designs[_selected].category);
      if (indices.isEmpty) {
        indices = [
          for (var i = 0; i < designs.length; i++)
            if ((!_recommended || designs[i].recommended) &&
                (_purpose == null || designs[i].purpose == _purpose))
              i,
        ];
      }
      if (!indices.contains(_selected) && indices.isNotEmpty) {
        _selected = indices.first;
      }
    });
  }

  final _previewKey = GlobalKey();
  final _title = TextEditingController(text: 'Make it your space');
  final _message = TextEditingController(text: 'Choose what happens next.');

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _selected) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selected = index);
  }

  @override
  Widget build(BuildContext context) {
    final p = _Preferences.of(context);
    final colors = Theme.of(context).colorScheme;
    final design = designs[_selected];
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Real app examples',
            icon: const Icon(Icons.apps_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RecipeGallery()),
            ),
          ),
          IconButton(
            tooltip: 'Share configuration',
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final config = PlaygroundConfiguration(
                preset: design.id,
                family: p.family,
                dark: p.dark,
                rtl: p.rtl,
                reduced: p.reduced,
                accent: p.accent,
                width: p.previewWidth,
                title: _title.text,
                message: _message.text,
                transitionMs: p.transitionMs,
                curveDepth: p.curveDepth,
                depthIntensity: p.depthIntensity,
              );
              final base =
                  Uri.base.hasScheme &&
                      const ['http', 'https'].contains(Uri.base.scheme)
                  ? Uri.base
                  : Uri.https(
                      'ahmedelsapagh10.github.io',
                      '/flutter_ui_gallery/',
                    );
              await Clipboard.setData(
                ClipboardData(text: config.toUri(base).toString()),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuration link copied')),
                );
              }
            },
          ),
        ],
        titleSpacing: 20,
        toolbarHeight: 60,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/flutter_ui_gallery.png',
                width: 30,
                height: 30,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'ui gallery',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Playground',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final frameHeight = wide
              ? (constraints.maxHeight - 214).clamp(360.0, 570.0)
              : (MediaQuery.sizeOf(context).height * .57).clamp(410.0, 540.0);
          return SingleChildScrollView(
            key: const ValueKey('playground-scroll'),
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 28 : 16,
              vertical: 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final category in DesignCategory.values)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: ChoiceChip(
                                label: Text(_categoryLabel(category)),
                                selected: design.category == category,
                                onSelected: (_) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  setState(() {
                                    _purpose = null;
                                    _selected = _indices(category).first;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilterChip(
                          label: const Text('Recommended'),
                          selected: _recommended,
                          onSelected: (value) => _browse(recommended: value),
                        ),
                        PopupMenuButton<DesignPurpose>(
                          tooltip: 'Browse by task',
                          onSelected: (purpose) =>
                              _browse(purpose: purpose, recommended: false),
                          itemBuilder: (_) => [
                            for (final purpose in DesignPurpose.values)
                              PopupMenuItem(
                                value: purpose,
                                child: Text(purposeLabel(purpose)),
                              ),
                          ],
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 48,
                              minWidth: 48,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.filter_list_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _purpose == null
                                        ? 'Browse by task'
                                        : purposeLabel(_purpose!),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_purpose != null)
                          TextButton(
                            onPressed: () => _browse(recommended: false),
                            child: const Text('All tasks'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            key: ValueKey((
                              design.category,
                              _purpose,
                              _recommended,
                              _selected,
                            )),
                            initialValue: _selected,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Preset',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                            items: [
                              for (final i in _indices(design.category))
                                DropdownMenuItem(
                                  value: i,
                                  child: Text(
                                    designs[i].name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (i) {
                              if (i != null) _select(i);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Previous preset',
                          onPressed: () {
                            final indices = _indices(design.category);
                            _select(
                              indices[(indices.indexOf(_selected) - 1) %
                                  indices.length],
                            );
                          },
                          icon: const Icon(Icons.chevron_left),
                        ),
                        IconButton(
                          tooltip: 'Next preset',
                          onPressed: () {
                            final indices = _indices(design.category);
                            _select(
                              indices[(indices.indexOf(_selected) + 1) %
                                  indices.length],
                            );
                          },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    AnimatedBuilder(
                      animation: Listenable.merge([_title, _message]),
                      builder: (context, _) {
                        final code = playgroundSnippet(
                          design: design,
                          family: p.family,
                          brightness: p.dark
                              ? Brightness.dark
                              : Brightness.light,
                          title: _title.text,
                          message: _message.text,
                          accent: p.accent,
                          reduced: p.reduced,
                          transitionMs: p.transitionMs,
                          curveDepth: _hasCurve(design) ? p.curveDepth : null,
                          depthIntensity: _hasDepth(design)
                              ? p.depthIntensity
                              : 1,
                        );
                        final preview = _PhonePreview(
                          key: _previewKey,
                          index: _selected,
                          title: _title,
                          message: _message,
                          height: frameHeight,
                        );
                        final controls = _Controls(
                          design: design,
                          title: _title,
                          message: _message,
                        );
                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: _CodePanel(code: code)),
                              const SizedBox(width: 36),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    preview,
                                    const SizedBox(height: 14),
                                    controls,
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            preview,
                            const SizedBox(height: 20),
                            _CodePanel(code: code),
                            const SizedBox(height: 14),
                            controls,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhonePreview extends StatelessWidget {
  const _PhonePreview({
    super.key,
    required this.index,
    required this.title,
    required this.message,
    required this.height,
  });
  final int index;
  final TextEditingController title, message;
  final double height;
  @override
  Widget build(BuildContext context) {
    final p = _Preferences.of(context);
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: p.previewWidth),
        child: Container(
          key: const ValueKey('phone-frame'),
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: colors.outlineVariant, width: 5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final source = MediaQuery.of(context);
                final focusedInPreview =
                    FocusManager.instance.primaryFocus?.context
                        ?.findAncestorWidgetOfExactType<_PhonePreview>() !=
                    null;
                return MediaQuery(
                  data: source.copyWith(
                    size: constraints.biggest,
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                    viewInsets: focusedInPreview
                        ? source.viewInsets
                        : EdgeInsets.zero,
                  ),
                  child: Navigator(
                    key: ValueKey(index),
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (_) => AnimatedBuilder(
                        animation: Listenable.merge([title, message]),
                        builder: (context, _) {
                          final preferences = _Preferences.of(context);
                          final design = designs[index];
                          return SurfaceDemo(
                            key: ValueKey(index),
                            index: index,
                            title: title.text,
                            message: message.text,
                            curveDepth: _hasCurve(design)
                                ? preferences.curveDepth
                                : null,
                            depthIntensity: _hasDepth(design)
                                ? preferences.depthIntensity
                                : 1,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.design,
    required this.title,
    required this.message,
  });
  final SurfaceDesign design;
  final TextEditingController title, message;
  @override
  Widget build(BuildContext context) {
    final p = _Preferences.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PopupMenuButton<UiGalleryDesignFamily>(
              tooltip: 'Design family',
              onSelected: p.onFamily,
              itemBuilder: (_) => [
                for (final family in UiGalleryDesignFamily.values)
                  PopupMenuItem(
                    value: family,
                    child: Text(_familyLabel(family)),
                  ),
              ],
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_familyLabel(p.family)),
                ),
              ),
            ),
            PopupMenuButton<Color>(
              tooltip: 'Accent color',
              icon: Icon(Icons.palette_outlined, color: p.accent),
              onSelected: p.onAccent,
              itemBuilder: (_) => [
                for (final color in const [
                  Color(0xff4f46e5),
                  Color(0xff0d9488),
                  Color(0xffd97706),
                  Color(0xff7c3aed),
                  Color(0xffe11d48),
                ])
                  PopupMenuItem(
                    value: color,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: color, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            IconButton(
              tooltip: p.dark ? 'Light mode' : 'Dark mode',
              onPressed: () => p.onDark(!p.dark),
              icon: Icon(
                p.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
            ),
            FilterChip(
              label: const Text('Animation'),
              selected: !p.reduced,
              onSelected: (enabled) => p.onReduced(!enabled),
              showCheckmark: false,
              avatar: Icon(
                !p.reduced
                    ? Icons.motion_photos_on_outlined
                    : Icons.motion_photos_off_outlined,
                size: 18,
              ),
            ),
            if (_hasCurve(design))
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Curve', style: Theme.of(context).textTheme.labelMedium),
                  SizedBox(
                    width: 100,
                    child: Slider(
                      value:
                          p.curveDepth ??
                          (design.bottomNav ==
                                  UiGalleryBottomNavPreset.concaveNotch
                              ? 24
                              : 14),
                      max: 28,
                      divisions: 14,
                      label: '${(p.curveDepth ?? 14).round()}',
                      onChanged: p.onCurveDepth,
                    ),
                  ),
                ],
              ),
          ],
        ),
        ExpansionTile(
          key: const PageStorageKey('advanced-controls'),
          title: const Text('More'),
          leading: const Icon(Icons.tune, size: 18),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 16),
          children: [
            if (design.bottomNav == null) ...[
              TextField(
                key: const PageStorageKey('playground-title'),
                controller: title,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const PageStorageKey('playground-content'),
                controller: message,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: design.appBar == null ? 'Content' : 'Subtitle',
                ),
              ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('RTL'),
              value: p.rtl,
              onChanged: p.onRtl,
            ),
            Row(
              children: [
                const Text('Duration'),
                Expanded(
                  child: Slider(
                    value:
                        p.transitionMs ??
                        (design.sheet != null ||
                                design.dialog != null ||
                                design.toast != null
                            ? 340
                            : 240),
                    min: 120,
                    max: 600,
                    divisions: 12,
                    label: '${p.transitionMs?.round() ?? 340} ms',
                    onChanged: p.reduced ? null : p.onTransition,
                  ),
                ),
                IconButton(
                  tooltip: 'Reset duration',
                  onPressed: () => p.onTransition(null),
                  icon: const Icon(Icons.restart_alt),
                ),
              ],
            ),
            if (_hasDepth(design))
              Row(
                children: [
                  const Text('Depth'),
                  Expanded(
                    child: Slider(
                      value: p.depthIntensity,
                      divisions: 10,
                      onChanged: p.onDepthIntensity,
                      label: '${(p.depthIntensity * 100).round()}%',
                    ),
                  ),
                ],
              ),
            if (_hasCurve(design))
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => p.onCurveDepth(null),
                  child: const Text('Reset curve'),
                ),
              ),
            Row(
              children: [
                const Text('Width'),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<double>(
                    isExpanded: true,
                    value: p.previewWidth,
                    items: const [
                      DropdownMenuItem(value: 390, child: Text('Phone')),
                      DropdownMenuItem(value: 768, child: Text('Tablet')),
                      DropdownMenuItem(value: 1200, child: Text('Wide')),
                    ],
                    onChanged: (v) {
                      if (v != null) p.onWidth(v);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _CodePanel extends StatefulWidget {
  const _CodePanel({required this.code});
  final String code;
  @override
  State<_CodePanel> createState() => _CodePanelState();
}

class _CodePanelState extends State<_CodePanel> {
  bool _copied = false;
  @override
  void didUpdateWidget(_CodePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code) _copied = false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('code-panel'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dart',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Directionality(
            textDirection: TextDirection.ltr,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText.rich(
                TextSpan(children: highlightedDart(widget.code, colors)),
                key: const ValueKey('dart-snippet'),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.65,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: widget.code));
                if (mounted) setState(() => _copied = true);
              },
              icon: Icon(_copied ? Icons.check : Icons.copy, size: 16),
              label: Text(_copied ? 'Copied' : 'Copy Code'),
            ),
          ),
        ],
      ),
    );
  }
}
