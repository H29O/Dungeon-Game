import 'algorithm_event.dart';
import 'dungeon_level.dart';
import 'grid_position.dart';

/// Represents the outcome of Dijkstra's shortest-path algorithm computation.
///
/// Unreachable targets are represented explicitly via [hasPath] = false and [totalCost] = null,
/// never via fabricated numeric costs.
class PathResult {
  final bool hasPath;
  final List<GridPosition> path;
  final int? totalCost;
  final int settledNodesCount;
  final int relaxationCount;
  final int successfulRelaxationsCount;
  final Duration duration;
  final List<AlgorithmEvent> events;

  const PathResult._({
    required this.hasPath,
    required this.path,
    required this.totalCost,
    required this.settledNodesCount,
    required this.relaxationCount,
    required this.successfulRelaxationsCount,
    required this.duration,
    required this.events,
  });

  /// Factory creating a successful shortest-path result with an optimal route.
  factory PathResult.success({
    required List<GridPosition> path,
    required int totalCost,
    required int settledNodesCount,
    required int relaxationCount,
    required int successfulRelaxationsCount,
    required Duration duration,
    List<AlgorithmEvent> events = const [],
  }) {
    if (path.isEmpty) {
      throw ArgumentError(
        'Successful path result must contain at least one node',
      );
    }
    if (totalCost < 0) {
      throw ArgumentError.value(
        totalCost,
        'totalCost',
        'Total cost cannot be negative',
      );
    }

    return PathResult._(
      hasPath: true,
      path: List.unmodifiable(path),
      totalCost: totalCost,
      settledNodesCount: settledNodesCount,
      relaxationCount: relaxationCount,
      successfulRelaxationsCount: successfulRelaxationsCount,
      duration: duration,
      events: List.unmodifiable(events),
    );
  }

  /// Factory creating an explicit failure result when the goal is unreachable.
  factory PathResult.noPath({
    required int settledNodesCount,
    required int relaxationCount,
    required int successfulRelaxationsCount,
    required Duration duration,
    List<AlgorithmEvent> events = const [],
  }) {
    return PathResult._(
      hasPath: false,
      path: const [],
      totalCost: null,
      settledNodesCount: settledNodesCount,
      relaxationCount: relaxationCount,
      successfulRelaxationsCount: successfulRelaxationsCount,
      duration: duration,
      events: List.unmodifiable(events),
    );
  }

  /// Independently recalculates and verifies the path cost against the given [level].
  ///
  /// Verification rules:
  /// 1. Route must be non-empty and start at [expectedStart].
  /// 2. Route must end at [expectedGoal].
  /// 3. Every consecutive pair of cells must be orthogonally adjacent.
  /// 4. Every cell along the path must be in-bounds and traversable (no walls).
  /// 5. The sum of entry costs of cells `path[1..end]` must strictly equal [totalCost]
  ///    (the source cell contributes 0 to route entry cost).
  bool verifyPathCost({
    required DungeonLevel level,
    required GridPosition expectedStart,
    required GridPosition expectedGoal,
  }) {
    if (!hasPath) return false;
    if (path.isEmpty) return false;
    if (path.first != expectedStart) return false;
    if (path.last != expectedGoal) return false;

    int computedCost = 0;

    for (int i = 0; i < path.length; i++) {
      final pos = path[i];
      if (!level.isInBounds(pos) || !level.tileAt(pos).isTraversable) {
        return false;
      }
      if (i > 0) {
        final prev = path[i - 1];
        if (!pos.isAdjacentTo(prev)) {
          return false;
        }
        computedCost += level.costToEnter(pos);
      }
    }

    return computedCost == totalCost;
  }

  @override
  String toString() {
    if (hasPath) {
      return 'PathResult.success(length: ${path.length}, cost: $totalCost, settled: $settledNodesCount, time: ${duration.inMicroseconds}µs)';
    }
    return 'PathResult.noPath(settled: $settledNodesCount, time: ${duration.inMicroseconds}µs)';
  }
}
