# Flutter UI Gallery — Interactive Playground

The example application for `flutter_ui_gallery`, covering all **66 presets**: 12 bottom sheets, 11 dialogs, 11 toasts, 17 app bars and 15 bottom navigation bars.

## Explore the components

- Start with **Recommended** for eight everyday presets, or **Browse by task** for actions, search, bulk selection, confirmations, progress, navigation and feedback.
- Compare **Minimal**, **Soft** and **Spatial** families with light/dark appearance, accent palettes and custom hex colors.
- Preview Phone (390dp), Tablet (768dp) and Wide (1200dp) layouts, Arabic/RTL, reduced motion, editable titles/messages and motion controls.
- Run each live scenario, then copy the generated public-API snippet and matching family setup.
- Use **Share configuration** to copy a browser link containing the selected preset and playground settings. Opening it restores those settings; local native runs generate links for the public gallery.

The public gallery URL is [ahmedelsapagh10.github.io/flutter_ui_gallery](https://ahmedelsapagh10.github.io/flutter_ui_gallery/). Deployment is managed by the repository's GitHub Pages workflow.

## Real app examples

Open **Real app examples** from the toolbar:

- **Notes · Margin (Pass A)** uses eight presets for notebook editing, commands, selection and archive/undo. It includes real Arabic copy, light/dark, 2.0 text, reduced motion, a wide reading pane and a clearly labeled Navigation style showcase setting. Its briefs are in [Notes Pass A](../doc/NOTES_PASS_A.md).
- **Productivity** combines search, typed commands, validated note creation, bulk selection, confirmation and archive/undo.
- **Shopping** retains its basket while navigating, validates the recipient, runs cancellable preparation with progress, and handles failure/retry.
- **Dashboard** handles loading, metrics, empty results, errors, refresh and retry.

These pages use local sample data and page-owned state. `ShoppingExample.prepare` and `DashboardExample.load` accept asynchronous callbacks so the examples can exercise actual operations, errors and empty results. They do not call a backend. Read [integration guidance](../doc/INTEGRATION.md) before adapting them to an existing repository or controller.

## Run locally

From this directory:

```bash
flutter pub get
flutter run -d chrome
```

Use `flutter run -d <device-id>` for an available Android or iOS device/simulator. The web example loads its display fonts through Google Fonts; Margin bundles Alexandria (OFL) for deterministic Arabic rendering on native and web; the other native examples use platform fallbacks. The package itself adds no external runtime dependencies.

## Validate

```bash
flutter analyze
flutter test
flutter build web --release --base-href /flutter_ui_gallery/
```

Preview frames help compare layouts, but native keyboard, back navigation, screen-reader and performance checks still require Android/iOS testing. See the [package README](../README.md) for the full validation and release scope.


Margin **Notes Pass B** is a separate entry under Real app examples, retaining Pass A for comparison. It adds an Edge Lift note-action shelf (move/save/archive), a Split Decision guard for unsaved drafts, local-save Inline Pulse feedback, persistent Focus Bar search and Layered Shelf/Scroll Dock navigation choices. Header and navigation style settings are explicitly showcase controls. [Read the six briefs and direction choices](../doc/NOTES_PASS_B.md). Data remains local to the session.

The approved Spatial recipe is now edge-only, with the same flat structural cue in cheap mode and no extra content plane. [Precedence exceptions and revised budget](../doc/FAMILY_SIGNATURES.md) record Minimal 3/66, Soft 3/66 and Spatial 10/66 (14 distinct presets). Existing opt-out family behavior is unchanged.


**Wallet · Still (Pass A)** is available under Real app examples: local single-currency accounts, same-currency transfer drafts, editable ledger categories and cancellable in-memory statement previews. Sample money only; no bank API, FX total, executed payment or file-save claim. Light/dark, Arabic with the example-only Alexandria font, 2.0 text, reduced motion and tablet layouts are included. [Seven briefs and Pass B boundary](../doc/WALLET_PASS_A.md). [Per-preset redesign default/migration proposal and CI evidence](../doc/REDESIGN_RELEASE_POLICY.md).
