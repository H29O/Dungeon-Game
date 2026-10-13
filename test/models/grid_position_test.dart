import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';

void main() {
  group('GridPosition', () {
    test('value equality and hashCode', () {
      const pos1 = GridPosition(2, 3);
      const pos2 = GridPosition(2, 3);
      const pos3 = GridPosition(3, 2);

      expect(pos1, equals(pos2));
      expect(pos1.hashCode, equals(pos2.hashCode));
      expect(pos1, isNot(equals(pos3)));
    });

    test('usable as keys in Map and Set', () {
      final set = <GridPosition>{
        const GridPosition(1, 2),
        const GridPosition(3, 4),
      };
      set.add(const GridPosition(1, 2)); // Duplicate addition

      expect(set.length, equals(2));
      expect(set.contains(const GridPosition(1, 2)), isTrue);

      final map = <GridPosition, String>{const GridPosition(0, 0): 'start'};
      map[const GridPosition(0, 0)] = 'updated';
      expect(map[const GridPosition(0, 0)], equals('updated'));
    });

    test('deterministic orthogonal neighbor order: Up, Right, Down, Left', () {
      const center = GridPosition(5, 5);
      final neighbors = center.orthogonalNeighbors();

      expect(neighbors.length, equals(4));
      expect(neighbors[0], equals(const GridPosition(4, 5))); // Up
      expect(neighbors[1], equals(const GridPosition(5, 6))); // Right
      expect(neighbors[2], equals(const GridPosition(6, 5))); // Down
      expect(neighbors[3], equals(const GridPosition(5, 4))); // Left
    });

    test('isAdjacentTo detects orthogonal neighbors only', () {
      const origin = GridPosition(2, 2);

      expect(origin.isAdjacentTo(const GridPosition(1, 2)), isTrue); // Up
      expect(origin.isAdjacentTo(const GridPosition(2, 3)), isTrue); // Right
      expect(origin.isAdjacentTo(const GridPosition(3, 2)), isTrue); // Down
      expect(origin.isAdjacentTo(const GridPosition(2, 1)), isTrue); // Left

      expect(
        origin.isAdjacentTo(const GridPosition(1, 1)),
        isFalse,
      ); // Diagonal
      expect(origin.isAdjacentTo(const GridPosition(2, 2)), isFalse); // Self
      expect(origin.isAdjacentTo(const GridPosition(0, 2)), isFalse); // Dist 2
    });

    test('manhattanDistanceTo calculation', () {
      const p1 = GridPosition(1, 1);
      const p2 = GridPosition(4, 5);

      expect(p1.manhattanDistanceTo(p2), equals(7)); // |1-4| + |1-5| = 3 + 4
      expect(p2.manhattanDistanceTo(p1), equals(7));
    });

    test('linear index and key representation', () {
      const p = GridPosition(2, 3);
      expect(p.toLinearIndex(10), equals(23)); // 2 * 10 + 3
      expect(p.toKey(), equals('2,3'));
    });
  });
}
