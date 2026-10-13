import '../models/algorithm_event.dart';
import '../models/dungeon_level.dart';
import '../models/grid_position.dart';
import '../models/path_result.dart';
import 'graph_builder.dart';
import 'priority_queue.dart';

/// Internal wrapper representing a frontier candidate in the priority queue.
class _DijkstraNode {
  final GridPosition position;
  final int cost;

  const _DijkstraNode(this.position, this.cost);
}

/// Core shortest-path pathfinding service using Dijkstra's algorithm.
///
/// Implements the exact specification and contracts defined in the project report:
/// - Directed edge weights based on entry cost of destination cell.
/// - Source vertex contributes 0 to total route cost.
/// - Binary min-heap priority queue with O(log V) operations.
/// - Ignores stale queue entries where queued cost > known distance.
/// - Early stopping occurs strictly when the target is popped from the priority queue,
///   guaranteeing optimality.
/// - Deterministic neighbor traversal order: Up, Right, Down, Left.
/// - Unreachable targets return an explicit [PathResult.noPath].
/// - Pure computation that never mutates the level or game state.
class DijkstraEngine {
  /// Computes the optimal path from [start] to [goal] within [level].
  ///
  /// Set [recordEvents] to true to capture a sequence of [AlgorithmEvent] records
  /// for visualization playback.
  PathResult findShortestPath({
    required DungeonLevel level,
    required GridPosition start,
    required GridPosition goal,
    bool recordEvents = false,
  }) {
    final stopwatch = Stopwatch()..start();

    if (!level.isInBounds(start) || !level.isTraversableAt(start)) {
      stopwatch.stop();
      return PathResult.noPath(
        settledNodesCount: 0,
        relaxationCount: 0,
        successfulRelaxationsCount: 0,
        duration: stopwatch.elapsed,
      );
    }

    if (!level.isInBounds(goal) || !level.isTraversableAt(goal)) {
      stopwatch.stop();
      return PathResult.noPath(
        settledNodesCount: 0,
        relaxationCount: 0,
        successfulRelaxationsCount: 0,
        duration: stopwatch.elapsed,
      );
    }

    final List<AlgorithmEvent> events = [];

    // Trivial case: start == goal
    if (start == goal) {
      stopwatch.stop();
      if (recordEvents) {
        events.add(NodeDiscoveredEvent(position: start, distance: 0));
        events.add(NodeSettledEvent(position: start, distance: 0));
        events.add(PathCompletedEvent(path: [start], totalCost: 0));
      }
      return PathResult.success(
        path: [start],
        totalCost: 0,
        settledNodesCount: 1,
        relaxationCount: 0,
        successfulRelaxationsCount: 0,
        duration: stopwatch.elapsed,
        events: events,
      );
    }

    final graph = GraphBuilder(level);
    final pq = MinHeap<_DijkstraNode>((a, b) => a.cost.compareTo(b.cost));

    final Map<GridPosition, int> dist = {};
    final Map<GridPosition, GridPosition> prev = {};
    final Set<GridPosition> settled = {};

    int relaxationCount = 0;
    int successfulRelaxationsCount = 0;

    // Initialize source distance to 0
    dist[start] = 0;
    pq.push(_DijkstraNode(start, 0));

    if (recordEvents) {
      events.add(NodeDiscoveredEvent(position: start, distance: 0));
    }

    while (pq.isNotEmpty) {
      final current = pq.pop();
      final u = current.position;
      final cost = current.cost;

      // Rule 4: Ignore stale priority queue entries
      if (cost > dist[u]!) {
        continue;
      }

      // If already finalized, skip
      if (settled.contains(u)) {
        continue;
      }

      // Finalize node
      settled.add(u);

      if (recordEvents) {
        events.add(NodeSettledEvent(position: u, distance: cost));
      }

      // Rule 8: Early termination when target is finalized
      if (u == goal) {
        break;
      }

      // Explore neighbors in deterministic order (Up, Right, Down, Left)
      final edges = graph.getNeighbors(u);

      for (final edge in edges) {
        final v = edge.target;
        final weight = edge.weight;

        if (settled.contains(v)) {
          continue;
        }

        relaxationCount++;
        final candidate = dist[u]! + weight;
        final currentBest = dist[v];

        // Rule 6: Strictly lower cost triggers relaxation
        if (currentBest == null || candidate < currentBest) {
          successfulRelaxationsCount++;

          if (recordEvents) {
            if (currentBest == null) {
              events.add(NodeDiscoveredEvent(position: v, distance: candidate));
            } else {
              events.add(
                DistanceUpdatedEvent(
                  position: v,
                  oldDistance: currentBest,
                  newDistance: candidate,
                ),
              );
            }
          }

          dist[v] = candidate;
          prev[v] = u;
          pq.push(_DijkstraNode(v, candidate));
        }
      }
    }

    stopwatch.stop();

    // Check if goal was finalized
    if (!settled.contains(goal) || !dist.containsKey(goal)) {
      return PathResult.noPath(
        settledNodesCount: settled.length,
        relaxationCount: relaxationCount,
        successfulRelaxationsCount: successfulRelaxationsCount,
        duration: stopwatch.elapsed,
        events: events,
      );
    }

    // Path reconstruction starting from goal back to start
    final List<GridPosition> reconstructedPath = [];
    GridPosition? curr = goal;

    while (curr != null) {
      reconstructedPath.add(curr);
      if (curr == start) break;
      curr = prev[curr];
    }

    // Safety validation for disconnected predecessor
    if (reconstructedPath.last != start) {
      return PathResult.noPath(
        settledNodesCount: settled.length,
        relaxationCount: relaxationCount,
        successfulRelaxationsCount: successfulRelaxationsCount,
        duration: stopwatch.elapsed,
        events: events,
      );
    }

    // Reverse to establish source-to-goal order
    final path = reconstructedPath.reversed.toList();
    final totalCost = dist[goal]!;

    // Independent route cost verification
    int independentCost = 0;
    for (int i = 1; i < path.length; i++) {
      independentCost += level.costToEnter(path[i]);
    }

    assert(
      independentCost == totalCost,
      'Internal verification error: reported cost ($totalCost) != independent cost ($independentCost)',
    );

    if (recordEvents) {
      events.add(PathCompletedEvent(path: path, totalCost: totalCost));
    }

    return PathResult.success(
      path: path,
      totalCost: totalCost,
      settledNodesCount: settled.length,
      relaxationCount: relaxationCount,
      successfulRelaxationsCount: successfulRelaxationsCount,
      duration: stopwatch.elapsed,
      events: events,
    );
  }
}
