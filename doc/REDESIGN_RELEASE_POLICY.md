# Phase 0 redesign release proposal

**Decision proposed for review:** keep every Phase 0 visual redesign opt-in through the current release line. Promote a completed, accepted redesign to default only in a separately announced major release, with per-preset migration examples and an explicit compatibility strategy designed before that release. No defaults change in this phase. `useSignature: true` on the existing family API remains the current opt-in recipe; choosing a family alone does not enable it. A redesign still awaiting its app/brief is a proposal, not an implemented behavior.

The 20 exact Phase 0 redesign enum values and proposed disposition are below. “Major default” is conditional on completing review and compatibility work; it is not a promise to ship unfinished designs.

- `UiGallerySheetPreset.orbit`: opt-in now; major default candidate. New context rail changes form width, height, secondary-content placement and keyboard scrolling. Existing custom content/height assumptions need review.
- `UiGallerySheetPreset.prism`: opt-in when implemented; major default candidate. Diagonal stage hierarchy can change safe content insets and title alignment.
- `UiGallerySheetPreset.flow`: opt-in when implemented; major default candidate. Canvas/header relationships may change scroll boundaries and content density.
- `UiGallerySheetPreset.pulseDock`: opt-in when implemented; major default candidate. A structural action dock could move footer controls and alter keyboard reach.
- `UiGallerySheetPreset.horizonPeek`: opt-in when implemented; major default candidate. Preview/expanded-content geometry may change perceived clipping and initial viewport.
- `UiGalleryDialogPreset.split`: opt-in now; major default candidate. Consequence descriptions become visible, actions become lanes and stack at large text; existing compact confirmations become taller. Typed results remain unchanged.
- `UiGalleryDialogPreset.orbitConfirm`: opt-in when implemented in Wallet B; major default candidate. Account-centered hierarchy may change icon sizing, order and dialog height; generic confirmations cannot assume the previous medallion position.
- `UiGalleryDialogPreset.alertCapsule`: opt-in when implemented; major default candidate. Compact density and line wrapping can affect existing long messages and stacked action layouts.
- `UiGalleryDialogPreset.milestone`: opt-in when implemented in Wallet B; major default candidate. Checkpoint/result hierarchy can change icon prominence, primary-action placement and height.
- `UiGalleryToastPreset.action`: opt-in now; major default candidate. Segmented recovery action changes message width, minimum height and stacked layout; overlay spacing/screenshots may move.
- `UiGalleryToastPreset.beacon`: opt-in when implemented; major default candidate. Detached status anchor may change overlay bounds and long-message wrapping.
- `UiGalleryAppBarPreset.floatingArc`: opt-in when implemented; major default candidate. Island insets and available title/action width may change; custom leading/actions need comparison.
- `UiGalleryAppBarPreset.splitHeader`: opt-in when implemented; major default candidate. Two context domains may wrap differently on narrow layouts and sliver collapse.
- `UiGalleryAppBarPreset.panoramaBar`: opt-in when implemented; major default candidate. Artwork/title horizon can change preferred height, contrast and safe action placement.
- `UiGalleryAppBarPreset.foldedCanopy`: opt-in when implemented; major default candidate. Exposed fold geometry may affect clipping, insets and collapsed-header screenshots.
- `UiGalleryAppBarPreset.parallaxCrest`: opt-in when implemented; major default candidate only after motion/cheap-mode verification. Artwork-linked depth could change motion expectations and sliver behavior.
- `UiGalleryBottomNavPreset.orbitDock`: opt-in when implemented in Wallet B; **default deferred pending account-switcher review**. Wells must represent real accounts/spaces, not arbitrary destinations. If the account brief fails, retain showcase-only status; no manufactured screen or deprecation. Selection/index/hit geometry are migration risks.
- `UiGalleryBottomNavPreset.layeredShelf`: opt-in now; major default candidate. Separate destination bays replace a moving panel, retain the rear shelf and may change label density, focus appearance and overlay height.
- `UiGalleryBottomNavPreset.perspectiveDock`: opt-in when implemented; **default deferred pending Admin back-stack review**. A rear destination needs actual navigation meaning; otherwise showcase-only. Motion, stacking order and selection expectations are migration risks.
- `UiGalleryBottomNavPreset.flipTiles`: opt-in when implemented; major default candidate after interruption/semantics review. Active-tile orientation and label exposure can alter motion and focus expectations.

No enum, SDK floor, dependency or deprecation change is proposed here. Geometry, scroll positions, screenshots and custom styling are observable behavior even when method signatures and typed results are stable. A future major migration must document these effects rather than calling them non-breaking.

## Honest uplift accounting

`UiGalleryToastPreset.inlinePulse` and `UiGalleryBottomNavPreset.scrollDock` received **localized copy and existing behavior reuse, not a visual uplift** in Notes B. Both retain **Phase 0 score 6** until a real visual change is authored, rendered and reviewed. The five-line briefs are proposals for direction, not evidence of a higher score. No other score is automatically increased because a preset found an app home.

## Release-validation status

The nine `design-overhaul` checkpoint commits are present, ending at `8b1f2e8efd79f7bbdeef1b42927460101ab03e50`. They include Phase 1, family signatures and the Notes/Wallet examples. These repository changes are unreleased; pub.dev `0.1.0` remains the published release, and the package version and SDK constraints are unchanged.

The [Flutter CI workflow](../.github/workflows/ci.yml) accepts pushes to `codex/**`, pull requests targeting `master` and manual dispatch. `design-overhaul` does not match the push trigger. **Validation plan:** after the P0 fixes are committed and pushed with separate authorization, use a pull request targeting `master` or manually run Flutter CI for `design-overhaul`. Trigger rules remain unchanged. Record the run URL and exact tested commit SHA; require the pinned, current-stable, Android and iOS jobs to pass before claiming release validation. For a pull request run, record both the branch commit and GitHub's tested merge SHA.

No green CI run has been established for the checkpoint or P0 fixes. Local guards and formatting results do not prove remote CI success, artifact uploads or device behavior. The historical [run 38740646866](https://github.com/Ahmedelsapagh10/flutter_ui_gallery/actions/runs/38740646866) concerns the older `339ccbdc4a23c468555f2706f4d5523420c41d0b` checkpoint and cannot validate the current tree. Failure-image uploads require evidence from an actual failing pinned run before they can be considered verified end to end.
