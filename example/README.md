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

Use `flutter run -d <device-id>` for an available Android or iOS device/simulator. The example's font dependency is confined to this application; the package itself adds no external runtime dependencies.

## Validate

```bash
flutter analyze
flutter test
flutter build web --release --base-href /flutter_ui_gallery/
```

Preview frames help compare layouts, but native keyboard, back navigation, screen-reader and performance checks still require Android/iOS testing. See the [package README](../README.md) for the full validation and release scope.
