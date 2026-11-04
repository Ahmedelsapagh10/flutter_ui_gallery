The native smoke test runs the existing playground and navigation demos on
Android and iOS. CI builds an Android release APK and an unsigned iOS release,
then runs the smoke test on an Android emulator and an iPhone simulator. The
package and example suites also run on Flutter 3.41.9 (Dart 3.11.5) and the
current stable SDK; formatting and visual baselines use the pinned SDK on macOS.

From `example`, run the smoke test on a connected device or running simulator:

```sh
flutter test integration_test/native_smoke_test.dart -d <device-id>
```

For performance, connect a physical Android or iOS device and run:

```sh
flutter drive --profile --no-dds -d <device-id> \
  --driver=test_driver/performance_driver.dart \
  --target=integration_test/navigation_performance_test.dart
```

The performance test rejects non-profile builds. It warms the existing Floating
Cove and Glass Dock demos, then measures eight rounds of destination changes and
scrolling using `IntegrationTestWidgetsFlutterBinding.watchPerformance`. The
driver writes real engine build/raster frame timings, frame counts, percentile
summaries, and run metadata to
`example/build/performance/navigation_frame_timings.json`. A failed run can
produce partial data; always check the test exit status before using its report.

Keep the device model, display refresh rate, Flutter version, OS version,
renderer, thermal state, and power settings alongside each report when comparing
runs. Use the same physical device and settings for comparisons. No universal
frame-time threshold is enforced, and emulator smoke results are not performance
measurements. iOS physical runs require the usual local signing configuration.
No measured performance results are checked into this repository.
