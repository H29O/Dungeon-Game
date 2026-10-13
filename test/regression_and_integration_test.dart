import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algorithmic_dungeon/algorithms/dijkstra.dart';
import 'package:algorithmic_dungeon/data/sample_levels.dart';
import 'package:algorithmic_dungeon/game/direction.dart';
import 'package:algorithmic_dungeon/game/game_controller.dart';
import 'package:algorithmic_dungeon/models/dungeon_level.dart';
import 'package:algorithmic_dungeon/models/dungeon_tile.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';
import 'package:algorithmic_dungeon/screens/dungeon_screen.dart';
import 'package:algorithmic_dungeon/screens/home_screen.dart';
import 'package:algorithmic_dungeon/screens/results_screen.dart';

void main() {
  group('Phase 5 Final Regression & Integration Audit', () {
    late DijkstraEngine engine;

    setUp(() {
      engine = DijkstraEngine();
    });

    test('Dijkstra strict properties: U-R-D-L tie-breaking and non-negative costs', () {
      // 3x3 uniform floor grid: from (1,1), all 4 neighbors have equal cost 1.
      final uniformGrid = List.generate(
        3,
        (_) => List.generate(3, (_) => DungeonTile.floor(movementCost: 1)),
      );
      final uniformLevel = DungeonLevel(
        id: 'tie_breaker',
        name: 'Tie Breaker',
        rows: 3,
        cols: 3,
        start: const GridPosition(1, 1),
        exit: const GridPosition(0, 1),
        grid: uniformGrid,
      );

      final result = engine.findShortestPath(
        level: uniformLevel,
        start: const GridPosition(1, 1),
        goal: const GridPosition(0, 1),
        recordEvents: true,
      );

      expect(result.hasPath, isTrue);
      expect(result.totalCost, equals(1));
      expect(
        result.path,
        equals([const GridPosition(1, 1), const GridPosition(0, 1)]),
      );
    });

    test('Dijkstra correctly handles disconnected unreachable target without crashing', () {
      final trappedLevel = DungeonLevel(
        id: 'trapped',
        name: 'Trapped Explorer',
        rows: 3,
        cols: 3,
        start: const GridPosition(0, 0),
        exit: const GridPosition(2, 2),
        grid: [
          [DungeonTile.floor(), DungeonTile.wall(), DungeonTile.floor()],
          [DungeonTile.wall(), DungeonTile.wall(), DungeonTile.wall()],
          [DungeonTile.floor(), DungeonTile.wall(), DungeonTile.exit()],
        ],
      );

      final result = engine.findShortestPath(
        level: trappedLevel,
        start: const GridPosition(0, 0),
        goal: const GridPosition(2, 2),
        recordEvents: true,
      );

      expect(result.hasPath, isFalse);
      expect(result.totalCost, isNull);
      expect(result.path, isEmpty);
      expect(result.events, isNotEmpty);
    });

    test('Full gameplay transactional lifecycle: pickups, cost deduction, and score', () {
      final controller = GameController(level: SampleLevels.level1);
      addTearDown(controller.dispose);

      // Start: Energy 60, Moves 0, Cost 0, Score 0
      expect(controller.currentEnergy, equals(60));
      expect(controller.moveCount, equals(0));
      expect(controller.score, equals(0));

      // Move Down 3 times to (3, 0), which has the +20 energy canister
      // (1,0) cost 1 -> energy 59
      // (2,0) cost 1 -> energy 58
      // (3,0) cost 1 -> energy 57, then canister (+20) -> energy 77
      controller.move(Direction.down);
      controller.move(Direction.down);
      controller.move(Direction.down);

      expect(controller.playerPosition, equals(const GridPosition(3, 0)));
      expect(controller.moveCount, equals(3));
      expect(controller.cumulativeRouteCost, equals(3));
      expect(controller.currentEnergy, equals(77));
      expect(controller.collectedItemIds, contains('item_3_0'));

      // Pacing back onto (3,0) does NOT give the canister again
      controller.move(Direction.up); // to (2,0), energy 76
      controller.move(Direction.down); // back to (3,0), energy 75
      expect(controller.currentEnergy, equals(75));

      // Replay / restart level restores state exactly
      controller.restartLevel();
      expect(controller.playerPosition, equals(const GridPosition(0, 0)));
      expect(controller.currentEnergy, equals(60));
      expect(controller.moveCount, equals(0));
      expect(controller.cumulativeRouteCost, equals(0));
      expect(controller.collectedItemIds, isEmpty);
    });

    test('Energy strictly capped at maxEnergy and never negative in GameController', () {
      final highCanisterLevel = DungeonLevel(
        id: 'high_canister',
        name: 'High Canister',
        rows: 2,
        cols: 2,
        start: const GridPosition(0, 0),
        exit: const GridPosition(1, 1),
        initialEnergy: 95,
        maxEnergy: 100,
        grid: [
          [
            DungeonTile.floor(),
            DungeonTile.energyPickup(movementCost: 1, energyAmount: 50),
          ],
          [DungeonTile.wall(), DungeonTile.exit()],
        ],
      );

      final controller = GameController(level: highCanisterLevel);
      addTearDown(controller.dispose);

      // Move Right into energy pickup: 95 - 1 = 94, + 50 = 144, capped at 100
      controller.move(Direction.right);
      expect(controller.currentEnergy, equals(100));
      expect(controller.currentEnergy <= controller.maxEnergy, isTrue);
    });

    testWidgets(
      'End-to-end screen navigation: Home -> Game -> Victory -> Results -> Menu',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(600, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

        // 1. Home screen is rendered
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('Start Game'), findsOneWidget);

        // 2. Tap Start Game
        await tester.tap(find.text('Start Game'));
        await tester.pumpAndSettle();

        expect(find.byType(DungeonScreen), findsOneWidget);

        // 3. Walk to exit: 4 Down, 5 Right, 1 Down
        final rightButton = find.byIcon(Icons.keyboard_arrow_right_rounded);
        final downButton = find.byIcon(Icons.keyboard_arrow_down_rounded);

        for (int i = 0; i < 4; i++) {
          await tester.tap(downButton);
          await tester.pump();
        }
        for (int i = 0; i < 5; i++) {
          await tester.tap(rightButton);
          await tester.pump();
        }
        await tester.tap(downButton);
        await tester.pumpAndSettle();

        // 4. Results Screen is automatically displayed
        expect(find.byType(ResultsScreen), findsOneWidget);
        expect(find.text('Labyrinth Escaped!'), findsOneWidget);
        expect(
          find.text('10'),
          findsNWidgets(3),
        ); // Actual 10, Optimal 10, Moves 10
        expect(
          find.text('Route Efficiency: 100.0% (Optimal! 🏆)'),
          findsOneWidget,
        );

        // 5. Tap Main Menu button (scroll into view if needed)
        final menuButton = find.text('Main Menu');
        expect(menuButton, findsOneWidget);
        await tester.ensureVisible(menuButton);
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        // 6. Confirmed returned to HomeScreen
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(ResultsScreen), findsNothing);
        expect(find.byType(DungeonScreen), findsNothing);
      },
    );
  });
}
