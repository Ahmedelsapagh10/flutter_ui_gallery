import 'package:flutter/material.dart';

enum DesignCategory { sheets, dialogs, toasts, header }

class SurfaceDesign {
  const SurfaceDesign(
    this.name,
    this.category,
    this.tagline,
    this.useCase,
    this.icon,
  );
  final String name;
  final DesignCategory category;
  final String tagline;
  final String useCase;
  final IconData icon;
}

const designs = [
  SurfaceDesign(
    'Orbit Dock',
    DesignCategory.sheets,
    'A little space. A lot of possibility.',
    'Quick actions, sharing and contextual tools. A floating asymmetric dock keeps actions close without taking over the screen.',
    Icons.space_dashboard_outlined,
  ),
  SurfaceDesign(
    'Fold Motion',
    DesignCategory.sheets,
    'Details, at your own pace.',
    'Descriptions, options and forms. Start with a compact peek, then unfold the same content without losing your place.',
    Icons.unfold_more_rounded,
  ),
  SurfaceDesign(
    'Prism Stage',
    DesignCategory.sheets,
    'Give the important thing a stage.',
    'Product previews and booking details. A framed showcase and separate action zone give content a clear hierarchy.',
    Icons.crop_portrait_rounded,
  ),
  SurfaceDesign(
    'Flow Canvas',
    DesignCategory.sheets,
    'One task. A continuous journey.',
    'Selections, checkout and onboarding. A spatial progress track connects steps while keeping forms mounted.',
    Icons.linear_scale_rounded,
  ),
  SurfaceDesign(
    'Halo Focus',
    DesignCategory.dialogs,
    'Make the next move feel clear.',
    'Important decisions. A quiet composition surrounds the primary action with a fine halo of emphasis.',
    Icons.radio_button_checked_rounded,
  ),
  SurfaceDesign(
    'Split Decision',
    DesignCategory.dialogs,
    'Two regions. One deliberate choice.',
    'Discard, delete and account actions. Information and decisions occupy distinct regions that stack on smaller screens.',
    Icons.call_split_rounded,
  ),
  SurfaceDesign(
    'Timeline Dialog',
    DesignCategory.dialogs,
    'See where you are. Know what comes next.',
    'Verification and processing. A compact sequence reflects real progress supplied by your application.',
    Icons.route_outlined,
  ),
  SurfaceDesign(
    'Spotlight Result',
    DesignCategory.dialogs,
    'An ending with a little presence.',
    'Payment and task results. An orbital mark makes success, warning and failure easy to recognize without visual noise.',
    Icons.check_circle_outline_rounded,
  ),
  SurfaceDesign(
    'Signal Pill',
    DesignCategory.toasts,
    'Small signal. Perfect timing.',
    'Saved changes and short status updates. A compact capsule adapts to the message and leaves the screen open.',
    Icons.more_horiz_rounded,
  ),
  SurfaceDesign(
    'Edge Ribbon',
    DesignCategory.toasts,
    'A message with direction.',
    'Warnings and connection errors. An edge-aligned accent distinguishes information that deserves attention.',
    Icons.horizontal_rule_rounded,
  ),
  SurfaceDesign(
    'Action Capsule',
    DesignCategory.toasts,
    'A second chance, within reach.',
    'Undo and retry. A coordinated message/action surface includes an optional timeout track and accessible dismissal.',
    Icons.undo_rounded,
  ),
  SurfaceDesign(
    'Adaptive Horizon',
    DesignCategory.header,
    'A header that follows your focus.',
    'Explore and content screens. A title settles into a compact position as you scroll, using Scaffold’s existing notifications.',
    Icons.view_day_outlined,
  ),
];
