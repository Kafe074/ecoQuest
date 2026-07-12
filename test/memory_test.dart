import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:save_earth/screens/memory/memory_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Memory screen shows the board and initial counters', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: MemoryScreen()),
    );

    expect(find.textContaining('Movimientos: 0'), findsOneWidget);
    expect(find.textContaining('Parejas encontradas: 0 de'), findsOneWidget);
    expect(find.byIcon(Icons.eco_outlined), findsNWidgets(16));
  });

  testWidgets('Tapping a card flips it to reveal its content', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: MemoryScreen()),
    );

    await tester.tap(find.byIcon(Icons.eco_outlined).first);
    await tester.pump();

    expect(find.byIcon(Icons.eco_outlined), findsNWidgets(15));
  });
}
