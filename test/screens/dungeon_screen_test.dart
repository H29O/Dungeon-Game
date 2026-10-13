import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/data/sample_levels.dart';
import 'package:algorithmic_dungeon/game/game_controller.dart';
import 'package:algorithmic_dungeon/screens/dungeon_screen.dart';
import 'package:algorithmic_dungeon/widgets/dungeon_board.dart';
import 'package:algorithmic_dungeon/widgets/movement_controls.dart';

void main() {
  group('DungeonScreen Gameplay UI', () {
    testWidgets('renders all essential gameplay widgets and stats', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: DungeonScreen()));

      // App bar & title
      expect(find.text('The Labyrinth Threshold'), findsOneWidget);

      // Stats
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('Moves'), findsOneWidget);
      expect(find.text('Route Cost'), findsOneWidget);
      expect(find.text('Score'), findsOneWidget);
      expect(find.text('60/100'), findsOneWidget);

      // Board & Controls & Legend
      expect(find.byType(DungeonBoard), findsOneWidget);
      expect(find.byType(MovementControls), findsOneWidget);
      expect(find.text('Floor'), findsOneWidget);
      expect(find.text('Rubble'), findsOneWidget);
      expect(find.text('Hazard'), findsOneWidget);
      expect(find.text('Wall'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
    });

    testWidgets('tapping Right moves player and updates energy & move count', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = GameController(level: SampleLevels.level1);

      await tester.pumpWidget(
        MaterialApp(home: DungeonScreen(controller: controller)),
      );

      expect(find.text('60/100'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(3)); // moves 0, cost 0, score 0

      // Tap Right button (icon keyboard_arrow_right_rounded)
      final rightButton = find.byIcon(Icons.keyboard_arrow_right_rounded);
      expect(rightButton, findsOneWidget);

      await tester.tap(rightButton);
      await tester.pump();

      // Energy drops by 1 to 59, moves become 1, cost becomes 1
      expect(find.text('59/100'), findsOneWidget);
      expect(controller.moveCount, equals(1));
      expect(controller.cumulativeRouteCost, equals(1));
    });

    testWidgets('restart button resets level to initial state', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = GameController(level: SampleLevels.level1);

      await tester.pumpWidget(
        MaterialApp(home: DungeonScreen(controller: controller)),
      );

      // Move Right
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right_rounded));
      await tester.pump();
      expect(find.text('59/100'), findsOneWidget);

      // Tap Restart icon
      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pump();

      // Restored
      expect(find.text('60/100'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(3));
    });

    testWidgets('pause button toggles paused banner', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = GameController(level: SampleLevels.level1);

      await tester.pumpWidget(
        MaterialApp(home: DungeonScreen(controller: controller)),
      );

      // Move once so game is playing
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right_rounded));
      await tester.pump();

      // Tap Pause icon
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();

      expect(find.text('Game Paused'), findsOneWidget);

      // Tap Resume button in banner
      await tester.tap(find.text('Resume'));
      await tester.pump();

      expect(find.text('Game Paused'), findsNothing);
    });
  });
}
