# Integrating the gallery

Add the package to your existing Flutter application and import `package:flutter_ui_gallery/flutter_ui_gallery.dart`. Keep your current state management, dependency injection, repositories and navigation setup.

## Theme and component overrides

Create `UiGalleryTheme.family(UiGalleryDesignFamily.soft, theme: yourTheme)` and add it to the host theme's extensions alongside existing extensions. Minimal, Soft and Spatial use the host ColorScheme and text styles.

Resolution order is shared theme style, component theme style, local appearance and per-call style. Unspecified fields inherit, including individual TextStyle properties and motion timings. Use `sheetStyle`, `dialogStyle`, `toastStyle`, `appBarStyle` and `bottomNavStyle` for component defaults. Use `copyWith` to retain other properties and `merge` to apply partial surface or motion overrides. System accessibility settings override decorative motion.

## State and navigation

Pass the selected navigation index and handle destination changes in your existing controller. Keep destination widgets mounted with your application's existing stack/router when drafts and scroll offsets must survive. The package does not create destination state or decide back-button behavior.

Sheets and dialogs return typed route results. Perform mutations through the application's controller after checking that the initiating page remains mounted. Use the modal's context to dismiss it, and choose `useRootNavigator` according to your navigator hierarchy. Localize titles, action labels, search hints and selection counts in the host application.

## Async operations

Drive timeline and progress toast notifiers from real operation callbacks. The caller owns the notifier, cancellation and errors. Dismiss the toast before disposing its notifier. Treat cancellation as a request until the operation acknowledges it, and guard late callbacks after page disposal or a newer request.

## Working examples

[`example/lib/gallery/recipes.dart`](../example/lib/gallery/recipes.dart) contains three page-owned examples:

- Productivity: retained search, typed commands, validated creation, selection, confirmation and archive/undo.
- Shopping: retained basket, recipient validation, progress, cooperative cancellation, failure and retry. Supply `ShoppingExample.prepare` to connect your operation.
- Dashboard: loading, data, empty, failure, retry and refresh. Supply `DashboardExample.load` to connect your repository.

The defaults use local sample data. No network endpoint or backend behavior is assumed. The example tests inject pending, failing and successful operations to verify these states.

Open **Real app examples** in the [playground](https://ahmedelsapagh10.github.io/flutter_ui_gallery/). Use **Share configuration** to preserve a preset, design family, appearance, text and motion settings in a URL. Generated code includes the matching theme factory; apply it to your own MaterialApp theme and retain your other extensions.
