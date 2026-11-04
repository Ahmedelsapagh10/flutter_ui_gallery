# Margin — Notes Pass A

Pass A uses eight presets: Search Switch app bar, Selection Bar app bar, Command Palette dialog, Orbit Dock sheet, Stack Panel sheet, Action Capsule toast, Morphing Capsule nav and Adaptive Minimal nav. They cover the seed's validated creation, retained search, typed commands, controlled selection, archive/undo, notebook selection and a useful dense navigation fallback. The Navigation style setting is explicitly a showcase control; changing it retains destination and note state.

Pass B retains Edge Lift sheet, Split Decision dialog, Inline Pulse toast, Focus Bar app bar, Layered Shelf nav and Scroll Dock nav. Pass B is now implemented as a separate recipe entry; Pass A still exposes only its original eight presets.

## Briefs written before implementation

### Search Switch app bar — `UiGalleryAppBarPreset.searchSwitch`
- Concept: find a thought without leaving the current notebook.
- Signature: the title shares its toolbar with retained inline search.
- Motion: finite title/search crossfade, Minimal 160ms change, no motion when disabled.
- Edge cases: Arabic query/hint/semantics; empty matches; large text; search survives selection, nav style and theme changes.
- Anti-pattern avoided: a decorative search box that does not filter real notes.

Selected direction: retained inline search over a second permanent toolbar; it keeps the writing view quiet. The persistent Focus Bar remains Pass B.

### Selection Bar app bar — `UiGalleryAppBarPreset.selectionBar`
- Concept: archive a deliberate set of notes while keeping the selection count visible.
- Signature: caller-owned count and clear action replace the normal heading.
- Motion: finite 160ms contextual surface change; reduced motion is immediate.
- Edge cases: Arabic count/bulk actions; back clears selection first; selected notes can be filtered; no hidden selection gets silently discarded.
- Anti-pattern avoided: a second state owner inside the header.

Selected direction: reuse the controlled contextual header over an extra floating bulk toolbar; it preserves the seed's back policy.

### Command Palette dialog — `UiGalleryDialogPreset.commandPalette`
- Concept: create, select or change notebook through a typed keyboard command.
- Signature: searchable commands with real returned values and disabled-state navigation.
- Motion: finite Minimal 180/120ms entrance/exit; no loop.
- Edge cases: Arabic labels/descriptions/empty state; Escape and arrow keys; keyboard insets; narrow/wide layouts.
- Anti-pattern avoided: commands that merely display a toast instead of doing work.

Selected direction: dispatch typed results through page-owned actions over an independent command controller.

### Orbit Dock sheet — `UiGallerySheetPreset.orbit`
- Concept: separate the act of capturing a thought from the editable writing canvas.
- Signature: asymmetric dock with a leading capture/context rail and independent editable canvas, stacking in tight space.
- Motion: finite existing rise/fade, 180/120ms Minimal; no simulated progress.
- Edge cases: directional capture rail and Arabic copy; input validation; keyboard; long text; 2.0 text stacks the rail above content; caller-owned widget state remains mounted.
- Anti-pattern avoided: a generic rounded form differentiated only by one corner.

Selected direction: a structural capture rail beside editable content over a decorative orbital badge; it gives the asymmetric silhouette a job. This is a visual redesign and receives the full 12-cell golden gate.

### Stack Panel sheet — `UiGallerySheetPreset.stackPanel`
- Concept: browse the notebooks behind the active collection.
- Signature: two exposed backing planes remain visible in every family, even Minimal.
- Motion: finite rise/layer reveal with family timings; reduced motion settles immediately.
- Edge cases: Arabic notebook names; counts; empty notebooks; current choice; wide/narrow layouts; large text.
- Anti-pattern avoided: removing the stack to satisfy a family rule or adding a fourth plane in Spatial.

Selected direction: reuse the existing stack and show real notebook choices over another generic settings list.

### Action Capsule toast — `UiGalleryToastPreset.action`
- Concept: undo a specific archive operation without leaving the list.
- Signature: distinct trailing recovery segment separated from the message, retaining a capsule outline; stacks below at narrow/large text.
- Motion: finite vertical entrance/fade with 180/120ms Minimal timing; accessibility lifetime remains queue-owned.
- Edge cases: Arabic Undo and message; long operation text; repeated archives; action runs once; restore only this operation's notes.
- Anti-pattern avoided: Signal Pill with an optional text button appended to the same row.

Selected direction: a segmented recovery surface over an extra floating button; it makes the action visible without duplicating Ribbon Action Bar's leading dock. This redesign receives 12 golden cells.

### Morphing Capsule nav — `UiGalleryBottomNavPreset.morphingCapsule`
- Concept: make the active Notes/Notebooks/Saved destination legible without showing all labels at once.
- Signature: the active destination takes more width and keeps its semantic selection fill under Minimal.
- Motion: finite interruptible width redistribution, 160ms Minimal change.
- Edge cases: Arabic destinations and semantics; 2.0 text; retained destination and note state; keyboard hiding; wide layout.
- Anti-pattern avoided: extra navigation bars shown together to satisfy a preset checklist.

Selected direction: one controlled destination bar with a labeled showcase style setting over simultaneous docks.

### Adaptive Minimal nav — `UiGalleryBottomNavPreset.adaptiveMinimal`
- Concept: provide a conventional, compact navigation comparison for the same product destinations.
- Signature: flat ruled baseline and adaptive labels; deliberate baseline, not an ornamental uplift.
- Motion: finite selection baseline, 160ms change; reduced motion immediate.
- Edge cases: Arabic labels; large text; same retained destination state as the capsule; original indexes preserved.
- Anti-pattern avoided: changing the destination model when only presentation changes.

Selected direction: the existing neutral preset over a newly invented navigation pattern.

## Product and localization

Margin uses a slate-seeded ColorScheme, structural rules, restrained headings and real local sample notebooks. It reuses ProductivityExample's page-owned operation pattern; no repository, backend or persistence endpoint is invented. Notes contain editable titles/body text, notebook assignment and saved state. English and Arabic copy cover settings, commands, validation, empty/error states, dates, counts, tooltips and semantic labels. Locale and theme controls are labeled showcase controls.

All operations are local to this example session. No cloud synchronization or permanent saving is claimed.
