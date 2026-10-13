import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/nova_surfaces.dart';

Future<BuildContext> host(
  WidgetTester tester, {
  MediaQueryData? media,
  TextDirection direction = TextDirection.ltr,
  ThemeData? theme,
  Widget? body,
  GlobalKey<NavigatorState>? navigatorKey,
}) async {
  late BuildContext context;
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      theme: theme ?? ThemeData(colorSchemeSeed: Colors.indigo),
      builder: (context, child) => Directionality(
        textDirection: direction,
        child: MediaQuery(
          data: media ?? const MediaQueryData(size: Size(800, 600)),
          child: child!,
        ),
      ),
      home: Scaffold(
        body: Builder(
          builder: (c) {
            context = c;
            return body ?? const SizedBox();
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return context;
}

void main() {
  for (final preset in NovaSheetPreset.values) {
    testWidgets(
      '${preset.name} sheet returns a typed result and repeats safely',
      (tester) async {
        final context = await host(tester);
        for (var cycle = 0; cycle < 3; cycle++) {
          final result = NovaSheet.show<int>(
            context: context,
            preset: preset,
            header: const Text('Custom header'),
            footer: Builder(
              builder: (context) => FilledButton(
                onPressed: () => Navigator.of(context).pop(42),
                child: const Text('Done'),
              ),
            ),
            child: const Text('Custom content'),
          );
          await tester.pumpAndSettle();
          expect(find.text('Custom content'), findsOneWidget);
          await tester.tap(find.text('Done'));
          await tester.pumpAndSettle();
          expect(await result, 42);
          expect(find.text('Custom content'), findsNothing);
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets('${preset.name} handles keyboard, RTL and long content', (
      tester,
    ) async {
      final context = await host(
        tester,
        direction: TextDirection.rtl,
        media: const MediaQueryData(
          size: Size(800, 600),
          viewInsets: EdgeInsets.only(bottom: 200),
          padding: EdgeInsets.only(top: 24, bottom: 20),
          textScaler: TextScaler.linear(2),
        ),
      );
      final result = NovaSheet.show<void>(
        context: context,
        preset: preset,
        header: const Text('تفاصيل'),
        footer: const Text('Sticky footer'),
        child: Column(children: List.generate(30, (i) => Text('سطر $i'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sticky footer'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Sticky footer')).dy,
        lessThanOrEqualTo(400),
      );
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.text('Sticky footer'))).pop();
      await tester.pumpAndSettle();
      await result;
    });
  }

  testWidgets('sheet supports nested navigators and self-scrolling content', (
    tester,
  ) async {
    final nested = GlobalKey<NavigatorState>();
    late BuildContext inner;
    await host(
      tester,
      body: Navigator(
        key: nested,
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (context) {
            inner = context;
            return const Scaffold();
          },
        ),
      ),
    );
    final result = NovaSheet.show<String>(
      context: inner,
      scrollable: false,
      child: ListView(
        children: [
          for (var i = 0; i < 50; i++) ListTile(title: Text('Option $i')),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(nested.currentState!.canPop(), isTrue);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    nested.currentState!.pop('nested');
    await tester.pumpAndSettle();
    expect(await result, 'nested');
    final rootResult = NovaSheet.show<int>(
      context: inner,
      useRootNavigator: true,
      child: const Text('Root sheet'),
    );
    await tester.pumpAndSettle();
    expect(nested.currentState!.canPop(), isFalse);
    Navigator.of(tester.element(find.text('Root sheet'))).pop(7);
    await tester.pumpAndSettle();
    expect(await rootResult, 7);
  });

  testWidgets('sheet dismisses by drag and Android back', (tester) async {
    final context = await host(tester);
    final dragged = NovaSheet.show<void>(
      context: context,
      child: const SizedBox(height: 180, child: Text('Drag content')),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.text('Drag content'), const Offset(0, 350));
    await tester.pumpAndSettle();
    expect(find.text('Drag content'), findsNothing);
    await dragged;
    final back = NovaSheet.show<void>(
      context: context,
      child: const Text('Back content'),
    );
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Back content'), findsNothing);
    await back;
  });

  testWidgets('Fold retains editable content while expanding', (tester) async {
    final context = await host(tester);
    NovaSheet.show<void>(
      context: context,
      preset: NovaSheetPreset.fold,
      child: const Column(children: [TextField(), SizedBox(height: 500)]),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Keep me');
    final labels = MaterialLocalizations.of(
      tester.element(find.byType(TextField)),
    );
    await tester.tap(find.text(labels.collapsedIconTapHint));
    await tester.pumpAndSettle();
    expect(find.text('Keep me'), findsOneWidget);
    await tester.tap(find.text(labels.expandedIconTapHint));
    await tester.pumpAndSettle();
    expect(find.text('Keep me'), findsOneWidget);
    Navigator.of(tester.element(find.byType(TextField))).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('Flow keeps page state and excludes hidden-page semantics', (
    tester,
  ) async {
    var step = 0;
    late StateSetter update;
    await host(
      tester,
      body: StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return NovaFlow(
            steps: const ['Details', 'Review'],
            currentStep: step,
            children: const [
              TextField(decoration: InputDecoration(labelText: 'Name')),
              Text('Review page'),
            ],
          );
        },
      ),
    );
    await tester.enterText(find.byType(TextField), 'Nova');
    update(() => step = 1);
    await tester.pumpAndSettle();
    expect(find.text('Review page'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    update(() => step = 0);
    await tester.pumpAndSettle();
    expect(find.text('Nova'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final preset in NovaDialogPreset.values) {
    testWidgets(
      '${preset.name} dialog supports typed actions at large scale and RTL',
      (tester) async {
        final context = await host(
          tester,
          direction: TextDirection.rtl,
          media: const MediaQueryData(
            size: Size(800, 600),
            textScaler: TextScaler.linear(2.5),
          ),
        );
        final result = NovaDialog.show<int>(
          context: context,
          title: 'قرار مهم',
          message: 'هذه رسالة طويلة لاختبار المحتوى وحجم النص.',
          preset: preset,
          actions: const [
            NovaDialogAction(label: 'إلغاء', value: 0),
            NovaDialogAction(label: 'موافقة', value: 1, primary: true),
          ],
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('موافقة'));
        await tester.tap(find.text('موافقة'));
        await tester.pumpAndSettle();
        expect(await result, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('confirm handles cancellation, barriers and back navigation', (
    tester,
  ) async {
    final context = await host(tester);
    final cancel = NovaDialog.confirm(context: context, title: 'Confirm?');
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Confirm?'), findsOneWidget);
    await tester.tap(
      find.text(MaterialLocalizations.of(context).cancelButtonLabel),
    );
    await tester.pumpAndSettle();
    expect(await cancel, isFalse);
    final barrier = NovaDialog.confirm(
      context: context,
      title: 'Barrier?',
      barrierDismissible: true,
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(await barrier, isNull);
    final back = NovaDialog.confirm(context: context, title: 'Back?');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(await back, isNull);
  });

  testWidgets('dialog uses a closed keyboard focus loop', (tester) async {
    final context = await host(tester);
    NovaDialog.confirm(context: context, title: 'Keyboard?');
    await tester.pumpAndSettle();
    for (var i = 0; i < 6; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focused = FocusManager.instance.primaryFocus!.context!;
      expect(focused.findAncestorWidgetOfExactType<Dialog>(), isNotNull);
    }
    Navigator.of(tester.element(find.text('Keyboard?'))).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('timeline reacts to external progress and completion', (
    tester,
  ) async {
    final context = await host(tester);
    final progress = ValueNotifier(
      NovaTimelineState(steps: ['Upload', 'Process'], currentStep: 0),
    );
    final result = NovaDialog.timeline<void>(
      context: context,
      title: 'Actual progress',
      progress: progress,
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsNothing);
    progress.value = NovaTimelineState(
      steps: ['Upload', 'Process'],
      currentStep: 1,
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    progress.value = NovaTimelineState(
      steps: ['Upload', 'Process'],
      currentStep: 1,
      completed: true,
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
    Navigator.of(tester.element(find.text('Actual progress'))).pop();
    await tester.pumpAndSettle();
    await result;
    progress.dispose();
    expect(tester.takeException(), isNull);
  });

  for (final result in NovaResult.values) {
    testWidgets('Spotlight represents ${result.name}', (tester) async {
      final context = await host(tester);
      NovaDialog.show<void>(
        context: context,
        title: result.name,
        preset: NovaDialogPreset.spotlight,
        result: result,
      );
      await tester.pumpAndSettle();
      expect(
        find.byIcon(switch (result) {
          NovaResult.success => Icons.check_rounded,
          NovaResult.warning => Icons.priority_high_rounded,
          NovaResult.failure => Icons.close_rounded,
        }),
        findsOneWidget,
      );
      Navigator.of(tester.element(find.text(result.name))).pop();
      await tester.pumpAndSettle();
    });
  }

  testWidgets('toast queue deduplicates, preserves FIFO and closes handles', (
    tester,
  ) async {
    final context = await host(tester);
    final a = NovaToast.show(
      context,
      message: 'First',
      maxVisible: 1,
      duration: Duration.zero,
    );
    final duplicate = NovaToast.show(context, message: 'First', maxVisible: 1);
    final b = NovaToast.show(
      context,
      message: 'Second',
      maxVisible: 1,
      duration: Duration.zero,
    );
    final c = NovaToast.show(
      context,
      message: 'Third',
      maxVisible: 1,
      duration: Duration.zero,
    );
    expect(identical(a, duplicate), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);
    a.dismiss();
    await tester.pumpAndSettle();
    await a.closed;
    expect(find.text('Second'), findsOneWidget);
    c.dismiss();
    await tester.pumpAndSettle();
    await c.closed;
    b.dismiss();
    await tester.pumpAndSettle();
    await b.closed;
    expect(find.text('Second'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'toast duration begins when dequeued and respects visible limit',
    (tester) async {
      final context = await host(tester);
      NovaToast.show(
        context,
        message: 'One',
        maxVisible: 1,
        duration: const Duration(seconds: 1),
      );
      NovaToast.show(
        context,
        message: 'Two',
        maxVisible: 1,
        duration: const Duration(seconds: 1),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 950));
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Two'), findsNothing);
    },
  );

  testWidgets('toast duplicate replacement and explicit allow policy work', (
    tester,
  ) async {
    final context = await host(tester);
    final old = NovaToast.show(
      context,
      message: 'Old',
      duplicateKey: 'event',
      duration: Duration.zero,
    );
    final replacement = NovaToast.show(
      context,
      message: 'Updated',
      duplicateKey: 'event',
      duplicates: NovaToastDuplicates.replace,
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();
    await old.closed;
    expect(find.text('Old'), findsNothing);
    expect(find.text('Updated'), findsOneWidget);
    final extra = NovaToast.show(
      context,
      message: 'Updated',
      duplicates: NovaToastDuplicates.allow,
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();
    expect(find.text('Updated'), findsNWidgets(2));
    replacement.dismiss();
    extra.dismiss();
    await tester.pumpAndSettle();
  });

  testWidgets('route pop clears visible and pending toasts', (tester) async {
    final key = GlobalKey<NavigatorState>();
    await host(tester, navigatorKey: key);
    late BuildContext owner;
    key.currentState!.push(
      MaterialPageRoute<void>(
        builder: (context) {
          owner = context;
          return const Scaffold(body: Text('Owner route'));
        },
      ),
    );
    await tester.pumpAndSettle();
    final a = NovaToast.show(
      owner,
      message: 'Owned',
      duration: Duration.zero,
      maxVisible: 1,
    );
    final b = NovaToast.show(
      owner,
      message: 'Pending',
      duration: Duration.zero,
      maxVisible: 1,
    );
    await tester.pumpAndSettle();
    key.currentState!.pop();
    await tester.pumpAndSettle();
    await a.closed;
    await b.closed;
    expect(find.text('Owned'), findsNothing);
    expect(find.text('Pending'), findsNothing);
    a.dismiss();
    b.dismiss();
    expect(tester.takeException(), isNull);
  });

  testWidgets('route replacement cleans toasts without a pop gesture', (
    tester,
  ) async {
    final key = GlobalKey<NavigatorState>();
    final context = await host(tester, navigatorKey: key);
    final toast = NovaToast.show(
      context,
      message: 'Replaced owner',
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();
    key.currentState!.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const Scaffold()),
    );
    await tester.pumpAndSettle();
    await toast.closed;
    expect(find.text('Replaced owner'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('overlay disposal clears notifications and their timers', (
    tester,
  ) async {
    final context = await host(tester);
    final toast = NovaToast.show(
      context,
      message: 'Overlay scoped',
      scope: NovaToastScope.overlay,
      duration: const Duration(hours: 1),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await toast.closed;
    toast.dismiss();
    expect(tester.takeException(), isNull);
  });

  testWidgets('actionable toast stays accessible and action runs once', (
    tester,
  ) async {
    final context = await host(
      tester,
      media: const MediaQueryData(
        size: Size(800, 600),
        accessibleNavigation: true,
      ),
    );
    var actions = 0;
    final toast = NovaToast.show(
      context,
      message: 'Removed',
      preset: NovaToastPreset.action,
      duration: const Duration(milliseconds: 100),
      actionLabel: 'Undo',
      onAction: () => actions++,
      showProgress: true,
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 20));
    expect(find.text('Removed'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(actions, 1);
    await toast.closed;
  });

  for (final preset in NovaToastPreset.values) {
    testWidgets('${preset.name} toast fits narrow RTL with large text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final context = await host(
        tester,
        direction: TextDirection.rtl,
        media: const MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(2),
        ),
      );
      final toast = NovaToast.show(
        context,
        message: 'تم حفظ جميع تغييراتك بنجاح',
        preset: preset,
        actionLabel: 'تراجع',
        onAction: () {},
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      toast.dismiss();
      await tester.pumpAndSettle();
    });
  }

  testWidgets('reduced motion removes sheet, dialog and toast transitions', (
    tester,
  ) async {
    final context = await host(
      tester,
      media: const MediaQueryData(
        size: Size(800, 600),
        disableAnimations: true,
      ),
    );
    NovaSheet.show<void>(context: context, child: const Text('Instant sheet'));
    await tester.pump();
    await tester.pump();
    final route =
        ModalRoute.of(tester.element(find.text('Instant sheet')))
            as TransitionRoute;
    expect(route.transitionDuration, Duration.zero);
    Navigator.of(tester.element(find.text('Instant sheet'))).pop();
    await tester.pumpAndSettle();
    NovaDialog.confirm(context: context, title: 'Instant dialog');
    await tester.pump();
    await tester.pump();
    final dialog =
        ModalRoute.of(tester.element(find.text('Instant dialog')))
            as TransitionRoute;
    expect(dialog.transitionDuration, Duration.zero);
    Navigator.of(tester.element(find.text('Instant dialog'))).pop();
    await tester.pumpAndSettle();
    final toast = NovaToast.show(
      context,
      message: 'Instant toast',
      showProgress: true,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Instant toast'), findsOneWidget);
    toast.dismiss();
    await tester.pumpAndSettle();
    expect(find.text('Instant toast'), findsNothing);
  });

  testWidgets('NovaTheme overrides and light/dark themes resolve correctly', (
    tester,
  ) async {
    for (final brightness in Brightness.values) {
      final context = await host(
        tester,
        theme: ThemeData(
          brightness: brightness,
          extensions: const [
            NovaTheme(
              surfaceColor: Colors.amber,
              contentColor: Colors.black,
              accentColor: Colors.purple,
            ),
          ],
        ),
      );
      NovaDialog.confirm(context: context, title: 'Theme');
      await tester.pumpAndSettle();
      expect(
        tester.widget<Dialog>(find.byType(Dialog)).backgroundColor,
        Colors.amber,
      );
      Navigator.of(tester.element(find.text('Theme'))).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets(
    'Horizon follows scroll without a controller and preserves back navigation',
    (tester) async {
      final key = GlobalKey<NavigatorState>();
      await host(tester, navigatorKey: key);
      key.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: const NovaAppBar(
              title: Text('Explore'),
              subtitle: Text('Expanded subtitle'),
              scrollAware: true,
            ),
            body: ListView(
              children: List.generate(
                30,
                (i) => ListTile(title: Text('Row $i')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Expanded subtitle'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Expanded subtitle'), findsNothing);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Explore'), findsNothing);
    },
  );

  testWidgets(
    'sliver Horizon fits RTL and large text with contextual actions',
    (tester) async {
      await host(
        tester,
        direction: TextDirection.rtl,
        media: const MediaQueryData(
          size: Size(800, 600),
          textScaler: TextScaler.linear(2),
        ),
        body: CustomScrollView(
          slivers: [
            NovaSliverAppBar(
              title: const Text('استكشف'),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 1600)),
          ],
        ),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('استكشف'), findsOneWidget);
    },
  );
}
