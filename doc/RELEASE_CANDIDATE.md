# Local release candidate — 2026-11-03

**Decision: accepted for local RC review.** The implementation has no known
unresolved local test failure. Publication is held for version preparation and
separately authorized hosted validation. This is not a claim of complete native
accessibility, physical-device performance or remote CI verification.

Tested implementation: `3981a46e2489a2e18415b11c232a7672be82ea51` on
`design-overhaul`. The commit containing this report changes documentation only;
its final HEAD, clean status and dry-run are recorded in the external evidence.
No push, workflow dispatch, merge, deployment, tag or publication was performed.

## Completed and frozen

The package provides 66 surface presets with caller-owned state, typed results,
Minimal/Soft/Spatial families, opt-in structural signatures and host-theme styling.
This freeze retains the verified Capsule, Command Palette, Split/SideBySideChoice,
Orbit/SplitLayer, Action/Editorial and scaled navigation improvements.

- SelectionBar now measures its localized status. If the phrase cannot fit, it
  shows the localized count and retains the full status in semantics and a
  tooltip. Clear/bulk actions and controlled count remain intact. Normal renders
  are byte-identical; six compact Arabic 2x/3x cases improve only title pixels.
- A coordinated optional recipe uses the existing
  `UiGalleryTheme.family(..., useSignature: true)` configuration. No new public
  factory or theming architecture was needed. The runnable five-category Quick
  Start demonstrates contextual Sheet, typed Dialog, actionable Toast, AppBar and
  controlled Navigation together; top feedback keeps navigation usable.
- Playground discovery offers 14 useful starting points and retains all 66
  presets. Calm structure is opt-in and matches preview, shared configuration and
  generated code. Old links retain their prior signature-off behavior.
- Copy Code retains typed choice/result contracts and caller-owned timeline
  progress. Generated theme helpers explain where to apply the configuration.
- README installation distinguishes published 0.1.0 from this unreleased checkout,
  provides a complete runnable application and preserves advanced references.
  CHANGELOG adds Unreleased without rewriting historical entries.

The 14 starting points are Orbit, SplitLayer, TaskRail, Split, CommandPalette,
SideBySideChoice, Timeline, Action, Signal, SearchSwitch, EditorialTopbar,
LayeredShelf, AdaptiveMinimal and MorphingCapsule. This discovery selection does
not retroactively approve either historical 20-item shortlist or imply all 20
received new implementation or native validation.

## Intentionally deferred

The remaining open-ended Hero redesign/score program, a new recipe factory,
additional playground search/scale features and broader visual work are deferred.
Strong existing components remain unchanged. No new preset, dependency or
architecture was introduced. There is no requirement to finish those optional
items before local RC preparation.

EditorialTopbar's fixed 128px header requires reading gestures at extreme 3x
Arabic. Compact 3x navigation can require horizontal scrolling. These remain
explicit native accessibility review items, not fully verified accessibility
claims. Widget semantics/focus tests do not substitute for TalkBack/VoiceOver.

## Verification actually executed

- Flutter **3.41.9**, Dart3.11.5, framework00b0c91f06, engine42d3d75a56:
  **667 package and 518 example tests passed**, including all strict goldens.
- Flutter **3.47.9**, Dart3.13.7, frameworkc197ca5199, engine89c39edfdf:
  **643 package and 364 compatible example tests passed**, using the established
  exclusion of renderer-specific golden tests. Final runs use an isolated copy.
- Both SDKs: **five snippet checks, 396 generated helpers**, then clean analysis
  including the generated fixture. Final pinned source analysis also clean.
- Pinned read-only format: **72 files, zero changes**. Whitespace check passed.
- Historical, versioned, SDK and font guards passed. All **262 prior golden
  artifacts, including 243 PNGs**, remain byte-identical to the starting commit.
  No baseline migration, tolerance change or comparison suppression in this freeze.
- SelectionBar:15 focused cases and15 actual before/after render pairs, including
  full status semantics, visible count, keyboard clearing and preserved actions.
- Quick Start: exact README/compiled-fixture consistency and real typed
  sheet→decision→archive→navigation→Undo flow pass. Six actual Flutter frames.
- Workflow YAML parses locally; CI files and triggers are unchanged. Actionlint
  is unavailable, so this is not full hosted workflow execution validation.
- Clean implementation-commit `flutter pub publish --dry-run`: **exit0,
  zero warnings, 14MB compressed archive**. Archive listing includes MIT and all
  four bundled font OFL notices; no temporary generated snippet/capture fixture,
  SDK, build cache, credential or recovery snapshot is included. Pub.dev warns
  that its server may enforce additional checks; dry-run does not upload.

Raw logs and exact image hashes are in the external `release-candidate/` folder
under the existing Codex visualization root:
`2026/11/02/01a19dfe-66b2-7291-b1a2-1164e743e729/`.
Open `gallery.html` for consolidated current and earlier Flutter render evidence;
`verification.json`, `integrity-review.md`, `historical-integrity-final.json` and
`implementation.diff` provide the check inventory and exact evidence.

### Failures encountered and resolved

The initial Selection capture harness disposed semantics too late; captures were
preserved and the harness corrected with finally. The final15 cases pass.
Initial adoption checks assumed an unselected capsule label was rendered and a
newly displaced slider was already visible; tests now use destination tooltips
and scroll the slider into view while retaining the original behavior assertions.
The Quick Start's bottom toast actually obscured navigation; its configuration
now uses the existing top position, and the complete flow passes.

One stable command ran from the primary checkout instead of its isolated copy,
causing SDK/test-library compilation mismatch. The failed log is retained;
generated assets were preserved separately, the pinned package was rebuilt and
passed667, and isolated stable runs passed643/364. No source workaround was used.
Initial pub dry-run's only warning was the dirty working tree; after committing,
the clean dry-run passed with zero warnings.

## Compatibility and remaining evidence

Public component declarations, exports, Nova aliases, theme/style contracts,
SDK constraints and dependencies are preserved. Runtime opt-in layouts change
only within the reviewed scope. Existing signature-off baselines still pass.
The declared Flutter floor remains>=3.41.0 and Dart^3.11.5; only3.41.9 and3.47.9
were executed, so the exact3.41.0 floor is not independently verified here.

No Android device was connected. The local inventory has an iPhone17Pro/iOS26.2
simulator in Shutdown state; no native run was performed. Hardware keyboard,
real IME, native screen readers, orientation on devices and profile-mode frame/
memory measurements remain unverified. Static review found no concrete lifecycle
leak; it does not establish measured performance. These gaps do not block local
RC preparation under the finalization instruction.

Remote CI remains pending for this exact commit. Earlier runs do not validate
this candidate. Before a release-validation claim, the existing policy requires
pinned, current-stable, Android build/smoke and iOS build/smoke jobs on the exact
candidate SHA. No code was changed to bypass those checks.

## Local commits and exact changed files

- `a024c115bd9a214d42aead7632923ba25df9fd48`: scaled navigation labels, previously
  verified versioned expectations and checkpoint.
- `b416350a4562c571d7fd24c5230cfbce06ae4cb8`: only
  `lib/src/appbars/gallery_appbar.dart` and
  `example/test/selection_readability_test.dart` for the visible-count fix.
- `3981a46e2489a2e18415b11c232a7672be82ea51`: adoption/validation changes below.
- Final report commit: only this report and `doc/DEVELOPMENT_PROGRESS.md`.

Adoption files: `README.md` (runnable setup/recipe/release distinction),
`CHANGELOG.md` (Unreleased), `example/lib/gallery/catalog.dart` (14 starting points),
`configuration.dart` (compatible opt-in flag), `snippet.dart` (matching typed
examples), `example/lib/main.dart` (matching preview/control/share),
`example/test/adoption_test.dart` (configuration/control regression),
`snippet_test.dart` (generated contract checks), `widget_test.dart` (ensure actual
slider reachability), `quick_start_test.dart` (compiled docs and real flow), and
root/example `dart_test.yaml` (register existing golden tag; no skips/tolerances).

## Version and publication steps

Recommend **0.2.0** for the unreleased scope, with 0.1.0 retained as the published
version until separately approved release preparation. No automatic version bump.
SDK/dependency/platform configuration changes are not required by this candidate.

1. Approve the intended version; update pubspec and promote the Unreleased notes.
   Recheck archive contents, README and dry-run after that metadata change.
2. Separately authorize pushing `design-overhaul` and hosted validation. Record
   exact tested SHA and all four job outcomes; resolve actual failures.
3. Review known native accessibility limitations and desired platform evidence.
   Keep unperformed checks explicitly unverified in release communications.
4. Confirm clean Git state and publisher access; obtain explicit publication/tag/
   release authorization. Only then publish the approved version. Dry-run success
   does not establish ownership, version availability or completed publication.

There are no unresolved local code/test blockers. Version preparation and exact-
SHA hosted CI are outstanding publication/release-validation gates. Disk space at
finalization is approximately7.9GiB; no additional cleanup is needed.
