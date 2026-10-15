# Preset variation matrix

66 compositions: 12 sheets, 11 dialogs, 11 toasts, 17 app bars and 15 bottom navigation bars. Existing presets retain their enum values; descriptive aliases do not count as additional presets. Motion remains finite and system reduced-motion settings take priority.

## Start with eight

The gallery's **Recommended** filter starts with these everyday components:

- **Orbit Dock** (`UiGallerySheetPreset.orbit`): compact actions and validated editing.
- **Halo Focus** (`UiGalleryDialogPreset.halo`): a clear confirmation before committing a change.
- **Command Palette** (`UiGalleryDialogPreset.commandPalette`): searchable commands with typed results and keyboard navigation.
- **Signal Pill** (`UiGalleryToastPreset.signal`): brief status feedback.
- **Progress Card** (`UiGalleryToastPreset.progressCard`): determinate progress and an optional cancellation action.
- **Search Switch** (`UiGalleryAppBarPreset.searchSwitch`): a title that switches to an editable search field.
- **Selection Bar** (`UiGalleryAppBarPreset.selectionBar`): selected-item counts and caller-owned bulk actions.
- **Adaptive Minimal** (`UiGalleryBottomNavPreset.adaptiveMinimal`): a restrained destination bar for an existing router or IndexedStack.

Use **Browse by task** to filter the full catalog by Quick actions, Search, Bulk selection, Confirmation, Task progress, Navigation, or Status and feedback. Category filters still expose every composition.

## Coordinated families

`UiGalleryTheme.family` applies a shared visual recipe to any preset while retaining the supplied ThemeData's colors and fonts:

- **Minimal** (`UiGalleryDesignFamily.minimal`): compact rounded sheets/dialogs, no added elevation and short transitions.
- **Soft** (`UiGalleryDesignFamily.soft`): more rounded surfaces, comfortable spacing and gentle elevation.
- **Spatial** (`UiGalleryDesignFamily.spatial`): larger radii, generous spacing, stronger depth and longer finite transitions.

Families coordinate shared colors, message typography and elevation, with component-specific typography and spacing. Sheets, dialogs and toasts receive matching rounded shapes; app bars and bottom navigation preserve their preset silhouettes. Per-call overrides refine the result. See [integration guidance](INTEGRATION.md) for attaching a family to an existing ThemeData and connecting real application state.

## Sheets

- **Orbit Dock** (`orbit`): Floating asymmetric action zones. Motion: cohesive rise with content reveal. Use: quick actions, sharing and contextual tools.
- **Fold Motion** (`fold`): Peek state unfolding into one connected surface. Motion: state-preserving expansion. Use: descriptions, editable forms and options.
- **Prism Stage** (`prism`): Showcase plane with a separate action deck. Motion: subtle depth rise. Use: product previews and booking details.
- **Flow Canvas** (`flow`): Task canvas with a spatial step track. Motion: directional, state-preserving page change. Use: checkout selections and onboarding.
- **Edge Lift** (`edgeLift`): Flush, shallow edge shelf with a slim action region. Motion: quick native lift. Use: fast decisions and quick controls.
- **Stack Panel** (`stackPanel`): Three offset planes behind an active panel. Motion: layer reveal. Use: collections and grouped options.
- **Neo Tray** (`neoTray`): Toolbar, framed utility well and segmented footer. Motion: connected tray entrance. Use: device settings and utilities.
- **Split Layer** (`splitLayer`): Parallel content and secondary/action zones. Motion: unified spatial entrance. Use: comparisons and checkout summaries.
- **Pulse Dock** (`pulseDock`): Emphasis crest above a focused primary task. Motion: controlled compression-to-rest scale. Use: urgent but deliberate primary actions.
- **Horizon Peek** (`horizonPeek`): Large preview plane above compact details. Motion: half-sheet rise. Use: media previews and location details.
- **Depth Frame** (`depthFrame`): Nested structural frame and inset content plane. Motion: depth-based scale. Use: premium previews and approvals.
- **Task Rail** (`taskRail`): Context rail beside a compact utility canvas. Motion: quick vertical entrance. Use: contextual tools and adjustments.

## Dialogs

- **Halo Focus** (`halo`): Central narrative and emphasized primary action. Motion: soft scale and fade. Use: important confirmations.
- **Split Decision** (`split`): Narrative panel beside a decision region. Motion: coordinated lateral entrance. Use: destructive and safe decisions.
- **Timeline Dialog** (`timeline`): Connected sequence driven by real external state. Motion: progress-state transitions. Use: verification and processing.
- **Spotlight Result** (`spotlight`): Orbital result mark with generous negative space. Motion: brief focal scale reveal. Use: success, warning and failure results.
- **Orbit Confirm** (`orbitConfirm`): Offset confirmation medallion and action orbit. Motion: depth scale reveal. Use: single-object confirmations.
- **Side-by-Side Choice** (`sideBySideChoice`): Equally legible choice cards with descriptions. Motion: lateral reveal. Use: plan and workflow choices.
- **Compact Alert Capsule** (`alertCapsule`): Icon and short narrative in a compact horizontal unit. Motion: quick upward reveal. Use: brief utility alerts.
- **Milestone Dialog** (`milestone`): Milestone banner with connected content below. Motion: staged upward reveal. Use: actual workflow achievements and sequence checkpoints.
- **Panel Decision** (`panelDecision`): Structured narrative panel with a stacked decision column. Motion: quiet fade. Use: high-value approvals and settings.
- **Status Beacon** (`statusBeacon`): Status rail, information region and full action row. Motion: short fade. Use: system notices and operational states.

- **Command Palette** (`commandPalette`): Searchable typed commands with description matching, disabled entries, empty results, arrow-key navigation, Enter to select and Escape to dismiss. Use `UiGalleryDialog.commands`.

## Toasts

- **Signal Pill** (`signal`): Message-sized capsule with status and dismissal. Motion: short precise vertical entrance. Use: saved changes and short updates.
- **Edge Ribbon** (`ribbon`): Edge-aligned directional accent strip. Motion: entrance from the selected edge. Use: warnings and connection errors.
- **Action Capsule** (`action`): Coordinated message and action with timeout track. Motion: slide with action feedback. Use: undo and retry.
- **Stack Tag** (`stackTag`): Labeled clipped-corner tag for grouped events. Motion: directional slide. Use: stackable compact event notices.
- **Inline Pulse** (`inlinePulse`): Flat information strip with a precise baseline. Motion: minimal fade. Use: passive synchronization updates.
- **Beacon Toast** (`beacon`): Separate circular status well and message region. Motion: small scale with slide. Use: status notices with extra context.
- **Ribbon Action Bar** (`ribbonActionBar`): Action precedes the message on a directional strip. Motion: selected-edge entrance. Use: action-first retry notifications.
- **Dock Toast** (`dock`): Wide docked status deck and divider. Motion: bottom rise. Use: persistent session and download status.
- **Snap Notice** (`snapNotice`): Small side-anchored vertical notice. Motion: quick side snap. Use: short context-specific feedback.
- **Mini Console** (`miniConsole`): Monospace status header and message log region. Motion: minimal fade. Use: developer and system information.

- **Progress Card** (`progressCard`): Determinate task progress supplied by a caller-owned notifier; stays visible until dismissed. Supports a localizable progress label and optional cancellation action. Use `UiGalleryToast.progress`.

## Header

- **Adaptive Horizon** (`adaptiveHorizon`): Title settles beside contextual actions. Motion: scroll-aware title repositioning. Use: explore and content screens.
- **Floating Arc** (`floatingArc`): Inset navigation island separated from the page. Motion: scroll-aware island transition. Use: lightweight creative navigation.
- **Compact Rail** (`compactRail`): Dense toolbar ending in a structural context rail. Motion: minimal position change. Use: utility screens with many actions.
- **Split Header** (`splitHeader`): Title/subtitle region beside an independent action zone. Motion: scroll contraction. Use: dashboards and account workspaces.
- **Focus Bar** (`focusBar`): Context toolbar above an actual editable search field. Motion: focus and compact scroll transition. Use: search-driven content discovery.
- **Panorama Bar** (`panoramaBar`): Wide background plane with a low title horizon. Motion: immersive-to-compact scroll transition. Use: media and immersive collections.
- **Layered Nav** (`layeredNav`): Navigation context above an offset title deck. Motion: layered scroll contraction. Use: nested content and collections.
- **Editorial Topbar** (`editorialTopbar`): Eyebrow/navigation row, large heading and strong rule. Motion: editorial heading settles with scroll. Use: articles and content-first pages.

- **Sculpted Wave** (`sculptedWave`): Curved lower edge with a large content heading. Use: immersive content.
- **Folded Canopy** (`foldedCanopy`): Overlapping header planes with restrained depth. Use: creative workspaces.
- **Parallax Crest** (`parallaxCrest`): Offset decorative planes behind stable controls. Use: media collections.
- **Orbit Command** (`orbitCommand`): Floating command surface with a separate action capsule. Use: compact dashboards.
- **Search Switch** (`searchSwitch`): Title switches to an editable search field; closing preserves the query. Supply `onSearchChanged` or `searchField`. Use: collections and discovery.
- **Centered Title** (`centeredTitle`): Native balanced toolbar positioning keeps a short title centered while actions remain at the end. Use: focused detail pages.
- **Breadcrumb Trail** (`breadcrumbTrail`): Scrollable breadcrumb widget in `subtitle` above the title and trailing actions. Breadcrumb navigation remains caller-owned. Use: nested workspaces.
- **Section Tabs** (`sectionTabs`): Title and context above caller-supplied `bottom`, such as a `TabBar`; use a `DefaultTabController` and `TabBarView`. Use: connected collection views.

- **Selection Bar** (`selectionBar`): Normal title becomes a localized selection count with an optional clear button and caller-supplied bulk actions. Selection and back policy stay in the application.

## Bottom navigation

- **Floating Cove** (`floatingCove`): Floating curved surface with a moving active panel.
- **Concave Notch** (`concaveNotch`): Recessed center gap for an optional primary action.
- **Convex Wave** (`convexWave`): Raised curved crest follows selection.
- **Orbit Dock** (`orbitDock`): Circular destination wells above a layered dock.
- **Ribbon Curve** (`ribbonCurve`): Directional ribbon surface with horizontal icon and label layout.
- **Layered Shelf** (`layeredShelf`): Active panel above offset structural layers.
- **Split Island** (`splitIsland`): Separate destination groups around an optional center action.
- **Perspective Dock** (`perspectiveDock`): Decorative depth planes and bounded icon tilt.
- **Morphing Capsule** (`morphingCapsule`): Selected destination receives more width for its label.
- **Adaptive Minimal** (`adaptiveMinimal`): Flat surface, adaptive labels and minimal selection indicator.
- **Glass Dock** (`glassDock`): Clipped backdrop blur with a translucent surface and moving marker. Use `Scaffold.extendBody: true` to show content beneath it. Explicit surface colors are preserved.
- **Liquid Drop** (`liquidDrop`): A connected droplet moves and compresses during selection; interrupted changes continue from the current position.
- **Scroll Dock** (`scrollDock`): Hides on downward vertical scrolling beyond the top region and reveals on upward scrolling, using the Scaffold's scroll notification observer. Hidden destinations leave focus, semantics and hit testing; selection remains caller-owned.
- **Flip Tiles** (`flipTiles`): Bounded perspective on outlined icon tiles; icon subtrees and touch targets remain stable.

- **Overflow Dock** (`overflowDock`): Responsive primary destinations plus a native More menu. `maxVisibleItems` caps the number of slots including More; narrower layouts reduce the visible count. Original indexes and disabled states are preserved.

## Design references

The new presets are independently implemented with Flutter widgets. Reference patterns were discovered through [Flutter Gems app bars](https://fluttergems.dev/app-bar-action-bar/) and [bottom navigation](https://fluttergems.dev/bottom-navigation-bar/):

- Search transition: [app_bar_with_search_switch](https://pub.dev/packages/app_bar_with_search_switch).
- Header composition and tabs: [sliver_app_bar_builder](https://pub.dev/packages/sliver_app_bar_builder) and [app_sliver](https://pub.dev/packages/app_sliver).
- Glass, liquid selection, scroll visibility and tile motion: [crystal_navigation_bar](https://pub.dev/packages/crystal_navigation_bar), [water_drop_nav_bar](https://pub.dev/packages/water_drop_nav_bar), [flutter_floating_bottom_bar](https://pub.dev/packages/flutter_floating_bottom_bar) and [flip_box_bar_plus](https://pub.dev/documentation/flip_box_bar_plus/latest/).

## Structural guarantees

All sheets accept arbitrary widgets; secondary content is optional. Split layouts stack on narrow screens. Flow keeps pages mounted. Timeline and milestone progress is supplied by the application. Toast compositions share one queue and route cleanup implementation. All headers share native navigation and scroll ownership.
