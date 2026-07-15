import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:save_earth/widgets/option_tile.dart';
import 'package:save_earth/screens/quiz/quiz_screen.dart';

void main() {
  testWidgets('Quiz screen shows the first question and score', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: QuizScreen()),
    );

    expect(find.textContaining('Puntaje: 0'), findsOneWidget);
    expect(find.textContaining('Pregunta 1 de'), findsOneWidget);
  });

  testWidgets('Selecting an option shows feedback dialog and advances', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: QuizScreen()),
    );

    await tester.tap(find.byType(OptionTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Continuar'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Pregunta 2 de'), findsOneWidget);
  });
}
