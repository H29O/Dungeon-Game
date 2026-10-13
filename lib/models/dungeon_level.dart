import 'dungeon_tile.dart';
import 'grid_position.dart';

/// Represents an immutable, validated dungeon level matrix.
class DungeonLevel {
  final String id;
  final String name;
  final int rows;
  final int cols;
  final List<List<DungeonTile>> grid;
  final GridPosition start;
  final GridPosition exit;
  final int initialEnergy;
  final int maxEnergy;
  final int? generationSeed;

  /// Constructs and thoroughly validates a dungeon level matrix.
  DungeonLevel({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required List<List<DungeonTile>> grid,
    required this.start,
    required this.exit,
    this.initialEnergy = 100,
    this.maxEnergy = 100,
    this.generationSeed,
  }) : grid = List.unmodifiable(
         grid.map((row) => List<DungeonTile>.unmodifiable(row)),
       ) {
    _validate();
  }

  void _validate() {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Level ID must not be empty');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Level name must not be empty');
    }
    if (rows <= 0) {
      throw ArgumentError.value(rows, 'rows', 'Row count must be positive');
    }
    if (cols <= 0) {
      throw ArgumentError.value(cols, 'cols', 'Column count must be positive');
    }
    if (initialEnergy < 0 || maxEnergy <= 0 || initialEnergy > maxEnergy) {
      throw ArgumentError(
        'Invalid energy configuration: initialEnergy=$initialEnergy, maxEnergy=$maxEnergy',
      );
    }

    if (grid.length != rows) {
      throw ArgumentError(
        'Grid row count (${grid.length}) does not match declared rows ($rows)',
      );
    }

    for (int r = 0; r < rows; r++) {
      if (grid[r].length != cols) {
        throw ArgumentError(
          'Row $r length (${grid[r].length}) does not match declared columns ($cols)',
        );
      }
      for (int c = 0; c < cols; c++) {
        final tile = grid[r][c];
        if (tile.isTraversable && tile.movementCost < 0) {
          throw ArgumentError(
            'Traversable tile at ($r, $c) has negative entry cost: ${tile.movementCost}',
          );
        }
      }
    }

    if (!isInBounds(start)) {
      throw ArgumentError(
        'Start position $start is outside bounds ($rows x $cols)',
      );
    }
    if (!isInBounds(exit)) {
      throw ArgumentError(
        'Exit position $exit is outside bounds ($rows x $cols)',
      );
    }

    if (!tileAt(start).isTraversable) {
      throw ArgumentError(
        'Start position $start is on a non-traversable tile (${tileAt(start).type})',
      );
    }
    if (!tileAt(exit).isTraversable) {
      throw ArgumentError(
        'Exit position $exit is on a non-traversable tile (${tileAt(exit).type})',
      );
    }
  }

  /// Verifies whether a given position falls within the grid boundaries.
  bool isInBounds(GridPosition pos) {
    return pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols;
  }

  /// Returns the tile situated at [pos]. Throws [RangeError] if out of bounds.
  DungeonTile tileAt(GridPosition pos) {
    if (!isInBounds(pos)) {
      throw RangeError(
        'Position $pos is out of bounds for grid of size $rows x $cols',
      );
    }
    return grid[pos.row][pos.col];
  }

  /// Checks if the cell at [pos] is in bounds and can be traversed.
  bool isTraversableAt(GridPosition pos) {
    return isInBounds(pos) && tileAt(pos).isTraversable;
  }

  /// Returns the entry movement cost for stepping onto [pos].
  int costToEnter(GridPosition pos) {
    return tileAt(pos).movementCost;
  }

  @override
  String toString() =>
      'DungeonLevel(id: $id, name: $name, size: ${rows}x$cols, start: $start, exit: $exit)';
}
