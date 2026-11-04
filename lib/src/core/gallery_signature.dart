import 'package:flutter/material.dart';
import 'gallery_theme.dart';

/// A content-zone treatment; never replaces a preset's outer shape or controls.
class GalleryFamilyRegion extends StatelessWidget {
  const GalleryFamilyRegion({
    super.key,
    required this.style,
    required this.child,
    this.framed = false,
  });
  final UiGalleryStyle style;
  final Widget child;
  final bool framed;
  @override
  Widget build(BuildContext context) {
    if (!style.signatureEnabled) return child;
    if (style.gallery.designFamily == UiGalleryDesignFamily.spatial) {
      return GalleryFamilyEdge(
        style: style,
        child: Padding(
          padding: const EdgeInsets.all(UiGalleryTokens.space3),
          child: child,
        ),
      );
    }
    final soft = style.gallery.designFamily == UiGalleryDesignFamily.soft;
    final ink = soft
        ? style.theme.colorScheme.onPrimaryContainer
        : style.content;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: soft ? style.theme.colorScheme.primaryContainer : null,
        border: !soft
            ? Border(
                top: BorderSide(color: style.line),
                bottom: BorderSide(color: style.line),
              )
            : null,
        borderRadius: soft && !framed
            ? BorderRadius.circular(UiGalleryTokens.radiusSmall)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(UiGalleryTokens.space3),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: ink),
          child: IconTheme.merge(
            data: IconThemeData(color: ink),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GalleryFamilyMark extends StatelessWidget {
  const GalleryFamilyMark({
    super.key,
    required this.style,
    required this.child,
  });
  final UiGalleryStyle style;
  final Widget child;
  @override
  Widget build(BuildContext context) => !style.signatureEnabled
      ? child
      : GalleryFamilyRegion(style: style, child: child);
}

/// Paints a flat registered edge inside the reserved surface bounds.
/// Controls and curved/notched hit paths are never transformed.
class GalleryFamilyEdge extends StatelessWidget {
  const GalleryFamilyEdge({
    super.key,
    required this.style,
    required this.child,
    this.ownsRule = false,
    this.ownsDepth = false,
    this.shape,
  });
  final UiGalleryStyle style;
  final Widget child;
  final bool ownsRule, ownsDepth;
  final ShapeBorder? shape;
  @override
  Widget build(BuildContext context) {
    if (!style.signatureEnabled) return child;
    return CustomPaint(
      foregroundPainter: _FamilyEdgePainter(
        style,
        Directionality.of(context),
        ownsRule,
        ownsDepth,
        shape,
      ),
      child: child,
    );
  }
}

class _FamilyEdgePainter extends CustomPainter {
  _FamilyEdgePainter(
    this.style,
    this.direction,
    this.ownsRule,
    this.ownsDepth,
    this.shape,
  );
  final UiGalleryStyle style;
  final TextDirection direction;
  final bool ownsRule, ownsDepth;
  final ShapeBorder? shape;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    if (shape != null) {
      canvas.clipPath(
        shape!.getOuterPath(Offset.zero & size, textDirection: direction),
      );
    }
    final family = style.gallery.designFamily;
    if (family == UiGalleryDesignFamily.minimal && !ownsRule) {
      canvas.drawLine(
        Offset(0, size.height - UiGalleryTokens.lineWidth),
        Offset(size.width, size.height - UiGalleryTokens.lineWidth),
        Paint()..color = style.line,
      );
    } else if (family == UiGalleryDesignFamily.spatial && !ownsDepth) {
      final paint = Paint()
        ..color = style.media.highContrast
            ? style.line
            : style.theme.colorScheme.secondaryContainer;
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          size.height - UiGalleryTokens.signatureEdgeWidth * 2,
          size.width,
          UiGalleryTokens.signatureEdgeWidth,
        ),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          direction == TextDirection.rtl
              ? UiGalleryTokens.signatureEdgeInset
              : size.width -
                    UiGalleryTokens.signatureEdgeInset -
                    UiGalleryTokens.signatureEdgeWidth,
          0,
          UiGalleryTokens.signatureEdgeWidth,
          size.height - UiGalleryTokens.signatureEdgeWidth,
        ),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FamilyEdgePainter old) =>
      old.style != style ||
      old.direction != direction ||
      old.ownsRule != ownsRule ||
      old.ownsDepth != ownsDepth ||
      old.shape != shape;
}

/// A connected control well inside a preset's existing bounds.
class GalleryFamilyWell extends StatelessWidget {
  const GalleryFamilyWell({
    super.key,
    required this.style,
    required this.child,
  });
  final UiGalleryStyle style;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (!style.signatureEnabled ||
        style.gallery.designFamily != UiGalleryDesignFamily.soft) {
      return child;
    }
    final colors = style.theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(UiGalleryTokens.radiusSmall),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.onPrimaryContainer),
        child: child,
      ),
    );
  }
}
