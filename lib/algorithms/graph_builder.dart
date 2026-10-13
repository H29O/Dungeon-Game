import '../models/dungeon_level.dart';
import '../models/grid_position.dart';

/// Represents a directed, weighted edge from the current vertex to an adjacent [target] vertex.
class WeightedEdge {
  final GridPosition target;
  final int weight;

  const WeightedEdge({required this.target, required this.weight});

  @override
  String toString() => 'WeightedEdge(-> $target, weight: $weight)';
}

/// Builds and queries the graph derived from a [DungeonLevel].
///
/// Follows the non-negotiable specification rules:
/// - Every traversable grid cell represents a graph vertex.
/// - Walls are non-traversable and strictly excluded.
/// - 4-directional movement only (orthogonal steps).
/// - Deterministic neighbor traversal order: **Up, Right, Down, Left**.
/// - Edge weight from `u` to `v` equals the entry cost of `v` (`level.costToEnter(v)`).
/// - Non-negative weights only.
class GraphBuilder {
  final DungeonLevel level;

  GraphBuilder(this.level);

  /// Computes all valid outgoing edges from [u] in the required deterministic order:
  /// Up, Right, Down, Left.
  ///
  /// Excludes positions that are out of bounds or non-traversable (walls).
  List<WeightedEdge> getNeighbors(GridPosition u) {
    if (!level.isInBounds(u)) {
      throw RangeError('Vertex $u is out of bounds for level');
    }

    final candidates = u.orthogonalNeighbors();
    final List<WeightedEdge> edges = [];

    for (final v in candidates) {
      if (level.isInBounds(v) && level.isTraversableAt(v)) {
        final weight = level.costToEnter(v);
        edges.add(WeightedEdge(target: v, weight: weight));
      }
    }

    return edges;
  }

  /// Returns the total count of traversable vertices in the labyrinth.
  int get traversableVertexCount {
    int count = 0;
    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.cols; c++) {
        if (level.grid[r][c].isTraversable) {
          count++;
        }
      }
    }
    return count;
  }
}
