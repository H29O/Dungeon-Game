import 'grid_position.dart';

/// Represents explicit gameplay states.
enum GameStatus { ready, playing, paused, showingAlgorithm, won, lost }

/// Represents the immutable state of a player exploring a dungeon level.
///
/// Designed to be completely independent of Flutter widgets and controllers.
class PlayerState {
  final GridPosition position;
  final int currentEnergy;
  final int maxEnergy;
  final int score;
  final int moveCount;
  final int cumulativeRouteCost;
  final Set<String> collectedItemIds;
  final int hintUsageCount;
  final GameStatus status;

  const PlayerState({
    required this.position,
    required this.currentEnergy,
    required this.maxEnergy,
    this.score = 0,
    this.moveCount = 0,
    this.cumulativeRouteCost = 0,
    this.collectedItemIds = const {},
    this.hintUsageCount = 0,
    this.status = GameStatus.ready,
  });

  /// Factory initializing a clean starting player state at [startPosition].
  factory PlayerState.initial({
    required GridPosition startPosition,
    int initialEnergy = 100,
    int maxEnergy = 100,
  }) {
    return PlayerState(
      position: startPosition,
      currentEnergy: initialEnergy,
      maxEnergy: maxEnergy,
      score: 0,
      moveCount: 0,
      cumulativeRouteCost: 0,
      collectedItemIds: const {},
      hintUsageCount: 0,
      status: GameStatus.ready,
    );
  }

  /// Returns a copy of this state with updated fields.
  PlayerState copyWith({
    GridPosition? position,
    int? currentEnergy,
    int? maxEnergy,
    int? score,
    int? moveCount,
    int? cumulativeRouteCost,
    Set<String>? collectedItemIds,
    int? hintUsageCount,
    GameStatus? status,
  }) {
    return PlayerState(
      position: position ?? this.position,
      currentEnergy: currentEnergy ?? this.currentEnergy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      score: score ?? this.score,
      moveCount: moveCount ?? this.moveCount,
      cumulativeRouteCost: cumulativeRouteCost ?? this.cumulativeRouteCost,
      collectedItemIds: collectedItemIds ?? this.collectedItemIds,
      hintUsageCount: hintUsageCount ?? this.hintUsageCount,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PlayerState) return false;
    return other.position == position &&
        other.currentEnergy == currentEnergy &&
        other.maxEnergy == maxEnergy &&
        other.score == score &&
        other.moveCount == moveCount &&
        other.cumulativeRouteCost == cumulativeRouteCost &&
        other.hintUsageCount == hintUsageCount &&
        other.status == status &&
        _setEquals(other.collectedItemIds, collectedItemIds);
  }

  static bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  @override
  int get hashCode => Object.hash(
    position,
    currentEnergy,
    maxEnergy,
    score,
    moveCount,
    cumulativeRouteCost,
    Object.hashAllUnordered(collectedItemIds),
    hintUsageCount,
    status,
  );

  @override
  String toString() =>
      'PlayerState(pos: $position, energy: $currentEnergy/$maxEnergy, score: $score, moves: $moveCount, cost: $cumulativeRouteCost, status: $status)';
}
