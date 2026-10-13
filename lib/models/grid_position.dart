/// Represents an immutable 2D grid coordinate in the dungeon labyrinth.
class GridPosition implements Comparable<GridPosition> {
  final int row;
  final int col;

  const GridPosition(this.row, this.col);

  /// Generates the four orthogonal neighbors in the required deterministic order:
  /// Up, Right, Down, Left.
  List<GridPosition> orthogonalNeighbors() {
    return [
      GridPosition(row - 1, col), // Up
      GridPosition(row, col + 1), // Right
      GridPosition(row + 1, col), // Down
      GridPosition(row, col - 1), // Left
    ];
  }

  /// Checks if another position is orthogonally adjacent (Manhattan distance == 1).
  bool isAdjacentTo(GridPosition other) {
    return (row - other.row).abs() + (col - other.col).abs() == 1;
  }

  /// Computes the Manhattan (L1) distance to another position.
  int manhattanDistanceTo(GridPosition other) {
    return (row - other.row).abs() + (col - other.col).abs();
  }

  /// Computes a 1D linear index given the total number of columns in the grid.
  int toLinearIndex(int numCols) => row * numCols + col;

  /// Returns a compact string key suitable for caching or serialization.
  String toKey() => '$row,$col';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridPosition && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);

  @override
  int compareTo(GridPosition other) {
    if (row != other.row) {
      return row.compareTo(other.row);
    }
    return col.compareTo(other.col);
  }

  @override
  String toString() => 'GridPosition($row, $col)';
}
