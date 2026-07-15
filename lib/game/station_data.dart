import 'package:flame/game.dart' show Vector2;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../screens/impact_simulator/impact_simulator_screen.dart';
import '../screens/memory/memory_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/river_cleanup/river_cleanup_screen.dart';
import '../screens/waste_sorting/waste_sorting_screen.dart';
import '../services/score_service.dart';
import '../theme/app_theme.dart';

/// Describes one minigame "station" placed in the open world. This is the
/// only place that knows about the minigame screens, keeping the Flame
/// components decoupled from Navigator/screen concerns.
@immutable
class StationData {
  const StationData({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.position,
    required this.screenBuilder,
    required this.scoreKey,
    this.isModal = false,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final Vector2 position;
  final Widget Function() screenBuilder;

  /// The [ScoreService] key used to check whether this station's minigame
  /// has already been played, to show a "completed" badge in the world.
  final String scoreKey;

  /// Card-sized games (quiz, impact simulator) open as a centered modal
  /// over the world instead of a full-screen route.
  final bool isModal;
}

final Vector2 kWorldSize = Vector2(1600, 1200);

final List<StationData> kStations = [
  StationData(
    id: 'impact',
    title: 'Simulador de Impacto',
    icon: PhosphorIconsFill.globeHemisphereWest,
    color: AppTheme.primaryGreen,
    position: Vector2(400, 300),
    screenBuilder: () => const ImpactSimulatorScreen(),
    scoreKey: ScoreService.impactBestScoreKey,
    isModal: true,
  ),
  StationData(
    id: 'waste',
    title: 'Clasificá los Residuos',
    icon: PhosphorIconsFill.recycle,
    color: AppTheme.earthBlue,
    position: Vector2(1200, 300),
    screenBuilder: () => const WasteSortingScreen(),
    scoreKey: ScoreService.wasteBestAccuracyKey,
  ),
  StationData(
    id: 'quiz',
    title: 'Quiz Ambiental',
    icon: PhosphorIconsFill.question,
    color: Colors.orange,
    position: Vector2(400, 900),
    screenBuilder: () => const QuizScreen(),
    scoreKey: ScoreService.quizBestAccuracyKey,
    isModal: true,
  ),
  StationData(
    id: 'river',
    title: 'Río Limpio',
    icon: PhosphorIconsFill.fish,
    color: AppTheme.riverTeal,
    position: Vector2(800, 250),
    screenBuilder: () => const RiverCleanupScreen(),
    scoreKey: ScoreService.riverBestScoreKey,
  ),
  StationData(
    id: 'memory',
    title: 'Memoria Verde',
    icon: PhosphorIconsFill.puzzlePiece,
    color: Colors.purple,
    position: Vector2(1200, 900),
    screenBuilder: () => const MemoryScreen(),
    scoreKey: ScoreService.memoryBestMovesKey,
  ),
];
