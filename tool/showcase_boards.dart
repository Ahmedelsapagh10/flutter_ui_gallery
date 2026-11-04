import 'dart:ui' as ui;
import 'package:flutter/material.dart';

const recommended = {
  'header.searchSwitch',
  'toasts.action',
  'sheets.orbit',
  'dialogs.sideBySideChoice',
  'bottomNav.morphingCapsule',
};
const showcaseGroups = {
  'tile-app-bars': ['header.searchSwitch'],
  'tile-toasts': ['toasts.action'],
  'tile-bottom-sheets': ['sheets.orbit'],
  'tile-dialogs': ['dialogs.sideBySideChoice'],
  'tile-bottom-navigation': ['bottomNav.morphingCapsule'],
  'app-bars': [
    'header.searchSwitch',
    'header.editorialTopbar',
    'header.sculptedWave',
  ],
  'toasts': ['toasts.action', 'toasts.progressCard', 'toasts.miniConsole'],
  'bottom-sheets': ['sheets.orbit', 'sheets.splitLayer', 'sheets.depthFrame'],
  'dialogs': [
    'dialogs.sideBySideChoice',
    'dialogs.commandPalette',
    'dialogs.spotlight',
  ],
  'bottom-navigation': [
    'bottomNav.morphingCapsule',
    'bottomNav.layeredShelf',
    'bottomNav.glassDock',
  ],
  'hero': [
    'header.searchSwitch',
    'toasts.action',
    'sheets.orbit',
    'dialogs.sideBySideChoice-dark',
    'bottomNav.morphingCapsule',
  ],
};
const titles = {
  'app-bars': ('App Bars', '17 presets · Give every screen a point of view.'),
  'toasts': ('Toasts', '11 presets · Small moments of clarity.'),
  'bottom-sheets': (
    'Bottom Sheets',
    '12 presets · Keep the next action within reach.',
  ),
  'dialogs': ('Dialogs', '11 presets · Make the next decision feel clear.'),
  'bottom-navigation': (
    'Bottom Navigation',
    '15 presets · A beautiful way to find your way.',
  ),
};
const labels = {
  'header.searchSwitch': 'Search Switch',
  'header.editorialTopbar': 'Editorial Topbar',
  'header.sculptedWave': 'Sculpted Wave',
  'toasts.action': 'Action Capsule',
  'toasts.progressCard': 'Progress Card',
  'toasts.miniConsole': 'Mini Console',
  'sheets.orbit': 'Orbit Dock',
  'sheets.splitLayer': 'Split Layer',
  'sheets.depthFrame': 'Depth Frame',
  'dialogs.sideBySideChoice': 'Side-by-Side Choice',
  'dialogs.commandPalette': 'Command Palette',
  'dialogs.spotlight': 'Spotlight Result',
  'bottomNav.morphingCapsule': 'Morphing Capsule',
  'bottomNav.layeredShelf': 'Layered Shelf',
  'bottomNav.glassDock': 'Glass Dock',
};
const ink = Color(0xff092d3c);
const teal = Color(0xff007f88);

class ShowcaseBoard extends StatelessWidget {
  const ShowcaseBoard({super.key, required this.group, required this.images});
  final String group;
  final Map<String, ui.Image> images;

  Widget _capture(String id, {bool hero = false}) {
    final category = id.split('.').first;
    final rect = switch (category) {
      'header' => const Rect.fromLTWH(0, 0, 660, 390),
      'toasts' => const Rect.fromLTWH(0, 575, 660, 265),
      'bottomNav' => const Rect.fromLTWH(0, 730, 660, 110),
      'sheets' => const Rect.fromLTWH(0, 120, 660, 720),
      _ => const Rect.fromLTWH(0, 100, 660, 640),
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: CustomPaint(
        painter: _CapturePainter(images[id]!, rect),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _card(String id, {bool hero = false}) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: const Color(0xffdcebee)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0e123746),
          blurRadius: 24,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _capture(id, hero: hero)),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 5),
            child: Text(
              labels[id.replaceAll('-dark', '')]!,
              style: const TextStyle(
                color: ink,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xffedf8fa),
    body: group.startsWith('tile-')
        ? _tile()
        : group == 'hero'
        ? _hero()
        : Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FLUTTER UI GALLERY',
                  style: TextStyle(color: teal, fontSize: 13, letterSpacing: 2),
                ),
                const SizedBox(height: 14),
                Text(
                  titles[group]!.$1,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  titles[group]!.$2,
                  style: const TextStyle(
                    color: Color(0xff456575),
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final id in showcaseGroups[group]!)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _card(id),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
  );

  Widget _tile() {
    final slug = group.substring(5);
    final id = showcaseGroups[group]!.single;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _capture(id)),
          const SizedBox(height: 10),
          Text(
            titles[slug]!.$1,
            maxLines: 1,
            style: const TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            titles[slug]!.$2.split(' · ').first,
            style: const TextStyle(color: teal, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _hero() => Stack(
    children: [
      Positioned(
        left: 48,
        top: 56,
        width: 380,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FLUTTER UI GALLERY',
              style: TextStyle(
                color: teal,
                letterSpacing: 2,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Beautiful\nFlutter\ncomponents.',
              style: TextStyle(
                color: ink,
                fontSize: 60,
                height: 1.07,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Ready to use.',
              style: TextStyle(
                color: teal,
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Real widgets. Thoughtful details.\nYour theme, your state, your app.',
              style: TextStyle(
                color: Color(0xff456575),
                fontSize: 20,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 34),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xffcce3e8)),
              ),
              child: const Text(
                '66 presets   /   5 categories',
                style: TextStyle(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'APP BARS · TOASTS · SHEETS\nDIALOGS · BOTTOM NAVIGATION',
              style: TextStyle(
                color: teal,
                fontSize: 12,
                height: 1.8,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      Positioned(
        left: 465,
        top: 42,
        width: 430,
        height: 268,
        child: _card('header.searchSwitch', hero: true),
      ),
      Positioned(
        left: 915,
        top: 42,
        width: 440,
        height: 220,
        child: _card('toasts.action', hero: true),
      ),
      Positioned(
        left: 465,
        top: 330,
        width: 430,
        height: 385,
        child: _card('sheets.orbit', hero: true),
      ),
      Positioned(
        left: 915,
        top: 282,
        width: 440,
        height: 290,
        child: _card('dialogs.sideBySideChoice-dark', hero: true),
      ),
      Positioned(
        left: 915,
        top: 580,
        width: 440,
        height: 143,
        child: _card('bottomNav.morphingCapsule', hero: true),
      ),
    ],
  );
}

class _CapturePainter extends CustomPainter {
  _CapturePainter(this.image, this.source);
  final ui.Image image;
  final Rect source;
  @override
  void paint(Canvas canvas, Size size) {
    final fit = applyBoxFit(BoxFit.contain, source.size, size);
    final destination = Alignment.center.inscribe(
      fit.destination,
      Offset.zero & size,
    );
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(_CapturePainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.source != source;
}
