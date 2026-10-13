import 'package:flutter/material.dart';

import '../models/dungeon_level.dart';
import '../models/dungeon_tile.dart';
import '../models/grid_position.dart';
import '../models/player_state.dart';

/// Responsive grid board displaying the labyrinth tiles, obstacles, and player.
class DungeonBoard extends StatelessWidget {
  final DungeonLevel level;
  final PlayerState playerState;

  const DungeonBoard({
    super.key,
    required this.level,
    required this.playerState,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDimension = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        final double boardSize = maxDimension.clamp(200.0, 380.0);

        return Center(
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCE3ED), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: List.generate(level.rows, (r) {
                return Expanded(
                  child: Row(
                    children: List.generate(level.cols, (c) {
                      final pos = GridPosition(r, c);
                      final tile = level.tileAt(pos);
                      final isPlayerHere = playerState.position == pos;
                      final isCollected = playerState.collectedItemIds.contains(
                        'item_${r}_$c',
                      );

                      return Expanded(
                        child: _buildTileCell(
                          pos: pos,
                          tile: tile,
                          isPlayerHere: isPlayerHere,
                          isCollected: isCollected,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTileCell({
    required GridPosition pos,
    required DungeonTile tile,
    required bool isPlayerHere,
    required bool isCollected,
  }) {
    Color backgroundColor;
    Widget? terrainContent;

    switch (tile.type) {
      case TileType.wall:
        backgroundColor = const Color(0xFF2C3A47);
        terrainContent = const Icon(
          Icons.grid_4x4,
          size: 16,
          color: Color(0xFF4A5F73),
        );
        break;

      case TileType.rubble:
        backgroundColor = const Color(0xFFFEF9E7);
        terrainContent = const Text(
          '3',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD9921E),
          ),
        );
        break;

      case TileType.hazard:
        backgroundColor = const Color(0xFFFDEEE9);
        terrainContent = const Text(
          '5',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD9534F),
          ),
        );
        break;

      case TileType.exit:
        backgroundColor = const Color(0xFFE8F8F5);
        terrainContent = const Icon(
          Icons.door_sliding_outlined,
          size: 18,
          color: Color(0xFF138A72),
        );
        break;

      case TileType.floor:
        backgroundColor = const Color(0xFFFFFFFF);
        break;
    }

    // Optional uncollected items
    Widget? itemIcon;
    if (!isCollected) {
      if (tile.collectible == CollectibleType.energy) {
        itemIcon = const Icon(
          Icons.bolt_rounded,
          size: 16,
          color: Color(0xFFD9921E),
        );
      } else if (tile.collectible == CollectibleType.treasure) {
        itemIcon = const Icon(
          Icons.diamond_outlined,
          size: 16,
          color: Color(0xFFD9921E),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ?terrainContent,
          ?itemIcon,
          if (isPlayerHere)
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFF3867D6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x663867D6),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.navigation_rounded,
                size: 15,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
