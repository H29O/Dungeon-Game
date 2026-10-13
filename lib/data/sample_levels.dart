import '../models/dungeon_level.dart';
import '../models/dungeon_tile.dart';
import '../models/grid_position.dart';

/// Provides deterministic, hand-crafted levels for testing and demonstration.
class SampleLevels {
  /// The primary deterministic demo level: "The Labyrinth Threshold".
  ///
  /// Topology: 6x6 grid.
  /// Start: `(0, 0)`
  /// Exit: `(5, 5)`
  ///
  /// Features:
  /// - Normal corridors (cost: 1).
  /// - Upper route featuring Rubble at (0, 2) (cost: 3).
  /// - Central hazardous shortcut at Row 2 (cost: 5 each).
  /// - Energy canister pickup at (3, 0) (+20 energy).
  /// - Treasure cache at (0, 4) (+100 points).
  /// - Initial energy: 60, Max energy: 100.
  /// - Guaranteed reachable exit with verified optimal route cost of 10.
  static DungeonLevel get level1 {
    final List<List<DungeonTile>> grid = [
      // Row 0
      [
        DungeonTile.floor(movementCost: 1), // (0, 0) Start
        DungeonTile.floor(movementCost: 1), // (0, 1)
        DungeonTile.rubble(movementCost: 3), // (0, 2)
        DungeonTile.floor(movementCost: 1), // (0, 3)
        DungeonTile.treasure(movementCost: 1, points: 100), // (0, 4)
        DungeonTile.wall(), // (0, 5)
      ],
      // Row 1
      [
        DungeonTile.floor(movementCost: 1), // (1, 0)
        DungeonTile.wall(), // (1, 1)
        DungeonTile.wall(), // (1, 2)
        DungeonTile.wall(), // (1, 3)
        DungeonTile.floor(movementCost: 1), // (1, 4)
        DungeonTile.wall(), // (1, 5)
      ],
      // Row 2: Central hazardous shortcut
      [
        DungeonTile.floor(movementCost: 1), // (2, 0)
        DungeonTile.hazard(movementCost: 5), // (2, 1)
        DungeonTile.hazard(movementCost: 5), // (2, 2)
        DungeonTile.hazard(movementCost: 5), // (2, 3)
        DungeonTile.floor(movementCost: 1), // (2, 4)
        DungeonTile.wall(), // (2, 5)
      ],
      // Row 3
      [
        DungeonTile.energyPickup(movementCost: 1, energyAmount: 20), // (3, 0)
        DungeonTile.wall(), // (3, 1)
        DungeonTile.wall(), // (3, 2)
        DungeonTile.wall(), // (3, 3)
        DungeonTile.floor(movementCost: 1), // (3, 4)
        DungeonTile.wall(), // (3, 5)
      ],
      // Row 4
      [
        DungeonTile.floor(movementCost: 1), // (4, 0)
        DungeonTile.floor(movementCost: 1), // (4, 1)
        DungeonTile.floor(movementCost: 1), // (4, 2)
        DungeonTile.floor(movementCost: 1), // (4, 3)
        DungeonTile.floor(movementCost: 1), // (4, 4)
        DungeonTile.floor(movementCost: 1), // (4, 5)
      ],
      // Row 5
      [
        DungeonTile.wall(), // (5, 0)
        DungeonTile.wall(), // (5, 1)
        DungeonTile.wall(), // (5, 2)
        DungeonTile.wall(), // (5, 3)
        DungeonTile.wall(), // (5, 4)
        DungeonTile.exit(movementCost: 1), // (5, 5) Exit
      ],
    ];

    return DungeonLevel(
      id: 'level_1',
      name: 'The Labyrinth Threshold',
      rows: 6,
      cols: 6,
      grid: grid,
      start: const GridPosition(0, 0),
      exit: const GridPosition(5, 5),
      initialEnergy: 60,
      maxEnergy: 100,
    );
  }
}
