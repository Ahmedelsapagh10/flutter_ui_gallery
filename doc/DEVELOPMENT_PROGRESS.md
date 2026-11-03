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

## Current phase: P1.5 — next

- Select Toast.action and AppBar.editorialTopbar from the existing audit.
- Preserve Action's proven recovery layout; improve constrained message/action
  readability. Editorial needs readable compact/large-text hierarchy within
  the existing preferred-height contract.
- Read-only preparation complete; no P1.5 implementation/pass claimed here.
- Next action: capture current Flutter before renders, implement scoped signature
  improvements, render/review/refine, tests/guards, then a separate local commit.

## Remaining sequence

P1.5 Toast + AppBar → P1.6 final Hero quality register → P2 optional coordinated
recipe and functional example → P3 discovery/snippets/documentation → P4 final
local release-readiness verification and dry-run. Update this ledger after each
verified phase. Do not report later phases complete before their gates pass.

Disk at start: approximately 1.4 GiB free. Recheck before heavy operations;
preserve SDKs, recovery evidence and user files. Native builds may need more space.
