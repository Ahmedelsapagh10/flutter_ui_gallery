# Still — Wallet Pass A

Written before implementation. Still is a quiet local money ledger, distinct from Margin's editorial notebook: forest-seeded ColorScheme, compact account labels, tabular monetary figures, rounded Soft wells, precise ledger rows and explicit sample-only copy. There is no bank connection, payment, authentication, exchange-rate service or cloud synchronization. Each account owns exactly one currency. Cross-currency transfers are not offered, balances are not aggregated across currencies, and a scheduled transfer is a **local draft**, not an executed payment. The account switcher in Pass B must control these actual accounts/spaces.

## Split Layer sheet — `UiGallerySheetPreset.splitLayer` (Keep, 8)
- Concept: draft a scheduled transfer while retaining the source account and balance context.
- Signature: context beside amount/destination/date fields on wide layouts; the same content stacks on phones and at 2.0 text.
- Motion: finite family entrance/exit; reduced motion immediate, no task simulation.
- Edge cases: Arabic digits/decimal separators; positive two-decimal amount; insufficient balance; same-currency targets only; empty compatible target list; local future date and cancellation.
- Anti-pattern avoided: collecting bank credentials or showing an exchange rate invented by the example.

Selected direction: source-account context plus an editable local draft over a decorative card enrollment sheet. Confirmation uses Halo Focus and creates a retained draft without changing balances.

## Task Rail sheet — `UiGallerySheetPreset.taskRail` (Keep, 7)
- Concept: change the category assigned to one local ledger entry.
- Signature: persistent tuning rail beside the transaction label, existing category and a controlled choice list.
- Motion: finite sheet rise and controlled choice update; no repeated motion.
- Edge cases: Arabic merchant/category copy; 2.0 text; cancel preserves the original; empty activity; category changes scoped to the chosen transaction.
- Anti-pattern avoided: a fake automatic categorization service or settings that never affect the ledger.

Selected direction: edit one real entry's category over a speculative merchant-rules engine. The current model supports the former truthfully.

## Halo Focus dialog — `UiGalleryDialogPreset.halo` (brief/reuse, score remains 6)
- Concept: deliberately commit a scheduled-transfer draft to the local plan list.
- Signature: halo around the actual primary action, with source/destination, one currency, amount and date clearly stated.
- Motion: finite family dialog entrance; reduced motion immediate.
- Edge cases: cancel leaves balances and plans untouched; confirm creates one draft once; Arabic amounts/date; large text; no claim that money moved.
- Anti-pattern avoided: a success dialog masquerading as a bank transaction confirmation.

Selected direction: explicit local-plan confirmation over payment-like authorization copy. Existing visual treatment is reused; no visual uplift or score increase is claimed in Pass A.

## Status Beacon dialog — `UiGalleryDialogPreset.statusBeacon` (brief/reuse, score remains 6)
- Concept: explain local export completion, cancellation or failure with the available next action.
- Signature: status emphasis anchored to the actual caller-owned operation result.
- Motion: finite entry; status is final, never an indefinite pulsing connection claim.
- Edge cases: localized retry/cancel/empty/error copy; export generation failure; route disposal; no stale async writes; selectable local output.
- Anti-pattern avoided: manufacturing bank sync, network errors or a connection recovery screen for a local-only app.

Selected direction: truthful local statement status over a fabricated connection story. Existing visuals are reused; score remains 6 until a separately reviewed visual uplift.

## Progress Card toast — `UiGalleryToastPreset.progressCard` (Keep, 8)
- Concept: expose progress while generating the actual local statement rows, with cancellation.
- Signature: caller-owned progress value and explicit cancel; completion does not create a fake file download.
- Motion: finite toast entrance and numeric progress; no timer-based fake percentage; reduced motion still shows task state.
- Edge cases: empty statement, row processing errors, retry, cancellation, owner disposal, Arabic percentages and an injectable exporter for meaningful failure tests.
- Anti-pattern avoided: a progress bar detached from work or claiming a file was saved without a file operation.

Selected direction: build an inspectable in-memory CSV statement over simulated bank synchronization. Copy explicitly says local preview; the existing Shopping recipe's operation/cancellation pattern is the seed.

## Centered Title app bar — `UiGalleryAppBarPreset.centeredTitle` (deliberate baseline, 5)
- Concept: give the account/statement detail view a balanced, quiet identity.
- Signature: true centered Still title, with account/status context in the page and bounded utility actions.
- Motion: finite family changes; reduced motion immediate.
- Edge cases: RTL title and tooltips; 2.0 text; narrow action widths; retained account and selected destination on locale changes.
- Anti-pattern avoided: ornamental header complexity competing with monetary information.

Selected direction: keep the deliberate baseline over a new oversized finance hero bar; its score is intentionally not uplifted.

## Concave Notch nav — `UiGalleryBottomNavPreset.concaveNotch` (Keep, 8)
- Concept: activity, accounts and planned drafts surround one real create-draft action.
- Signature: recessed center slot contains a minimum-48px transfer button; selected destination remains caller-owned.
- Motion: finite selection transition; cheap mode preserves the notch and targets; reduced motion immediate.
- Edge cases: RTL logical order; 2.0 labels; tablet; keyboard hiding; empty account activity; back returns to Activity before leaving.
- Anti-pattern avoided: a center button with no action or an Orbit Dock account switcher used as a duplicate destination bar.

Selected direction: a purposeful create-draft notch over a floating decorative plus. Pass A uses no Orbit Dock nav; its account-well redesign is reserved for Pass B review.

## Pass B boundary

Orbit Confirm dialog, Milestone Dialog, Signal Pill and Orbit Dock nav are not implemented in Pass A. The proposed Orbit Dock **nav** home is a real account switcher: Personal (EGP), Shared (EGP), Savings (USD), with separate balances/activity and no currency mixing. Its five-line brief and two-direction review must still precede Pass B. It is provisional, not pre-approved merely because the data model now has accounts. If the wells do not clarify account/space identity, mark showcase-only honestly.
