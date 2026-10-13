import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/screens/dungeon_screen.dart';
import 'package:algorithmic_dungeon/screens/home_screen.dart';

void main() {
  group('HomeScreen Widget & Navigation', () {
    testWidgets('renders game title, premise, and play button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('Algorithmic Dungeon'), findsAtLeastNWidgets(1));
      expect(find.text('How to Play'), findsOneWidget);
      expect(find.text('Start Game'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('tapping Start Game navigates to DungeonScreen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      final playButton = find.text('Start Game');
      expect(playButton, findsOneWidget);

      await tester.tap(playButton);
      await tester.pumpAndSettle();

      expect(find.byType(DungeonScreen), findsOneWidget);
      expect(find.text('The Labyrinth Threshold'), findsOneWidget);
    });
  });
}
