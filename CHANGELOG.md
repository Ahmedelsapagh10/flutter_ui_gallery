## 0.1.0

- Add coordinated Minimal, Soft and Spatial theme families with shared and per-component styles that retain the host application's ColorScheme and typography.
- Add style and motion `copyWith`, partial `merge` and interpolation; partial motion overrides preserve inherited timings.
- Add eight recommended presets, browsing by task and configuration share links to the playground.
- Add productivity, shopping and dashboard examples with caller-owned state, input validation, cancellation, empty results and error/retry handling.
- Add continuous integration and GitHub Pages workflows, integration guidance and package screenshots. Native release and accessibility checks remain part of the release checklist.

- Add Command Palette, Selection Bar, Progress Card and Overflow Dock, bringing the collection to 66 presets.
- Add typed command search and keyboard navigation, controlled bulk selection, caller-owned task progress and responsive navigation overflow.
- Expose shared visual/motion overrides on timeline and status convenience methods; replace internal dialog preset labels with an optional caller-supplied eyebrow.
- Add disabled dialog actions and immediately apply updated navigation motion curves.

- Add Search Switch, Centered Title, Breadcrumb Trail and Section Tabs headers, plus Glass Dock, Liquid Drop, Scroll Dock and Flip Tiles navigation. The gallery now covers 62 presets.
- Add working search, breadcrumb routing and tabbed collection examples, with matching copyable code.

- Expand to 40 presets: 12 sheets, 10 dialogs, 10 toasts and 8 app bars.
- Add SurfaceStyle and Motion overrides without requiring a theme wrapper.
- Add secondary sheet zones, described choice actions, search headers and shared sliver presets.
- Preserve existing enum values, short-form APIs and Nova aliases; add descriptive preset aliases.
- Group gallery previews by category and provide a live scenario and snippet for every preset.
- Requeue excess notifications when reducing the visibility cap.
- Harden keyboard peek layout, reduced-motion resizing and custom toast slot constraints.
- Honor independent dialog exit durations and preserve manual toast dismissal under accessible navigation.
- Add full header/sliver coverage, all-preset gallery tests and representative visual baselines.

## 0.0.1

### Initial Release — Flutter UI Gallery (2050 Design Vision)
- **Official Rebranding**: Rebranded to **Flutter UI Gallery** (`flutter_ui_gallery`) with first-class `UiGallery*` public API surfaces (`UiGallerySheet`, `UiGalleryDialog`, `UiGalleryToast`, `UiGalleryAppBar`, `UiGalleryTheme`, `UiGalleryTokens`).
- **Backward Compatibility**: Fully backward-compatible `Nova*` typedef aliases and exports preserved for seamless migration.
- **Bottom Sheets (`UiGallerySheet`)**:
  - `orbit`: Floating asymmetric spatial dock with modular action zones.
  - `fold`: Progressive unfolding peek sheet that expands smoothly without losing form/text state.
  - `prism`: Structured presentation stage with distinct content showcase and sticky action tray.
  - `flow`: Multi-step interactive workflow canvas with spatial progress tracking (`UiGalleryFlow`).
- **Dialogs (`UiGalleryDialog`)**:
  - `halo`: Focused central composition with subtle halo emphasis ring on primary action (`UiGalleryDialog.confirm`).
  - `split`: Divided composition separating context and decisions, responsive stacking on mobile viewports.
  - `timeline`: Visual sequential progress dialog driven by external `ValueListenable<UiGalleryTimelineState>`.
  - `spotlight`: Orbital result dialog for `success`, `warning`, and `failure` states (`UiGalleryResult`).
- **Toasts (`UiGalleryToast`)**:
  - `signal`: Compact capsule status pill with adaptive width.
  - `ribbon`: Edge-anchored directional notification banner.
  - `action`: Interactive segmented surface pairing notification with Undo/Retry actions and live timeout progress.
  - Full FIFO queue management, deduplication policies (`ignore`, `replace`, `allow`), programmatic handles, and route-scoped cleanup.
- **Adaptive Headers (`UiGalleryAppBar` / `UiGallerySliverAppBar`)**:
  - `Adaptive Horizon`: Futuristic header with automatic scroll-awareness without manual `ScrollController` configuration.
- **Design System (`UiGalleryTheme` / `UiGalleryTokens`)**:
  - ThemeExtension integration, zero-dependency ambient `ThemeData` support, high contrast, reduced motion, and RTL support.
- **Soft Futuristic Product Showcase**:
  - Refined example gallery application in `example/` featuring:
    - Soft Futuristic Gallery aesthetic with restrained palette and two-font typography (`Outfit` + `Plus Jakarta Sans`, plus `Alexandria` for Arabic).
    - Top preset navigation strip for instant one-click switching across all 12 presets.
    - Category filtering cards (`Sheets`, `Dialogs`, `Toasts`, `Header`).
    - Interactive playground controls and live 1–3 line code generator.
    - Live device simulators (Phone 390dp, Tablet 768dp, Wide 1200dp).
- **Quality & Reliability**:
  - 43 automated tests passing (41 package unit & integration tests + 2 example showcase widget tests).
  - Clean static analysis with 0 linter issues across entire workspace.
