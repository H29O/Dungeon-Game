import 'package:flutter/material.dart';

import '../game/game_controller.dart';

/// Screen presenting comprehensive run statistics, path comparisons,
/// and replay actions upon dungeon completion or defeat.
class ResultsScreen extends StatelessWidget {
  final GameController controller;
  final VoidCallback? onReplay;
  final VoidCallback? onMainMenu;

  const ResultsScreen({
    super.key,
    required this.controller,
    this.onReplay,
    this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isVictory = controller.isWon;
    final primaryAccent = isVictory
        ? const Color(0xFF138A72)
        : const Color(0xFFD9534F);
    final headerBg = isVictory
        ? const Color(0xFFE8F8F5)
        : const Color(0xFFFDEEE9);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text(
          isVictory ? 'Mission Complete' : 'Run Over',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Dungeon',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Outcome Banner
                  _buildOutcomeHeader(isVictory, primaryAccent, headerBg),
                  const SizedBox(height: 16),

                  // Route Cost & Dijkstra Comparison (Core Academic Feature)
                  _buildPathComparisonCard(context),
                  const SizedBox(height: 16),

                  // Run Statistics Card
                  _buildRunStatisticsCard(),
                  const SizedBox(height: 24),

                  // Primary Navigation Actions
                  _buildActionButtons(context),
                  const SizedBox(height: 16),

                  // Academic Project Footer
                  const Text(
                    'PCCOE IT • DAA Academic Project\nShortest Path Exploration with Dijkstra Engine',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8C98A9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutcomeHeader(
    bool isVictory,
    Color primaryAccent,
    Color headerBg,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: primaryAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVictory
                  ? Icons.emoji_events_rounded
                  : Icons.heart_broken_rounded,
              size: 36,
              color: primaryAccent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isVictory ? 'Labyrinth Escaped!' : 'Defeat: Energy Depleted',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryAccent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isVictory
                ? 'Explorer successfully reached the exit portal alive.'
                : 'Energy reserves ran out before reaching the exit.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF596579)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPathComparisonCard(BuildContext context) {
    final actualCost = controller.cumulativeRouteCost;
    final optimalCost = controller.optimalRouteCost;
    final efficiency = controller.routeEfficiency;
    final isVictory = controller.isWon;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFDCE3ED)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.compare_arrows_rounded,
                  size: 20,
                  color: Color(0xFF3867D6),
                ),
                SizedBox(width: 8),
                Text(
                  'Route Cost Comparison',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Actual Route Cost
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDCE3ED)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Actual Route Cost',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF596579),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$actualCost',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172033),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Traversed path sum',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF8C98A9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Optimal Dijkstra Cost
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF138A72).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Optimal Dijkstra Cost',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF138A72),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$optimalCost',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF138A72),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Theoretical minimum',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF596579),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isVictory) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: efficiency >= 100.0
                      ? const Color(0xFFE8F8F5)
                      : const Color(0xFFFEF9E7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: efficiency >= 100.0
                        ? const Color(0xFF138A72)
                        : const Color(0xFFD9921E),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      efficiency >= 100.0
                          ? Icons.stars_rounded
                          : Icons.info_outline_rounded,
                      size: 18,
                      color: efficiency >= 100.0
                          ? const Color(0xFF138A72)
                          : const Color(0xFFD9921E),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Route Efficiency: ${efficiency.toStringAsFixed(1)}% '
                        '${efficiency >= 100.0 ? "(Optimal! 🏆)" : "(Suboptimal path taken)"}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: efficiency >= 100.0
                              ? const Color(0xFF138A72)
                              : const Color(0xFF9A3412),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              '• Note: Dijkstra\'s algorithm guarantees minimum total edge cost, '
              'not necessarily the fewest grid steps.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Color(0xFF596579),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunStatisticsCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFDCE3ED)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 20,
                  color: Color(0xFF3867D6),
                ),
                SizedBox(width: 8),
                Text(
                  'Run Breakdown',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFD9921E),
              label: 'Final Score',
              value: '${controller.score} pts',
            ),
            const Divider(height: 16, color: Color(0xFFF1F5F9)),
            _buildMetricRow(
              icon: Icons.bolt_rounded,
              iconColor: const Color(0xFFD9921E),
              label: 'Remaining Energy',
              value: '${controller.currentEnergy} / ${controller.maxEnergy}',
            ),
            const Divider(height: 16, color: Color(0xFFF1F5F9)),
            _buildMetricRow(
              icon: Icons.directions_walk_rounded,
              iconColor: const Color(0xFF3867D6),
              label: 'Steps / Moves Taken',
              value: '${controller.moveCount}',
            ),
            const Divider(height: 16, color: Color(0xFFF1F5F9)),
            _buildMetricRow(
              icon: Icons.diamond_outlined,
              iconColor: const Color(0xFF138A72),
              label: 'Treasures Collected',
              value: '${controller.collectedTreasuresCount}',
            ),
            const Divider(height: 16, color: Color(0xFFF1F5F9)),
            _buildMetricRow(
              icon: Icons.visibility_outlined,
              iconColor: const Color(0xFF3867D6),
              label: 'Algorithm Vision Hints Used',
              value: '${controller.hintUsageCount}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF596579),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172033),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Replay Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3867D6),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.replay_rounded, size: 22),
            label: const Text(
              'Replay Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              if (onReplay != null) {
                onReplay!();
              } else {
                controller.restartLevel();
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        // Main Menu Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFDCE3ED), width: 1.5),
              foregroundColor: const Color(0xFF172033),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.home_rounded, size: 20),
            label: const Text(
              'Main Menu',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              if (onMainMenu != null) {
                onMainMenu!();
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ),
      ],
    );
  }
}
