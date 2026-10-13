## 0.0.1

### Initial Release — Nova Surfaces (2050 Design Vision)
- **Bottom Sheets (`NovaSheet`)**:
  - `orbit`: Floating asymmetric spatial dock with modular action zones.
  - `fold`: Progressive unfolding peek sheet that expands smoothly without losing state.
  - `prism`: Structured presentation stage with distinct content showcase and action trays.
  - `flow`: Multi-step interactive workflow canvas with spatial progress tracking (`NovaFlow`).
- **Dialogs (`NovaDialog`)**:
  - `halo`: Focused central composition with halo emphasis ring on the primary action (`NovaDialog.confirm`).
  - `split`: Divided composition separating context and decisions, responsive stacking on mobile viewports.
  - `timeline`: Visual sequential progress dialog driven by external `ValueListenable<NovaTimelineState>`.
  - `spotlight`: Orbital result dialog for `success`, `warning`, and `failure` states (`NovaResult`).
- **Toasts (`NovaToast`)**:
  - `signal`: Compact capsule status pill with adaptive width.
  - `ribbon`: Edge-anchored directional notification banner.
  - `action`: Interactive segmented surface pairing notification with Undo/Retry actions and live timeout progress.
  - Full queue management, concurrency controls, deduplication policies, programmatic handles, and route-scoped cleanup.
- **Adaptive Headers (`NovaAppBar` / `NovaSliverAppBar`)**:
  - `Adaptive Horizon`: Futuristic header with automatic scroll-awareness without manual `ScrollController` configuration.
- **Design System (`NovaTheme` / `NovaTokens`)**:
  - ThemeExtension integration, zero-dependency ambient `ThemeData` support, high contrast, reduced motion, and RTL support.
- **Interactive Component Gallery**:
  - Complete showcase app in `example/` with live device frames, theme customization, and copyable recipes.
- **Quality**:
  - 39 automated unit and integration tests passing.
