import 'grid_position.dart';

/// Sealed base class representing deterministic trace events generated during
/// execution of Dijkstra's algorithm.
sealed class AlgorithmEvent {
  const AlgorithmEvent();
}

/// Emitted when a graph vertex is first discovered and enqueued into the priority queue.
class NodeDiscoveredEvent extends AlgorithmEvent {
  final GridPosition position;
  final int distance;

  const NodeDiscoveredEvent({required this.position, required this.distance});

  @override
  String toString() => 'NodeDiscovered($position, dist: $distance)';
}

/// Emitted when the minimum-distance vertex is popped from the priority queue
/// and its shortest path is permanently finalized.
class NodeSettledEvent extends AlgorithmEvent {
  final GridPosition position;
  final int distance;

  const NodeSettledEvent({required this.position, required this.distance});

  @override
  String toString() => 'NodeSettled($position, dist: $distance)';
}

/// Emitted when edge relaxation discovers a strictly lower path cost to an already-discovered vertex.
class DistanceUpdatedEvent extends AlgorithmEvent {
  final GridPosition position;
  final int oldDistance;
  final int newDistance;

  const DistanceUpdatedEvent({
    required this.position,
    required this.oldDistance,
    required this.newDistance,
  });

  @override
  String toString() =>
      'DistanceUpdated($position, old: $oldDistance, new: $newDistance)';
}

/// Emitted when path reconstruction completes successfully, yielding the verified final route.
class PathCompletedEvent extends AlgorithmEvent {
  final List<GridPosition> path;
  final int totalCost;

  PathCompletedEvent({
    required List<GridPosition> path,
    required this.totalCost,
  }) : path = List.unmodifiable(path);

  @override
  String toString() => 'PathCompleted(len: ${path.length}, cost: $totalCost)';
}
