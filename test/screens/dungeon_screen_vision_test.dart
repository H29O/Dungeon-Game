import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algorithmic_dungeon/data/sample_levels.dart';
import 'package:algorithmic_dungeon/game/game_controller.dart';
import 'package:algorithmic_dungeon/screens/dungeon_screen.dart';

void main() {
  group('DungeonScreen Algorithm Vision UI & Interactions', () {
    testWidgets('renders Algorithm Vision button in initial play state', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = GameController(level: SampleLevels.level1);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(home: DungeonScreen(controller: controller)),
      );

      expect(find.text('Algorithm Vision'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
    });

    testWidgets('tapping Algorithm Vision opens panel and shows statistics', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = GameController(level: SampleLevels.level1);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(home: DungeonScreen(controller: controller)),
      );

      // Tap Algorithm Vision
      await tester.tap(find.text('Algorithm Vision'));
      await tester.pumpAndSettle();

      // Vision panel is visible
      expect(find.text('Optimal Cost: 10'), findsOneWidget);
      expect(find.text('Step'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
      expect(find.text('Final'), findsOneWidget);
      expect(find.text('Close Vision'), findsOneWidget);
      expect(find.text('Frontier'), findsOneWidget);
      expect(find.text('Settled'), findsNWidgets(2)); // metric label and legend
      expect(find.text('Optimal Route'), findsOneWidget);

      // Manual D-Pad is hidden while Vision is active
      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsNothing);
    });

    testWidgets('tapping Step advances the step counter in the UI', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = GameController(level: SampleLevels.level1);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(home: DungeonScreen(controller: controller)),
      );

      await tester.tap(find.text('Algorithm Vision'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 0 /'), findsOneWidget);

      // Tap Step
      await tester.tap(find.text('Step'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 1 /'), findsOneWidget);

      // Tap Step again
      await tester.tap(find.text('Step'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 2 /'), findsOneWidget);
    });

    testWidgets('tapping Final fast-forwards to complete route', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = GameController(level: SampleLevels.level1);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(home: DungeonScreen(controller: controller)),
      );

      await tester.tap(find.text('Algorithm Vision'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Final'));
      await tester.pumpAndSettle();

      expect(controller.visualizationController.state?.isCompleted, isTrue);
      expect(
        controller.visualizationController.state?.finalPath.length,
        controller.visualizationController.state?.result.path.length,
      );
    });

    testWidgets('tapping Close Vision restores D-Pad controls', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = GameController(level: SampleLevels.level1);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(home: DungeonScreen(controller: controller)),
      );

      await tester.tap(find.text('Algorithm Vision'));
      await tester.pumpAndSettle();

      // Tap Close Vision
      await tester.tap(find.text('Close Vision'));
      await tester.pumpAndSettle();

      // D-Pad is restored
      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
      expect(find.text('Close Vision'), findsNothing);
      expect(controller.isShowingAlgorithm, isFalse);
    });
  });
}
