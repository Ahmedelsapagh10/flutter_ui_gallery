# Product evolution progress

Local development only. Remote push, workflows, merge, deployment and publication
remain separately authorized actions. Historical PNGs and manifests are immutable.

## Verified starting point — 2026-11-03

Branch: `design-overhaul`; clean starting HEAD:
`5c595218bedecf1ce20012c2c2c3cb3fb6ac4c14`.

- P1.2 complete: `76e8608`, followed by independent repeated-row focus fix
  `f9eeed8`. Capsule design remains approved; palette focus and Enter cues agree.
- P1.3 complete: `5c59521`, Split and SideBySideChoice implementations and
  strict versioned expectations.
- Previous verified matrix: Flutter 3.41.9 package 667 / example 317;
  Flutter 3.47.9 compatible package 643 / example 211. Those counts describe
  P1.3, not new source. Both SDKs analyzed 396 snippets. Physical-device,
  screen-reader, real IME and performance evidence remain unverified.
- Evidence root: local Codex visualization directory
  `2026/11/02/01a19dfe-66b2-7291-b1a2-1164e743e729/`;
  P1.3 full report is in `p1-3-dialog-implementation/report.md`.

## P1.4 — locally verified; commit containing this entry

- Orbit: preserve asymmetry; remove empty context band and improve content focus.
- SplitLayer selected over TaskRail: audit 53/65 versus an already strong
  TaskRail 58/65. Address compact context/content/action ordering and retained
  form state across responsive reflow.
- Actual before/after evidence: `p1-4-sheet-implementation/` under the same root.
- Complete final matrix: pinned 3.41.9 package 667 / example 407, zero strict
  golden failures; stable 3.47.9 compatible package 643 / example 277.
- Both SDKs pass three snippet checks / 396 helpers and analysis. Pinned format
  checks 66 files with zero changes. All historical/font guards pass.
- 66 new sheet behavior cases; 60 final actual render cases; 54 before/after
  pairs. 40 new versioned expectations (12 existing Orbit, four Wallet
  SplitLayer, 24 new specimens), preserving all 173 prior PNGs/manifests.
- Fixed compact keyboard overflow, preserved caller form/scroll position across
  layout changes, and reserved Spatial edge space after render inspection.
- One validation command used the wrong checkout and produced incompatible
  generated shader assets. Those assets were preserved separately and rebuilt
  by the pinned SDK; the full final package suite then passed.
- Reclaimed 560 MiB only from the previously explicitly approved unopened,
  unchanged Gradle transform folder. No SDK/user/recovery/evidence deletion.

## P1.5 — locally verified; commit containing this entry

- Action Toast: full-width long/scaled messages, readable recovery action and
  48px Close. FIFO, duplicate handling, timers and overlay architecture retained.
- EditorialTopbar: quiet host-theme hierarchy, whole-word reading width, large
  text heading priority, stable actions; internal reading scroll isolated from
  caller primary controller and scroll-aware collapse. Signature-off unchanged.
- Actual render evidence: `p1-5-feedback-header-implementation/gallery.html`
  under the existing external evidence root. 54 before/after pairs, exact masks,
  three historical migrations and three extreme Arabic reading captures.
- Pinned 3.41.9: 667 package / 468 example passes, including strict goldens.
  Stable 3.47.9 isolated checkout: 643 package / 314 compatible example passes.
- 37 focused behavior cases; 24 new strict specimens; 3 reviewed Action 2x
  migrations in feedback-calm-v1. All 213 prior PNGs and seven associated
  protected metadata files unchanged. All current hash/font guards pass.
- Both SDKs pass 396 generated helpers / three snippet checks and analysis.
  Final pinned format: 69 files, zero changes. After two test-only lint fixes,
  affected pinned 42 tests and stable Action 18 + snippets 3 tests passed again.
- Actual gallery browser verification: 174 images decoded, zero failed images,
  no horizontal page overflow. This validates evidence presentation, not native UI.
- Trade-off: fixed 128px Editorial header requires reading gestures at extreme
  3x Arabic; 2x tested headings fully initially visible. Native screen readers,
  physical devices, real IME and measured performance remain unverified.
- Recovered 618,466,088 bytes only from the explicitly approved unused compiler
  cache. Automatic review initially rejected deletion; user then explicitly
  approved this exact scope. No other deletion performed.

## Current checkpoint — P1.6 next

- P1.4 commit: `4f4bd51f129511f722454dcdaaaff4b5e538b27a`.
- Finish this P1.5 focused commit; record SHA in external commit.json.
- Next batch: AdaptiveMinimal + LayeredShelf scaled navigation labels. Read-only
  findings and exact evidence hashes are in `p1-6-preparation/next-batch.md`.
  Fixed horizontal breakpoint ignores actual font/scaler; measure label width,
  preserve signature-off behavior, test scroll/focus reachability. Then address
  SelectionBar localized count visibility while preserving full semantics.
- Preserve proposed/approved distinction for final 20 register, including two
  conditional showcase entries. No inferred /100 scores from earlier /65 audit.
- P1.6 implementation and P2/P3/P4 are not complete. Continue in required order.
- Available disk about 580 MiB at checkpoint: recheck before Flutter/native builds.

## Remaining sequence

P1.5 Toast + AppBar → P1.6 final Hero quality register → P2 optional coordinated
recipe and functional example → P3 discovery/snippets/documentation → P4 final
local release-readiness verification and dry-run. Update this ledger after each
verified phase. Do not report later phases complete before their gates pass.

Disk at start: approximately 1.4 GiB free. Recheck before heavy operations;
preserve SDKs, recovery evidence and user files. Native builds may need more space.
