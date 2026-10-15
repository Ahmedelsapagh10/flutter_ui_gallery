import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

enum UiGalleryCurve { wave, concave, convex, ribbon }

enum UiGalleryCurveEdge { top, bottom }

/// A bounded Bezier silhouette. [position] follows the reading direction.
/// [dimensions] reserves the curved edge so custom content stays inside it.
@immutable
class UiGalleryCurvedBorder extends ShapeBorder {
  const UiGalleryCurvedBorder({
    this.curve = UiGalleryCurve.wave,
    this.edge = UiGalleryCurveEdge.top,
    this.depth = 16,
    this.position = .5,
    this.span = .5,
    this.radius = 20,
    this.side = BorderSide.none,
  }) : assert(depth >= 0 && depth < double.infinity),
       assert(radius >= 0 && radius < double.infinity),
       assert(position >= 0 && position <= 1),
       assert(span > 0 && span <= 1);

  final UiGalleryCurve curve;
  final UiGalleryCurveEdge edge;
  final double depth, position, span, radius;
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.fromLTRB(
    side.width,
    side.width + (edge == UiGalleryCurveEdge.top ? depth : 0),
    side.width,
    side.width + (edge == UiGalleryCurveEdge.bottom ? depth : 0),
  );

  @override
  ShapeBorder scale(double t) => UiGalleryCurvedBorder(
    curve: curve,
    edge: edge,
    depth: depth * math.max(0, t),
    radius: radius * math.max(0, t),
    position: position,
    span: span,
    side: side.scale(t),
  );

  UiGalleryCurvedBorder _lerp(UiGalleryCurvedBorder other, double t) =>
      UiGalleryCurvedBorder(
        curve: curve,
        edge: edge,
        depth: math.max(0, lerpDouble(depth, other.depth, t)!),
        radius: math.max(0, lerpDouble(radius, other.radius, t)!),
        position: lerpDouble(position, other.position, t)!.clamp(0, 1),
        span: lerpDouble(span, other.span, t)!.clamp(.001, 1),
        side: BorderSide.lerp(side, other.side, t),
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) =>
      a is UiGalleryCurvedBorder && a.curve == curve && a.edge == edge
      ? a._lerp(this, t)
      : super.lerpFrom(a, t);

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) =>
      b is UiGalleryCurvedBorder && b.curve == curve && b.edge == edge
      ? _lerp(b, t)
      : super.lerpTo(b, t);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) return Path();
    final d = depth.clamp(0.0, rect.height / 3);
    final r = radius.clamp(
      0.0,
      math.min(rect.width / 4, (rect.height - d) / 2),
    );
    final raised =
        curve == UiGalleryCurve.convex || curve == UiGalleryCurve.ribbon;
    final y = rect.top + (raised ? d : 0);
    final center = (rect.left + rect.width * position).clamp(
      rect.left + r,
      rect.right - r,
    );
    final half = rect.width * span / 2;
    final start = math.max(rect.left + r, center - half);
    final end = math.min(rect.right - r, center + half);
    final path = Path()
      ..moveTo(rect.left + r, y)
      ..lineTo(start, y);
    switch (curve) {
      case UiGalleryCurve.concave:
        path.cubicTo(
          start + (center - start) * .5,
          y,
          center - (center - start) * .5,
          y + d,
          center,
          y + d,
        );
        path.cubicTo(
          center + (end - center) * .5,
          y + d,
          end - (end - center) * .5,
          y,
          end,
          y,
        );
      case UiGalleryCurve.convex:
        path.cubicTo(
          start + (center - start) * .5,
          y,
          center - (center - start) * .5,
          y - d,
          center,
          y - d,
        );
        path.cubicTo(
          center + (end - center) * .5,
          y - d,
          end - (end - center) * .5,
          y,
          end,
          y,
        );
      case UiGalleryCurve.wave:
        path.cubicTo(
          start + (end - start) * .2,
          y,
          start + (end - start) * .25,
          y + d,
          center,
          y + d * .5,
        );
        path.cubicTo(
          center + (end - center) * .6,
          y,
          end - (end - center) * .2,
          y,
          end,
          y,
        );
      case UiGalleryCurve.ribbon:
        path.cubicTo(
          start + (center - start) * .4,
          y,
          center - (center - start) * .6,
          y - d,
          center,
          y - d,
        );
        path.cubicTo(
          center + (end - center) * .2,
          y - d,
          end - (end - center) * .2,
          y,
          end,
          y,
        );
    }
    path
      ..lineTo(rect.right - r, y)
      ..quadraticBezierTo(rect.right, y, rect.right, y + r)
      ..lineTo(rect.right, rect.bottom - r)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right - r, rect.bottom)
      ..lineTo(rect.left + r, rect.bottom)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - r)
      ..lineTo(rect.left, y + r)
      ..quadraticBezierTo(rect.left, y, rect.left + r, y)
      ..close();
    final transform = Matrix4.identity();
    if (textDirection == TextDirection.rtl) {
      transform
        ..translateByDouble(rect.left + rect.right, 0, 0, 1)
        ..scaleByDouble(-1, 1, 1, 1);
    }
    if (edge == UiGalleryCurveEdge.bottom) {
      transform
        ..translateByDouble(0, rect.top + rect.bottom, 0, 1)
        ..scaleByDouble(1, -1, 1, 1);
    }
    return path.transform(transform.storage);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(side.width), textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    canvas.drawPath(
      getOuterPath(rect.deflate(side.width / 2), textDirection: textDirection),
      side.toPaint(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UiGalleryCurvedBorder &&
      other.curve == curve &&
      other.edge == edge &&
      other.depth == depth &&
      other.position == position &&
      other.span == span &&
      other.radius == radius &&
      other.side == side;

  @override
  int get hashCode =>
      Object.hash(curve, edge, depth, position, span, radius, side);
}

/// Existing shapes keep their original spacing; curved borders reserve depth.
EdgeInsetsGeometry galleryCurveInsets(ShapeBorder? shape) =>
    shape is UiGalleryCurvedBorder ? shape.dimensions : EdgeInsets.zero;
