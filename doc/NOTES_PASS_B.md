# Margin — Notes Pass B

These six briefs precede implementation. Pass B extends the existing page-owned Notes app; it adds no backend, state framework, dependency or enum. Pass A remains reproducible through the original example constructor. All navigation variants are mutually exclusive and selected through the labeled showcase setting.

## Edge Lift sheet — `UiGallerySheetPreset.edgeLift` (Keep, 7)
- Concept: act on one note without entering the full writing editor.
- Signature: square edge shelf with the note title, current notebook and compact move/archive/save controls.
- Motion: finite edge rise; reduced motion settles immediately.
- Edge cases: Arabic actions/counts; long titles; move cancellation; deleted note; 2.0 text and keyboard insets.
- Anti-pattern avoided: inventing formatting controls unsupported by the note model.

Selected direction: a real note-action shelf over a decorative reading modal. Moving uses the existing notebook model and changes only that note.

## Split Decision dialog — `UiGalleryDialogPreset.split` (Redesign, 6)
- Concept: protect a changed draft when the writer exits.
- Signature: two consequence lanes with separate intent buttons and supporting outcome text, joined to the draft context above; stack at large text.
- Motion: finite family entrance/change; no oscillation or countdown.
- Edge cases: Keep editing retains controllers; Discard closes only the editor; save bypasses the exit guard; cancel/Escape/back never discards; real Arabic outcomes.
- Anti-pattern avoided: a generic confirmation or two equally destructive buttons disguised as choice cards.

Selected direction: consequence lanes over an icon-heavy split illustration. The primary safe action resumes writing; the destructive action explicitly discards local edits. Opt-in redesign receives a 12-cell gate.

## Inline Pulse toast — `UiGalleryToastPreset.inlinePulse` (copy/behavior reuse only; score remains 6)
- Concept: acknowledge an actual local note save without suggesting cloud synchronization.
- Signature: quiet inline status rule; no perpetual pulse and no fake progress.
- Motion: one finite reveal/fade, suppressed with reduced motion.
- Edge cases: Arabic saved/updated copy; accessibility lifetime; repeated saves; route focus stays with writing/list; 2.0 scale.
- Anti-pattern avoided: a fabricated syncing state or timer posing as persistence.

Selected direction: reuse the authored baseline with truthful local-save copy over a looping activity indicator. This is a direction brief only. The implementation reuses existing visuals and behavior with localized copy; no visual uplift was made and the score stays 6.

## Focus Bar app bar — `UiGalleryAppBarPreset.focusBar` (Keep, 7)
- Concept: keep search in reach throughout a notebook workspace.
- Signature: a permanent search lane below the heading, using the same query controller as Search Switch.
- Motion: finite layout/selection changes; reduced motion is immediate.
- Edge cases: locale and navigation-style changes retain the query; Arabic hint; no results; 2.0 text; selection temporarily owns the header.
- Anti-pattern avoided: a second search state or a field that only filters sample text visually.

Selected direction: real persistent search over another toggle. A labeled showcase header setting compares it with Search Switch without showing both at once.

## Layered Shelf nav — `UiGalleryBottomNavPreset.layeredShelf` (Redesign, 5)
- Concept: separate collection browsing, current notes and saved notes into workspace bays.
- Signature: individual inset destination bays, active top registration rule and exposed backing shelf; never a single moving capsule copied from Floating Cove.
- Motion: finite active-bay change; cheap mode retains the flat shelf; no control hit-bound transforms.
- Edge cases: Arabic ordering; 2.0 labels; selected semantics; changing presentation preserves notebook/query/destination; disabled items remain disabled.
- Anti-pattern avoided: manufacturing an extra app screen merely to give a decorative rear plane a home.

Selected direction: destination bays on one controlled shelf over additional fake workspace tabs. The existing Notes/Notebooks/Saved destinations provide real grouping; the app labels the current collection. Opt-in redesign receives a 12-cell gate.

## Scroll Dock nav — `UiGalleryBottomNavPreset.scrollDock` (copy/behavior reuse only; score remains 6)
- Concept: give the note list room while reading, restoring navigation on return scroll.
- Signature: the existing dock follows real user scroll direction and hides its focus/semantics when concealed.
- Motion: finite hide/reveal; reduced motion switches instantly.
- Edge cases: short lists stay visible; nested horizontal scrolling ignored; Arabic; restoration on reverse scroll; 2.0 text; keyboard hiding and selection state.
- Anti-pattern avoided: hiding on a timer or leaving invisible destinations focusable.

Selected direction: reuse the existing scroll observer over a separate page controller. A long test collection verifies the behavior; no manufactured product screen is added.

## Review accounting correction

Inline Pulse toast and Scroll Dock nav received copy/behavior reuse, **not a visual uplift**. Both remain scored **6** until a real visual change is rendered and approved. This correction also applies to the Notes Pass B review artifact.
