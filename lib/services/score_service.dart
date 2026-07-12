import 'package:shared_preferences/shared_preferences.dart';

/// Persists and retrieves each game's best score across app restarts.
class ScoreService {
  ScoreService._();

  static const String quizBestAccuracyKey = 'best_quiz_accuracy';
  static const String wasteBestAccuracyKey = 'best_waste_accuracy';
  static const String memoryBestMovesKey = 'best_memory_moves';
  static const String impactBestScoreKey = 'best_impact_score';

  /// Stores [value] under [key] if it improves on the previous best, then
  /// returns the resulting best value (existing best when it wasn't beaten).
  static Future<int> saveIfBest(
    String key,
    int value, {
    required bool higherIsBetter,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(key);
    final best = current == null
        ? value
        : (higherIsBetter ? (value > current ? value : current) : (value < current ? value : current));
    if (best != current) {
      await prefs.setInt(key, best);
    }
    return best;
  }

  static Future<int?> getBest(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }
}
