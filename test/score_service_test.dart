import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:save_earth/services/score_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('keeps the higher value when higherIsBetter is true', () async {
    const key = 'test_higher';
    expect(await ScoreService.saveIfBest(key, 60, higherIsBetter: true), 60);
    expect(await ScoreService.saveIfBest(key, 40, higherIsBetter: true), 60);
    expect(await ScoreService.saveIfBest(key, 90, higherIsBetter: true), 90);
    expect(await ScoreService.getBest(key), 90);
  });

  test('keeps the lower value when higherIsBetter is false', () async {
    const key = 'test_lower';
    expect(await ScoreService.saveIfBest(key, 10, higherIsBetter: false), 10);
    expect(await ScoreService.saveIfBest(key, 15, higherIsBetter: false), 10);
    expect(await ScoreService.saveIfBest(key, 4, higherIsBetter: false), 4);
    expect(await ScoreService.getBest(key), 4);
  });

  test('returns null when nothing has been saved yet', () async {
    expect(await ScoreService.getBest('never_saved'), isNull);
  });
}
