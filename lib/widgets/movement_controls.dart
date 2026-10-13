import 'package:flutter/material.dart';

import '../game/direction.dart';
import '../game/game_controller.dart';

/// Large, accessible directional movement pad for navigating the dungeon.
class MovementControls extends StatelessWidget {
  final GameController controller;

  const MovementControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool canMove =
        !controller.isWon && !controller.isLost && !controller.isPaused;

    return Center(
      child: SizedBox(
        width: 190,
        height: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Up Button
            _buildDirectionButton(
              context: context,
              direction: Direction.up,
              icon: Icons.keyboard_arrow_up_rounded,
              enabled: canMove,
            ),
            const SizedBox(height: 6),
            // Middle Row: Left, Center spacer, Right
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDirectionButton(
                  context: context,
                  direction: Direction.left,
                  icon: Icons.keyboard_arrow_left_rounded,
                  enabled: canMove,
                ),
                const SizedBox(width: 48),
                _buildDirectionButton(
                  context: context,
                  direction: Direction.right,
                  icon: Icons.keyboard_arrow_right_rounded,
                  enabled: canMove,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Down Button
            _buildDirectionButton(
              context: context,
              direction: Direction.down,
              icon: Icons.keyboard_arrow_down_rounded,
              enabled: canMove,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton({
    required BuildContext context,
    required Direction direction,
    required IconData icon,
    required bool enabled,
  }) {
    return SizedBox(
      width: 48,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: enabled
              ? const Color(0xFFFFFFFF)
              : const Color(0xFFF1F5F9),
          foregroundColor: enabled
              ? const Color(0xFF3867D6)
              : const Color(0xFF94A3B8),
          elevation: enabled ? 1 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: enabled
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        onPressed: enabled ? () => controller.move(direction) : null,
        child: Icon(icon, size: 26),
      ),
    );
  }
}
