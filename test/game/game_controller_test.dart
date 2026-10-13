import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/data/sample_levels.dart';
import 'package:algorithmic_dungeon/game/direction.dart';
import 'package:algorithmic_dungeon/game/game_controller.dart';
import 'package:algorithmic_dungeon/models/dungeon_level.dart';
import 'package:algorithmic_dungeon/models/dungeon_tile.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';
import 'package:algorithmic_dungeon/models/player_state.dart';

void main() {
  group('GameController Movement & Transactions', () {
    late DungeonLevel level;
    late GameController controller;

    setUp(() {
      level = SampleLevels.level1;
      controller = GameController(level: level);
    });

    test('initializes with level start position and initial parameters', () {
      expect(controller.playerPosition, equals(level.start));
      expect(controller.currentEnergy, equals(level.initialEnergy));
      expect(controller.maxEnergy, equals(level.maxEnergy));
      expect(controller.moveCount, equals(0));
      expect(controller.cumulativeRouteCost, equals(0));
      expect(controller.score, equals(0));
      expect(controller.status, equals(GameStatus.ready));
      expect(controller.movementHistory, equals([level.start]));
      expect(controller.lastRejectionReason, isNull);
    });

    test('valid move deducts cost, increments moves and route cost', () {
      // (0,0) -> (0,1) is floor with entry cost 1
      final success = controller.move(Direction.right);

      expect(success, isTrue);
      expect(controller.playerPosition, equals(const GridPosition(0, 1)));
      expect(controller.currentEnergy, equals(level.initialEnergy - 1));
      expect(controller.moveCount, equals(1));
      expect(controller.cumulativeRouteCost, equals(1));
      expect(controller.status, equals(GameStatus.playing));
      expect(controller.lastRejectionReason, isNull);
      expect(controller.movementHistory.length, equals(2));
    });

    test('movement into a wall is rejected with no state mutations', () {
      // From (0,0), Down is (1,0) [Floor]. Right is (0,1) [Floor].
      // Move Right to (0,1). From (0,1), Right is (0,2) [Rubble: cost 3], Down is (1,1) [WALL].
      controller.move(Direction.right); // At (0,1)
      final energyBefore = controller.currentEnergy;
      final movesBefore = controller.moveCount;
      final costBefore = controller.cumulativeRouteCost;
      final scoreBefore = controller.score;
      final posBefore = controller.playerPosition;

      // Attempt moving into wall at (1,1)
      final success = controller.move(Direction.down);

      expect(success, isFalse);
      expect(controller.playerPosition, equals(posBefore));
      expect(controller.currentEnergy, equals(energyBefore));
      expect(controller.moveCount, equals(movesBefore));
      expect(controller.cumulativeRouteCost, equals(costBefore));
      expect(controller.score, equals(scoreBefore));
      expect(controller.lastRejectionReason, contains('wall'));
    });

    test('out-of-bounds movement is rejected with no state mutations', () {
      // At (0,0), Up is (-1,0) [OOB] and Left is (0,-1) [OOB]
      final energyBefore = controller.currentEnergy;
      final movesBefore = controller.moveCount;

      final successUp = controller.move(Direction.up);
      expect(successUp, isFalse);
      expect(controller.playerPosition, equals(const GridPosition(0, 0)));
      expect(controller.currentEnergy, equals(energyBefore));
      expect(controller.moveCount, equals(movesBefore));
      expect(controller.lastRejectionReason, contains('boundaries'));

      final successLeft = controller.move(Direction.left);
      expect(successLeft, isFalse);
      expect(controller.playerPosition, equals(const GridPosition(0, 0)));
      expect(controller.currentEnergy, equals(energyBefore));
      expect(controller.moveCount, equals(movesBefore));
    });

    test(
      'insufficient energy movement is rejected with no state mutations',
      () {
        // Create a level with a high-cost cell and low player energy
        final lowEnergyGrid = [
          [
            DungeonTile.floor(movementCost: 1),
            DungeonTile.hazard(movementCost: 15),
          ],
          [DungeonTile.wall(), DungeonTile.exit(movementCost: 1)],
        ];
        final lowEnergyLevel = DungeonLevel(
          id: 'low_e',
          name: 'Low Energy',
          rows: 2,
          cols: 2,
          grid: lowEnergyGrid,
          start: const GridPosition(0, 0),
          exit: const GridPosition(1, 1),
          initialEnergy: 5, // Less than hazard cost 15
          maxEnergy: 50,
        );
        final lowEController = GameController(level: lowEnergyLevel);

        // Attempt to enter hazard (cost 15) with only 5 energy
        final success = lowEController.move(Direction.right);

        expect(success, isFalse);
        expect(lowEController.playerPosition, equals(const GridPosition(0, 0)));
        expect(lowEController.currentEnergy, equals(5));
        expect(lowEController.moveCount, equals(0));
        expect(
          lowEController.lastRejectionReason,
          contains('Insufficient energy'),
        );
      },
    );

    test('movement while paused is rejected', () {
      controller.move(Direction.right); // At (0,1), playing
      controller.pause();
      expect(controller.isPaused, isTrue);

      final posBefore = controller.playerPosition;
      final energyBefore = controller.currentEnergy;

      final success = controller.move(Direction.left);
      expect(success, isFalse);
      expect(controller.playerPosition, equals(posBefore));
      expect(controller.currentEnergy, equals(energyBefore));
      expect(controller.lastRejectionReason, contains('paused'));

      // Resuming restores movement
      controller.resume();
      expect(controller.isPlaying, isTrue);
      final successResume = controller.move(Direction.left);
      expect(successResume, isTrue);
    });

    test('energy pickup applies after movement deduction and caps at maxEnergy', () {
      // In SampleLevels.level1, (3,0) has an energy canister (+20 energy).
      // Path from (0,0) down col 0:
      // (0,0) -> (1,0) [cost 1] -> (2,0) [cost 1] -> (3,0) [cost 1, +20 energy]
      // Start energy: 60, Max energy: 100.
      controller.move(Direction.down); // to (1,0): energy 59
      controller.move(Direction.down); // to (2,0): energy 58
      controller.move(
        Direction.down,
      ); // to (3,0): 58 - 1 (entry cost) + 20 (pickup) = 77

      expect(controller.playerPosition, equals(const GridPosition(3, 0)));
      expect(controller.currentEnergy, equals(77));
      expect(controller.collectedItemIds.contains('item_3_0'), isTrue);

      // Stepping off and returning does not collect again
      controller.move(Direction.up); // to (2,0): 77 - 1 = 76
      controller.move(
        Direction.down,
      ); // to (3,0): 76 - 1 = 75 (no extra energy)
      expect(controller.currentEnergy, equals(75));
    });

    test('treasure item awards points exactly once', () {
      // In SampleLevels.level1:
      // (0,0) -> (0,1)[c:1] -> (0,2)[rubble c:3] -> (0,3)[c:1] -> (0,4)[treasure +100, c:1]
      controller.move(Direction.right); // (0,1)
      controller.move(Direction.right); // (0,2) rubble
      controller.move(Direction.right); // (0,3)
      controller.move(Direction.right); // (0,4) treasure

      expect(controller.playerPosition, equals(const GridPosition(0, 4)));
      expect(controller.score, equals(100));
      expect(controller.collectedItemIds.contains('item_0_4'), isTrue);

      // Stepping off and returning does not award duplicate treasure
      controller.move(Direction.left); // (0,3)
      controller.move(Direction.right); // (0,4)
      expect(controller.score, equals(100)); // Still 100
    });

    test('exit detection triggers victory and rejects subsequent movement', () {
      // Reach exit at (5,5) via row 4:
      // (0,0) -> (1,0) -> (2,0) -> (3,0) -> (4,0)
      controller.move(Direction.down);
      controller.move(Direction.down);
      controller.move(Direction.down);
      controller.move(Direction.down); // At (4,0)

      // (4,0) -> (4,1) -> (4,2) -> (4,3) -> (4,4) -> (4,5)
      controller.move(Direction.right);
      controller.move(Direction.right);
      controller.move(Direction.right);
      controller.move(Direction.right);
      controller.move(Direction.right); // At (4,5)

      // Move into Exit at (5,5)
      final exitSuccess = controller.move(Direction.down);
      expect(exitSuccess, isTrue);
      expect(controller.playerPosition, equals(const GridPosition(5, 5)));
      expect(controller.isWon, isTrue);
      expect(controller.status, equals(GameStatus.won));
      expect(controller.score, greaterThanOrEqualTo(100)); // Completion bonus

      // Subsequent movement is rejected
      final moveAfterWin = controller.move(Direction.up);
      expect(moveAfterWin, isFalse);
      expect(controller.lastRejectionReason, contains('completed'));
    });

    test('energy depletion triggers loss condition and rejects movement', () {
      // Grid with high hazard costs and minimal energy
      final trapGrid = [
        [
          DungeonTile.floor(movementCost: 1),
          DungeonTile.hazard(movementCost: 5),
          DungeonTile.exit(movementCost: 1),
        ],
      ];
      final trapLevel = DungeonLevel(
        id: 'trap',
        name: 'Trap',
        rows: 1,
        cols: 3,
        grid: trapGrid,
        start: const GridPosition(0, 0),
        exit: const GridPosition(0, 2),
        initialEnergy: 5,
        maxEnergy: 10,
      );
      final trapController = GameController(level: trapLevel);

      // Move into hazard (cost 5) with 5 energy -> new energy = 0
      final moveResult = trapController.move(Direction.right);
      expect(moveResult, isTrue);
      expect(trapController.currentEnergy, equals(0));
      expect(trapController.isLost, isTrue);
      expect(trapController.status, equals(GameStatus.lost));

      // Attempting to move from lost state is rejected
      final moveAfterLoss = trapController.move(Direction.right);
      expect(moveAfterLoss, isFalse);
      expect(trapController.lastRejectionReason, contains('depleted'));
    });

    test(
      'restart restores initial state, clears history and collected items',
      () {
        controller.move(Direction.down);
        controller.move(Direction.down);
        controller.move(Direction.down); // Collected energy at (3,0)

        expect(controller.moveCount, greaterThan(0));
        expect(controller.movementHistory.length, greaterThan(1));
        expect(controller.collectedItemIds, isNotEmpty);

        controller.restartLevel();

        expect(controller.playerPosition, equals(level.start));
        expect(controller.currentEnergy, equals(level.initialEnergy));
        expect(controller.maxEnergy, equals(level.maxEnergy));
        expect(controller.moveCount, equals(0));
        expect(controller.cumulativeRouteCost, equals(0));
        expect(controller.score, equals(0));
        expect(controller.status, equals(GameStatus.ready));
        expect(controller.collectedItemIds, isEmpty);
        expect(controller.movementHistory, equals([level.start]));
        expect(controller.lastRejectionReason, isNull);
      },
    );
  });
}
