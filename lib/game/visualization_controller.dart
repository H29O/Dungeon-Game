import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/grid_position.dart';
import '../models/path_result.dart';
import '../models/visualization_state.dart';

/// Controller managing the event-driven replay, timer loop, playback speed,
/// and display states for Algorithm Vision.
class VisualizationController extends ChangeNotifier {
  VisualizationState? _state;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  Timer? _timer;

  VisualizationState? get state => _state;
  bool get isActive => _state != null;
  bool get isPlaying => _isPlaying;
  double get playbackSpeed => _playbackSpeed;

  /// Initializes visualization with the captured algorithm result.
  void initialize({
    required GridPosition source,
    required GridPosition target,
    required PathResult result,
  }) {
    _cancelTimer();
    _isPlaying = false;
    _state = VisualizationState.initial(
      source: source,
      target: target,
      result: result,
    );
    notifyListeners();
  }

  /// Advances the visualization by exactly one algorithm event.
  void step() {
    if (_state == null) return;
    if (_isPlaying) {
      pause();
    }
    _stepInternal();
  }

  void _stepInternal() {
    if (_state == null) return;
    if (!_state!.hasNextStep) {
      if (_isPlaying) {
        pause();
      }
      return;
    }

    _state = _state!.stepForward();
    if (!_state!.hasNextStep && _isPlaying) {
      _isPlaying = false;
      _cancelTimer();
    }
    notifyListeners();
  }

  /// Begins automatic playback of recorded algorithm events.
  void play() {
    if (_state == null || _isPlaying) return;
    if (!_state!.hasNextStep) {
      // If at end, reset to start before playing again
      _state = _state!.resetToStart();
    }

    _isPlaying = true;
    _startTimer();
    notifyListeners();
  }

  /// Pauses automatic playback.
  void pause() {
    if (!_isPlaying) return;
    _isPlaying = false;
    _cancelTimer();
    notifyListeners();
  }

  /// Sets the playback speed multiplier (e.g. 1.0, 2.0, 4.0).
  void setSpeed(double newSpeed) {
    if (newSpeed <= 0 || newSpeed == _playbackSpeed) return;
    _playbackSpeed = newSpeed;
    if (_isPlaying) {
      _cancelTimer();
      _startTimer();
    }
    notifyListeners();
  }

  /// Immediately reveals all settled nodes and the final optimal route.
  void showFinalPath() {
    if (_state == null) return;
    if (_isPlaying) {
      pause();
    }
    _state = _state!.showFinalPath();
    notifyListeners();
  }

  /// Resets replay back to the first step.
  void reset() {
    if (_state == null) return;
    if (_isPlaying) {
      pause();
    }
    _state = _state!.resetToStart();
    notifyListeners();
  }

  /// Clears the visualization overlays and resets controller state.
  void clear() {
    _cancelTimer();
    _isPlaying = false;
    _state = null;
    notifyListeners();
  }

  void _startTimer() {
    _cancelTimer();
    final intervalMs = (350 / _playbackSpeed).round().clamp(25, 1000);
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _stepInternal();
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
