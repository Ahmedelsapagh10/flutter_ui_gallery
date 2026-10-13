import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Optional overrides. Components otherwise use the surrounding [ThemeData].
@immutable
class UiGalleryTheme extends ThemeExtension<UiGalleryTheme> {
  const UiGalleryTheme({
    this.accentColor,
    this.surfaceColor,
    this.contentColor,
    this.motionIntensity = 1,
  }) : assert(motionIntensity >= 0 && motionIntensity <= 1);

  final Color? accentColor;
  final Color? surfaceColor;
  final Color? contentColor;

  /// Zero disables decorative motion; system reduced motion always wins.
  final double motionIntensity;

  @override
  UiGalleryTheme copyWith({
    Color? accentColor,
    Color? surfaceColor,
    Color? contentColor,
    double? motionIntensity,
  }) => UiGalleryTheme(
    accentColor: accentColor ?? this.accentColor,
    surfaceColor: surfaceColor ?? this.surfaceColor,
    contentColor: contentColor ?? this.contentColor,
    motionIntensity: motionIntensity ?? this.motionIntensity,
  );

  @override
  UiGalleryTheme lerp(covariant UiGalleryTheme? other, double t) {
    if (other == null) return this;
    return UiGalleryTheme(
      accentColor: Color.lerp(accentColor, other.accentColor, t),
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t),
      contentColor: Color.lerp(contentColor, other.contentColor, t),
      motionIntensity: lerpDouble(motionIntensity, other.motionIntensity, t)!,
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
  UiGalleryStyle.of(BuildContext context, [UiGalleryTheme? override])
    : theme = Theme.of(context),
      media = MediaQuery.of(context),
      gallery =
          override ??
          Theme.of(context).extension<UiGalleryTheme>() ??
          const UiGalleryTheme();

  final ThemeData theme;
  final MediaQueryData media;
  final UiGalleryTheme gallery;
  Color get accent => gallery.accentColor ?? theme.colorScheme.primary;
  Color get surface => gallery.surfaceColor ?? theme.colorScheme.surface;
  Color get content => gallery.contentColor ?? theme.colorScheme.onSurface;
  Color get muted => Color.alphaBlend(content.withValues(alpha: .68), surface);
  Color get line => content.withValues(alpha: media.highContrast ? .45 : .12);
  Color get tinted => Color.alphaBlend(accent.withValues(alpha: .08), surface);
  bool get reduceMotion =>
      media.disableAnimations ||
      media.accessibleNavigation ||
      gallery.motionIntensity == 0;
  Duration duration(Duration value) => reduceMotion
      ? Duration.zero
      : Duration(
          microseconds: (value.inMicroseconds * gallery.motionIntensity)
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
