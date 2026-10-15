import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Partial visual overrides. Unspecified fields inherit the surrounding theme.
@immutable
class UiGallerySurfaceStyle {
  const UiGallerySurfaceStyle({
    this.surfaceColor,
    this.contentColor,
    this.accentColor,
    this.titleStyle,
    this.messageStyle,
    this.shape,
    this.padding,
    this.maxWidth,
    this.elevation,
    this.gradient,
    this.shadowColor,
    this.borderColor,
  }) : assert(maxWidth == null || maxWidth > 0),
       assert(elevation == null || elevation >= 0);
  final Color? surfaceColor,
      contentColor,
      accentColor,
      shadowColor,
      borderColor;
  final TextStyle? titleStyle, messageStyle;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth, elevation;
  final Gradient? gradient;

  /// Copies this configuration, retaining any field not supplied.
  UiGallerySurfaceStyle copyWith({
    Color? surfaceColor,
    Color? contentColor,
    Color? accentColor,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    ShapeBorder? shape,
    EdgeInsetsGeometry? padding,
    double? maxWidth,
    double? elevation,
    Gradient? gradient,
    Color? shadowColor,
    Color? borderColor,
  }) => merge(
    UiGallerySurfaceStyle(
      surfaceColor: surfaceColor,
      contentColor: contentColor,
      accentColor: accentColor,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      shape: shape,
      padding: padding,
      maxWidth: maxWidth,
      elevation: elevation,
      gradient: gradient,
      shadowColor: shadowColor,
      borderColor: borderColor,
    ),
  );

  /// Applies only the specified fields of [other], including partial typography.
  UiGallerySurfaceStyle merge(UiGallerySurfaceStyle? other) {
    if (other == null) return this;
    return UiGallerySurfaceStyle(
      surfaceColor: other.surfaceColor ?? surfaceColor,
      contentColor: other.contentColor ?? contentColor,
      accentColor: other.accentColor ?? accentColor,
      titleStyle: titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      messageStyle:
          messageStyle?.merge(other.messageStyle) ?? other.messageStyle,
      shape: other.shape ?? shape,
      padding: other.padding ?? padding,
      maxWidth: other.maxWidth ?? maxWidth,
      elevation: other.elevation ?? elevation,
      gradient: other.gradient ?? gradient,
      shadowColor: other.shadowColor ?? shadowColor,
      borderColor: other.borderColor ?? borderColor,
    );
  }

  /// Interpolates explicit values. An unspecified endpoint retains inheritance
  /// rather than inventing a zero size or transparent surface.
  static UiGallerySurfaceStyle? lerp(
    UiGallerySurfaceStyle? a,
    UiGallerySurfaceStyle? b,
    double t,
  ) {
    if (t <= 0 || identical(a, b)) return a;
    if (t >= 1) return b;
    if (a == null) return b;
    if (b == null) return a;
    return UiGallerySurfaceStyle(
      surfaceColor: Color.lerp(
        a.surfaceColor ?? b.surfaceColor,
        b.surfaceColor ?? a.surfaceColor,
        t,
      ),
      contentColor: Color.lerp(
        a.contentColor ?? b.contentColor,
        b.contentColor ?? a.contentColor,
        t,
      ),
      accentColor: Color.lerp(
        a.accentColor ?? b.accentColor,
        b.accentColor ?? a.accentColor,
        t,
      ),
      borderColor: Color.lerp(
        a.borderColor ?? b.borderColor,
        b.borderColor ?? a.borderColor,
        t,
      ),
      shadowColor: Color.lerp(
        a.shadowColor ?? b.shadowColor,
        b.shadowColor ?? a.shadowColor,
        t,
      ),
      titleStyle: TextStyle.lerp(
        a.titleStyle ?? b.titleStyle,
        b.titleStyle ?? a.titleStyle,
        t,
      ),
      messageStyle: TextStyle.lerp(
        a.messageStyle ?? b.messageStyle,
        b.messageStyle ?? a.messageStyle,
        t,
      ),
      shape: ShapeBorder.lerp(a.shape ?? b.shape, b.shape ?? a.shape, t),
      padding: EdgeInsetsGeometry.lerp(
        a.padding ?? b.padding,
        b.padding ?? a.padding,
        t,
      ),
      maxWidth: lerpDouble(
        a.maxWidth ?? b.maxWidth,
        b.maxWidth ?? a.maxWidth,
        t,
      ),
      elevation: lerpDouble(
        a.elevation ?? b.elevation,
        b.elevation ?? a.elevation,
        t,
      )?.clamp(0.0, double.infinity),
      gradient: Gradient.lerp(
        a.gradient ?? b.gradient,
        b.gradient ?? a.gradient,
        t,
      ),
    );
  }
}

/// Partial motion overrides; system accessibility settings always take priority.
@immutable
class UiGalleryMotion {
  const UiGalleryMotion({
    Duration? entrance,
    Duration? exit,
    Duration? change,
    Curve? curve,
    double? intensity,
  }) : assert(intensity == null || (intensity >= 0 && intensity <= 1)),
       _entrance = entrance,
       _exit = exit,
       _change = change,
       _curve = curve,
       _intensity = intensity;
  final Duration? _entrance, _exit, _change;
  final Curve? _curve;
  final double? _intensity;
  Duration get entrance => _entrance ?? const Duration(milliseconds: 340);
  Duration get exit => _exit ?? const Duration(milliseconds: 220);
  Duration get change => _change ?? const Duration(milliseconds: 240);
  Curve get curve => _curve ?? Curves.easeOutCubic;
  double get intensity => _intensity ?? 1;

  UiGalleryMotion copyWith({
    Duration? entrance,
    Duration? exit,
    Duration? change,
    Curve? curve,
    double? intensity,
  }) => merge(
    UiGalleryMotion(
      entrance: entrance,
      exit: exit,
      change: change,
      curve: curve,
      intensity: intensity,
    ),
  );

  /// Keeps inherited timings when an override changes only intensity or curve.
  UiGalleryMotion merge(UiGalleryMotion? other) {
    if (other == null) return this;
    return UiGalleryMotion(
      entrance: other._entrance ?? _entrance,
      exit: other._exit ?? _exit,
      change: other._change ?? _change,
      curve: other._curve ?? _curve,
      intensity: other._intensity ?? _intensity,
    );
  }

  static UiGalleryMotion? lerp(
    UiGalleryMotion? a,
    UiGalleryMotion? b,
    double t,
  ) {
    if (t <= 0 || identical(a, b)) return a;
    if (t >= 1) return b;
    a ??= const UiGalleryMotion();
    b ??= const UiGalleryMotion();
    Duration timing(Duration start, Duration end) => Duration(
      microseconds: lerpDouble(
        start.inMicroseconds,
        end.inMicroseconds,
        t,
      )!.round(),
    );
    return UiGalleryMotion(
      entrance: timing(a.entrance, b.entrance),
      exit: timing(a.exit, b.exit),
      change: timing(a.change, b.change),
      intensity: lerpDouble(a.intensity, b.intensity, t)!.clamp(0.0, 1.0),
      curve: identical(a.curve, b.curve)
          ? a.curve
          : _MixedCurve(a.curve, b.curve, t),
    );
  }
}

class _MixedCurve extends Curve {
  const _MixedCurve(this.a, this.b, this.t);
  final Curve a, b;
  final double t;
  @override
  double transformInternal(double value) =>
      lerpDouble(a.transform(value), b.transform(value), t)!;
}
