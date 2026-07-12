import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:save_earth/screens/waste_sorting/waste_sorting_screen.dart';

void main() {
  testWidgets('Waste sorting screen shows timer, score and a draggable item', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WasteSortingScreen()),
    );

    expect(find.textContaining('Puntaje: 0'), findsOneWidget);
    expect(find.textContaining('s'), findsWidgets);
    expect(find.byWidgetPredicate((w) => w.runtimeType.toString().startsWith('Draggable')), findsWidgets);
  });

  testWidgets('Dropping an item on a bin updates score or mistakes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WasteSortingScreen()),
    );

    final draggable = find.byWidgetPredicate((w) => w.runtimeType.toString().startsWith('Draggable'));
    final target = find.byWidgetPredicate((w) => w.runtimeType.toString().startsWith('DragTarget')).first;

    await tester.drag(draggable.first, tester.getCenter(target) - tester.getCenter(draggable.first));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Puntaje: 1').evaluate().isNotEmpty ||
          find.textContaining('Objeto 2 de').evaluate().isNotEmpty,
      isTrue,
    );
  });
}
