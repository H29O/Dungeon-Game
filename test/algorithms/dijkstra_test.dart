import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/algorithms/dijkstra.dart';
import 'package:algorithmic_dungeon/models/algorithm_event.dart';
import 'package:algorithmic_dungeon/models/dungeon_level.dart';
import 'package:algorithmic_dungeon/models/dungeon_tile.dart';
import 'package:algorithmic_dungeon/models/grid_position.dart';

void main() {
  final engine = DijkstraEngine();

  group('DijkstraEngine Correctness', () {
    test('straight corridor with known uniform cost', () {
      // 1x5 corridor of cost 1 tiles:
      // (0,0) -> (0,1) -> (0,2) -> (0,3) -> (0,4)
      // Moving into each of the 4 destination cells costs 1 each.
      // Expected cost: 4.
      final grid = [
        List.generate(5, (_) => DungeonTile.floor(movementCost: 1)),
      ];

      final level = DungeonLevel(
        id: 'corridor',
        name: 'Straight Corridor',
        rows: 1,
        cols: 5,
        grid: grid,
        start: const GridPosition(0, 0),
        exit: const GridPosition(0, 4),
      );

      final result = engine.findShortestPath(
        level: level,
        start: const GridPosition(0, 0),
        goal: const GridPosition(0, 4),
      );

      expect(result.hasPath, isTrue);
      expect(result.totalCost, equals(4));
      expect(result.path.length, equals(5));
      expect(result.path.first, equals(const GridPosition(0, 0)));
      expect(result.path.last, equals(const GridPosition(0, 4)));
      expect(
        result.verifyPathCost(
          level: level,
          expectedStart: const GridPosition(0, 0),
          expectedGoal: const GridPosition(0, 4),
        ),
        isTrue,
      );
    });

    test('prefers longer cheaper route over shorter expensive route', () {
      // 3x3 Grid:
      // S(0,0)  H(0,1)  G(0,2)   <- Upper path has length 2 steps, but (0,1) is hazard (cost 10) + goal (cost 1) = 11.
      // F(1,0)  W(1,1)  F(1,2)   <- Center is Wall.
      // F(2,0)  F(2,1)  F(2,2)   <- Lower detour has 4 steps, all floor cost 1:
      // (0,0)->(1,0)->(2,0)->(2,1)->(2,2)->(1,2)->(0,2): cost = 1 + 1 + 1 + 1 + 1 + 1 = 6.
      // Or shorter detour (0,0)->(1,0)->(1,1 wall no)-> alternative.
      //
      // Let's create an explicit 3x4 map:
      // Row 0: Start(0,0)[c:1], Hazard(0,1)[c:10], Goal(0,2)[c:1]
      // Row 1: Floor(1,0)[c:1], Wall(1,1)[wall],   Floor(1,2)[c:1]
      // Row 2: Floor(2,0)[c:1], Floor(2,1)[c:1],  Floor(2,2)[c:1]
      final grid = [
        [
          DungeonTile.floor(movementCost: 1),
          DungeonTile.hazard(movementCost: 10),
          DungeonTile.exit(movementCost: 1),
        ],
        [
          DungeonTile.floor(movementCost: 1),
          DungeonTile.wall(),
          DungeonTile.floor(movementCost: 1),
        ],
        [
          DungeonTile.floor(movementCost: 1),
          DungeonTile.floor(movementCost: 1),
          DungeonTile.floor(movementCost: 1),
        ],
      ];

      final level = DungeonLevel(
        id: 'weighted_choice',
        name: 'Weighted Choice',
        rows: 3,
        cols: 3,
        grid: grid,
        start: const GridPosition(0, 0),
        exit: const GridPosition(0, 2),
      );

      final result = engine.findShortestPath(
        level: level,
        start: const GridPosition(0, 0),
        goal: const GridPosition(0, 2),
      );

      expect(result.hasPath, isTrue);

      // Upper direct route: (0,0) -> (0,1) [cost 10] -> (0,2) [cost 1] = 11.
      // Lower detour route: (0,0) -> (1,0)[1] -> (2,0)[1] -> (2,1)[1] -> (2,2)[1] -> (1,2)[1] -> (0,2)[1] = 6.
      // Dijkstra MUST choose the lower route (cost 6) despite having 6 steps instead of 2 steps!
      expect(result.totalCost, equals(6));
      expect(result.path.length, equals(7)); // 7 positions = 6 transitions
      expect(
        result.path.contains(const GridPosition(0, 1)),
        isFalse,
      ); // Avoids hazard!
      expect(
        result.verifyPathCost(
          level: level,
          expectedStart: const GridPosition(0, 0),
          expectedGoal: const GridPosition(0, 2),
        ),
        isTrue,
      );
    });

    test('reports no-path safely when destination is wall-blocked', () {
      // 3x3 grid where Goal is surrounded by walls:
      // F  F  F
      // F  W  W
      // F  W  G(2,2)
      final grid = [
        [DungeonTile.floor(), DungeonTile.floor(), DungeonTile.floor()],
        [DungeonTile.floor(), DungeonTile.wall(), DungeonTile.wall()],
        [DungeonTile.floor(), DungeonTile.wall(), DungeonTile.exit()],
      ];

      final level = DungeonLevel(
        id: 'blocked',
        name: 'Blocked Goal',
        rows: 3,
        cols: 3,
        grid: grid,
        start: const GridPosition(0, 0),
        exit: const GridPosition(2, 2),
      );

      final result = engine.findShortestPath(
        level: level,
        start: const GridPosition(0, 0),
        goal: const GridPosition(2, 2),
      );

      expect(result.hasPath, isFalse);
      expect(result.path, isEmpty);
      expect(result.totalCost, isNull); // Never a fake numeric cost
      expect(result.settledNodesCount, greaterThan(0));
    });

    test('handles start equals goal as cost 0', () {
      final grid = [
        [DungeonTile.floor(), DungeonTile.floor()],
        [DungeonTile.floor(), DungeonTile.exit()],
      ];

      final level = DungeonLevel(
        id: 'start_is_goal',
        name: 'Zero Step',
        rows: 2,
        cols: 2,
        grid: grid,
        start: const GridPosition(1, 1),
        exit: const GridPosition(1, 1),
      );

      final result = engine.findShortestPath(
        level: level,
        start: const GridPosition(1, 1),
        goal: const GridPosition(1, 1),
      );

      expect(result.hasPath, isTrue);
      expect(result.path, equals([const GridPosition(1, 1)]));
      expect(result.totalCost, equals(0));
      expect(result.settledNodesCount, equals(1));
    });

    test('validates multiple equal-cost shortest paths without assuming single route', () {
      // 2x2 grid with all floor cost 1:
      // (0,0) -> (1,1).
      // Path 1: (0,0) -> (0,1) -> (1,1) [cost: 1 + 1 = 2]
      // Path 2: (0,0) -> (1,0) -> (1,1) [cost: 1 + 1 = 2]
      final grid = [
        [
          DungeonTile.floor(movementCost: 1),
          DungeonTile.floor(movementCost: 1),
        ],
        [DungeonTile.floor(movementCost: 1), DungeonTile.exit(movementCost: 1)],
      ];

      final level = DungeonLevel(
        id: 'symmetric',
        name: 'Symmetric',
        rows: 2,
        cols: 2,
        grid: grid,
        start: const GridPosition(0, 0),
        exit: const GridPosition(1, 1),
      );

      final result = engine.findShortestPath(
        level: level,
        start: const GridPosition(0, 0),
        goal: const GridPosition(1, 1),
      );

      expect(result.hasPath, isTrue);
      expect(result.totalCost, equals(2));
      expect(result.path.length, equals(3));
      expect(
        result.verifyPathCost(
          level: level,
          expectedStart: const GridPosition(0, 0),
          expectedGoal: const GridPosition(1, 1),
        ),
        isTrue,
      );
    });

    test(
      'every returned path step is orthogonally adjacent and avoids walls',
      () {
        final grid = [
          [DungeonTile.floor(), DungeonTile.wall(), DungeonTile.floor()],
          [DungeonTile.floor(), DungeonTile.wall(), DungeonTile.floor()],
          [DungeonTile.floor(), DungeonTile.floor(), DungeonTile.exit()],
        ];

        final level = DungeonLevel(
          id: 'maze',
          name: 'Small Maze',
          rows: 3,
          cols: 3,
          grid: grid,
          start: const GridPosition(0, 0),
          exit: const GridPosition(2, 2),
        );

        final result = engine.findShortestPath(
          level: level,
          start: const GridPosition(0, 0),
          goal: const GridPosition(2, 2),
        );

        expect(result.hasPath, isTrue);

        for (int i = 0; i < result.path.length; i++) {
          final pos = result.path[i];
          expect(level.isTraversableAt(pos), isTrue);
          expect(level.tileAt(pos).type, isNot(equals(TileType.wall)));

          if (i > 0) {
            expect(pos.isAdjacentTo(result.path[i - 1]), isTrue);
          }
        }
      },
    );

    test('event recording captured when enabled and empty when disabled', () {
      final grid = [
        [DungeonTile.floor(), DungeonTile.floor()],
        [DungeonTile.floor(), DungeonTile.exit()],
      ];

      final level = DungeonLevel(
        id: 'events_test',
        name: 'Events',
        rows: 2,
        cols: 2,
        grid: grid,
        start: const GridPosition(0, 0),
        exit: const GridPosition(1, 1),
      );

      // 1. Disabled: events list is empty
      final withoutEvents = engine.findShortestPath(
        level: level,
        start: const GridPosition(0, 0),
        goal: const GridPosition(1, 1),
        recordEvents: false,
      );
      expect(withoutEvents.events, isEmpty);

      // 2. Enabled: events captured
      final withEvents = engine.findShortestPath(
        level: level,
        start: const GridPosition(0, 0),
        goal: const GridPosition(1, 1),
        recordEvents: true,
      );
      expect(withEvents.events, isNotEmpty);

      // Verify presence of event types
      final discoveredEvents = withEvents.events
          .whereType<NodeDiscoveredEvent>();
      final settledEvents = withEvents.events.whereType<NodeSettledEvent>();
      final completedEvents = withEvents.events.whereType<PathCompletedEvent>();

      expect(discoveredEvents, isNotEmpty);
      expect(settledEvents, isNotEmpty);
      expect(completedEvents.length, equals(1));
      expect(completedEvents.first.totalCost, equals(withEvents.totalCost));
    });

    test('does not mutate level grid during computation', () {
      final grid = [
        [
          DungeonTile.floor(movementCost: 2),
          DungeonTile.rubble(movementCost: 4),
        ],
        [DungeonTile.wall(), DungeonTile.exit(movementCost: 1)],
      ];

      final level = DungeonLevel(
        id: 'no_mutation',
        name: 'No Mutation',
        rows: 2,
        cols: 2,
        grid: grid,
        start: const GridPosition(0, 0),
        exit: const GridPosition(1, 1),
      );

      // Snapshot tiles before
      final beforeTile00 = level.tileAt(const GridPosition(0, 0));
      final beforeTile01 = level.tileAt(const GridPosition(0, 1));
      final beforeTile10 = level.tileAt(const GridPosition(1, 0));
      final beforeTile11 = level.tileAt(const GridPosition(1, 1));

      // Run Dijkstra
      engine.findShortestPath(
        level: level,
        start: const GridPosition(0, 0),
        goal: const GridPosition(1, 1),
      );

      // Assert identical after
      expect(level.tileAt(const GridPosition(0, 0)), equals(beforeTile00));
      expect(level.tileAt(const GridPosition(0, 1)), equals(beforeTile01));
      expect(level.tileAt(const GridPosition(1, 0)), equals(beforeTile10));
      expect(level.tileAt(const GridPosition(1, 1)), equals(beforeTile11));
    });
  });
}
