# Documentation maintenance

Activate Flutter 3.41.9 / Dart 3.11.5. The showcase reuses the example's existing
preset inventory and snippet generator. It changes no component implementation.

From the package root, resolve the existing dependencies with `flutter pub get`.
Then run these commands from `example/`:

```sh
flutter test --no-pub tool/export_showcase.dart
```

Back at the package root, format the generated Dart sources:

```sh
dart format example/lib/gallery/documentation_calls.dart example/lib/gallery/documentation_examples.dart
```

From `example/`, render all canonical presets, dark examples, interaction states,
and editorial boards using real Flutter widgets. Roboto and Material Icons load
from the active SDK; the Mini Console uses the system Menlo monospace font on
macOS. On another host, set `SHOWCASE_MONO_FONT` to a real installed monospace font
file. Missing fonts fail the capture instead of emitting unreadable test glyphs:

```sh
flutter test --no-pub tool/capture_showcase.dart
```

From the package root, generate the README, category catalogs, lossless component
crops, copyable source files, and capture hashes. Python 3 and `cwebp` are local
documentation tools, not package dependencies. The builder uses the active Dart
formatter; it checks all category counts, local image targets, and anchors.

```sh
python3 tool/build_showcase.py
python3 tool/build_showcase.py --check
```

The capture tests deliberately write only `doc/assets/showcase-v021/`. They never
update historical goldens or manifests. The generated examples in
`example/lib/gallery/documentation_*.dart` must be regenerated rather than edited.

## Browser preview

```sh
python3 tool/preview_showcase.py
python3 -m http.server 4173 --bind 127.0.0.1
```

Open <http://localhost:4173/build/doc-preview/README.html>. The preview parses the
actual Markdown with Dart `markdown` 7.3.0 (resolved offline in a temporary tools
package) and adds real copy controls. It does not add a project dependency. If
that parser is not cached, run `dart pub cache add markdown --version 7.3.0` first.
Generated preview HTML stays in the ignored build directory. The preview is an
approximation of GitHub/pub.dev rendering; the live pub.dev page requires a
separate publication.

README images use absolute GitHub URLs into the versioned asset directory.
The local preview maps those URLs to the checkout. They become available remotely
when the maintainer pushes the commit; nothing in this workflow pushes, publishes,
or deploys. Keep this versioned asset directory intact after release.

`.pubignore` keeps individual capture sources, goldens, and maintenance tooling
out of the package archive. The six screenshot metadata assets remain included.

The older `capture_readme.dart` tool is retained for historical previews; it is
not used to generate the new showcase and uses its original local font path.
