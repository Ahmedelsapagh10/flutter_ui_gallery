# Compatibility and visual verification

Moved from the 0.2.0 README to keep the package introduction focused on components.

## Compatibility and verification

The `UiGallery*` APIs, `Nova*` compatibility aliases and canonical preset identities
remain available. The 0.2.0 structural redesigns require `useSignature: true`.
Compared with published 0.1.0, family geometry, typography and motion have also
been refined with signatures disabled. Source compatibility does not imply
pixel-identical appearance: compare application screenshots and custom shape/
style assumptions when upgrading or enabling signatures. Historical golden
PNGs and hash manifests are preserved; intentional changes use named versioned
expectations with strict comparisons.

At compact widths, scaled navigation labels may require horizontal scrolling.
EditorialTopbar retains its fixed preferred height: at extreme **3× Arabic**, its
heading and supporting copy require reading gestures. Native screen-reader access
to that arrangement remains **unverified**, not fully accepted accessibility evidence.
Widget semantics and keyboard tests do not prove TalkBack or VoiceOver quality.

Run the repository's pinned checks with Flutter 3.41.9:

```sh
python3 tool/check_golden_hashes.py
python3 tool/check_notes_pins.py
python3 tool/check_still_pins.py
flutter test --no-pub
cd example
flutter test --no-pub test
flutter test --no-pub test/snippet_test.dart --dart-define=WRITE_SNIPPET_FIXTURE=true
flutter analyze --no-pub ..
```

Resolve package and example dependencies first. `check_notes_pins.py` reads
`flutter` from `PATH`, so activate the pinned SDK before running it. The snippet
command writes a temporary analyzer fixture; preserve it as evidence or remove
only that generated fixture after analysis. Current-stable behavior runs exclude
renderer-specific tests with `--exclude-tags golden`. Never regenerate historical
goldens to resolve failures. Remote CI, native builds, physical-device testing and
measured performance are separate evidence, not implied by local widget tests.


See [release policy](REDESIGN_RELEASE_POLICY.md) for hosted release gates.
