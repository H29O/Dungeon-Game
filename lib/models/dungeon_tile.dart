/// Represents the terrain and obstacle classification of a dungeon cell.
enum TileType { floor, wall, rubble, hazard, exit }

/// Represents optional collectible items placed upon a traversable tile.
enum CollectibleType { none, energy, treasure }

/// Represents an immutable tile on the dungeon grid.
///
/// In accordance with the project specification:
/// - Moving from cell `u` into cell `v` incurs the [movementCost] to enter `v`.
/// - Walls are non-traversable and must be excluded from graph traversal.
/// - Negative movement costs are strictly invalid and rejected during construction.
class DungeonTile {
  final TileType type;
  final int movementCost;
  final bool isTraversable;
  final CollectibleType collectible;
  final int collectibleValue;

  /// Primary constructor validating constraints.
  const DungeonTile({
    required this.type,
    required this.movementCost,
    required this.isTraversable,
    this.collectible = CollectibleType.none,
    this.collectibleValue = 0,
  }) : assert(movementCost >= 0, 'Movement cost must be non-negative'),
       assert(
         type != TileType.wall || !isTraversable,
         'Walls must never be traversable',
       );

  /// Factory creating a validated tile with runtime error checking.
  factory DungeonTile.create({
    required TileType type,
    required int movementCost,
    bool? isTraversable,
    CollectibleType collectible = CollectibleType.none,
    int collectibleValue = 0,
  }) {
    if (movementCost < 0) {
      throw ArgumentError.value(
        movementCost,
        'movementCost',
        'Movement cost cannot be negative',
      );
    }

    final traversable = (type == TileType.wall)
        ? false
        : (isTraversable ?? true);

    return DungeonTile(
      type: type,
      movementCost: movementCost,
      isTraversable: traversable,
      collectible: collectible,
      collectibleValue: collectibleValue,
    );
  }

  /// Standard traversable floor corridor (default entry cost: 1).
  factory DungeonTile.floor({
    int movementCost = 1,
    CollectibleType collectible = CollectibleType.none,
    int collectibleValue = 0,
  }) {
    return DungeonTile.create(
      type: TileType.floor,
      movementCost: movementCost,
      collectible: collectible,
      collectibleValue: collectibleValue,
    );
  }

  /// Wall obstacle that cannot be entered or traversed.
  factory DungeonTile.wall() {
    return const DungeonTile(
      type: TileType.wall,
      movementCost: 0,
      isTraversable: false,
      collectible: CollectibleType.none,
      collectibleValue: 0,
    );
  }

  /// Costly rubble terrain (default entry cost: 3).
  factory DungeonTile.rubble({
    int movementCost = 3,
    CollectibleType collectible = CollectibleType.none,
    int collectibleValue = 0,
  }) {
    return DungeonTile.create(
      type: TileType.rubble,
      movementCost: movementCost,
      collectible: collectible,
      collectibleValue: collectibleValue,
    );
  }

  /// High-cost hazard or water terrain (default entry cost: 5).
  factory DungeonTile.hazard({
    int movementCost = 5,
    CollectibleType collectible = CollectibleType.none,
    int collectibleValue = 0,
  }) {
    return DungeonTile.create(
      type: TileType.hazard,
      movementCost: movementCost,
      collectible: collectible,
      collectibleValue: collectibleValue,
    );
  }

  /// Exit portal cell representing the labyrinth goal.
  factory DungeonTile.exit({int movementCost = 1}) {
    return DungeonTile.create(
      type: TileType.exit,
      movementCost: movementCost,
      collectible: CollectibleType.none,
      collectibleValue: 0,
    );
  }

  /// Floor cell with an energy recharge canister.
  factory DungeonTile.energyPickup({
    int movementCost = 1,
    int energyAmount = 15,
  }) {
    return DungeonTile.create(
      type: TileType.floor,
      movementCost: movementCost,
      collectible: CollectibleType.energy,
      collectibleValue: energyAmount,
    );
  }

  /// Floor cell with an optional treasure collectible.
  factory DungeonTile.treasure({int movementCost = 1, int points = 100}) {
    return DungeonTile.create(
      type: TileType.floor,
      movementCost: movementCost,
      collectible: CollectibleType.treasure,
      collectibleValue: points,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DungeonTile &&
        other.type == type &&
        other.movementCost == movementCost &&
        other.isTraversable == isTraversable &&
        other.collectible == collectible &&
        other.collectibleValue == collectibleValue;
  }

  @override
  int get hashCode => Object.hash(
    type,
    movementCost,
    isTraversable,
    collectible,
    collectibleValue,
  );

  @override
  String toString() =>
      'DungeonTile(type: $type, cost: $movementCost, traversable: $isTraversable, collectible: $collectible)';
}
