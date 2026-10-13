import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/algorithms/graph_builder.dart';
import 'package:algorithmic_dungeon/models/dungeon_level.dart';
import 'package:algorithmic_dungeon/models/dungeon_tile.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';

void main() {
  group('GraphBuilder', () {
    test(
      'deterministic neighbor order (Up, Right, Down, Left) and edge weights',
      () {
        // 3x3 grid with distinct terrain costs:
        // [ (0,0): 1 ] [ (0,1): 2 ] [ (0,2): 1 ]  (Up of center is (0,1) with cost 2)
        // [ (1,0): 3 ] [ (1,1): 1 ] [ (1,2): 4 ]  (Center is (1,1); Left is (1,0) cost 3; Right is (1,2) cost 4)
        // [ (2,0): 1 ] [ (2,1): 5 ] [ (2,2): 1 ]  (Down of center is (2,1) with cost 5)
        final grid = [
          [
            DungeonTile.floor(movementCost: 1),
            DungeonTile.floor(movementCost: 2),
            DungeonTile.floor(movementCost: 1),
          ],
          [
            DungeonTile.floor(movementCost: 3),
            DungeonTile.floor(movementCost: 1),
            DungeonTile.floor(movementCost: 4),
          ],
          [
            DungeonTile.floor(movementCost: 1),
            DungeonTile.floor(movementCost: 5),
            DungeonTile.floor(movementCost: 1),
          ],
        ];

        final level = DungeonLevel(
          id: 'cross_test',
          name: 'Cross Test',
          rows: 3,
          cols: 3,
          grid: grid,
          start: const GridPosition(0, 0),
          exit: const GridPosition(2, 2),
        );

        final builder = GraphBuilder(level);
        final neighbors = builder.getNeighbors(const GridPosition(1, 1));

        expect(neighbors.length, equals(4));

        // 1. Up: (0, 1), cost 2
        expect(neighbors[0].target, equals(const GridPosition(0, 1)));
        expect(neighbors[0].weight, equals(2));

        // 2. Right: (1, 2), cost 4
        expect(neighbors[1].target, equals(const GridPosition(1, 2)));
        expect(neighbors[1].weight, equals(4));

        // 3. Down: (2, 1), cost 5
        expect(neighbors[2].target, equals(const GridPosition(2, 1)));
        expect(neighbors[2].weight, equals(5));

        // 4. Left: (1, 0), cost 3
        expect(neighbors[3].target, equals(const GridPosition(1, 0)));
        expect(neighbors[3].weight, equals(3));
      },
    );

    test('excludes walls from neighbor edges', () {
      // Center (1, 1) surrounded by walls above and to the right
      final grid = [
        [DungeonTile.floor(), DungeonTile.wall(), DungeonTile.floor()],
        [DungeonTile.floor(), DungeonTile.floor(), DungeonTile.wall()],
        [DungeonTile.floor(), DungeonTile.floor(), DungeonTile.floor()],
      ];

      final level = DungeonLevel(
        id: 'walls_test',
        name: 'Walls Test',
        rows: 3,
        cols: 3,
        grid: grid,
        start: const GridPosition(0, 0),
        exit: const GridPosition(2, 2),
      );

      final builder = GraphBuilder(level);
      final neighbors = builder.getNeighbors(const GridPosition(1, 1));

      // Up (0,1) is a wall (excluded)
      // Right (1,2) is a wall (excluded)
      // Down (2,1) is floor (included)
      // Left (1,0) is floor (included)
      expect(neighbors.length, equals(2));
      expect(neighbors[0].target, equals(const GridPosition(2, 1))); // Down
      expect(neighbors[1].target, equals(const GridPosition(1, 0))); // Left
    });

    test('boundary handling at corners', () {
      final grid = [
        [
          DungeonTile.floor(movementCost: 1),
          DungeonTile.floor(movementCost: 7),
        ],
        [
          DungeonTile.floor(movementCost: 4),
          DungeonTile.floor(movementCost: 1),
        ],
      ];

      final level = DungeonLevel(
        id: 'corner_test',
        name: 'Corner',
        rows: 2,
        cols: 2,
        grid: grid,
        start: const GridPosition(0, 0),
        exit: const GridPosition(1, 1),
      );

      final builder = GraphBuilder(level);
      // Top-left corner (0,0): Up and Left are out of bounds.
      // Expected: Right (0,1) with weight 7, Down (1,0) with weight 4.
      final neighbors = builder.getNeighbors(const GridPosition(0, 0));
      expect(neighbors.length, equals(2));
      expect(neighbors[0].target, equals(const GridPosition(0, 1)));
      expect(neighbors[0].weight, equals(7));
      expect(neighbors[1].target, equals(const GridPosition(1, 0)));
      expect(neighbors[1].weight, equals(4));
    });

    test('traversableVertexCount accounts only for non-walls', () {
      final grid = [
        [DungeonTile.floor(), DungeonTile.wall()],
        [DungeonTile.wall(), DungeonTile.floor()],
      ];

      final level = DungeonLevel(
        id: 'count_test',
        name: 'Count',
        rows: 2,
        cols: 2,
        grid: grid,
        start: const GridPosition(0, 0),
        exit: const GridPosition(1, 1),
      );

      final builder = GraphBuilder(level);
      expect(builder.traversableVertexCount, equals(2));
    });
  });
}
