import 'package:flutter_test/flutter_test.dart';

import 'package:algorithmic_dungeon/algorithms/dijkstra.dart';
import 'package:algorithmic_dungeon/data/sample_levels.dart';
import 'package:algorithmic_dungeon/game/visualization_controller.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';
import 'package:algorithmic_dungeon/models/path_result.dart';

void main() {
  group('VisualizationController', () {
    late VisualizationController controller;
    late PathResult sampleResult;
    final start = const GridPosition(0, 0);
    final exit = const GridPosition(5, 5);

    setUp(() {
      controller = VisualizationController();
      sampleResult = DijkstraEngine().findShortestPath(
        level: SampleLevels.level1,
        start: start,
        goal: exit,
        recordEvents: true,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('initialize sets state and notifies listeners', () {
      bool notified = false;
      controller.addListener(() => notified = true);

      controller.initialize(source: start, target: exit, result: sampleResult);

      expect(notified, isTrue);
      expect(controller.isActive, isTrue);
      expect(controller.isPlaying, isFalse);
      expect(controller.state?.currentStep, 0);
      expect(controller.state?.totalSteps, sampleResult.events.length);
    });

    test('step advances by one event and pauses if playing', () {
      controller.initialize(source: start, target: exit, result: sampleResult);

      controller.step();
      expect(controller.state?.currentStep, 1);

      controller.step();
      expect(controller.state?.currentStep, 2);
    });

    test('play and pause toggle playback timer and isPlaying flag', () {
      controller.initialize(source: start, target: exit, result: sampleResult);

      expect(controller.isPlaying, isFalse);
      controller.play();
      expect(controller.isPlaying, isTrue);

      controller.pause();
      expect(controller.isPlaying, isFalse);
    });

    test('setSpeed updates speed multiplier safely', () {
      controller.initialize(source: start, target: exit, result: sampleResult);

      expect(controller.playbackSpeed, 1.0);
      controller.setSpeed(2.0);
      expect(controller.playbackSpeed, 2.0);

      // Invalid or negative speed ignored
      controller.setSpeed(-1.0);
      expect(controller.playbackSpeed, 2.0);
    });

    test('showFinalPath immediately reveals all settled nodes and route', () {
      controller.initialize(source: start, target: exit, result: sampleResult);

      controller.showFinalPath();
      expect(controller.state?.isCompleted, isTrue);
      expect(controller.state?.finalPath, sampleResult.path);
      expect(
        controller.state?.settledNodes.length,
        sampleResult.settledNodesCount,
      );
    });

    test('reset resets step progress to step 0', () {
      controller.initialize(source: start, target: exit, result: sampleResult);

      controller.step();
      controller.step();
      expect(controller.state?.currentStep, 2);

      controller.reset();
      expect(controller.state?.currentStep, 0);
      expect(controller.state?.isCompleted, isFalse);
    });

    test('clear cancels timer, nullifies state, and notifies', () {
      controller.initialize(source: start, target: exit, result: sampleResult);
      controller.play();

      bool notified = false;
      controller.addListener(() => notified = true);

      controller.clear();
      expect(controller.isActive, isFalse);
      expect(controller.isPlaying, isFalse);
      expect(controller.state, isNull);
      expect(notified, isTrue);
    });
  });
}
