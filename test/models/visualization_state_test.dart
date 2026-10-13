import 'package:flutter_test/flutter_test.dart';

import 'package:algorithmic_dungeon/data/sample_levels.dart';
import 'package:algorithmic_dungeon/algorithms/dijkstra.dart';
import 'package:algorithmic_dungeon/models/algorithm_event.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';
import 'package:algorithmic_dungeon/models/path_result.dart';
import 'package:algorithmic_dungeon/models/visualization_state.dart';

void main() {
  group('VisualizationState', () {
    late PathResult sampleResult;
    final start = const GridPosition(0, 0);
    final exit = const GridPosition(5, 5);

    setUp(() {
      sampleResult = DijkstraEngine().findShortestPath(
        level: SampleLevels.level1,
        start: start,
        goal: exit,
        recordEvents: true,
      );
    });

    test('initial state has step 0, empty sets, and incomplete status', () {
      final state = VisualizationState.initial(
        source: start,
        target: exit,
        result: sampleResult,
      );

      expect(state.currentStep, 0);
      expect(state.totalSteps, sampleResult.events.length);
      expect(state.hasNextStep, isTrue);
      expect(state.frontierNodes, isEmpty);
      expect(state.settledNodes, isEmpty);
      expect(state.finalPath, isEmpty);
      expect(state.isCompleted, isFalse);
      expect(state.currentEvent, isNull);
    });

    test('stepForward advances exactly one event and updates sets', () {
      var state = VisualizationState.initial(
        source: start,
        target: exit,
        result: sampleResult,
      );

      // Step 1: source NodeDiscoveredEvent
      state = state.stepForward();
      expect(state.currentStep, 1);
      expect(state.currentEvent, isA<NodeDiscoveredEvent>());
      final discovered = state.currentEvent as NodeDiscoveredEvent;
      expect(state.frontierNodes.contains(discovered.position), isTrue);
      expect(state.nodeDistances[discovered.position], discovered.distance);

      // Step 2: source NodeSettledEvent
      state = state.stepForward();
      expect(state.currentStep, 2);
      expect(state.currentEvent, isA<NodeSettledEvent>());
      final settled = state.currentEvent as NodeSettledEvent;
      expect(state.settledNodes.contains(settled.position), isTrue);
      expect(state.frontierNodes.contains(settled.position), isFalse);
    });

    test('stepping through all events reaches completion with final path', () {
      var state = VisualizationState.initial(
        source: start,
        target: exit,
        result: sampleResult,
      );

      while (state.hasNextStep) {
        state = state.stepForward();
      }

      expect(state.isCompleted, isTrue);
      expect(state.currentStep, sampleResult.events.length);
      expect(state.finalPath, sampleResult.path);
      expect(state.finalPath.isNotEmpty, isTrue);
      expect(state.finalPath.first, start);
      expect(state.finalPath.last, exit);
    });

    test(
      'showFinalPath fast-forwards immediately to all settled nodes and route',
      () {
        final state = VisualizationState.initial(
          source: start,
          target: exit,
          result: sampleResult,
        );

        final fastState = state.showFinalPath();

        expect(fastState.isCompleted, isTrue);
        expect(fastState.currentStep, sampleResult.events.length);
        expect(fastState.finalPath, sampleResult.path);
        expect(fastState.settledNodes.length, sampleResult.settledNodesCount);
        expect(fastState.settledNodes.contains(start), isTrue);
        expect(fastState.settledNodes.contains(exit), isTrue);
      },
    );

    test('resetToStart returns to step 0 and clears sets', () {
      final state = VisualizationState.initial(
        source: start,
        target: exit,
        result: sampleResult,
      ).showFinalPath();

      expect(state.isCompleted, isTrue);

      final resetState = state.resetToStart();
      expect(resetState.currentStep, 0);
      expect(resetState.isCompleted, isFalse);
      expect(resetState.frontierNodes, isEmpty);
      expect(resetState.settledNodes, isEmpty);
      expect(resetState.finalPath, isEmpty);
    });

    test('handles unreachable result safely without crashing', () {
      final noPathResult = PathResult.noPath(
        settledNodesCount: 2,
        relaxationCount: 1,
        successfulRelaxationsCount: 1,
        duration: const Duration(microseconds: 50),
        events: [
          const NodeDiscoveredEvent(position: GridPosition(0, 0), distance: 0),
          const NodeSettledEvent(position: GridPosition(0, 0), distance: 0),
        ],
      );

      var state = VisualizationState.initial(
        source: const GridPosition(0, 0),
        target: const GridPosition(5, 5),
        result: noPathResult,
      );

      final fastState = state.showFinalPath();
      expect(fastState.isCompleted, isTrue);
      expect(fastState.finalPath, isEmpty);
      expect(fastState.settledNodes.contains(const GridPosition(0, 0)), isTrue);
    });
  });
}
