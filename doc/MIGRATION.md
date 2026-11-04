# Migration

## 0.2.0 → 0.2.1

This patch changes documentation, captures, and example tooling. Public APIs,
runtime dependencies, SDK constraints, and component implementations are unchanged.
No application migration or Android/iOS configuration changes are required.

The new screenshots explicitly enable the Soft family with `useSignature: true`.
An existing app does not opt into those signatures by upgrading. Apply the shown
theme when you want the same treatment; keep your own theme and state otherwise.

## Upgrading from 0.1.x

The `UiGallery*` APIs, `Nova*` compatibility aliases, and canonical preset identities
remain available. Family geometry, typography, and motion changed in 0.2.0 even
with signatures disabled, so compare your app's screenshots and custom shape/style
assumptions. Structural redesigns require `useSignature: true`.

- [Signature precedence and exceptions](FAMILY_SIGNATURES.md)
- [Caller-owned state and integration](INTEGRATION.md)
- [Compatibility and verification](VERIFICATION.md)
- [Changelog](../CHANGELOG.md)
