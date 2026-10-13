import 'package:flutter_test/flutter_test.dart';

import 'package:algorithmic_dungeon/data/sample_levels.dart';
import 'package:algorithmic_dungeon/game/direction.dart';
import 'package:algorithmic_dungeon/game/game_controller.dart';
import 'package:algorithmic_dungeon/models/dungeon_level.dart';
import 'package:algorithmic_dungeon/models/dungeon_tile.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';
import 'package:algorithmic_dungeon/models/player_state.dart';

void main() {
  group('GameController Algorithm Vision & Game-State Isolation', () {
    late GameController controller;

    setUp(() {
      controller = GameController(level: SampleLevels.level1);
    });

    tearDown(() {
      controller.dispose();
    });

    test('startAlgorithmVision captures current position as source and computes route', () {
      expect(controller.isShowingAlgorithm, isFalse);
      expect(controller.playerPosition, const GridPosition(0, 0));

      controller.startAlgorithmVision();

      expect(controller.isShowingAlgorithm, isTrue);
      expect(controller.visualizationController.isActive, isTrue);
      final state = controller.visualizationController.state!;
      expect(state.source, const GridPosition(0, 0));
      expect(state.target, const GridPosition(5, 5));
      expect(state.result.hasPath, isTrue);
      expect(state.result.totalCost, 10);
    });

    test('startAlgorithmVision uses player location after manual movement', () {
      // Move Right to (0, 1)
      final moved = controller.move(Direction.right);
      expect(moved, isTrue);
      expect(controller.playerPosition, const GridPosition(0, 1));
      expect(controller.moveCount, 1);
      expect(controller.currentEnergy, 59);

      controller.startAlgorithmVision();

      final state = controller.visualizationController.state!;
      expect(state.source, const GridPosition(0, 1));
      expect(state.target, const GridPosition(5, 5));
      expect(state.result.hasPath, isTrue);
      // Route starting at (0, 1) to (5, 5) optimal cost is 11
      expect(state.result.totalCost, 11);
      expect(state.result.path.first, const GridPosition(0, 1));
      expect(state.result.path.last, const GridPosition(5, 5));
    });

    test('CRITICAL: Algorithm Vision never mutates gameplay state', () {
      // Record initial state snapshot
      final initialPosition = controller.playerPosition;
      final initialEnergy = controller.currentEnergy;
      final initialScore = controller.score;
      final initialMoves = controller.moveCount;
      final initialCost = controller.cumulativeRouteCost;
      final initialCollected = Set<String>.from(controller.collectedItemIds);

      // Activate vision
      controller.startAlgorithmVision();

      // Assert complete isolation
      expect(controller.playerPosition, initialPosition);
      expect(controller.currentEnergy, initialEnergy);
      expect(controller.score, initialScore);
      expect(controller.moveCount, initialMoves);
      expect(controller.cumulativeRouteCost, initialCost);
      expect(controller.collectedItemIds, initialCollected);

      // Fast-forward final path inside visualization
      controller.visualizationController.showFinalPath();

      // Assert state remains completely untouched
      expect(controller.playerPosition, initialPosition);
      expect(controller.currentEnergy, initialEnergy);
      expect(controller.score, initialScore);
      expect(controller.moveCount, initialMoves);
      expect(controller.cumulativeRouteCost, initialCost);
      expect(controller.collectedItemIds, initialCollected);
    });

    test('movement is strictly rejected while Algorithm Vision is active', () {
      controller.startAlgorithmVision();

      // Attempt to move while in vision mode
      final moved = controller.move(Direction.right);
      expect(moved, isFalse);
      expect(controller.playerPosition, const GridPosition(0, 0));
      expect(controller.currentEnergy, 60);
      expect(controller.moveCount, 0);
      expect(
        controller.lastRejectionReason,
        contains('Cannot move while Algorithm Vision is active'),
      );
    });

    test(
      'closeAlgorithmVision clears visualization and restores play state',
      () {
        controller.startAlgorithmVision();
        expect(controller.isShowingAlgorithm, isTrue);

        controller.closeAlgorithmVision();
        expect(controller.isShowingAlgorithm, isFalse);
        expect(controller.visualizationController.isActive, isFalse);

        // Now manual movement succeeds again
        final moved = controller.move(Direction.right);
        expect(moved, isTrue);
        expect(controller.playerPosition, const GridPosition(0, 1));
      },
    );

    test('restartLevel invalidates active visualization and restores initial level', () {
      controller.move(Direction.right);
      controller.startAlgorithmVision();
      controller.visualizationController.step();
      expect(controller.visualizationController.state?.currentStep, 1);

      controller.restartLevel();

      expect(controller.visualizationController.isActive, isFalse);
      expect(controller.isShowingAlgorithm, isFalse);
      expect(controller.status, GameStatus.ready);
      expect(controller.playerPosition, const GridPosition(0, 0));
      expect(controller.currentEnergy, 60);
      expect(controller.moveCount, 0);
    });

    test('handles wall-blocked unreachable destination safely', () {
      final wallBlockedLevel = DungeonLevel(
        id: 'blocked_level',
        name: 'Blocked Exit Level',
        rows: 2,
        cols: 2,
        start: const GridPosition(0, 0),
        exit: const GridPosition(1, 1),
        grid: [
          [DungeonTile.floor(), DungeonTile.wall()],
          [DungeonTile.wall(), DungeonTile.exit()],
        ],
        initialEnergy: 50,
        maxEnergy: 50,
      );

      final blockedController = GameController(level: wallBlockedLevel);
      addTearDown(blockedController.dispose);

      blockedController.startAlgorithmVision();

      final state = blockedController.visualizationController.state!;
      expect(state.result.hasPath, isFalse);
      expect(state.result.totalCost, isNull);
    });

    test('startAlgorithmVision increments hintUsageCount exactly once per activation', () {
      expect(controller.hintUsageCount, equals(0));

      controller.startAlgorithmVision();
      expect(controller.hintUsageCount, equals(1));

      controller.closeAlgorithmVision();
      expect(controller.hintUsageCount, equals(1));

      controller.startAlgorithmVision();
      expect(controller.hintUsageCount, equals(2));

      controller.restartLevel();
      expect(controller.hintUsageCount, equals(0));
    });

    test(
      'optimalRouteCost returns 10 and routeEfficiency computes accurately',
      () {
        expect(controller.optimalRouteCost, equals(10));
        expect(controller.routeEfficiency, equals(100.0));

        // After 4 down, 5 right, 1 down (cost 10):
        for (int i = 0; i < 4; i++) {
          controller.move(Direction.down);
        }
        for (int i = 0; i < 5; i++) {
          controller.move(Direction.right);
        }
        controller.move(Direction.down);

        expect(controller.isWon, isTrue);
        expect(controller.cumulativeRouteCost, equals(10));
        expect(controller.optimalRouteCost, equals(10));
        expect(controller.routeEfficiency, equals(100.0));
      },
    );

    test('collectedTreasuresCount increments when treasure is collected', () {
      expect(controller.collectedTreasuresCount, equals(0));

      // Move toward treasure at (0, 4) on level1:
      // (0,0) -> R -> R -> R -> R
      controller.move(Direction.right); // (0, 1)
      controller.move(Direction.right); // (0, 2) rubble
      controller.move(Direction.right); // (0, 3) floor
      controller.move(Direction.right); // (0, 4) treasure!

      expect(controller.collectedTreasuresCount, equals(1));
      expect(controller.score, equals(100));
    });
  });
}
