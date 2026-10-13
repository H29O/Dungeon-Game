# Phase 2 Completion Report: Playable Core Game

**Project:** Algorithmic Dungeon: Escape the Labyrinth  
**Framework:** Flutter + Dart  
**Platform:** Android (`Pixel_6_API_34`)  
**Phase:** Phase 2 — Playable Core Game  
**Status:** COMPLETE (All Acceptance Criteria Passed)

---

## 1. Files Created and Modified

### Gameplay State & Controller (`lib/game/`)
- [`lib/game/direction.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/lib/game/direction.dart): Direction enum (`up`, `down`, `left`, `right`) with coordinate delta offsets (`dx`, `dy`) and accessible labels.
- [`lib/game/game_controller.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/lib/game/game_controller.dart): Single-authority `ChangeNotifier` state manager executing the mandatory 11-step atomic movement transaction protocol, tracking player state, energy accounting, victory/defeat transitions, pausing, and pristine restart restoration.

### Data & Level Design (`lib/data/`)
- [`lib/data/sample_levels.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/lib/data/sample_levels.dart): Deterministic, hand-designed 6×6 dungeon level ("The Labyrinth Threshold"). Start at `(0, 0)`, Exit at `(5, 5)`, initial energy 60, maximum energy 100. Incorporates Rubble (`cost 3`), Hazards (`cost 5`), Walls, an Energy Canister (+20 energy), and Treasure (+100 points). Mathematically verified reachable via Dijkstra with an optimal cost of 10.

### UI Screens & Widgets (`lib/screens/`, `lib/widgets/`)
- [`lib/screens/home_screen.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/lib/screens/home_screen.dart): Clean entry screen presenting game title, DAA academic project metadata, "How to Play" rule card, and a prominent "Start Game" action navigating to the dungeon.
- [`lib/screens/dungeon_screen.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/lib/screens/dungeon_screen.dart): Comprehensive playable screen featuring top app bar with pause and restart actions, persistent runtime statistics HUD (Energy, Moves, Route Cost, Score), reactive game status banners (Pause, Victory, Loss, Invalid Move rejection), scalable dungeon board, terrain legend, and accessible directional controls.
- [`lib/widgets/dungeon_board.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/lib/widgets/dungeon_board.dart): Responsive grid board rendering floors, walls, terrain badges (movement costs), collectibles, exit portal, and player marker using flex sizing to prevent RenderFlex overflows.
- [`lib/widgets/movement_controls.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/lib/widgets/movement_controls.dart): Accessible D-Pad layout featuring 48×40 touch targets with directional arrows, automatically disabled when the game is won, lost, or paused.
- [`lib/main.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/lib/main.dart): Configured application root with the designated light theme (`#F6F8FC` background, `#3867D6` accent) and routing to `HomeScreen`.

### Unit and Widget Tests (`test/`)
- [`test/game/game_controller_test.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/test/game/game_controller_test.dart): 11 tests verifying initial parameters, valid moves, wall collisions, out-of-bounds rejection, insufficient energy rejection, pause locking, energy pickup ordering & max-energy cap, single-collection treasure rule, exit victory, energy depletion loss, and exact restart restoration.
- [`test/data/sample_levels_test.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/test/data/sample_levels_test.dart): 3 tests verifying level matrix rectangularity, start/exit traversability, Dijkstra optimal cost of 10, and step count vs weighted cost divergence.
- [`test/screens/home_screen_test.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/test/screens/home_screen_test.dart): 2 tests verifying widget rendering and navigation into `DungeonScreen`.
- [`test/screens/dungeon_screen_test.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/test/screens/dungeon_screen_test.dart): 4 tests verifying essential widget rendering, D-Pad player movement & stat updates, restart state reset, and pause/resume banner toggling.
- [`test/widget_test.dart`](file:///Users/heetoswal/Documents/DAA%20FA2/test/widget_test.dart): Root application smoke test.

---

## 2. Game Controller Architecture & Atomic State Transitions

The `GameController` acts as the single source of truth for all game-state mutations:
- **State Encapsulation:** Widgets strictly dispatch user intents (`move(Direction)`, `pause()`, `resume()`, `restartLevel()`) to the controller and react to notifications via `ListenableBuilder`.
- **Atomic 11-Step Movement Transaction Protocol:**
  1. *State Check:* Rejects move if `gameStatus` is not `ready` or `playing`.
  2. *Destination Calculation:* Computes target cell `(current.x + dir.dx, current.y + dir.dy)`.
  3. *Bounds Validation:* Rejects move if destination is outside `level.inBounds`.
  4. *Wall Validation:* Rejects move if destination tile `isWall`.
  5. *Affordability Check:* Rejects move if `playerState.energy < destinationTile.movementCost`.
  6. *Energy Deduction:* Deducts destination entry cost exactly once (`energy - cost`).
  7. *Position & Move Update:* Updates player position and increments `moves + 1`.
  8. *Cumulative Cost Update:* Increments route cost by destination cell entry cost.
  9. *Item Collection:*
     - Energy Canister: Restores energy (`min(maxEnergy, currentEnergy + 20)`).
     - Treasure: Adds 100 points to score.
     - Target item is marked as collected in `collectedItems` set so it can never be collected again.
  10. *Terminal State Evaluation:*
      - If destination equals `level.exit`, sets `GameStatus.won`.
      - Else if remaining energy equals `0`, sets `GameStatus.lost`.
      - Else sets `GameStatus.playing`.
  11. *Notification:* Notifies listeners only after the entire atomic transition completes.
- **Atomic Failure Guarantee:** If steps 1–5 fail, the controller sets a descriptive rejection notice while leaving player position, energy, moves, score, route cost, and run history strictly unmodified.

---

## 3. Deterministic Level Layout: "The Labyrinth Threshold"

A hand-crafted 6×6 grid demonstrating algorithmic decision-making:
- **Dimensions:** 6 rows × 6 columns.
- **Start Cell:** `(0, 0)` [Floor, cost 1].
- **Exit Cell:** `(5, 5)` [Floor / Portal, cost 1].
- **Initial Energy:** 60 / 100.
- **Terrain Breakdown:**
  - Standard Floor (`cost 1`): Clean traversable corridors.
  - Rubble (`cost 3`): Placed at `(0, 2)` along the northern path.
  - Hazards (`cost 5`): High-cost barrier across row 2 `(2, 1)`, `(2, 2)`, `(2, 3)`.
  - Interior Walls: Blocking cells at `(1, 1..3)`, `(1, 5)`, `(2, 5)`, `(3, 1..3)`, `(3, 5)`, and row 5 `(5, 0..4)`.
  - Energy Canister: Located at `(3, 0)` (+20 energy restoration).
  - Treasure: Located at `(0, 4)` (+100 score).
- **Algorithmic Trade-off:**
  - Route A (Through northern rubble & eastern corridor): (0,0) → (0,1) → (0,2)[Rubble cost 3] → (0,3) → (0,4) → (1,4) → (2,4) → (3,4) → (4,4) → (4,5) → (5,5). Total Cost = 12 (10 moves).
  - Route B (Through western corridor with Energy Canister): (0,0) → (1,0) → (2,0) → (3,0)[Canister] → (4,0) → (4,1) → (4,2) → (4,3) → (4,4) → (4,5) → (5,5). Total Cost = 10 (10 moves).
  - **Dijkstra Verification:** `DijkstraEngine.findShortestPath` autonomously proves Route B is the globally optimal path with a cost of 10.

---

## 4. Visual Design System

The UI strictly adheres to the light design tokens from the specification report:
- **Canvas / Background:** `#F6F8FC`
- **Surface / Card Background:** `#FFFFFF`
- **Primary Text:** `#172033`
- **Secondary Text:** `#596579`
- **Primary Accent:** `#3867D6`
- **Success / Exit Portal:** `#138A72`
- **Energy / Warning / Rubble:** `#D9921E`
- **Hazard / Loss:** `#D9534F`
- **Wall:** `#2C3A47` with micro-grid mesh pattern.
- **Clarity:** Distinct text badges (3, 5), icons (⚡, 💎, ⛩️, 🧭), and colors distinguish terrain without relying exclusively on color.

---

## 5. Verification Results

| Check | Command / Target | Result |
|---|---|---|
| **Code Formatting** | `dart format --output=none --set-exit-if-changed .` | **PASS** (All files cleanly formatted). |
| **Static Analysis** | `flutter analyze` | **PASS** (`No issues found!`, 0 errors, 0 warnings). |
| **Unit & Widget Tests**| `flutter test` | **PASS** (**64/64 tests passed**, 100% pass rate). |
| **Android Build** | `flutter build apk --debug` | **PASS** (`app-debug.apk` built in 3.5s). |
| **Device Execution** | Android Emulator (`Pixel_6_API_34`) | **PASS** (Interactive live verification). |

### Device Verification Details (`Pixel_6_API_34`):
1. **Home Screen:** Verified game title, academic subtitle, how-to-play card, and Start Game action.
2. **Game Launch:** Tapping "Start Game" cleanly transitions to `The Labyrinth Threshold`.
3. **Movement & Energy Accounting:** Tapping D-Pad Right moved the player from `(0, 0)` to `(0, 1)`, decremented energy from 60 to 59, and incremented moves and route cost to 1.
4. **Pause / Resume:** Tapped Pause; verified game pause banner displayed and D-Pad controls were immediately disabled.
5. **Restart Restoration:** Tapped Restart; verified player position reset to `(0, 0)`, energy restored to 60/100, moves reset to 0, route cost reset to 0, score reset to 0, and controls re-enabled.
6. **Victory Sequence:** Navigated 10 steps along the optimal route to `(5, 5)`, picking up the energy canister at `(3, 0)`. Verified exit portal trigger, victory banner with replay button, final stats (Energy 70/100, Moves 10, Route Cost 10, Score 100), item removal, and movement locking upon victory.
7. **Replay from Victory:** Tapped "Replay"; verified full level reset with energy canister restored at `(3, 0)` and player at `(0, 0)`.

---

## 6. Phase 2 Acceptance Criteria Checklist

| Acceptance Criterion (`rules.md` Phase 2) | Status | Evidence |
|---|---|---|
| Lightweight game controller using `ChangeNotifier` | **PASS** | `GameController` owns state and notifies listeners. |
| Deterministic, hand-designed first level with guaranteed route | **PASS** | `The Labyrinth Threshold` verified reachable (Dijkstra cost 10). |
| Grid rendered with player, walls, normal floor, costly terrain, exit | **PASS** | `DungeonBoard` renders all entities with distinct colors & badges. |
| Accessible directional movement controls | **PASS** | `MovementControls` D-Pad with 48×40 touch targets. |
| Movement bounds and wall collision validation | **PASS** | Moves into walls and outside bounds strictly rejected without mutations. |
| Insufficient energy validation | **PASS** | Rejects move if energy < destination entry cost; no state changed. |
| Single entry cost deduction at destination tile | **PASS** | Destination tile entry cost deducted exactly once; source contributes 0. |
| Route cost and move counter updates | **PASS** | Accurately tracks cumulative route cost and move increments. |
| Atomic transaction failure protection | **PASS** | Invalid moves do not alter position, energy, moves, cost, or score. |
| Energy pickups and treasure items | **PASS** | Energy canister restores 20 energy (capped at max); treasure awards 100 pts. Single collection enforced. |
| Victory detection at exit | **PASS** | Reaching `(5, 5)` sets `GameStatus.won` and displays victory banner. |
| Pause, resume, and restart controls | **PASS** | Pause locks movement; restart restores exact initial state and clears run history. |
| Movement rejected after win/loss/pause | **PASS** | Controller rejects moves and UI disables D-Pad when game is won, lost, or paused. |
| 100% automated test pass rate | **PASS** | 64/64 automated tests passed. |
| Device execution verified on `Pixel_6_API_34` | **PASS** | Full interactive playthrough and screenshot verification on emulator. |

---

## 7. Known Limitations and Deferred Features (Phase 3+)

In strict accordance with the Phase 2 scope boundaries:
- **Algorithm Vision UI:** Real-time frontier highlighting, settled node animations, and shortest-path overlays are deferred to Phase 3.
- **Algorithm Lab Screen:** Step-by-step playback controls, node relaxation logs, and viva evaluation dashboards belong to Phase 3.
- **Results Screen:** Detailed post-run analysis screens and efficiency scoring belong to Phase 4.
- **Sound & Persistence:** Audio effects and persistent storage belong to Phase 5.
