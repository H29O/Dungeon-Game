import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algorithmic_dungeon/data/sample_levels.dart';
import 'package:algorithmic_dungeon/game/direction.dart';
import 'package:algorithmic_dungeon/game/game_controller.dart';
import 'package:algorithmic_dungeon/models/dungeon_level.dart';
import 'package:algorithmic_dungeon/models/dungeon_tile.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';
import 'package:algorithmic_dungeon/screens/results_screen.dart';

void main() {
  group('ResultsScreen UI & Metrics', () {
    testWidgets('renders victory outcome with all required metrics', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = GameController(level: SampleLevels.level1);
      addTearDown(controller.dispose);

      // Navigate along the optimal path to victory:
      // (0,0) -> 4x Down -> 5x Right -> 1x Down -> (5,5)
      for (int i = 0; i < 4; i++) {
        controller.move(Direction.down);
      }
      for (int i = 0; i < 5; i++) {
        controller.move(Direction.right);
      }
      controller.move(Direction.down);

      expect(controller.isWon, isTrue);

      await tester.pumpWidget(
        MaterialApp(home: ResultsScreen(controller: controller)),
      );

      // Victory headline and app bar
      expect(find.text('Mission Complete'), findsOneWidget);
      expect(find.text('Labyrinth Escaped!'), findsOneWidget);

      // Route Cost comparison
      expect(find.text('Route Cost Comparison'), findsOneWidget);
      expect(find.text('Actual Route Cost'), findsOneWidget);
      expect(find.text('Optimal Dijkstra Cost'), findsOneWidget);
      expect(
        find.text('${controller.cumulativeRouteCost}'),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.text('${controller.optimalRouteCost}'),
        findsAtLeastNWidgets(1),
      );

      // Route efficiency
      expect(find.textContaining('Route Efficiency: 100.0%'), findsOneWidget);

      // Run breakdown
      expect(find.text('Run Breakdown'), findsOneWidget);
      expect(find.text('Final Score'), findsOneWidget);
      expect(find.text('Remaining Energy'), findsOneWidget);
      expect(find.text('Steps / Moves Taken'), findsOneWidget);
      expect(find.text('Treasures Collected'), findsOneWidget);
      expect(find.text('Algorithm Vision Hints Used'), findsOneWidget);

      // Actions
      expect(find.text('Replay Level'), findsOneWidget);
      expect(find.text('Main Menu'), findsOneWidget);
    });

    testWidgets('renders defeat outcome when energy is depleted', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final lowEnergyLevel = DungeonLevel(
        id: 'low_energy',
        name: 'Low Energy',
        rows: 3,
        cols: 3,
        start: const GridPosition(0, 0),
        exit: const GridPosition(2, 2),
        initialEnergy: 2,
        maxEnergy: 10,
        grid: List.generate(
          3,
          (_) => List.generate(3, (_) => DungeonTile.floor()),
        ),
      );

      final controller = GameController(level: lowEnergyLevel);
      addTearDown(controller.dispose);

      controller.move(Direction.right); // energy 1
      controller.move(Direction.right); // energy 0 -> defeat

      expect(controller.isLost, isTrue);

      await tester.pumpWidget(
        MaterialApp(home: ResultsScreen(controller: controller)),
      );

      // Defeat headline
      expect(find.text('Run Over'), findsOneWidget);
      expect(find.text('Defeat: Energy Depleted'), findsOneWidget);
      expect(find.text('0 / 10'), findsOneWidget); // 0 remaining energy
      expect(find.text('Replay Level'), findsOneWidget);
    });

    testWidgets(
      'strictly distinguishes actual route cost from optimal Dijkstra cost',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(600, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final controller = GameController(level: SampleLevels.level1);
        addTearDown(controller.dispose);

        // Make an extra detour back and forth to inflate actual route cost beyond optimal
        controller.move(Direction.right); // (0,1) cost 1
        controller.move(Direction.left); // (0,0) cost 1
        for (int i = 0; i < 4; i++) {
          controller.move(Direction.down);
        }
        for (int i = 0; i < 5; i++) {
          controller.move(Direction.right);
        }
        controller.move(Direction.down);

        expect(controller.isWon, isTrue);
        expect(controller.cumulativeRouteCost, equals(12));
        expect(controller.optimalRouteCost, equals(10));
        expect(
          controller.cumulativeRouteCost != controller.optimalRouteCost,
          isTrue,
        );

        await tester.pumpWidget(
          MaterialApp(home: ResultsScreen(controller: controller)),
        );

        // Verify both distinct costs appear in their specific cards
        // '12' appears for both Actual Route Cost and Steps Taken (12 moves)
        expect(find.text('12'), findsNWidgets(2));
        expect(find.text('10'), findsOneWidget); // Optimal Dijkstra cost
        expect(find.text('Actual Route Cost'), findsOneWidget);
        expect(find.text('Optimal Dijkstra Cost'), findsOneWidget);
        expect(find.textContaining('Route Efficiency: 83.3%'), findsOneWidget);
      },
    );

    testWidgets('tapping Replay invokes callback', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = GameController(level: SampleLevels.level1);
      addTearDown(controller.dispose);

      bool replayed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ResultsScreen(
            controller: controller,
            onReplay: () => replayed = true,
          ),
        ),
      );

      await tester.tap(find.text('Replay Level'));
      await tester.pump();

      expect(replayed, isTrue);
    });

    testWidgets('tapping Main Menu invokes callback', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = GameController(level: SampleLevels.level1);
      addTearDown(controller.dispose);

      bool wentToMenu = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ResultsScreen(
            controller: controller,
            onMainMenu: () => wentToMenu = true,
          ),
        ),
      );

      await tester.tap(find.text('Main Menu'));
      await tester.pump();

      expect(wentToMenu, isTrue);
    });
  });
}
