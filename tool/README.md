# Maintenance tools

From the package root, `flutter test --no-pub tool/capture_readme.dart` deliberately writes the README preview PNGs to `doc/assets/`; use the pinned Flutter 3.41.9 SDK, review the image diffs, and do not run it as part of the regression suite. The current capture tool uses the existing local SDK font path in `capture_readme.dart`.
