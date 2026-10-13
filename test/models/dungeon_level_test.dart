import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/models/dungeon_level.dart';
import 'package:algorithmic_dungeon/models/dungeon_tile.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';

void main() {
  group('DungeonLevel', () {
    List<List<DungeonTile>> createValidGrid(int rows, int cols) {
      return List.generate(
        rows,
        (_) => List.generate(cols, (_) => DungeonTile.floor()),
      );
    }

    test('creates valid level and exposes query methods', () {
      final level = DungeonLevel(
        id: 'test_1',
        name: 'Test Chamber',
        rows: 3,
        cols: 3,
        grid: createValidGrid(3, 3),
        start: const GridPosition(0, 0),
        exit: const GridPosition(2, 2),
      );

      expect(level.id, equals('test_1'));
      expect(level.name, equals('Test Chamber'));
      expect(level.rows, equals(3));
      expect(level.cols, equals(3));
      expect(level.isInBounds(const GridPosition(1, 1)), isTrue);
      expect(level.isInBounds(const GridPosition(3, 3)), isFalse);
      expect(level.isTraversableAt(const GridPosition(0, 0)), isTrue);
      expect(level.costToEnter(const GridPosition(0, 0)), equals(1));
    });

    test('rejects empty id or name', () {
      expect(
        () => DungeonLevel(
          id: '',
          name: 'Chamber',
          rows: 2,
          cols: 2,
          grid: createValidGrid(2, 2),
          start: const GridPosition(0, 0),
          exit: const GridPosition(1, 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => DungeonLevel(
          id: '1',
          name: '   ',
          rows: 2,
          cols: 2,
          grid: createValidGrid(2, 2),
          start: const GridPosition(0, 0),
          exit: const GridPosition(1, 1),
        ),
        throwsArgumentError,
      );
    });

    test('rejects non-rectangular grid matrix', () {
      // Row length mismatch
      final nonRectangular = [
        [DungeonTile.floor(), DungeonTile.floor()],
        [DungeonTile.floor()], // only 1 tile
      ];
      expect(
        () => DungeonLevel(
          id: 'invalid',
          name: 'Invalid Level',
          rows: 2,
          cols: 2,
          grid: nonRectangular,
          start: const GridPosition(0, 0),
          exit: const GridPosition(0, 1),
        ),
        throwsArgumentError,
      );

      // Declared rows mismatch
      expect(
        () => DungeonLevel(
          id: 'invalid',
          name: 'Invalid Level',
          rows: 3,
          cols: 2,
          grid: createValidGrid(2, 2),
          start: const GridPosition(0, 0),
          exit: const GridPosition(1, 1),
        ),
        throwsArgumentError,
      );
    });

    test('rejects out of bounds start or exit', () {
      expect(
        () => DungeonLevel(
          id: 'oob_start',
          name: 'Level',
          rows: 2,
          cols: 2,
          grid: createValidGrid(2, 2),
          start: const GridPosition(-1, 0),
          exit: const GridPosition(1, 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => DungeonLevel(
          id: 'oob_exit',
          name: 'Level',
          rows: 2,
          cols: 2,
          grid: createValidGrid(2, 2),
          start: const GridPosition(0, 0),
          exit: const GridPosition(2, 2),
        ),
        throwsArgumentError,
      );
    });

    test('rejects non-traversable wall at start or exit', () {
      final gridWithWallStart = createValidGrid(2, 2);
      gridWithWallStart[0][0] = DungeonTile.wall();

      expect(
        () => DungeonLevel(
          id: 'wall_start',
          name: 'Level',
          rows: 2,
          cols: 2,
          grid: gridWithWallStart,
          start: const GridPosition(0, 0),
          exit: const GridPosition(1, 1),
        ),
        throwsArgumentError,
      );

      final gridWithWallExit = createValidGrid(2, 2);
      gridWithWallExit[1][1] = DungeonTile.wall();

      expect(
        () => DungeonLevel(
          id: 'wall_exit',
          name: 'Level',
          rows: 2,
          cols: 2,
          grid: gridWithWallExit,
          start: const GridPosition(0, 0),
          exit: const GridPosition(1, 1),
        ),
        throwsArgumentError,
      );
    });

    test('level matrix is protected against external mutation', () {
      final originalGrid = createValidGrid(2, 2);
      final level = DungeonLevel(
        id: 'immutability',
        name: 'Imm',
        rows: 2,
        cols: 2,
        grid: originalGrid,
        start: const GridPosition(0, 0),
        exit: const GridPosition(1, 1),
      );

      // Mutating outer list must throw
      expect(
        () => level.grid.add([DungeonTile.floor()]),
        throwsUnsupportedError,
      );

      // Mutating inner list must throw
      expect(
        () => level.grid[0][0] = DungeonTile.wall(),
        throwsUnsupportedError,
      );
    });
  });
}
