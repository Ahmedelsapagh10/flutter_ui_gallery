# Opt-in family signatures

The existing family API accepts `useSignature: true`. It defaults to false; applications using the existing API retain their appearance. This is a recipe inside the existing theme/resolver, not another theme system.

```dart
final base = ThemeData(colorSchemeSeed: const Color(0xff455a64));
final themed = base.copyWith(extensions: [
  UiGalleryTheme.family(
    UiGalleryDesignFamily.spatial,
    theme: base,
    useSignature: true,
    effects: UiGalleryEffects.cheap,
  ),
]);
```

Minimal adds structural rules to content regions. Soft connects content with a ColorScheme tonal well. Spatial registers a flat bottom/end edge on the existing content surface. It adds no content plane or content shadow; cheap mode carries the same structural cue. Preset-owned elevation can still differ between effects modes. Existing family heading weights, curves and geometry refinement still apply. Rules use the resolver's line, including high-contrast fallback. Selection fills, meaningful status colors and controlled inputs remain visible under Minimal.

## Precedence and exceptions

A preset's structural signature always wins. Family wrappers treat content or paint inside an existing surface; they never replace its outer shape, clip path, hit targets, ordering or typography role. The following exceptions are exercised for every family in `test/family_signature_test.dart`:

- Sheets `stackPanel`, `depthFrame`, `prism`: keep their existing exposed planes/frame; No family replaces those outer structures; edge-only Spatial requires no plane exception. Minimal keeps Stack Panel's two backing planes.
- Sheet `neoTray`: Soft's content well remains square inside the preset's framed tray. All other sheets retain their prescribed outer radii, including `orbit` asymmetry and `edgeLift` square corners.
- Dialogs `spotlight`, `orbitConfirm`: keep their own depth emphasis; Spatial adds only a flat content edge. `panelDecision` keeps Soft’s framed region square. `sideBySideChoice` retains the separate choice controls outside the content treatment.
- Toasts `stackTag`, `signal`, `miniConsole`: keep the directional bevel, capsule and square monospace console respectively. Family marks treat the leading symbol, never the silhouette or status text. `action` retains its capsule and adds its own recovery segment only when opted in.
- App bars `editorialTopbar`: keep the editorial rule and lighter heading; Minimal does not draw a second rule. `sculptedWave`, `foldedCanopy`, `parallaxCrest`, `orbitCommand`: keep their own depth geometry instead of an additional registered edge. These policies also apply to sliver app bars.
- Navigation `concaveNotch`, `splitIsland`: preserve the notch/action gap; no generic depth edge crosses it. `orbitDock`, `layeredShelf`, `perspectiveDock`: retain their own backing planes; cheap effects keep these flat when opted in. Other paths are used to clip the family edge, including curves. `morphingCapsule` retains its selected capsule. `overflowDock` retains its existing scrolling/overflow composition without an extra family edge that could obscure its boundary; it still receives resolver colors, type and family motion.

### Exception budget (66 presets)

The executable registry is `lib/src/core/gallery_signature_exceptions.dart`; component policies reference its sets. Count each preset once per family, regardless of how many surfaces it owns:

- Minimal: **3/66 (4.5%)** — `UiGallerySheetPreset.stackPanel`, `UiGalleryAppBarPreset.editorialTopbar`, `UiGalleryBottomNavPreset.overflowDock`.
- Soft: **3/66 (4.5%)** — `UiGallerySheetPreset.neoTray`, `UiGalleryDialogPreset.panelDecision`, `UiGalleryBottomNavPreset.overflowDock`.
- Spatial: **10/66 (15.2%)** — four app-bar depth structures (`sculptedWave`, `foldedCanopy`, `parallaxCrest`, `orbitCommand`), five nav paths/planes (`concaveNotch`, `splitIsland`, `orbitDock`, `layeredShelf`, `perspectiveDock`) and `overflowDock` nav composition.

That is **14 distinct presets**, or **16 preset/family pairs**. The cross-family union is 21.2%; the budget applies separately to each family. Minimal’s Stack Panel guarantee is conservatively counted even though the generic content-only rule already preserves its outer planes. Generic silhouette/type/choice guarantees and Notes-specific redesigns are not bespoke family exceptions.

The approved softened Spatial rule removes seven exceptions: `stackPanel`, `depthFrame`, `prism` sheets; `spotlight`, `orbitConfirm` dialogs; and Spatial’s `neoTray`/`panelDecision` square content-plane treatments. All their structural tests remain. Edge-only content painting requires no fill/radius/frame exclusion. Every family is now below 25%. The pre-application 15-cell comparison used cheap effects for all columns and confirmed distinguishability from Soft through the unfilled registered edge versus Soft’s tonal well in light, dark and RTL.


Each named exception has a per-preset/per-family widget case in `test/family_signature_test.dart`; Stack Panel additionally checks its exposed plane and Neo Tray checks the square bordered well. A registry budget test guards these counts. The default, opt-out appearance remains covered by the unchanged original 24 golden comparisons and SHA-256 guard.

Explicit caller styles continue to override resolver defaults. The opt-in flag survives `copyWith`, interpolation and local theme merging. No enums, dependencies or SDK floors change.

## Visual baseline procedure

The 24 approved pre-Notes goldens are protected by `test/goldens/legacy_manifest.json`. Run `python3 tool/check_golden_hashes.py` before and after any capture; CI runs it too. Never rewrite that manifest as part of a visual update.

New Notes baselines use Flutter **3.41.9**, Dart **3.11.5**, DPR 1 and pinned font bytes in `example/test/goldens/notes-pass-a/pins.json`. Roboto/Material Icons come from that SDK; the Arabic example bundles Alexandria under its included OFL license. `python3 tool/check_notes_pins.py` verifies SDK and all three hashes. The SDK pin is a render-toolchain constraint, not a package SDK-floor change. New baselines use real shadows, deterministic reduced motion and local sample data. Render on the pinned macOS CI environment.

After explicit visual review, update only the named new fixture from `example/`:

```sh
flutter test test/notes_preset_goldens_test.dart --update-goldens
flutter test test/notes_test.dart --plain-name 'Margin light app specimen' --update-goldens
```

The first command targets the two redesigned presets: Orbit Dock **sheet** and Action Capsule **toast**, each with all three families × light/dark/Arabic RTL/2.0 text = 12 cells. For a single cell use `--plain-name` as well. The second illustrates updating one app specimen. Do not use a blanket `--update-goldens`. Re-run without the update flag, check all diffs, then run the 24-file hash guard. The current-stable CI leg skips tagged visual baselines; pinned CI compares them. Python 3 is required for the read-only guards.


## Arabic example font

The production Arabic example font is **Alexandria**, bundled only at `example/assets/fonts/Alexandria.ttf` and registered as `MarginArabic` in the example pubspec. The package has no font asset or dependency. Its SHA-256 is `db8ae03b62d55a65aa4e04307878df8c00d6e5388e4800635cbe0e22b6411b64`; the included OFL license permits redistribution. Both the example app and current RTL review captures use these pinned bytes. Arial remains confined to historical preview artifacts and is not a production fallback or a font used by the new Notes baselines.


## Versioned changes after Pass A

The 29 original Notes Pass A PNGs are additionally protected by `example/test/goldens/notes-pass-a/approved_manifest.json`; the same hash guard checks them. The eight Spatial specimens affected by the approved edge-only recipe are compared against **new** files in `example/test/goldens/spatial-edge/`. The old eight remain unchanged as historical evidence. Minimal and Soft still compare against the original Pass A files. This is an explicit versioned change, not a regeneration of existing goldens.

Pass B adds two redesigned presets, `UiGalleryDialogPreset.split` and `UiGalleryBottomNavPreset.layeredShelf`, each with its own three-family × four-environment gate in `example/test/goldens/notes-pass-b/`. Eight additional app views cover phone and tablet under light/dark/Arabic RTL/2.0. All use the same SDK and font pin manifest as Notes Pass A. To update a reviewed Pass B cell, target `test/notes_pass_b_goldens_test.dart --plain-name '<exact test name>' --update-goldens` from `example/`; never update the whole repository.
