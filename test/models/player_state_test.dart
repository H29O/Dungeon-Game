import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';
import 'package:algorithmic_dungeon/models/player_state.dart';

void main() {
  group('PlayerState', () {
    test('initial factory sets default gameplay parameters', () {
      final state = PlayerState.initial(
        startPosition: const GridPosition(1, 1),
        initialEnergy: 80,
        maxEnergy: 100,
      );

      expect(state.position, equals(const GridPosition(1, 1)));
      expect(state.currentEnergy, equals(80));
      expect(state.maxEnergy, equals(100));
      expect(state.score, equals(0));
      expect(state.moveCount, equals(0));
      expect(state.cumulativeRouteCost, equals(0));
      expect(state.status, equals(GameStatus.ready));
      expect(state.collectedItemIds, isEmpty);
      expect(state.hintUsageCount, equals(0));
    });

    test('copyWith updates specified fields and preserves others', () {
      final initial = PlayerState.initial(
        startPosition: const GridPosition(0, 0),
      );

      final moved = initial.copyWith(
        position: const GridPosition(0, 1),
        currentEnergy: 95,
        moveCount: 1,
        cumulativeRouteCost: 5,
        status: GameStatus.playing,
      );

      expect(moved.position, equals(const GridPosition(0, 1)));
      expect(moved.currentEnergy, equals(95));
      expect(moved.moveCount, equals(1));
      expect(moved.cumulativeRouteCost, equals(5));
      expect(moved.status, equals(GameStatus.playing));
      expect(moved.maxEnergy, equals(100)); // preserved
    });

    test('equality and hashCode support Set comparison', () {
      final state1 = PlayerState.initial(
        startPosition: const GridPosition(2, 2),
      ).copyWith(collectedItemIds: {'item_a', 'item_b'});

      final state2 = PlayerState.initial(
        startPosition: const GridPosition(2, 2),
      ).copyWith(collectedItemIds: {'item_b', 'item_a'});

      final state3 = state1.copyWith(score: 100);

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
      expect(state1, isNot(equals(state3)));
    });
  });
}
