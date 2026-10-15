import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'gallery_style.dart';

/// Coordinated recipes that retain the application's ColorScheme and fonts.
enum UiGalleryDesignFamily { minimal, soft, spatial }

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
  }) : assert(
         motionIntensity == null ||
             (motionIntensity >= 0 && motionIntensity <= 1),
       ),
       _motionIntensity = motionIntensity;

  /// Shared styles are inherited by all surfaces; component styles refine them.
  final UiGallerySurfaceStyle? surfaceStyle;
  final UiGallerySurfaceStyle? sheetStyle,
      dialogStyle,
      toastStyle,
      appBarStyle,
      bottomNavStyle;

  /// A matching collection without replacing ThemeData or application state.
  factory UiGalleryTheme.family(
    UiGalleryDesignFamily family, {
    required ThemeData theme,
  }) {
    final colors = theme.colorScheme;
    final (radius, spacing, elevation, entrance, change) = switch (family) {
      UiGalleryDesignFamily.minimal => (10.0, 20.0, 0.0, 180, 160),
      UiGalleryDesignFamily.soft => (22.0, 24.0, 3.0, 280, 220),
      UiGalleryDesignFamily.spatial => (28.0, 28.0, 6.0, 340, 260),
    };
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    final heading = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );
    return UiGalleryTheme(
      surfaceStyle: UiGallerySurfaceStyle(
        surfaceColor: colors.surface,
        contentColor: colors.onSurface,
        accentColor: colors.primary,
        borderColor: colors.outlineVariant,
        shadowColor: colors.shadow.withValues(alpha: .18),
        messageStyle: theme.textTheme.bodyMedium,
        elevation: elevation,
      ),
      sheetStyle: UiGallerySurfaceStyle(
        shape: shape,
        padding: EdgeInsets.all(spacing),
        titleStyle: heading,
      ),
      dialogStyle: UiGallerySurfaceStyle(
        shape: shape,
        padding: EdgeInsets.all(spacing),
        titleStyle: heading,
      ),
      toastStyle: UiGallerySurfaceStyle(
        shape: shape,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        titleStyle: theme.textTheme.titleSmall,
      ),
      // Header and navigation retain their preset silhouettes, including curves.
      appBarStyle: UiGallerySurfaceStyle(
        titleStyle: heading,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavStyle: UiGallerySurfaceStyle(
        messageStyle: theme.textTheme.labelSmall,
        padding: EdgeInsets.zero,
      ),
      motion: UiGalleryMotion(
        entrance: Duration(milliseconds: entrance),
        exit: Duration(milliseconds: entrance * 2 ~/ 3),
        change: Duration(milliseconds: change),
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
  }) => UiGalleryTheme(
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
  Color get surface =>
      visual.surfaceColor ?? gallery.surfaceColor ?? theme.colorScheme.surface;
  Color get content =>
      visual.contentColor ??
      gallery.contentColor ??
      theme.colorScheme.onSurface;
  Color get muted => Color.alphaBlend(content.withValues(alpha: .68), surface);
  Color get line =>
      visual.borderColor ??
      content.withValues(alpha: media.highContrast ? .45 : .12);
  Color get tinted => Color.alphaBlend(accent.withValues(alpha: .08), surface);
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
