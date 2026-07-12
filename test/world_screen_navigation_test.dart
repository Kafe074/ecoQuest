import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:save_earth/game/station_data.dart';
import 'package:save_earth/game/world_game.dart';
import 'package:save_earth/screens/impact_simulator/impact_simulator_screen.dart';
import 'package:save_earth/screens/world/world_screen.dart';

void main() {
  testWidgets(
    'interacting with a station opens its screen and returning resumes the game',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WorldScreen()));
      await tester.pump();

      final game = tester
          .widget<GameWidget<WorldGame>>(find.byType(GameWidget<WorldGame>))
          .game!;

      game.setNearbyStation(kStations.first);
      await tester.pump();

      expect(find.text('🌍 Tocá para jugar: Simulador de Impacto'), findsOneWidget);

      // pumpAndSettle never converges while a live GameWidget is in the
      // tree (its game loop keeps scheduling frames), so drive the route
      // transition with a bounded pump instead.
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ImpactSimulatorScreen), findsOneWidget);
      expect(game.paused, isTrue);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(GameWidget<WorldGame>), findsOneWidget);
      expect(game.paused, isFalse);
    },
  );
}
