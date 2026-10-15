import 'package:flutter/material.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

/// Validated, portable playground settings; no platform-specific browser APIs.
@immutable
class PlaygroundConfiguration {
  const PlaygroundConfiguration({
    this.preset = 'sheets.orbit',
    this.family = UiGalleryDesignFamily.soft,
    this.dark = false,
    this.rtl = false,
    this.reduced = false,
    this.accent = const Color(0xff4f46e5),
    this.width = 390,
    this.title = 'Make it your space',
    this.message = 'Choose what happens next.',
    this.transitionMs,
    this.curveDepth,
    this.depthIntensity = 1,
  });
  final String preset, title, message;
  final UiGalleryDesignFamily family;
  final bool dark, rtl, reduced;
  final Color accent;
  final double width, depthIntensity;
  final double? transitionMs, curveDepth;

  factory PlaygroundConfiguration.fromUri(Uri uri) {
    Map<String, String> values;
    try {
      values = uri.fragment.contains('?')
          ? Uri.parse(uri.fragment).queryParameters
          : uri.queryParameters;
    } on FormatException {
      return const PlaygroundConfiguration();
    }
    double? bounded(String key, double min, double max) {
      final value = double.tryParse(values[key] ?? '');
      return value != null && value.isFinite && value >= min && value <= max
          ? value
          : null;
    }

    final hex = values['accent'] ?? '';
    final argb = RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)
        ? int.tryParse('ff$hex', radix: 16)
        : null;
    final family = UiGalleryDesignFamily.values
        .where((family) => family.name == values['family'])
        .firstOrNull;
    final width = double.tryParse(values['width'] ?? '');
    return PlaygroundConfiguration(
      preset: values['preset'] ?? 'sheets.orbit',
      family: family ?? UiGalleryDesignFamily.soft,
      dark: values['dark'] == '1',
      rtl: values['rtl'] == '1',
      reduced: values['reduced'] == '1',
      accent: argb == null ? const Color(0xff4f46e5) : Color(argb),
      width: const [390.0, 768.0, 1200.0].contains(width) ? width! : 390,
      title: (values['title'] ?? 'Make it your space').characters
          .take(200)
          .toString(),
      message: (values['message'] ?? 'Choose what happens next.').characters
          .take(1000)
          .toString(),
      transitionMs: bounded('duration', 120, 600),
      curveDepth: bounded('curve', 0, 28),
      depthIntensity: bounded('depth', 0, 1) ?? 1,
    );
  }

  Uri toUri(Uri base) => base.replace(
    fragment: Uri(
      path: '/',
      queryParameters: {
        'preset': preset,
        'family': family.name,
        'accent': accent
            .toARGB32()
            .toRadixString(16)
            .padLeft(8, '0')
            .substring(2),
        'dark': dark ? '1' : '0',
        'rtl': rtl ? '1' : '0',
        'reduced': reduced ? '1' : '0',
        'width': width.round().toString(),
        'title': title,
        'message': message,
        if (transitionMs != null) 'duration': transitionMs!.toString(),
        if (curveDepth != null) 'curve': curveDepth!.toString(),
        'depth': depthIntensity.toString(),
      },
    ).toString(),
  );
}
