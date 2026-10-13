import '../models/algorithm_event.dart';
import '../models/grid_position.dart';
import '../models/path_result.dart';

/// Immutable snapshot representing the visual state of Dijkstra algorithm playback
/// at a specific event step.
class VisualizationState {
  final GridPosition source;
  final GridPosition target;
  final PathResult result;
  final int currentStep;
  final Set<GridPosition> frontierNodes;
  final Set<GridPosition> settledNodes;
  final Map<GridPosition, int> nodeDistances;
  final List<GridPosition> finalPath;
  final bool isCompleted;
  final AlgorithmEvent? currentEvent;

  const VisualizationState._({
    required this.source,
    required this.target,
    required this.result,
    required this.currentStep,
    required this.frontierNodes,
    required this.settledNodes,
    required this.nodeDistances,
    required this.finalPath,
    required this.isCompleted,
    required this.currentEvent,
  });

  /// Factory initializing a visualization state before any events are replayed.
  factory VisualizationState.initial({
    required GridPosition source,
    required GridPosition target,
    required PathResult result,
  }) {
    return VisualizationState._(
      source: source,
      target: target,
      result: result,
      currentStep: 0,
      frontierNodes: const {},
      settledNodes: const {},
      nodeDistances: const {},
      finalPath: const [],
      isCompleted: false,
      currentEvent: null,
    );
  }

  /// Total number of recorded events in this algorithm execution.
  int get totalSteps => result.events.length;

  /// Whether there are more events remaining to be stepped through.
  bool get hasNextStep => currentStep < totalSteps;

  /// Advances the visualization by exactly one event.
  VisualizationState stepForward() {
    if (!hasNextStep) {
      // Already at the end; ensure completed status and final path
      if (!isCompleted) {
        return copyWith(
          isCompleted: true,
          finalPath: result.hasPath ? result.path : const [],
        );
      }
      return this;
    }

    final event = result.events[currentStep];
    final nextStep = currentStep + 1;

    final newFrontier = Set<GridPosition>.from(frontierNodes);
    final newSettled = Set<GridPosition>.from(settledNodes);
    final newDistances = Map<GridPosition, int>.from(nodeDistances);
    List<GridPosition> newFinalPath = finalPath;
    bool completed = isCompleted;

    switch (event) {
      case NodeDiscoveredEvent():
        newFrontier.add(event.position);
        newDistances[event.position] = event.distance;
        break;

      case DistanceUpdatedEvent():
        newDistances[event.position] = event.newDistance;
        break;

      case NodeSettledEvent():
        newFrontier.remove(event.position);
        newSettled.add(event.position);
        newDistances[event.position] = event.distance;
        break;

      case PathCompletedEvent():
        newFinalPath = List.unmodifiable(event.path);
        completed = true;
        break;
    }

    if (nextStep >= totalSteps) {
      completed = true;
      if (result.hasPath && newFinalPath.isEmpty) {
        newFinalPath = result.path;
      }
    }

    return VisualizationState._(
      source: source,
      target: target,
      result: result,
      currentStep: nextStep,
      frontierNodes: Set.unmodifiable(newFrontier),
      settledNodes: Set.unmodifiable(newSettled),
      nodeDistances: Map.unmodifiable(newDistances),
      finalPath: newFinalPath,
      isCompleted: completed,
      currentEvent: event,
    );
  }

  /// Immediately fast-forwards through all algorithm events, populating all settled
  /// nodes and revealing the final optimal route.
  VisualizationState showFinalPath() {
    final allSettled = <GridPosition>{};
    final allDistances = <GridPosition, int>{};

    for (final event in result.events) {
      if (event is NodeDiscoveredEvent) {
        allDistances[event.position] = event.distance;
      } else if (event is DistanceUpdatedEvent) {
        allDistances[event.position] = event.newDistance;
      } else if (event is NodeSettledEvent) {
        allSettled.add(event.position);
        allDistances[event.position] = event.distance;
      }
    }

    return VisualizationState._(
      source: source,
      target: target,
      result: result,
      currentStep: totalSteps,
      frontierNodes: const {},
      settledNodes: Set.unmodifiable(allSettled),
      nodeDistances: Map.unmodifiable(allDistances),
      finalPath: result.hasPath ? result.path : const [],
      isCompleted: true,
      currentEvent: result.events.isNotEmpty ? result.events.last : null,
    );
  }

  /// Resets replay progress to step 0.
  VisualizationState resetToStart() {
    return VisualizationState.initial(
      source: source,
      target: target,
      result: result,
    );
  }

  VisualizationState copyWith({
    int? currentStep,
    Set<GridPosition>? frontierNodes,
    Set<GridPosition>? settledNodes,
    Map<GridPosition, int>? nodeDistances,
    List<GridPosition>? finalPath,
    bool? isCompleted,
    AlgorithmEvent? currentEvent,
  }) {
    return VisualizationState._(
      source: source,
      target: target,
      result: result,
      currentStep: currentStep ?? this.currentStep,
      frontierNodes: frontierNodes ?? this.frontierNodes,
      settledNodes: settledNodes ?? this.settledNodes,
      nodeDistances: nodeDistances ?? this.nodeDistances,
      finalPath: finalPath ?? this.finalPath,
      isCompleted: isCompleted ?? this.isCompleted,
      currentEvent: currentEvent ?? this.currentEvent,
    );
  }
}
