import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nova_surfaces_example/gallery/catalog.dart';

import 'support.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final preset in [
    UiGalleryBottomNavPreset.floatingCove,
    UiGalleryBottomNavPreset.glassDock,
  ]) {
    testWidgets(
      '${preset.name} native frame timings',
      (tester) async {
        expect(kProfileMode, isTrue, reason: 'Run flutter drive --profile.');
        expect(Platform.isAndroid || Platform.isIOS, isTrue);
        final design = designs.singleWhere(
          (design) => design.bottomNav == preset,
        );
        await pumpDesign(tester, design);

        Future<void> exercise() async {
          for (final index in [1, 2, 0]) {
            await selectDestination(tester, index);
          }
          final list = find.byType(ListView).hitTestable().first;
          await tester.fling(list, const Offset(0, -350), 800);
          await tester.pumpAndSettle();
          await tester.fling(list, const Offset(0, 350), 800);
          await tester.pumpAndSettle();
        }

        // Warm the destinations and shaders before collecting engine timings.
        await exercise();
        final reportKey = '${preset.name}_frames';
        await binding.watchPerformance(() async {
          for (var iteration = 0; iteration < 8; iteration++) {
            await exercise();
          }
        }, reportKey: reportKey);

        final summary = binding.reportData![reportKey] as Map<String, dynamic>;
        expect(summary['frame_count'], greaterThan(0));
        expect(tester.takeException(), isNull);
        binding.reportData!['run'] = {
          'platform': Platform.operatingSystem,
          'osVersion': Platform.operatingSystemVersion,
          'mode': 'profile',
          'iterationsPerPreset': 8,
          'destinationsPerIteration': [1, 2, 0],
          'scrollDistance': 350,
          'scrollVelocity': 800,
          'warmupIterations': 1,
        };
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  }
}
