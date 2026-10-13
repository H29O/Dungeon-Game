import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/models/dungeon_tile.dart';

void main() {
  group('DungeonTile', () {
    test('floor tile defaults to cost 1 and traversable', () {
      final tile = DungeonTile.floor();
      expect(tile.type, equals(TileType.floor));
      expect(tile.movementCost, equals(1));
      expect(tile.isTraversable, isTrue);
      expect(tile.collectible, equals(CollectibleType.none));
    });

    test('wall tile is non-traversable', () {
      final wall = DungeonTile.wall();
      expect(wall.type, equals(TileType.wall));
      expect(wall.isTraversable, isFalse);
    });

    test('rubble tile has higher default cost', () {
      final rubble = DungeonTile.rubble();
      expect(rubble.type, equals(TileType.rubble));
      expect(rubble.movementCost, equals(3));
      expect(rubble.isTraversable, isTrue);
    });

    test('hazard tile has high default cost', () {
      final hazard = DungeonTile.hazard();
      expect(hazard.type, equals(TileType.hazard));
      expect(hazard.movementCost, equals(5));
      expect(hazard.isTraversable, isTrue);
    });

    test('exit tile is traversable', () {
      final exit = DungeonTile.exit();
      expect(exit.type, equals(TileType.exit));
      expect(exit.isTraversable, isTrue);
      expect(exit.movementCost, equals(1));
    });

    test('energy pickup and treasure metadata', () {
      final energy = DungeonTile.energyPickup(energyAmount: 20);
      expect(energy.collectible, equals(CollectibleType.energy));
      expect(energy.collectibleValue, equals(20));

      final treasure = DungeonTile.treasure(points: 150);
      expect(treasure.collectible, equals(CollectibleType.treasure));
      expect(treasure.collectibleValue, equals(150));
    });

    test('rejects negative movement costs in factory', () {
      expect(
        () => DungeonTile.create(type: TileType.floor, movementCost: -1),
        throwsArgumentError,
      );
      expect(
        () => DungeonTile.create(type: TileType.rubble, movementCost: -5),
        throwsArgumentError,
      );
    });

    test('walls can never be traversable', () {
      final tile = DungeonTile.create(
        type: TileType.wall,
        movementCost: 0,
        isTraversable: true, // overridden by factory
      );
      expect(tile.isTraversable, isFalse);
    });

    test('value equality and hashCode', () {
      final tile1 = DungeonTile.floor(movementCost: 2);
      final tile2 = DungeonTile.floor(movementCost: 2);
      final tile3 = DungeonTile.floor(movementCost: 3);

      expect(tile1, equals(tile2));
      expect(tile1.hashCode, equals(tile2.hashCode));
      expect(tile1, isNot(equals(tile3)));
    });
  });
}
