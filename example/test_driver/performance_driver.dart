import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  timeout: const Duration(minutes: 12),
  writeResponseOnFailure: true,
  responseDataCallback: (data) async {
    await writeResponseData(
      data,
      destinationDirectory: 'build/performance',
      testOutputFilename: 'navigation_frame_timings',
    );
  },
);
