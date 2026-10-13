# Algorithmic Dungeon: Escape the Labyrinth

A 2D grid-based Android puzzle game built with Flutter + Dart for the Design and Analysis of Algorithms (DAA) academic project. The game challenges players to navigate a weighted labyrinth and features **Algorithm Vision**, powered by **Dijkstra's shortest-path algorithm** using a min-priority queue.

## Specifications
- **Platform:** Android
- **Framework:** Flutter 3.47.7 (Channel stable) • Dart 3.13.5
- **Package / Application ID:** `com.algorithmicdungeon.algorithmic_dungeon`
- **Application Label:** `Algorithmic Dungeon`
- **Theme:** Minimal light theme (Slate background `#F6F8FC`, primary `#3867D6`, success `#138A72`, warning `#D9921E`, hazard `#D9534F`)

## Environment Prerequisites
- macOS (Apple Silicon arm64)
- Flutter SDK 3.47.7+ in `~/development/flutter`
- Android SDK (API 34/36) in `~/Library/Android/sdk`
- OpenJDK 21 (`JAVA_HOME=/opt/homebrew/opt/openjdk@21`)

## Verified Commands

### 1. Resolve Dependencies
```bash
flutter pub get
```

### 2. Code Analysis
```bash
flutter analyze
```

### 3. Run Automated Tests
```bash
flutter test
```

### 4. Build Android Debug APK
```bash
flutter build apk --debug
```

### 5. Launch Application on Android Emulator
```bash
# Launch the configured Android Virtual Device (AVD)
flutter emulators --launch Pixel_6_API_34

# Run on the running device/emulator
flutter run -d Pixel_6_API_34
```

## Documentation
- `rules.md` — Authoritative phase roadmap, acceptance criteria, and project boundaries.
- `Algorithmic_Dungeon_Flutter_Implementation_Report.pdf` — Complete technical blueprint for game mechanics, Dijkstra engine, CustomPainter grid rendering, and viva preparation.
