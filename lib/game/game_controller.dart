import 'package:flutter/foundation.dart';

import '../models/dungeon_level.dart';
import '../models/dungeon_tile.dart';
import '../models/grid_position.dart';
import '../models/player_state.dart';
import 'direction.dart';

/// Single authority managing gameplay state and transactions for a dungeon run.
class GameController extends ChangeNotifier {
  final DungeonLevel level;
  late PlayerState _playerState;
  final List<GridPosition> _movementHistory = [];
  String? _lastRejectionReason;

  GameController({required this.level}) {
    _initLevel();
  }

  void _initLevel() {
    _playerState = PlayerState.initial(
      startPosition: level.start,
      initialEnergy: level.initialEnergy,
      maxEnergy: level.maxEnergy,
    );
    _movementHistory.clear();
    _movementHistory.add(level.start);
    _lastRejectionReason = null;
  }

  // --- Getters ---

  PlayerState get playerState => _playerState;
  GridPosition get playerPosition => _playerState.position;
  int get currentEnergy => _playerState.currentEnergy;
  int get maxEnergy => _playerState.maxEnergy;
  int get score => _playerState.score;
  int get moveCount => _playerState.moveCount;
  int get cumulativeRouteCost => _playerState.cumulativeRouteCost;
  GameStatus get status => _playerState.status;
  Set<String> get collectedItemIds => _playerState.collectedItemIds;
  int get hintUsageCount => _playerState.hintUsageCount;

  bool get isWon => _playerState.status == GameStatus.won;
  bool get isLost => _playerState.status == GameStatus.lost;
  bool get isPaused => _playerState.status == GameStatus.paused;
  bool get isPlaying => _playerState.status == GameStatus.playing;
  bool get isReady => _playerState.status == GameStatus.ready;

  String? get lastRejectionReason => _lastRejectionReason;
  List<GridPosition> get movementHistory => List.unmodifiable(_movementHistory);

  /// Executes an atomic player movement step in the specified [direction].
  ///
  /// Strictly adheres to the 11-step movement transaction protocol:
  /// 1. Verify game status permits movement.
  /// 2. Compute destination coordinate.
  /// 3. Reject out-of-bounds movement.
  /// 4. Reject movement into walls.
  /// 5. Reject movement if energy is insufficient for destination tile entry cost.
  /// 6. Deduct entry cost exactly once.
  /// 7. Update player position and move count.
  /// 8. Update cumulative route cost.
  /// 9. Collect item at destination if uncollected (energy/treasure).
  /// 10. Check if exit reached (victory) or energy depleted (loss).
  /// 11. Commit state atomically and notify listeners.
  ///
  /// Returns `true` if the movement succeeded; `false` if rejected.
  bool move(Direction direction) {
    // Step 1: Verify game status permits movement
    if (_playerState.status == GameStatus.won) {
      _reject('Labyrinth already completed! Restart to explore again.');
      return false;
    }
    if (_playerState.status == GameStatus.lost) {
      _reject('Energy depleted! Restart to attempt the labyrinth again.');
      return false;
    }
    if (_playerState.status == GameStatus.paused) {
      _reject('Game is paused. Tap Resume to continue.');
      return false;
    }

    // Step 2: Compute destination coordinate
    final target = direction.offset(_playerState.position);

    // Step 3: Reject out-of-bounds movement
    if (!level.isInBounds(target)) {
      _reject('Cannot move out of the dungeon boundaries.');
      return false;
    }

    // Step 4: Reject movement into walls
    final tile = level.tileAt(target);
    if (!tile.isTraversable) {
      _reject('Blocked by solid dungeon wall.');
      return false;
    }

    // Step 5: Reject movement if cannot afford destination entry cost
    final entryCost = level.costToEnter(target);
    if (_playerState.currentEnergy < entryCost) {
      _reject(
        'Insufficient energy! Tile requires $entryCost energy, but you have only ${_playerState.currentEnergy}.',
      );
      return false;
    }

    // Step 6: Deduct entry cost exactly once
    int newEnergy = _playerState.currentEnergy - entryCost;

    // Step 7: Update move count
    final newMoveCount = _playerState.moveCount + 1;

    // Step 8: Update cumulative route cost
    final newRouteCost = _playerState.cumulativeRouteCost + entryCost;

    // Step 9: Collect item at destination if present
    int newScore = _playerState.score;
    final newCollected = Set<String>.from(_playerState.collectedItemIds);
    final itemId = 'item_${target.row}_${target.col}';

    if (tile.collectible != CollectibleType.none &&
        !newCollected.contains(itemId)) {
      newCollected.add(itemId);

      if (tile.collectible == CollectibleType.energy) {
        // Energy pickup is applied after movement cost deduction, capped at maxEnergy
        newEnergy = (newEnergy + tile.collectibleValue).clamp(
          0,
          _playerState.maxEnergy,
        );
      } else if (tile.collectible == CollectibleType.treasure) {
        newScore += tile.collectibleValue;
      }
    }

    // Step 10: Check exit and failure conditions
    GameStatus newStatus;
    if (target == level.exit) {
      newStatus = GameStatus.won;
      newScore += 100; // Completion reward
    } else if (newEnergy <= 0) {
      newStatus = GameStatus.lost;
    } else {
      newStatus = GameStatus.playing;
    }

    // Step 11: Commit state atomically and notify listeners
    _playerState = _playerState.copyWith(
      position: target,
      currentEnergy: newEnergy,
      moveCount: newMoveCount,
      cumulativeRouteCost: newRouteCost,
      score: newScore,
      collectedItemIds: newCollected,
      status: newStatus,
    );
    _movementHistory.add(target);
    _lastRejectionReason = null;
    notifyListeners();
    return true;
  }

  /// Pauses the game if currently playing.
  void pause() {
    if (_playerState.status == GameStatus.playing) {
      _playerState = _playerState.copyWith(status: GameStatus.paused);
      _lastRejectionReason = null;
      notifyListeners();
    }
  }

  /// Resumes the game if currently paused.
  void resume() {
    if (_playerState.status == GameStatus.paused) {
      _playerState = _playerState.copyWith(status: GameStatus.playing);
      _lastRejectionReason = null;
      notifyListeners();
    }
  }

  /// Restores the exact initial gameplay state, resetting player position,
  /// energy reserves, score, collected items, and movement history.
  void restartLevel() {
    _initLevel();
    notifyListeners();
  }

  void _reject(String reason) {
    _lastRejectionReason = reason;
    notifyListeners();
  }
}
