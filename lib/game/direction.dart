import '../models/grid_position.dart';

/// Represents orthogonal directions for player navigation on the grid.
enum Direction {
  up,
  right,
  down,
  left;

  /// Returns the target [GridPosition] reached by moving one step in this direction from [from].
  GridPosition offset(GridPosition from) {
    switch (this) {
      case Direction.up:
        return GridPosition(from.row - 1, from.col);
      case Direction.right:
        return GridPosition(from.row, from.col + 1);
      case Direction.down:
        return GridPosition(from.row + 1, from.col);
      case Direction.left:
        return GridPosition(from.row, from.col - 1);
    }
  }

  /// Human-readable label for accessibility and UI feedback.
  String get label {
    switch (this) {
      case Direction.up:
        return 'Up';
      case Direction.right:
        return 'Right';
      case Direction.down:
        return 'Down';
      case Direction.left:
        return 'Left';
    }
  }
}
