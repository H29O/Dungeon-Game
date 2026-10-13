# Algorithmic Dungeon: Escape the Labyrinth

> **Academic Project:** Design and Analysis of Algorithms (DAA) — Formative Assessment 2 (FA2)<br/>
> **Institution:** Pimpri Chinchwad College of Engineering (PCCOE), Pune<br/>
> **Department:** Department of Information Technology<br/>
> **Platform:** Android (Flutter & Pure Dart)

---

## 1. Project Overview & Objective

**Algorithmic Dungeon: Escape the Labyrinth** is an interactive, algorithm-driven Android puzzle game designed to demonstrate, analyze, and visualize **Dijkstra's Shortest Path Algorithm** in an intuitive, engaging format.

The primary objective is to bridge theoretical algorithm study with practical software engineering by transforming a weighted mathematical graph into an explorable 2D dungeon grid. Players experience firsthand why greedy step-counting heuristics fail in non-uniform cost environments and can activate **Algorithm Vision** to inspect real-time graph relaxation, priority-queue frontiers, and settlement sets.

---

## 2. Problem Statement & Core Concept

In classical computer science, shortest-path algorithms are frequently taught using abstract node-link diagrams. Students often conflate:
1. **Unweighted graph distance** (minimum number of steps/hops, solvable via BFS), with
2. **Weighted graph distance** (minimum cumulative edge cost, requiring Dijkstra's algorithm).

### Core Gameplay Mechanics
- **Grid Labyrinth:** A 6×6 grid where each cell represents a distinct terrain type with non-negative traversal entry costs.
- **Entry-Cost Model:** Moving into an adjacent cell costs energy equal to that destination cell's weight:
  - **Normal Floor (`.`):** Weight = 1
  - **Rubble (`R`):** Weight = 3
  - **Hazard (`H`):** Weight = 5
  - **Wall (`#`):** Blocked / impassable
  - **Source Cell:** Contributes 0 entry cost.
- **Counter-Intuitive Routing:** A geometrically longer route of 10 floor tiles costs `10 × 1 = 10` energy, whereas a short 3-tile corridor through rubble and hazards costs `1 + 3 + 5 + 5 = 14` energy. Shorter paths in step count can be costlier in energy!
- **Energy & Collectibles:** The player starts with 60 energy (capped at 100 max). Reaching 0 energy results in Defeat. Optional energy canisters (+15 energy) and treasure relics (+50 score) provide tactical incentives.
- **Victory Condition:** Navigate from start `(0, 0)` to the exit `(5, 5)` while managing energy reserves.

---

## 3. Dijkstra's Algorithm & Graph Interpretation

The engine uses a pure Dart implementation of Dijkstra's algorithm with the following formal properties:

1. **Implicit Directed Graph Construction:**
   - Grid coordinates $(r, c)$ form nodes $V$.
   - Valid orthogonal moves (Up, Right, Down, Left) form edges $E$.
   - Edge weight $w(u, v)$ equals the entry cost of destination cell $v$.
   - Deterministic exploration tie-breaking order: **Up $\rightarrow$ Right $\rightarrow$ Down $\rightarrow$ Left**.
2. **Min-Priority Queue:**
   - Implemented as a binary min-heap with $O(\log |V|)$ insertion and extraction.
   - Handles stale priority queue entries cleanly via distance verification (`entry.cost > dist[u]`).
3. **Strict Relaxation:**
   - For edge $(u, v)$, relaxes distance if and only if:
     $$\text{dist}[u] + w(u, v) < \text{dist}[v]$$
4. **Early Termination:**
   - Terminates when the target cell is extracted/finalized from the priority queue.
5. **Event-Driven Recording:**
   - Yields an immutable stream of exploration events (`nodeEnqueued`, `nodePopped`, `edgeRelaxed`, `edgeSkipped`, `targetReached`, `pathReconstructed`) without altering game state.

---

## 4. Technology Stack & Architecture

- **Framework:** Flutter 3.47.7 (Channel stable)
- **Language:** Dart 3.13.5 (Sound Null Safety)
- **Target OS:** Android (minSdkVersion 21, targetSdkVersion 34, compileSdkVersion 34)
- **Package ID:** `com.algorithmicdungeon.algorithmic_dungeon`
- **Application Label:** `Algorithmic Dungeon`
- **Design System:** Bespoke lightweight design palette conforming to academic requirements:
  - Background: Slate Canvas `#F6F8FC`
  - Surface: Pure White `#FFFFFF`
  - Primary Accent: Royal Indigo `#3867D6`
  - Success / Route: Forest Teal `#138A72`
  - Energy / Warning: Amber Gold `#D9921E`
  - Hazard: Crimson Coral `#D9534F`
- **Zero Internet Requirement:** `AndroidManifest.xml` requires no network permissions; 100% offline and secure.

### Module Structure
```
lib/
├── algorithms/       # Pure Dart Dijkstra engine, Min-Heap, Algorithm Events
├── game/             # DungeonController, LevelMaps, LevelLoader
├── models/           # Position, CellType, Direction, GameState, RunStatistics
├── screens/          # HomeScreen, GameScreen, ResultsScreen
└── widgets/          # DungeonGridPainter, AlgorithmVisionWidget, HUD, D-Pad
```

---

## 5. Key Features

- **Playable Weighted Grid:** Smooth responsive CustomPainter grid rendering with crisp icons, terrain badges, and directional hero marker.
- **Algorithm Vision:** Interactive overlay providing:
  - Step-by-step forward stepping through graph exploration.
  - Automated playback with variable speed controls (1×, 2×, 4×).
  - Jump-to-final optimal path reconstruction.
  - Distinguishable visual sets: Frontier nodes (amber), Settled nodes (lavender), and Optimal Shortest Path (forest teal dots).
  - Real-time engine telemetry (settled node count, relaxation count, execution time in $\mu s$).
- **Comprehensive Results Screen:**
  - Route efficiency comparison: $\text{Efficiency} = \frac{\text{Optimal Dijkstra Cost}}{\text{Actual Player Route Cost}} \times 100\%$.
  - Run metrics: steps taken, energy remaining, items collected, and final score.
- **Zero Duplicate State:** Idempotent transitions preventing duplicate screens or memory leaks upon replay/navigation.

---

## 6. Prerequisites & Environment Setup

### Prerequisites
- macOS (Apple Silicon arm64) or Linux/Windows with Flutter SDK installed.
- Flutter SDK 3.47.7+ (`flutter --version`)
- Android SDK (API 34/36) with Android Virtual Device (AVD) (e.g., `Pixel_6_API_34`)
- OpenJDK 21 (`java -version`)

### Verification Commands
```bash
# Verify Flutter toolchain
flutter doctor -v

# Fetch project dependencies
flutter pub get
```

---

## 7. How to Run, Test, and Build

### Run Static Analysis & Formatting
```bash
# Verify code formatting
dart format --output=none --set-exit-if-changed .

# Verify static analysis (0 warnings / 0 errors required)
flutter analyze
```

### Run Automated Tests
```bash
# Run all 104 unit, widget, and integration tests
flutter test
```

### Build Android APKs
```bash
# 1. Build Debug APK
flutter build apk --debug

# 2. Build Release APK (standalone, optimized)
flutter build apk --release
```

### Launch on Android Emulator
```bash
# List available emulators
flutter emulators

# Launch Pixel_6_API_34 emulator
flutter emulators --launch Pixel_6_API_34

# Run application on the emulator
flutter run -d Pixel_6_API_34
```

---

## 8. Verified APK Deliverables

The generated standalone Android APKs are located at:

| APK Type | Location | Size | Verification Status |
| :--- | :--- | :--- | :--- |
| **Debug APK** | `build/app/outputs/flutter-apk/app-debug.apk` | ~158 MB | Built & verified |
| **Release APK** | `build/app/outputs/flutter-apk/app-release.apk` | ~43 MB (45,152,784 B) | Installed & verified on `Pixel_6_API_34` |

---

## 9. Known Limitations & Deferred Optional Features

In accordance with Section 6 of the implementation roadmap (`rules.md`):
- **Sound & Audio Effects:** Sound effects were classified as optional polish. To guarantee absolute runtime stability across varied Android audio hardware without native audio crashes, audio playback was intentionally deferred.
- **Local Persistence / Cloud Storage:** Persistent high scores across device reboots and cloud sync were explicitly excluded from the academic scope to avoid third-party plugin volatility.
- **Procedural Dungeon Generation:** All levels use deterministic, validated layouts to ensure mathematically provable Dijkstra paths during academic demonstrations.
