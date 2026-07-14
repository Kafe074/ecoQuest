import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:save_earth/screens/river_cleanup/river_cleanup_screen.dart';

Finder _floaters({required bool trash}) {
  return find.byWidgetPredicate((w) {
    final key = w.key;
    return key is ValueKey<String> &&
        key.value.startsWith('river-') &&
        key.value.endsWith(trash ? '-trash' : '-animal');
  });
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('River cleanup shows HUD and seeds floating items', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RiverCleanupScreen()));
    await tester.pump();
    // First ticker tick after layout seeds the initial floaters.
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Puntaje: 0'), findsOneWidget);
    expect(find.textContaining('s'), findsWidgets);
    expect(_floaters(trash: true), findsWidgets);
  });

  testWidgets('Tapping trash increases the score', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RiverCleanupScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(_floaters(trash: true).first);
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.textContaining('Puntaje: ${RiverCleanupScreen.trashPoints}'),
      findsOneWidget,
    );
  });

  testWidgets('Game ends when time is up and shows the ending screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RiverCleanupScreen()));
    await tester.pump();

    // Jump past the game duration in a single tick, then let the ending
    // screen (and its intro animation) settle with bounded pumps.
    await tester.pump(const Duration(seconds: RiverCleanupScreen.gameSeconds + 1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Jugar de nuevo'), findsOneWidget);
    expect(find.text('Volver al mundo'), findsOneWidget);
  });
}
