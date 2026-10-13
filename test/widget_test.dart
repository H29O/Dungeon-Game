import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/main.dart';

void main() {
  testWidgets('Algorithmic Dungeon starter screen smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AlgorithmicDungeonApp());

    expect(find.text('Algorithmic Dungeon'), findsAtLeastNWidgets(1));
    expect(
      find.text('Escape the Labyrinth • DAA Academic Project'),
      findsOneWidget,
    );
  });
}
