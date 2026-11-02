import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'gallery_style.dart';
import 'gallery_shape.dart';

/// Coordinated recipes that retain the application's ColorScheme and fonts.
enum UiGalleryDesignFamily { minimal, soft, spatial }

/// Cheap effects retain structure and contrast without blur or layered shadows.
enum UiGalleryEffects { full, cheap }

/// A finite damped response, normalized to settle exactly at the final frame.
class UiGallerySpringCurve extends Curve {
  const UiGallerySpringCurve({this.damping = 8, this.frequency = 0})
    : assert(damping > 0 && damping < double.infinity),
      assert(frequency >= 0 && frequency < double.infinity);
  final double damping, frequency;
  double _response(double t) => frequency == 0
      ? 1 - (1 + damping * t) * math.exp(-damping * t)
      : 1 -
            math.exp(-damping * t) *
                (math.cos(frequency * t) +
                    damping / frequency * math.sin(frequency * t));
  @override
  double transformInternal(double t) => _response(t) / _response(1);
}

// Selects the component-specific layer in the shared style resolver.
enum UiGallerySurface { sheet, dialog, toast, appBar, bottomNav }

/// Optional overrides. Components otherwise use the surrounding [ThemeData].
@immutable
class UiGalleryTheme extends ThemeExtension<UiGalleryTheme> {
  const UiGalleryTheme({
    this.accentColor,
    this.surfaceColor,
    this.contentColor,
    double? motionIntensity,
    this.surfaceStyle,
    this.motion,
    this.sheetStyle,
    this.dialogStyle,
    this.toastStyle,
    this.appBarStyle,
    this.bottomNavStyle,
    this.designFamily,
    UiGalleryEffects? effects,
    double? radiusScale,
    bool? useSignature,
  }) : assert(
         motionIntensity == null ||
             (motionIntensity >= 0 && motionIntensity <= 1),
       ),
       assert(
         radiusScale == null ||
             (radiusScale > 0 && radiusScale < double.infinity),
       ),
       _motionIntensity = motionIntensity,
       _effects = effects,
       _radiusScale = radiusScale,
       _useSignature = useSignature;

  final bool? _useSignature;
  bool get useSignature => _useSignature ?? false;
  final UiGalleryDesignFamily? designFamily;
  final UiGalleryEffects? _effects;
  final double? _radiusScale;
  UiGalleryEffects get effects => _effects ?? UiGalleryEffects.full;
  double get radiusScale => _radiusScale ?? 1;

  /// Shared styles are inherited by all surfaces; component styles refine them.
  final UiGallerySurfaceStyle? surfaceStyle;
  final UiGallerySurfaceStyle? sheetStyle,
      dialogStyle,
      toastStyle,
      appBarStyle,
      bottomNavStyle;

  /// A matching collection without replacing ThemeData or application state.
  /// Set [useSignature] to opt into structural rules, tonal wells or depth cues.
  /// Preset geometry, framed wells, planes and selection affordances win.
  factory UiGalleryTheme.family(
    UiGalleryDesignFamily family, {
    required ThemeData theme,
    UiGalleryEffects effects = UiGalleryEffects.full,
    bool useSignature = false,
  }) {
    final colors = theme.colorScheme;
    final (
      scale,
      spacing,
      elevation,
      entrance,
      exit,
      change,
      curve,
    ) = switch (family) {
      UiGalleryDesignFamily.minimal => (
        .65,
        UiGalleryTokens.space5,
        0.0,
        UiGalleryTokens.minimalEntrance,
        UiGalleryTokens.minimalExit,
        UiGalleryTokens.minimalChange,
        UiGalleryTokens.preciseCurve,
      ),
      UiGalleryDesignFamily.soft => (
        1.0,
        UiGalleryTokens.space6,
        3.0,
        UiGalleryTokens.softEntrance,
        UiGalleryTokens.softExit,
        UiGalleryTokens.softChange,
        UiGalleryTokens.softSpring,
      ),
      UiGalleryDesignFamily.spatial => (
        1.2,
        UiGalleryTokens.space7,
        6.0,
        UiGalleryTokens.spatialEntrance,
        UiGalleryTokens.spatialExit,
        UiGalleryTokens.spatialChange,
        UiGalleryTokens.spatialSpring,
      ),
    };
    return UiGalleryTheme(
      designFamily: family,
      useSignature: useSignature,
      effects: effects,
      radiusScale: scale,
      surfaceStyle: UiGallerySurfaceStyle(
        shadowColor: colors.shadow.withValues(
          alpha: UiGalleryTokens.shadowOpacity,
        ),
        elevation: elevation,
      ),
      sheetStyle: UiGallerySurfaceStyle(padding: EdgeInsets.all(spacing)),
      dialogStyle: UiGallerySurfaceStyle(padding: EdgeInsets.all(spacing)),
      toastStyle: UiGallerySurfaceStyle(padding: UiGalleryTokens.toastPadding),
      // Header and navigation retain their preset silhouettes, including curves.
      appBarStyle: UiGallerySurfaceStyle(
        padding: UiGalleryTokens.headerPadding,
      ),
      bottomNavStyle: UiGallerySurfaceStyle(padding: EdgeInsets.zero),
      motion: UiGalleryMotion(
        curve: curve,
        entrance: entrance,
        exit: exit,
        change: change,
      ),
    );
  }

  UiGallerySurfaceStyle? styleFor(UiGallerySurface? surface) =>
      switch (surface) {
        UiGallerySurface.sheet => sheetStyle,
        UiGallerySurface.dialog => dialogStyle,
        UiGallerySurface.toast => toastStyle,
        UiGallerySurface.appBar => appBarStyle,
        UiGallerySurface.bottomNav => bottomNavStyle,
        null => null,
      };
  final UiGalleryMotion? motion;
  final Color? accentColor;
  final Color? surfaceColor;
  final Color? contentColor;

  /// Zero disables decorative motion; system reduced motion always wins.
  final double? _motionIntensity;
  double get motionIntensity => _motionIntensity ?? 1;

  @override
  UiGalleryTheme copyWith({
    Color? accentColor,
    Color? surfaceColor,
    Color? contentColor,
    double? motionIntensity,
    UiGallerySurfaceStyle? surfaceStyle,
    UiGalleryMotion? motion,
    UiGallerySurfaceStyle? sheetStyle,
    UiGallerySurfaceStyle? dialogStyle,
    UiGallerySurfaceStyle? toastStyle,
    UiGallerySurfaceStyle? appBarStyle,
    UiGallerySurfaceStyle? bottomNavStyle,
    UiGalleryDesignFamily? designFamily,
    UiGalleryEffects? effects,
    double? radiusScale,
    bool? useSignature,
  }) => UiGalleryTheme(
    designFamily: designFamily ?? this.designFamily,
    useSignature: useSignature ?? _useSignature,
    effects: effects ?? _effects,
    radiusScale: radiusScale ?? _radiusScale,
    accentColor: accentColor ?? this.accentColor,
    surfaceColor: surfaceColor ?? this.surfaceColor,
    contentColor: contentColor ?? this.contentColor,
    motionIntensity: motionIntensity ?? _motionIntensity,
    surfaceStyle: surfaceStyle ?? this.surfaceStyle,
    motion: motion ?? this.motion,
    sheetStyle: sheetStyle ?? this.sheetStyle,
    dialogStyle: dialogStyle ?? this.dialogStyle,
    toastStyle: toastStyle ?? this.toastStyle,
    appBarStyle: appBarStyle ?? this.appBarStyle,
    bottomNavStyle: bottomNavStyle ?? this.bottomNavStyle,
  );

  @override
  UiGalleryTheme lerp(covariant UiGalleryTheme? other, double t) {
    if (other == null) return this;
    return UiGalleryTheme(
      designFamily: t < .5 ? designFamily : other.designFamily,
      useSignature: t < .5 ? _useSignature : other._useSignature,
      effects: t < .5 ? _effects : other._effects,
      radiusScale: lerpDouble(radiusScale, other.radiusScale, t),
      accentColor: Color.lerp(accentColor, other.accentColor, t),
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t),
      contentColor: Color.lerp(contentColor, other.contentColor, t),
      motionIntensity: lerpDouble(motionIntensity, other.motionIntensity, t)!,
      surfaceStyle: UiGallerySurfaceStyle.lerp(
        surfaceStyle,
        other.surfaceStyle,
        t,
      ),
      sheetStyle: UiGallerySurfaceStyle.lerp(sheetStyle, other.sheetStyle, t),
      dialogStyle: UiGallerySurfaceStyle.lerp(
        dialogStyle,
        other.dialogStyle,
        t,
      ),
      toastStyle: UiGallerySurfaceStyle.lerp(toastStyle, other.toastStyle, t),
      appBarStyle: UiGallerySurfaceStyle.lerp(
        appBarStyle,
        other.appBarStyle,
        t,
      ),
      bottomNavStyle: UiGallerySurfaceStyle.lerp(
        bottomNavStyle,
        other.bottomNavStyle,
        t,
      ),
      motion: UiGalleryMotion.lerp(motion, other.motion, t),
    );
  }
}

/// Shared geometry and motion values, in logical pixels and milliseconds.
abstract final class UiGalleryTokens {
  static const double space = 8;
  static const double space1 = 4,
      space2 = 8,
      space3 = 12,
      space4 = 16,
      space5 = 20,
      space6 = 24,
      space7 = 28,
      space8 = 32,
      space10 = 40,
      space12 = 48,
      space14 = 56,
      space16 = 64;
  static const double radiusSmall = 8,
      radiusMedium = 16,
      radiusLarge = 24,
      radiusCapsule = 32,
      radiusStage = 52,
      radiusFrame = 4;
  static const double radiusCompact = 10,
      radiusToolbar = 12,
      radiusNotch = 18,
      radiusAction = 20,
      radiusSoft = 22,
      radiusCove = 26,
      radiusPanel = 28,
      radiusOrbitEnd = 36,
      radiusSpotlight = 40,
      radiusOrbitStart = 48,
      tagBevel = 14;
  static const double gapCompact = 6, gapInline = 10, insetHandle = 14;
  static const double revealDistance = 16,
      noticeDistance = 24,
      sideDistance = 20,
      sheetRevealDistance = 12;
  static const Duration minimalEntrance = Duration(milliseconds: 180),
      minimalExit = Duration(milliseconds: 120),
      minimalChange = Duration(milliseconds: 160),
      softEntrance = Duration(milliseconds: 280),
      softExit = Duration(microseconds: 186000),
      softChange = Duration(milliseconds: 220),
      spatialEntrance = Duration(milliseconds: 340),
      spatialExit = Duration(milliseconds: 226),
      spatialChange = Duration(milliseconds: 260);
  static const double markerThickness = 3,
      radiusMarker = 3,
      radiusStep = 6,
      radiusHalo = 21,
      resultMarkSize = 112,
      resultOrbitRadius = 54,
      headerIslandHeight = 80,
      headerSplitHeight = 96,
      headerSearchHeight = 112,
      headerPanoramaHeight = 144,
      headerEditorialHeight = 128,
      headerWaveHeight = 120,
      headerCrestHeight = 168;
  static const double sheetSplitBreakpoint = 500,
      dialogSplitBreakpoint = 480,
      choiceBreakpoint = 380,
      compactHeaderBreakpoint = 84;
  static const double dialogRevealScale = .96,
      sheetRevealScale = .97,
      pulseRevealScale = .94,
      beaconRevealScale = .95;
  static const double lineWidth = 1, accentWidth = 4, baselineHeight = 2;
  static const double signatureEdgeWidth = 3, signatureEdgeInset = 2;
  static const double iconSmall = 16, icon = 24, iconLarge = 32;
  static const double handleWidth = 36, handleHeight = 4;
  static const double glassBlur = 12, glassOpacity = .74;
  static const double shadowOpacity = .18,
      tintOpacity = .08,
      dividerOpacity = .12,
      highContrastDividerOpacity = .45;
  static const double elevationLow = 2,
      elevationMedium = 6,
      elevationHigh = 12,
      cheapElevation = 1;
  static const double ribbonWidth = 560, ribbonActionWidth = 104;
  static const EdgeInsets toastPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  static const EdgeInsets headerPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  static const EdgeInsets surfacePadding = EdgeInsets.all(space6);
  static const EdgeInsets actionPadding = EdgeInsets.all(space5);
  static const Curve preciseCurve = Curves.easeOutQuart;
  static const Curve softSpring = UiGallerySpringCurve(damping: 8);
  static const Curve spatialSpring = UiGallerySpringCurve(
    damping: 7,
    frequency: 8,
  );

  static const double touchTarget = 48;
  static const double sheetWidth = 640;
  static const double dialogWidth = 560;
  static const Duration entrance = Duration(milliseconds: 340);
  static const Duration exit = Duration(milliseconds: 220);
  static const Duration change = Duration(milliseconds: 240);
  static const Curve curve = Curves.easeOutCubic;
}

// Backwards-compatible aliases
typedef NovaTheme = UiGalleryTheme;
typedef NovaTokens = UiGalleryTokens;

// Resolved on every build so host theme and accessibility changes propagate.
class UiGalleryStyle {
  UiGalleryStyle.of(
    BuildContext context, [
    UiGalleryTheme? override,
    UiGallerySurfaceStyle? style,
    UiGalleryMotion? motionOverride,
    UiGallerySurface? surface,
  ]) : theme = Theme.of(context),
       media = MediaQuery.of(context) {
    final ambient = theme.extension<UiGalleryTheme>() ?? const UiGalleryTheme();
    gallery = ambient.copyWith(
      accentColor: override?.accentColor,
      surfaceColor: override?.surfaceColor,
      contentColor: override?.contentColor,
      motionIntensity: override?._motionIntensity,
      designFamily: override?.designFamily,
      effects: override?._effects,
      radiusScale: override?._radiusScale,
      useSignature: override?._useSignature,
    );
    visual = const UiGallerySurfaceStyle()
        .merge(ambient.surfaceStyle)
        .merge(ambient.styleFor(surface))
        .merge(
          UiGallerySurfaceStyle(
            accentColor: override?.accentColor,
            surfaceColor: override?.surfaceColor,
            contentColor: override?.contentColor,
          ),
        )
        .merge(override?.surfaceStyle)
        .merge(override?.styleFor(surface))
        .merge(style);
    motion = const UiGalleryMotion()
        .merge(ambient.motion)
        .merge(override?.motion)
        .merge(motionOverride);
  }

  late final UiGallerySurfaceStyle visual;
  late final UiGalleryMotion motion;
  Curve get curve => motion.curve;
  final ThemeData theme;
  final MediaQueryData media;
  late final UiGalleryTheme gallery;
  Color get accent =>
      visual.accentColor ?? gallery.accentColor ?? theme.colorScheme.primary;
  bool get signatureEnabled =>
      gallery.useSignature && gallery.designFamily != null;
  Color get surface =>
      visual.surfaceColor ??
      gallery.surfaceColor ??
      (signatureEnabled && gallery.designFamily == UiGalleryDesignFamily.soft
          ? theme.colorScheme.surfaceContainerLow
          : theme.colorScheme.surface);
  Color get content =>
      visual.contentColor ??
      gallery.contentColor ??
      theme.colorScheme.onSurface;
  Color get muted => media.highContrast
      ? content
      : Color.alphaBlend(content.withValues(alpha: .68), surface);
  Color get line =>
      visual.borderColor ??
      content.withValues(
        alpha: media.highContrast
            ? UiGalleryTokens.highContrastDividerOpacity
            : UiGalleryTokens.dividerOpacity,
      );
  Color get tinted => Color.alphaBlend(
    accent.withValues(alpha: UiGalleryTokens.tintOpacity),
    surface,
  );
  bool get cheapEffects => gallery.effects == UiGalleryEffects.cheap;
  Color shadowFor(double opacity) =>
      visual.shadowColor ?? theme.colorScheme.shadow.withValues(alpha: opacity);
  double elevation(double fallback) => cheapEffects
      ? math.min(visual.elevation ?? fallback, UiGalleryTokens.cheapElevation)
      : visual.elevation ?? fallback;
  Color foregroundFor(Color background) {
    final colors = theme.colorScheme;
    if (background == colors.error) return colors.onError;
    if (background == colors.tertiary) return colors.onTertiary;
    if (background == colors.secondary) return colors.onSecondary;
    if (background == colors.primary) return colors.onPrimary;
    final candidates = [
      colors.onPrimary,
      colors.onSurface,
      colors.surface,
      colors.inverseSurface,
    ];
    double contrast(Color foreground) {
      final a = foreground.computeLuminance(),
          b = background.computeLuminance();
      return (math.max(a, b) + .05) / (math.min(a, b) + .05);
    }

    return candidates.reduce((a, b) => contrast(a) >= contrast(b) ? a : b);
  }

  /// Families refine corner relationships; explicit caller shapes still win.
  ShapeBorder shape(ShapeBorder preset, {bool preserveRadius = false}) {
    if (visual.shape != null) return visual.shape!;
    final factor = preserveRadius
        ? math.max(1.0, gallery.radiusScale)
        : gallery.radiusScale;
    if (preset is RoundedRectangleBorder) {
      return preset.copyWith(borderRadius: preset.borderRadius * factor);
    }
    if (preset is BeveledRectangleBorder) {
      return preset.copyWith(borderRadius: preset.borderRadius * factor);
    }
    if (preset is UiGalleryCurvedBorder) {
      return UiGalleryCurvedBorder(
        curve: preset.curve,
        edge: preset.edge,
        depth: preset.depth,
        position: preset.position,
        span: preset.span,
        radius: preset.radius * factor,
        side: preset.side,
      );
    }
    return preset;
  }

  TextStyle heading(
    TextStyle? base, {
    bool editorial = false,
    bool monospace = false,
  }) {
    final weight = switch (gallery.designFamily) {
      UiGalleryDesignFamily.minimal =>
        editorial ? FontWeight.w400 : FontWeight.w500,
      UiGalleryDesignFamily.soft =>
        editorial ? FontWeight.w500 : FontWeight.w600,
      UiGalleryDesignFamily.spatial =>
        editorial ? FontWeight.w600 : FontWeight.w700,
      null => base?.fontWeight,
    };
    return (base ?? const TextStyle())
        .copyWith(
          fontWeight: weight,
          fontFamily: monospace ? 'monospace' : base?.fontFamily,
        )
        .merge(visual.titleStyle);
  }

  TextStyle body(TextStyle? base, {bool monospace = false}) =>
      (base ?? const TextStyle())
          .copyWith(fontFamily: monospace ? 'monospace' : base?.fontFamily)
          .merge(visual.messageStyle);

  bool get reduceMotion =>
      media.disableAnimations ||
      media.accessibleNavigation ||
      gallery.motionIntensity == 0 ||
      motion.intensity == 0;
  Duration duration(Duration value) => reduceMotion
      ? Duration.zero
      : Duration(
          microseconds:
              (value.inMicroseconds *
                      gallery.motionIntensity *
                      motion.intensity)
                  .round(),
        );
}

typedef NovaStyle = UiGalleryStyle;

class UiGallerySectionLabel extends StatelessWidget {
  const UiGallerySectionLabel(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: color,
      letterSpacing: 1.6,
      fontWeight: FontWeight.w700,
    ),
  );
}

typedef NovaSectionLabel = UiGallerySectionLabel;
