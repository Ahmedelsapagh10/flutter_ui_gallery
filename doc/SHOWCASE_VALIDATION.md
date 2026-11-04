# Flutter UI Gallery 0.2.1 — showcase validation

Validated locally on 4 November 2026 with Flutter **3.41.9** / Dart **3.11.5**, macOS.
The source baseline was 0.2.0. This is a documentation patch; no library source,
public API, runtime dependency, SDK constraint, or Android/iOS configuration changed.

## Delivered

- A visual-first README with an actual Flutter hero, five category navigation
  previews, installation, five concise examples, customization, and resource links.
- Five editorial category overview images and a catalog with exactly **66** unique
  canonical entries: 17 app bars, 11 toasts, 12 sheets, 11 dialogs, 15 navigation bars.
- **88 PNGs:** 66 primary captures, 5 dark examples, 6 interaction states,
  1 hero, 5 category boards, and 5 navigation tiles. The 66 component-focused
  WebP derivatives use lossless compression; full PNGs stay linked for context.
- Primary captures are 660 × 840 px, rendered at 440 × 560 logical pixels / 1.5×.
  Hero resolution is 2100 × 1140 px. All source PNG hashes are in
  [the capture manifest](catalog/captures.json).
- **66** standalone copyable Dart sources, generated from the existing playground
  snippet infrastructure; their aggregate is compiled by the capture tests.
  The complete stateful [showcase app](../example/lib/showcase.dart) owns callbacks,
  navigation, selection, timeline state, toast progress, and notifier disposal.
- Total new capture assets: **5,470,217 bytes**. README image payload:
  **376,413 bytes**. `.pubignore` excludes individual captures, developer tooling,
  and regression goldens from the package archive while retaining six screenshot
  metadata images. Repository goldens and historical previews are preserved.

## Checks actually run

- `flutter test --no-pub` at the package root: **669 passed**, including golden tests.
- `flutter test --no-pub test` in `example/`: **523 passed**, including the five
  new interaction/lifecycle checks and the moved Quick Start fixture.
- Existing snippet validation with `WRITE_SNIPPET_FIXTURE=true`: **5 checks passed**,
  covering **396** family/configuration snippets. The emitted fixture was analyzed
  successfully and archived outside the source tree afterward.
- `flutter analyze --no-pub` (including the generated documentation examples):
  **no issues**. Analysis with the 396-snippet fixture also reported no issues.
- `dart format --output=none --set-exit-if-changed .`: **148 files, zero changes**.
- Flutter capture suite: **2 passed**; every canonical example compiled and rendered,
  plus dark, search, expanded-sheet, filtered-command, completed-timeline, and
  selected-navigation states. All 66 primary PNGs are distinct.
- `python3 tool/build_showcase.py --check`: reproducible generated content,
  exact category counts, and **357** local image/link/anchor targets passed.
- `python3 tool/check_golden_hashes.py`: **160** approved historical hashes unchanged.
  `check_notes_pins.py` and `check_still_pins.py`: SDK/font pins match.
- `flutter build web --no-pub -t lib/showcase.dart`: **built successfully**,
  including the Wasm dry run. The compiler emitted a non-fatal missing
  `CupertinoIcons` font warning; the documentation examples use Material icons.
  No package was added to suppress this warning.
- `git diff --check`: passed. Library source and historical golden/manifests have
  no diff from the baseline.
- Publication dry-run from the clean documentation commit: **exit 0, zero
  warnings**, approximately **7 MB** compressed. No upload or publication occurred.

## Browser and visual review

The preview uses the actual Markdown parsed with Dart `markdown` 7.3.0 / GFM,
with preview-only responsive styling and real Copy Code buttons. It is an
approximation of the pub.dev/GitHub renderers, not a live published page.

At **1280 px desktop** and **390 px mobile** widths, all five category jumps work,
all 11 README images load, and the document has no horizontal overflow. Code
blocks scroll within their own bounds. Every catalog image loads; entry counts
are exactly 17/11/12/11/15. Copy Code was exercised and its clipboard text matched
the original Dart source exactly. Contact-sheet review covered every preset.
Mini Console uses an explicitly loaded real monospace font, avoiding test glyphs.

The preview runs at <http://localhost:4173/build/doc-preview/README.html>.
Rebuild or restart it with the commands in [tool/README.md](../tool/README.md).
The original full gallery remains available; the new showcase is an additional
example entry point.

## Release limits and manual checks

Nothing was pushed, merged, published, deployed, or sent to remote workflows.
The new absolute GitHub image/document URLs resolve locally in the preview and
become available remotely when the maintainer pushes this commit to the referenced
`design-overhaul` branch. Keep that branch and versioned image directory available,
or update the URLs to an immutable release reference before publishing.

A direct read of pub.dev metadata failed because this environment could not
establish its network/SSL connection. The supplied published 0.2.0 version agrees
with the inspected checkout; live pub.dev rendering and remote image availability
cannot be verified without the later remote release steps. API reference links
use pub.dev's standard package documentation route.

Before publication, inspect the local preview and verify the final remote image
URLs after pushing. After publication, inspect pub.dev at desktop and mobile
widths. No application migration or platform setup commands are needed.

## File responsibilities

- `README.md`: generated adoption flow; `CHANGELOG.md` and `pubspec.yaml`: 0.2.1
  documentation release metadata and six current screenshot entries.
- `.pubignore`: exclude development-only capture/test payloads from the archive.
- `example/pubspec.lock`: align only the local path package version with 0.2.1;
  no external dependency versions changed.
- `doc/catalog/`: index, five category documents, 66 source files, canonical
  inventory, and capture hashes; each canonical preset has one catalog entry.
- `doc/assets/showcase-v021/`: only actual Flutter captures and editorial boards
  composed from them, with lossless component crops.
- `doc/QUICK_START.md`, `VERIFICATION.md`, `HISTORICAL_PREVIEWS.md`, `MIGRATION.md`:
  preserve deeper setup, compatibility, history, and migration information outside
  the README's adoption flow. This report records verification and limits.
- `example/lib/gallery/documentation_*.dart`: generated API examples and dispatch;
  `example/lib/showcase.dart`: runnable state owner.
- `example/tool/`: export and Flutter capture tests; `tool/showcase_boards.dart`:
  editorial composition; `tool/build_showcase.py`: generated Markdown/crops/checks;
  `tool/preview_showcase.py`: local GFM browser preview; `tool/readme_examples.dart`:
  compiled README fixture; `tool/README.md`: reproducible maintenance commands.
- The new package/example documentation tests cover inventory, compiled fences,
  state changes, typed results, dismissal, progress, and leaving an open surface.
  `example/test/quick_start_test.dart` now checks the relocated Quick Start text.

<details>
<summary>Exact changed file inventory</summary>

```text
.pubignore
CHANGELOG.md
README.md
doc/HISTORICAL_PREVIEWS.md
doc/MIGRATION.md
doc/QUICK_START.md
doc/SHOWCASE_VALIDATION.md
doc/VERIFICATION.md
doc/assets/showcase-v021/app-bars.png
doc/assets/showcase-v021/bottom-navigation.png
doc/assets/showcase-v021/bottom-sheets.png
doc/assets/showcase-v021/bottomNav.adaptiveMinimal.png
doc/assets/showcase-v021/bottomNav.adaptiveMinimal.webp
doc/assets/showcase-v021/bottomNav.concaveNotch.png
doc/assets/showcase-v021/bottomNav.concaveNotch.webp
doc/assets/showcase-v021/bottomNav.convexWave.png
doc/assets/showcase-v021/bottomNav.convexWave.webp
doc/assets/showcase-v021/bottomNav.flipTiles.png
doc/assets/showcase-v021/bottomNav.flipTiles.webp
doc/assets/showcase-v021/bottomNav.floatingCove.png
doc/assets/showcase-v021/bottomNav.floatingCove.webp
doc/assets/showcase-v021/bottomNav.glassDock.png
doc/assets/showcase-v021/bottomNav.glassDock.webp
doc/assets/showcase-v021/bottomNav.layeredShelf.png
doc/assets/showcase-v021/bottomNav.layeredShelf.webp
doc/assets/showcase-v021/bottomNav.liquidDrop.png
doc/assets/showcase-v021/bottomNav.liquidDrop.webp
doc/assets/showcase-v021/bottomNav.morphingCapsule-dark.png
doc/assets/showcase-v021/bottomNav.morphingCapsule-selected.png
doc/assets/showcase-v021/bottomNav.morphingCapsule.png
doc/assets/showcase-v021/bottomNav.morphingCapsule.webp
doc/assets/showcase-v021/bottomNav.orbitDock.png
doc/assets/showcase-v021/bottomNav.orbitDock.webp
doc/assets/showcase-v021/bottomNav.overflowDock.png
doc/assets/showcase-v021/bottomNav.overflowDock.webp
doc/assets/showcase-v021/bottomNav.perspectiveDock.png
doc/assets/showcase-v021/bottomNav.perspectiveDock.webp
doc/assets/showcase-v021/bottomNav.ribbonCurve.png
doc/assets/showcase-v021/bottomNav.ribbonCurve.webp
doc/assets/showcase-v021/bottomNav.scrollDock.png
doc/assets/showcase-v021/bottomNav.scrollDock.webp
doc/assets/showcase-v021/bottomNav.splitIsland.png
doc/assets/showcase-v021/bottomNav.splitIsland.webp
doc/assets/showcase-v021/dialogs.alertCapsule.png
doc/assets/showcase-v021/dialogs.alertCapsule.webp
doc/assets/showcase-v021/dialogs.commandPalette-filtered.png
doc/assets/showcase-v021/dialogs.commandPalette.png
doc/assets/showcase-v021/dialogs.commandPalette.webp
doc/assets/showcase-v021/dialogs.halo.png
doc/assets/showcase-v021/dialogs.halo.webp
doc/assets/showcase-v021/dialogs.milestone-completed.png
doc/assets/showcase-v021/dialogs.milestone.png
doc/assets/showcase-v021/dialogs.milestone.webp
doc/assets/showcase-v021/dialogs.orbitConfirm.png
doc/assets/showcase-v021/dialogs.orbitConfirm.webp
doc/assets/showcase-v021/dialogs.panelDecision.png
doc/assets/showcase-v021/dialogs.panelDecision.webp
doc/assets/showcase-v021/dialogs.png
doc/assets/showcase-v021/dialogs.sideBySideChoice-dark.png
doc/assets/showcase-v021/dialogs.sideBySideChoice.png
doc/assets/showcase-v021/dialogs.sideBySideChoice.webp
doc/assets/showcase-v021/dialogs.split.png
doc/assets/showcase-v021/dialogs.split.webp
doc/assets/showcase-v021/dialogs.spotlight.png
doc/assets/showcase-v021/dialogs.spotlight.webp
doc/assets/showcase-v021/dialogs.statusBeacon.png
doc/assets/showcase-v021/dialogs.statusBeacon.webp
doc/assets/showcase-v021/dialogs.timeline-completed.png
doc/assets/showcase-v021/dialogs.timeline.png
doc/assets/showcase-v021/dialogs.timeline.webp
doc/assets/showcase-v021/header.adaptiveHorizon.png
doc/assets/showcase-v021/header.adaptiveHorizon.webp
doc/assets/showcase-v021/header.breadcrumbTrail.png
doc/assets/showcase-v021/header.breadcrumbTrail.webp
doc/assets/showcase-v021/header.centeredTitle.png
doc/assets/showcase-v021/header.centeredTitle.webp
doc/assets/showcase-v021/header.compactRail.png
doc/assets/showcase-v021/header.compactRail.webp
doc/assets/showcase-v021/header.editorialTopbar.png
doc/assets/showcase-v021/header.editorialTopbar.webp
doc/assets/showcase-v021/header.floatingArc.png
doc/assets/showcase-v021/header.floatingArc.webp
doc/assets/showcase-v021/header.focusBar.png
doc/assets/showcase-v021/header.focusBar.webp
doc/assets/showcase-v021/header.foldedCanopy.png
doc/assets/showcase-v021/header.foldedCanopy.webp
doc/assets/showcase-v021/header.layeredNav.png
doc/assets/showcase-v021/header.layeredNav.webp
doc/assets/showcase-v021/header.orbitCommand.png
doc/assets/showcase-v021/header.orbitCommand.webp
doc/assets/showcase-v021/header.panoramaBar.png
doc/assets/showcase-v021/header.panoramaBar.webp
doc/assets/showcase-v021/header.parallaxCrest.png
doc/assets/showcase-v021/header.parallaxCrest.webp
doc/assets/showcase-v021/header.sculptedWave.png
doc/assets/showcase-v021/header.sculptedWave.webp
doc/assets/showcase-v021/header.searchSwitch-dark.png
doc/assets/showcase-v021/header.searchSwitch-expanded.png
doc/assets/showcase-v021/header.searchSwitch.png
doc/assets/showcase-v021/header.searchSwitch.webp
doc/assets/showcase-v021/header.sectionTabs.png
doc/assets/showcase-v021/header.sectionTabs.webp
doc/assets/showcase-v021/header.selectionBar.png
doc/assets/showcase-v021/header.selectionBar.webp
doc/assets/showcase-v021/header.splitHeader.png
doc/assets/showcase-v021/header.splitHeader.webp
doc/assets/showcase-v021/hero.png
doc/assets/showcase-v021/sheets.depthFrame.png
doc/assets/showcase-v021/sheets.depthFrame.webp
doc/assets/showcase-v021/sheets.edgeLift.png
doc/assets/showcase-v021/sheets.edgeLift.webp
doc/assets/showcase-v021/sheets.flow.png
doc/assets/showcase-v021/sheets.flow.webp
doc/assets/showcase-v021/sheets.fold-expanded.png
doc/assets/showcase-v021/sheets.fold.png
doc/assets/showcase-v021/sheets.fold.webp
doc/assets/showcase-v021/sheets.horizonPeek.png
doc/assets/showcase-v021/sheets.horizonPeek.webp
doc/assets/showcase-v021/sheets.neoTray.png
doc/assets/showcase-v021/sheets.neoTray.webp
doc/assets/showcase-v021/sheets.orbit-dark.png
doc/assets/showcase-v021/sheets.orbit.png
doc/assets/showcase-v021/sheets.orbit.webp
doc/assets/showcase-v021/sheets.prism.png
doc/assets/showcase-v021/sheets.prism.webp
doc/assets/showcase-v021/sheets.pulseDock.png
doc/assets/showcase-v021/sheets.pulseDock.webp
doc/assets/showcase-v021/sheets.splitLayer.png
doc/assets/showcase-v021/sheets.splitLayer.webp
doc/assets/showcase-v021/sheets.stackPanel.png
doc/assets/showcase-v021/sheets.stackPanel.webp
doc/assets/showcase-v021/sheets.taskRail.png
doc/assets/showcase-v021/sheets.taskRail.webp
doc/assets/showcase-v021/tile-app-bars.png
doc/assets/showcase-v021/tile-bottom-navigation.png
doc/assets/showcase-v021/tile-bottom-sheets.png
doc/assets/showcase-v021/tile-dialogs.png
doc/assets/showcase-v021/tile-toasts.png
doc/assets/showcase-v021/toasts.action-dark.png
doc/assets/showcase-v021/toasts.action.png
doc/assets/showcase-v021/toasts.action.webp
doc/assets/showcase-v021/toasts.beacon.png
doc/assets/showcase-v021/toasts.beacon.webp
doc/assets/showcase-v021/toasts.dock.png
doc/assets/showcase-v021/toasts.dock.webp
doc/assets/showcase-v021/toasts.inlinePulse.png
doc/assets/showcase-v021/toasts.inlinePulse.webp
doc/assets/showcase-v021/toasts.miniConsole.png
doc/assets/showcase-v021/toasts.miniConsole.webp
doc/assets/showcase-v021/toasts.png
doc/assets/showcase-v021/toasts.progressCard.png
doc/assets/showcase-v021/toasts.progressCard.webp
doc/assets/showcase-v021/toasts.ribbon.png
doc/assets/showcase-v021/toasts.ribbon.webp
doc/assets/showcase-v021/toasts.ribbonActionBar.png
doc/assets/showcase-v021/toasts.ribbonActionBar.webp
doc/assets/showcase-v021/toasts.signal.png
doc/assets/showcase-v021/toasts.signal.webp
doc/assets/showcase-v021/toasts.snapNotice.png
doc/assets/showcase-v021/toasts.snapNotice.webp
doc/assets/showcase-v021/toasts.stackTag.png
doc/assets/showcase-v021/toasts.stackTag.webp
doc/catalog/README.md
doc/catalog/app-bars.md
doc/catalog/bottom-navigation.md
doc/catalog/bottom-sheets.md
doc/catalog/captures.json
doc/catalog/code/bottomNav.adaptiveMinimal.dart
doc/catalog/code/bottomNav.concaveNotch.dart
doc/catalog/code/bottomNav.convexWave.dart
doc/catalog/code/bottomNav.flipTiles.dart
doc/catalog/code/bottomNav.floatingCove.dart
doc/catalog/code/bottomNav.glassDock.dart
doc/catalog/code/bottomNav.layeredShelf.dart
doc/catalog/code/bottomNav.liquidDrop.dart
doc/catalog/code/bottomNav.morphingCapsule.dart
doc/catalog/code/bottomNav.orbitDock.dart
doc/catalog/code/bottomNav.overflowDock.dart
doc/catalog/code/bottomNav.perspectiveDock.dart
doc/catalog/code/bottomNav.ribbonCurve.dart
doc/catalog/code/bottomNav.scrollDock.dart
doc/catalog/code/bottomNav.splitIsland.dart
doc/catalog/code/dialogs.alertCapsule.dart
doc/catalog/code/dialogs.commandPalette.dart
doc/catalog/code/dialogs.halo.dart
doc/catalog/code/dialogs.milestone.dart
doc/catalog/code/dialogs.orbitConfirm.dart
doc/catalog/code/dialogs.panelDecision.dart
doc/catalog/code/dialogs.sideBySideChoice.dart
doc/catalog/code/dialogs.split.dart
doc/catalog/code/dialogs.spotlight.dart
doc/catalog/code/dialogs.statusBeacon.dart
doc/catalog/code/dialogs.timeline.dart
doc/catalog/code/header.adaptiveHorizon.dart
doc/catalog/code/header.breadcrumbTrail.dart
doc/catalog/code/header.centeredTitle.dart
doc/catalog/code/header.compactRail.dart
doc/catalog/code/header.editorialTopbar.dart
doc/catalog/code/header.floatingArc.dart
doc/catalog/code/header.focusBar.dart
doc/catalog/code/header.foldedCanopy.dart
doc/catalog/code/header.layeredNav.dart
doc/catalog/code/header.orbitCommand.dart
doc/catalog/code/header.panoramaBar.dart
doc/catalog/code/header.parallaxCrest.dart
doc/catalog/code/header.sculptedWave.dart
doc/catalog/code/header.searchSwitch.dart
doc/catalog/code/header.sectionTabs.dart
doc/catalog/code/header.selectionBar.dart
doc/catalog/code/header.splitHeader.dart
doc/catalog/code/sheets.depthFrame.dart
doc/catalog/code/sheets.edgeLift.dart
doc/catalog/code/sheets.flow.dart
doc/catalog/code/sheets.fold.dart
doc/catalog/code/sheets.horizonPeek.dart
doc/catalog/code/sheets.neoTray.dart
doc/catalog/code/sheets.orbit.dart
doc/catalog/code/sheets.prism.dart
doc/catalog/code/sheets.pulseDock.dart
doc/catalog/code/sheets.splitLayer.dart
doc/catalog/code/sheets.stackPanel.dart
doc/catalog/code/sheets.taskRail.dart
doc/catalog/code/toasts.action.dart
doc/catalog/code/toasts.beacon.dart
doc/catalog/code/toasts.dock.dart
doc/catalog/code/toasts.inlinePulse.dart
doc/catalog/code/toasts.miniConsole.dart
doc/catalog/code/toasts.progressCard.dart
doc/catalog/code/toasts.ribbon.dart
doc/catalog/code/toasts.ribbonActionBar.dart
doc/catalog/code/toasts.signal.dart
doc/catalog/code/toasts.snapNotice.dart
doc/catalog/code/toasts.stackTag.dart
doc/catalog/dialogs.md
doc/catalog/inventory.json
doc/catalog/toasts.md
example/lib/gallery/documentation_calls.dart
example/lib/gallery/documentation_examples.dart
example/lib/showcase.dart
example/pubspec.lock
example/test/documentation_showcase_test.dart
example/test/quick_start_test.dart
example/tool/capture_showcase.dart
example/tool/export_showcase.dart
pubspec.yaml
test/documentation_examples_test.dart
tool/README.md
tool/build_showcase.py
tool/preview_showcase.py
tool/readme_examples.dart
tool/showcase_boards.dart
```

</details>
