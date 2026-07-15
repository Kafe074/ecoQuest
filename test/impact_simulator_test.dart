import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:save_earth/widgets/option_tile.dart';
import 'package:save_earth/screens/impact_simulator/impact_simulator_data.dart';
import 'package:save_earth/screens/impact_simulator/impact_simulator_screen.dart';

/// Taps the option at [optionIndex] for the current scenario and dismisses
/// the resulting feedback dialog, leaving the game on the next scenario.
Future<void> _answerOption(WidgetTester tester, {int optionIndex = 0}) async {
  await tester.tap(find.byType(OptionTile).at(optionIndex));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Impact simulator shows the first scenario with neutral stats', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ImpactSimulatorScreen()));

    expect(find.textContaining('Situación 1 de ${impactScenarios.length}'), findsOneWidget);
    expect(find.text('Contaminación'), findsOneWidget);
    expect(find.text('Recursos'), findsOneWidget);
    expect(find.text('Calidad de vida'), findsOneWidget);
  });

  testWidgets('Choosing an option shows a feedback dialog and advances to the next scenario', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ImpactSimulatorScreen()));

    await tester.tap(find.byType(OptionTile).first);
    await tester.pump();

    expect(find.text('¿Sabías que...?'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Situación 2 de'), findsOneWidget);
  });

  testWidgets('Completing every scenario shows the ending screen and can restart', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: ImpactSimulatorScreen()));

    for (var i = 0; i < impactScenarios.length; i++) {
      await _answerOption(tester);
    }

    expect(find.textContaining('Puntaje ecológico'), findsOneWidget);
    expect(find.text('Jugar de nuevo'), findsOneWidget);

    await tester.tap(find.text('Jugar de nuevo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Situación 1 de'), findsOneWidget);
  });

  testWidgets('First playthrough sets a new best score, a worse one shows the previous best', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: ImpactSimulatorScreen()));

    // The last option of every scenario in impact_simulator_data.dart is the
    // greenest choice, so picking it each time yields a high eco score.
    for (final scenario in impactScenarios) {
      await _answerOption(tester, optionIndex: scenario.options.length - 1);
    }
    expect(find.textContaining('¡Nuevo mejor puntaje!'), findsOneWidget);

    await tester.tap(find.text('Jugar de nuevo'));
    await tester.pumpAndSettle();

    // The first option of every scenario is consistently the worst choice.
    for (var i = 0; i < impactScenarios.length; i++) {
      await _answerOption(tester, optionIndex: 0);
    }

    expect(find.textContaining('Mejor puntaje:'), findsOneWidget);
    expect(find.textContaining('¡Nuevo mejor puntaje!'), findsNothing);
  });
}
