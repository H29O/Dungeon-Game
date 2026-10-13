import 'package:flutter/material.dart';

import '../data/sample_levels.dart';
import '../game/game_controller.dart';
import '../widgets/algorithm_vision_panel.dart';
import '../widgets/dungeon_board.dart';
import '../widgets/movement_controls.dart';

/// Complete, playable dungeon exploration screen with integrated
/// Algorithm Vision for Dijkstra shortest-path observation.
class DungeonScreen extends StatefulWidget {
  final GameController? controller;

  const DungeonScreen({super.key, this.controller});

  @override
  State<DungeonScreen> createState() => _DungeonScreenState();
}

class _DungeonScreenState extends State<DungeonScreen> {
  late final GameController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = GameController(level: SampleLevels.level1);
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF3867D6),
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              _controller.level.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _controller.isPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                ),
                tooltip: _controller.isPaused ? 'Resume' : 'Pause',
                onPressed: _controller.isWon || _controller.isLost
                    ? null
                    : () {
                        if (_controller.isPaused) {
                          _controller.resume();
                        } else {
                          _controller.pause();
                        }
                      },
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt_rounded),
                tooltip: 'Restart Level',
                onPressed: () => _controller.restartLevel(),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 8),
                  if (_controller.isWon)
                    _buildVictoryBanner()
                  else if (_controller.isLost)
                    _buildLossBanner()
                  else if (_controller.isPaused)
                    _buildPausedBanner()
                  else if (_controller.lastRejectionReason != null)
                    _buildRejectionBanner(),
                  const SizedBox(height: 8),

                  // Dungeon Board with optional Algorithm Vision overlays
                  ListenableBuilder(
                    listenable: _controller.visualizationController,
                    builder: (context, _) {
                      return DungeonBoard(
                        level: _controller.level,
                        playerState: _controller.playerState,
                        visualizationState:
                            _controller.visualizationController.state,
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Interactive controls: Algorithm Vision panel or manual controls
                  if (_controller.isShowingAlgorithm)
                    AlgorithmVisionPanel(controller: _controller)
                  else ...[
                    _buildLegend(),
                    const SizedBox(height: 8),
                    _buildVisionLaunchButton(),
                    const SizedBox(height: 8),
                    MovementControls(controller: _controller),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisionLaunchButton() {
    final canLaunch =
        !_controller.isWon && !_controller.isLost && !_controller.isPaused;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.visibility_rounded, size: 18),
        label: const Text('Algorithm Vision'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          side: const BorderSide(color: Color(0xFF3867D6), width: 1.5),
          foregroundColor: const Color(0xFF3867D6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: canLaunch ? () => _controller.startAlgorithmVision() : null,
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCE3ED)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.bolt_rounded,
            iconColor: const Color(0xFFD9921E),
            label: 'Energy',
            value: '${_controller.currentEnergy}/${_controller.maxEnergy}',
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.directions_walk_rounded,
            iconColor: const Color(0xFF3867D6),
            label: 'Moves',
            value: '${_controller.moveCount}',
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.speed_rounded,
            iconColor: const Color(0xFF138A72),
            label: 'Route Cost',
            value: '${_controller.cumulativeRouteCost}',
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFD9921E),
            label: 'Score',
            value: '${_controller.score}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF596579)),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: const Color(0xFFE2E8F0));
  }

  Widget _buildVictoryBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF138A72)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF138A72)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Labyrinth Escaped! Victory!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF138A72),
                  ),
                ),
                Text(
                  'Moves: ${_controller.moveCount} • Cumulative Cost: ${_controller.cumulativeRouteCost} • Score: ${_controller.score}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF172033),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _controller.restartLevel(),
            child: const Text('Replay'),
          ),
        ],
      ),
    );
  }

  Widget _buildLossBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEEE9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9534F)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_rounded, color: Color(0xFFD9534F)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Energy Depleted! The explorer could not escape.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFD9534F),
              ),
            ),
          ),
          TextButton(
            onPressed: () => _controller.restartLevel(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPausedBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9E7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9921E)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pause_circle_filled_rounded,
            color: Color(0xFFD9921E),
            size: 18,
          ),
          const SizedBox(width: 8),
          const Text(
            'Game Paused',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFD9921E),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => _controller.resume(),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDBA74)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFFEA580C),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _controller.lastRejectionReason!,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9A3412)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem('Floor', '1', const Color(0xFF64748B)),
          _buildLegendItem('Rubble', '3', const Color(0xFFD9921E)),
          _buildLegendItem('Hazard', '5', const Color(0xFFD9534F)),
          _buildLegendIcon('Wall', Icons.grid_4x4, const Color(0xFF2C3A47)),
          _buildLegendIcon(
            'Exit',
            Icons.door_sliding_outlined,
            const Color(0xFF138A72),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String cost, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            cost,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF596579)),
        ),
      ],
    );
  }

  Widget _buildLegendIcon(String label, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF596579)),
        ),
      ],
    );
  }
}
