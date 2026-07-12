import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:save_earth/game/world_game.dart';
import 'package:save_earth/main.dart';

void main() {
  testWidgets('App loads the open world game', (WidgetTester tester) async {
    await tester.pumpWidget(const SaveEarthApp());
    await tester.pump();

    expect(find.byType(GameWidget<WorldGame>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
