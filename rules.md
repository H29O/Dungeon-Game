# Algorithmic Dungeon — Implementation Roadmap

**Project:** Algorithmic Dungeon: Escape the Labyrinth  
**Platform:** Android  
**Framework:** Flutter + Dart  
**Core Algorithm:** Dijkstra's shortest-path algorithm  
**Deadline:** 2 days for the main implementation, with Day 3 reserved for testing, bug fixes, and final delivery.

---

## 1. Purpose of This Roadmap

This roadmap divides the project into small, independently verifiable phases. Each phase must be completed and validated before the next phase begins.

The accompanying `Algorithmic_Dungeon_Flutter_Implementation_Report.pdf` is the authoritative technical specification for this project. This roadmap controls implementation order, prioritization, and deadline management.

### Rules for the implementation agent

1. Read `rulebook.md` and the complete implementation report before modifying the project.
2. Follow the specified game rules, movement-cost convention, Dijkstra contract, and visual design system.
3. Do not introduce a different framework, game engine, backend, cloud service, or unnecessary dependency.
4. Do not implement future features before completing the current phase.
5. Keep the algorithm independent of Flutter widgets.
6. Do not replace actual algorithmic behavior with hardcoded paths, fake statistics, or decorative animations.
7. After each phase, run the relevant tests, fix regressions, and report the files changed and the verification results.
8. Preserve working functionality. Do not rewrite completed modules merely to improve code style.
9. Do not ask for approval after every minor implementation decision. Make reasonable decisions within this specification and document significant trade-offs.
10. Never claim a feature is complete unless it has been implemented and verified.

## 2. Scope and Priority

### P0 — Mandatory deliverables

- A working Flutter Android application.
- A polished home screen and playable dungeon screen.
- At least one deterministic, fully playable level.
- Correct grid movement, collision handling, energy accounting, and restart behavior.
- A correct implementation of Dijkstra's algorithm using a min-priority queue.
- Algorithm Vision with a valid final path and genuine exploration visualization.
- A results screen with actual route cost and optimal route cost.
- Unit tests for the algorithm and essential game rules.
- A working Android APK that can be installed and demonstrated offline.

### P1 — Include if time permits

- A small collection of additional hand-designed levels.
- Step-by-step algorithm playback with play/pause and speed controls.
- Basic sound effects and additional interface polish.
- Local persistence for settings or best scores.

### P2 — Defer

- Procedural maze generation.
- Enemies, combat, physics, or 3D graphics.
- Online accounts, networking, cloud synchronization, and leaderboards.
- Complex achievements, extensive settings, and advanced scoring systems.
- Features that do not improve the core gameplay or demonstrate Dijkstra's algorithm.

**Scope rule:** Never sacrifice algorithm correctness, a complete gameplay loop, or a working APK to implement a P1 or P2 feature.

---

# 3. Phase-by-Phase Implementation Plan

## Phase 0 — Environment and Project Foundation

**Time budget:** 1–2 hours  
**Priority:** Mandatory

### Objectives

Establish a clean Flutter project and verify the development environment before implementing gameplay.

### Tasks

1. Inspect the existing repository and its contents before creating, deleting, or overwriting anything.
2. Verify Flutter, Dart, Git, and the Android toolchain.
3. Configure the Android SDK and either an Android emulator or a physical Android device.
4. Create or verify the Flutter project structure.
5. Configure the application name as `Algorithmic Dungeon` and use a consistent project identifier.
6. Establish the light visual theme described in the implementation report.
7. Confirm the starter application launches successfully.
8. Initialize a Git checkpoint for the verified baseline.

### Deliverables

- A working Flutter project.
- A verified Android development environment.
- A successful initial Android launch.
- A clean, reproducible project structure.

### Acceptance criteria

- `flutter doctor -v` has no unresolved blocking Android toolchain errors.
- The application launches on the selected Android target.
- The project builds without errors.
- No unrelated files or existing working projects have been modified.

**Gate:** Do not proceed until the basic application builds and launches.

---

## Phase 1 — Domain Models and Dijkstra Engine

**Time budget:** 3–4 hours  
**Priority:** Mandatory

### Objectives

Implement the algorithmic foundation before building complex screens.

### Tasks

Create the necessary domain models:

- `GridPosition`
- `DungeonTile`
- `DungeonLevel`
- `PlayerState`
- `PathResult`
- `AlgorithmEvent` (for visualization)

Implement:

1. Grid and level validation.
2. Tile types, traversability, and movement costs.
3. Four-directional neighbor discovery.
4. Graph construction that excludes walls.
5. Dijkstra's algorithm using a min-priority queue.
6. Distance tracking and predecessor reconstruction.
7. Path-cost verification.
8. Detection of unreachable destinations.
9. Algorithm statistics, including settled nodes and relaxation counts.
10. Optional event recording for the visualization phase.

### Non-negotiable algorithm rules

- Every traversable cell represents a graph vertex.
- Moving from cell `u` into cell `v` costs the entry cost of `v`.
- The source cell contributes zero to the route cost.
- All edge weights must be non-negative.
- Use a min-priority queue, not a FIFO queue as a substitute for Dijkstra.
- Ignore stale queue entries.
- Stop when the destination is finalized, not when it is first discovered.
- Return an explicit no-path result when the destination is unreachable.
- Multiple equal-cost paths are valid.
- Algorithm computation must not mutate the level or player state.

### Tests

At minimum, test:

- A straight corridor with a known cost.
- A longer but cheaper route versus a shorter but more expensive route.
- A wall-blocked or unreachable destination.
- Start equal to goal.
- Multiple equal-cost routes.
- Invalid negative costs.
- Path validity and independently recomputed path cost.

### Deliverables

- Independent algorithm and model modules.
- Passing Dijkstra unit tests.
- A deterministic sample level or test fixture.
- Verified path reconstruction and algorithm statistics.

### Acceptance criteria

Every reachable test case returns a valid minimum-cost path, and every reported path cost matches the independently calculated cost.

**Gate:** No complex UI work until the algorithm tests pass.

---

## Phase 2 — Playable Core Game

**Time budget:** 4–5 hours  
**Priority:** Mandatory

### Objectives

Turn the domain model into a complete, playable game.

### Tasks

1. Implement a lightweight game controller using `ChangeNotifier` or an equally simple state-management solution.
2. Create a deterministic, hand-designed first level with a guaranteed route.
3. Render the dungeon grid.
4. Add the player, walls, normal floor, costly terrain, and exit.
5. Implement directional movement buttons. Add swipe controls only if time permits.
6. Validate movement bounds, walls, energy, and game status.
7. Deduct the destination tile's entry cost exactly once.
8. Update position, move count, and cumulative route cost.
9. Prevent invalid moves from changing game state.
10. Implement energy pickups and optional treasure if they fit the schedule.
11. Detect victory when the player reaches the exit.
12. Implement restart, pause, and resume.
13. Ensure restart restores the original position, energy, score, collected items, history, and visualization state.

### Game-state requirements

Use explicit states such as:

- `ready`
- `playing`
- `paused`
- `showingAlgorithm`
- `won`
- `lost`

Won or lost games must not accept further movement.

Energy pickups are applied after movement cost is deducted. Energy must never exceed the configured maximum.

### Deliverables

- A playable dungeon.
- A functioning movement controller.
- A working restart and victory condition.
- A deterministic level suitable for the final demonstration.

### Acceptance criteria

The player can navigate a complete level, walls cannot be crossed, energy is accounted for correctly, and restarting reliably restores the initial state.

**Gate:** The game must be playable from start to finish before algorithm animation is added.

---

## Phase 3 — Algorithm Vision and Visualization

**Time budget:** 3–4 hours  
**Priority:** Mandatory

### Objectives

Make Dijkstra's algorithm visible and understandable to the evaluator.

### Tasks

1. Connect Algorithm Vision to the actual Dijkstra implementation.
2. Compute the optimal route from the player's current position to the exit.
3. Render the final route on the grid.
4. Show frontier/discovered cells separately from settled cells.
5. Use genuine algorithm events to drive the visualization.
6. Display tentative distances where they can be shown clearly.
7. Display the final optimal route cost.
8. Display meaningful statistics such as settled nodes, relaxation attempts, and computation time.
9. Provide a fast-finish mode.
10. Add Step, Play/Pause, and basic speed controls if time permits.
11. Allow the visualization to be cleared or restarted.
12. Ensure that Algorithm Vision never changes the player's position, energy, score, or movement history.

### Important implementation rule

The algorithm must execute independently of animation. Record deterministic events during computation, then replay those events in the UI.

Do not add artificial delays inside Dijkstra. Do not fabricate visited nodes, distances, paths, or statistics.

### Deliverables

- Working Algorithm Vision.
- A genuine final-path overlay.
- Exploration visualization.
- Accurate route-cost and algorithm statistics.

### Acceptance criteria

- The route starts at the player's current position and ends at the exit.
- The route contains no walls or invalid steps.
- The displayed cost matches the path's independently calculated cost.
- Frontier and settled nodes are visually distinguishable.
- The visualization does not mutate game state.

**Gate:** Verify the actual algorithm result before spending time on animation polish.

---

## Phase 4 — UI Completion, Results, and Integration

**Time budget:** 3–4 hours  
**Priority:** Mandatory

### Objectives

Complete the essential screens and make the game presentable.

### Tasks

#### Home screen

- Game title and short premise.
- Prominent Play button.
- Algorithm Lab or Algorithm Vision entry point.
- Concise instructions and credits.

#### Dungeon screen

- Level name and game status.
- Energy indicator and score.
- Scalable dungeon grid.
- Accessible directional controls.
- Algorithm Vision button.
- Restart and pause controls.
- Compact terrain legend.

#### Results screen

- Victory or failure status.
- Moves taken.
- Actual route cost.
- Optimal route cost from the same starting state.
- Remaining energy.
- Treasure and hints used, if implemented.
- Replay or return-to-menu controls.

#### Visual consistency

Follow the PDF's light-theme direction:

- Background: `#F6F8FC`
- Surfaces: `#FFFFFF`
- Primary text: `#172033`
- Secondary text: `#596579`
- Primary accent: `#3867D6`
- Path/success accent: `#138A72`
- Energy/warning accent: `#D9921E`
- Hazard accent: `#D9534F`

Use clear contrast, readable labels, consistent spacing, and restrained shadows. Do not rely on color alone to distinguish terrain.

### Deliverables

- Complete navigation between essential screens.
- Integrated game logic and algorithm visualization.
- A coherent and consistent interface.
- A working results and replay flow.

### Acceptance criteria

A new user can start a game, understand the controls, finish the level, inspect the optimal route, view the results, and replay without encountering a broken navigation path.

**Gate:** Freeze major feature additions once this phase is complete.

---

## Phase 5 — Testing, Android Build, and Final Delivery

**Time budget:** 3–4 hours on Day 2, with additional time reserved on Day 3  
**Priority:** Mandatory

### Objectives

Ensure that the project is stable, demonstrable, and ready for submission.

### Tasks

1. Run all algorithm and game-controller unit tests.
2. Test wall collisions, out-of-bounds movement, insufficient energy, and victory.
3. Verify energy pickups and treasure collection, if implemented.
4. Verify restart after movement and Algorithm Vision.
5. Compare the displayed route cost against the actual route.
6. Test the no-path state.
7. Test the app on the intended Android device or emulator.
8. Check that the grid and controls fit the screen.
9. Fix crashes, broken controls, layout overflow, and incorrect statistics.
10. Build a release APK.
11. Install and launch the release APK.
12. Capture screenshots of the home screen, gameplay, Algorithm Vision, and results.
13. Prepare a short demonstration script and a backup recording or screenshots.
14. Update the README with setup, run, test, and build instructions.
15. Commit the final verified version to Git.

### Deliverables

- Passing automated tests.
- A successfully installed and working release APK.
- Required screenshots and README.
- A reproducible demonstration.
- A clean, committed final project.

### Acceptance criteria

The final APK works offline, a complete game can be demonstrated without relying on network services, and the algorithm's output can be independently verified.

**Gate:** The release is complete only after the APK has been installed and tested, not merely after the build command succeeds.

---

# 4. Deadline and Scheduling Strategy

## Day 1 — Establish correctness and a playable game

| Work block | Phase | Target |
|---|---|---|
| Block 1 | Phase 0 | Environment and starter app working |
| Block 2 | Phase 1 | Dijkstra implemented and tested |
| Block 3 | Phase 2 | Complete playable core |
| End-of-day checkpoint | — | Game builds and can be played |

If setup takes longer than expected, reduce optional scope rather than skipping algorithm tests.

## Day 2 — Complete the educational experience

| Work block | Phase | Target |
|---|---|---|
| Block 1 | Phase 3 | Algorithm Vision working |
| Block 2 | Phase 4 | Essential screens integrated |
| Block 3 | Phase 5 | Test, build, install and verify APK |
| End-of-day checkpoint | — | Complete demonstrable project |

## Day 3 — Contingency and submission

Use this day only as a buffer for:

- Environment or build failures.
- Algorithm correctness defects.
- Device-specific layout problems.
- Integration regressions.
- Missing screenshots, documentation, or demo preparation.

Do not schedule new major features for Day 3.

These estimates are aggressive targets, not guarantees. A functioning, correct core game takes precedence over feature count.

---

# 5. Global Engineering Constraints

1. **Single source of truth:** Game movement and Dijkstra must share the same tile-cost convention.
2. **Separation of concerns:** Widgets render state; the controller manages game actions; the algorithm service calculates paths.
3. **Deterministic demonstration:** Use a fixed, tested level rather than relying on randomness.
4. **No fake implementations:** Do not hardcode an optimal path for the demo or invent algorithm statistics.
5. **No unnecessary architecture:** Do not introduce a backend, database, dependency injection framework, or complex state-management library.
6. **Minimal dependencies:** Use only what the project actually needs. If a heap package is added, verify its compatibility; otherwise implement and test a small min-heap.
7. **Incremental verification:** Run targeted tests after changes and the full relevant suite at integration checkpoints.
8. **Safe changes:** Inspect existing files before overwriting them. Preserve working code and use Git checkpoints.
9. **No hidden scope expansion:** Do not add procedural generation, enemies, accounts, networking, or other deferred features without an explicit need.
10. **Honest completion reports:** Distinguish implemented, tested, partially implemented, and deferred features.

# 6. Definition of Done

The project is complete when all of the following are true:

- [ ] The Flutter application launches on Android.
- [ ] The home screen can start a game.
- [ ] At least one deterministic level is fully playable.
- [ ] Movement, walls, energy, victory, and restart work correctly.
- [ ] Dijkstra uses a min-priority queue and passes its correctness tests.
- [ ] Algorithm Vision shows genuine exploration and the actual computed path.
- [ ] The displayed route cost is correct.
- [ ] The results screen displays meaningful game statistics.
- [ ] The app works offline.
- [ ] The release APK has been installed and verified.
- [ ] The README, screenshots, tests, and demonstration materials are ready.
- [ ] The final code is committed and can be built from a clean checkout.

**Final principle:** Build a correct, complete, and demonstrable Algorithmic Dungeon first. Add optional features only when every mandatory acceptance criterion is satisfied.