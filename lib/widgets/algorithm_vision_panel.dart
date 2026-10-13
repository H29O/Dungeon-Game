import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../models/algorithm_event.dart';

/// Interactive control panel and real-time statistics display for Algorithm Vision.
class AlgorithmVisionPanel extends StatelessWidget {
  final GameController controller;

  const AlgorithmVisionPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final vController = controller.visualizationController;

    return ListenableBuilder(
      listenable: vController,
      builder: (context, _) {
        final state = vController.state;
        if (state == null) return const SizedBox.shrink();

        final result = state.result;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Algorithm Statistics Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDCE3ED)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility_rounded,
                            size: 18,
                            color: Color(0xFF3867D6),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Algorithm Vision',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172033),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: result.hasPath
                              ? const Color(0xFFE8F8F5)
                              : const Color(0xFFFDEEE9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: result.hasPath
                                ? const Color(0xFF138A72)
                                : const Color(0xFFD9534F),
                          ),
                        ),
                        child: Text(
                          result.hasPath
                              ? 'Optimal Cost: ${result.totalCost}'
                              : 'No Path Found',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: result.hasPath
                                ? const Color(0xFF138A72)
                                : const Color(0xFFD9534F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Metrics Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric(
                        label: 'Endpoints',
                        value:
                            '(${state.source.row},${state.source.col})→(${state.target.row},${state.target.col})',
                      ),
                      _buildMetric(
                        label: 'Path Length',
                        value: result.hasPath
                            ? '${result.path.length} cells'
                            : '0 cells',
                      ),
                      _buildMetric(
                        label: 'Settled',
                        value: '${result.settledNodesCount} nodes',
                      ),
                      _buildMetric(
                        label: 'Relaxations',
                        value:
                            '${result.relaxationCount} (${result.successfulRelaxationsCount})',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Computation time & current step description
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Step ${state.currentStep} / ${state.totalSteps}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3867D6),
                              ),
                            ),
                            Text(
                              'Computed in ${result.duration.inMicroseconds} µs',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF596579),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _describeEvent(state.currentEvent, state),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF172033),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Vision Legend
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem(
                    'Frontier',
                    const Color(0xFFF59E0B),
                    const Color(0xFFFEF3C7),
                  ),
                  _buildLegendItem(
                    'Settled',
                    const Color(0xFF818CF8),
                    const Color(0xFFEEF2FF),
                  ),
                  _buildLegendItem(
                    'Optimal Route',
                    const Color(0xFF3867D6),
                    const Color(0xFFDBEAFE),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Playback Controls
            _buildControlsBar(vController, state),
          ],
        );
      },
    );
  }

  Widget _buildMetric({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Color(0xFF596579)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172033),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color borderColor, Color fillColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: borderColor, width: 1.5),
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

  Widget _buildControlsBar(dynamic vController, dynamic state) {
    return Column(
      children: [
        // Primary Action Buttons
        Row(
          children: [
            // Step Button
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.skip_next_rounded, size: 16),
                label: const Text('Step'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(color: Color(0xFF3867D6)),
                  foregroundColor: const Color(0xFF3867D6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: state.hasNextStep ? () => vController.step() : null,
              ),
            ),
            const SizedBox(width: 6),

            // Play / Pause Button
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(
                  vController.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 16,
                ),
                label: Text(vController.isPlaying ? 'Pause' : 'Play'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: const Color(0xFF3867D6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (vController.isPlaying) {
                    vController.pause();
                  } else {
                    vController.play();
                  }
                },
              ),
            ),
            const SizedBox(width: 6),

            // Show Final Path Button (Fast-Finish)
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.fast_forward_rounded, size: 16),
                label: const Text('Final'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(color: Color(0xFF138A72)),
                  foregroundColor: const Color(0xFF138A72),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => vController.showFinalPath(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Speed & Exit Row
        Row(
          children: [
            // Speed Chips
            const Text(
              'Speed: ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF596579),
              ),
            ),
            _buildSpeedChip(vController, 1.0, '1×'),
            const SizedBox(width: 4),
            _buildSpeedChip(vController, 2.0, '2×'),
            const SizedBox(width: 4),
            _buildSpeedChip(vController, 4.0, '4×'),

            const Spacer(),

            // Reset Button
            IconButton(
              icon: const Icon(Icons.replay_rounded, size: 20),
              tooltip: 'Reset Replay',
              color: const Color(0xFF596579),
              onPressed: () => vController.reset(),
            ),

            // Close Vision Button
            TextButton.icon(
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Close Vision'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD9534F),
              ),
              onPressed: () => controller.closeAlgorithmVision(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeedChip(dynamic vController, double speed, String label) {
    final isSelected = vController.playbackSpeed == speed;
    return InkWell(
      onTap: () => vController.setSpeed(speed),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3867D6) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF596579),
          ),
        ),
      ),
    );
  }

  String _describeEvent(AlgorithmEvent? event, dynamic state) {
    if (event == null) {
      if (state.isCompleted) {
        return state.result.hasPath
            ? 'Shortest path found! Total optimal cost: ${state.result.totalCost}'
            : 'Exploration exhausted: exit is unreachable.';
      }
      return 'Ready to explore: tap Step or Play to observe Dijkstra.';
    }

    return switch (event) {
      NodeDiscoveredEvent e =>
        'Frontier: Discovered node (${e.position.row}, ${e.position.col}) with tentative dist ${e.distance}',
      NodeSettledEvent e =>
        'Settled: Finalized shortest path to (${e.position.row}, ${e.position.col}) (cost ${e.distance})',
      DistanceUpdatedEvent e =>
        'Relaxation: Node (${e.position.row}, ${e.position.col}) updated from ${e.oldDistance} to ${e.newDistance}',
      PathCompletedEvent e =>
        'Finalized: Reconstructed optimal route of ${e.path.length} steps (cost ${e.totalCost})',
    };
  }
}
