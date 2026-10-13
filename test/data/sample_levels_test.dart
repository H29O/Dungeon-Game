import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/algorithms/dijkstra.dart';
import 'package:algorithmic_dungeon/data/sample_levels.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';

void main() {
  group('SampleLevels.level1 Verification', () {
    final level = SampleLevels.level1;
    final engine = DijkstraEngine();

    test('level1 topology and dimension constraints', () {
      expect(level.rows, equals(6));
      expect(level.cols, equals(6));
      expect(level.start, equals(const GridPosition(0, 0)));
      expect(level.exit, equals(const GridPosition(5, 5)));
      expect(level.initialEnergy, equals(60));
      expect(level.maxEnergy, equals(100));
    });

    test('exit is guaranteed reachable by Dijkstra with optimal cost 10', () {
      final result = engine.findShortestPath(
        level: level,
        start: level.start,
        goal: level.exit,
      );

      expect(result.hasPath, isTrue);
      expect(result.totalCost, equals(10));
      expect(result.path.length, equals(11)); // 11 positions = 10 transitions
      expect(result.path.first, equals(const GridPosition(0, 0)));
      expect(result.path.last, equals(const GridPosition(5, 5)));
      expect(
        result.verifyPathCost(
          level: level,
          expectedStart: level.start,
          expectedGoal: level.exit,
        ),
        isTrue,
      );

      // Verify that optimal route cost (10) is well within initial energy (60)
      expect(result.totalCost!, lessThanOrEqualTo(level.initialEnergy));
    });

    test('demonstrates step count vs weighted cost distinction', () {
      // From (2, 0) to (2, 4):
      // Direct center shortcut via row 2 has hazards: (2,1)[5], (2,2)[5], (2,3)[5], (2,4)[1] = cost 16 (4 steps).
      // Perimeter detour via row 4 has all floor: cost 8 (8 steps).
      final result = engine.findShortestPath(
        level: level,
        start: const GridPosition(2, 0),
        goal: const GridPosition(2, 4),
      );

      expect(result.hasPath, isTrue);
      expect(result.totalCost, equals(8)); // Prefers lower cost 8 over 16
      expect(result.path.length, equals(9)); // 8 steps
      expect(
        result.verifyPathCost(
          level: level,
          expectedStart: const GridPosition(2, 0),
          expectedGoal: const GridPosition(2, 4),
        ),
        isTrue,
      );
    });
  });
}
