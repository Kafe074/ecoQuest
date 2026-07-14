import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../services/score_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/game_ending.dart';
import '../../widgets/game_scaffold.dart';
import 'river_cleanup_data.dart';

/// Arcade minigame: trash and animals float down a river; tapping trash
/// collects it for points while tapping an animal costs points. Driven by a
/// single [Ticker] acting as the game loop.
class RiverCleanupScreen extends StatefulWidget {
  const RiverCleanupScreen({super.key});

  static const int gameSeconds = 40;
  static const int trashPoints = 10;
  static const int animalPenalty = 5;

  @override
  State<RiverCleanupScreen> createState() => _RiverCleanupScreenState();
}

class _Floater {
  _Floater({
    required this.id,
    required this.item,
    required this.x,
    required this.yFactor,
    required this.speed,
    required this.bobPhase,
  });

  final int id;
  final RiverItem item;
  double x;

  /// Vertical position as a fraction of the river height (0 = top).
  final double yFactor;
  final double speed;
  final double bobPhase;
  bool tapped = false;
  double tappedAt = 0;
}

class _RiverCleanupScreenState extends State<RiverCleanupScreen>
    with SingleTickerProviderStateMixin {
  static const Color _themeColor = AppTheme.riverTeal;
  static const double _itemSize = 54;

  late final Ticker _ticker;
  final Random _random = Random();
  final List<_Floater> _floaters = [];

  Size _riverSize = Size.zero;
  double _elapsed = 0;
  double _lastTick = 0;
  double _nextSpawnIn = 0;
  int _nextId = 0;
  bool _seeded = false;

  int _score = 0;
  int _collected = 0;
  int _mistakes = 0;
  bool _finished = false;
  int? _bestScore;
  String? _warning;
  Timer? _warningTimer;

  int get _secondsLeft =>
      (RiverCleanupScreen.gameSeconds - _elapsed).ceil().clamp(0, RiverCleanupScreen.gameSeconds);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _warningTimer?.cancel();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _lastTick).clamp(0.0, 0.1);
    _lastTick = now;
    _elapsed = now;

    if (_riverSize == Size.zero) return;

    if (_secondsLeft <= 0) {
      _finish();
      return;
    }

    // Seed a few items on the very first sized tick so the river never
    // starts empty; from then on new items enter from the right edge.
    if (!_seeded) {
      _seeded = true;
      _spawn(x: _riverSize.width * 0.25, forceTrash: true);
      _spawn(x: _riverSize.width * 0.55);
      _spawn(x: _riverSize.width * 0.85, forceTrash: true);
      _nextSpawnIn = 1.0;
    }

    _nextSpawnIn -= dt;
    if (_nextSpawnIn <= 0) {
      _spawn(x: _riverSize.width + _itemSize);
      _nextSpawnIn = 0.8 + _random.nextDouble() * 0.7;
    }

    for (final f in _floaters) {
      f.x -= f.speed * dt;
    }
    _floaters.removeWhere(
      (f) => f.x < -_itemSize || (f.tapped && _elapsed - f.tappedAt > 0.35),
    );

    setState(() {});
  }

  void _spawn({required double x, bool forceTrash = false}) {
    final isTrash = forceTrash || _random.nextDouble() < 0.65;
    final pool = isTrash ? riverTrash : riverAnimals;
    _floaters.add(_Floater(
      id: _nextId++,
      item: pool[_random.nextInt(pool.length)],
      x: x,
      yFactor: 0.12 + _random.nextDouble() * 0.72,
      speed: 55 + _random.nextDouble() * 45,
      bobPhase: _random.nextDouble() * 2 * pi,
    ));
  }

  void _tapFloater(_Floater floater) {
    if (_finished || floater.tapped) return;
    setState(() {
      floater.tapped = true;
      floater.tappedAt = _elapsed;
      if (floater.item.isTrash) {
        _score += RiverCleanupScreen.trashPoints;
        _collected++;
      } else {
        _score = max(0, _score - RiverCleanupScreen.animalPenalty);
        _mistakes++;
        _showWarning('¡Cuidado! ${floater.item.name} vive en el río 💙');
      }
    });
  }

  void _showWarning(String text) {
    _warningTimer?.cancel();
    _warning = text;
    _warningTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _warning = null);
    });
  }

  Future<void> _finish() async {
    if (_finished) return;
    _ticker.stop();
    setState(() => _finished = true);
    final best = await ScoreService.saveIfBest(
      ScoreService.riverBestScoreKey,
      _score,
      higherIsBetter: true,
    );
    if (mounted) setState(() => _bestScore = best);
  }

  void _restart() {
    setState(() {
      _floaters.clear();
      _elapsed = 0;
      _lastTick = 0;
      _nextSpawnIn = 0;
      _seeded = false;
      _score = 0;
      _collected = 0;
      _mistakes = 0;
      _finished = false;
      _bestScore = null;
      _warning = null;
    });
    _ticker
      ..stop()
      ..start();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Río Limpio',
      emoji: '🐟',
      color: _themeColor,
      subtitle: 'Sacá la basura sin molestar a los animales',
      child: _finished ? _buildEnding(context) : _buildGame(context),
    );
  }

  Widget _buildGame(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            HudChip(
              icon: Icons.timer_outlined,
              label: '$_secondsLeft s',
              color: _secondsLeft <= 10 ? Colors.redAccent : _themeColor,
            ),
            const Spacer(),
            HudChip(
              icon: Icons.delete_sweep_rounded,
              label: '$_collected',
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(width: 8),
            HudChip(
              icon: Icons.star_rounded,
              label: 'Puntaje: $_score',
              color: Colors.amber.shade800,
            ),
          ],
        ),
        const SizedBox(height: 12),
        GameProgressBar(
          value: _secondsLeft / RiverCleanupScreen.gameSeconds,
          label: 'Tocá la basura 🥤 y dejá tranquilos a los animales 🐟',
          color: _themeColor,
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 34,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _warning == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(_warning),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.redAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _warning!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                _riverSize = Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.lightBlue.shade200,
                            Colors.blue.shade600,
                          ],
                        ),
                      ),
                    ),
                    CustomPaint(painter: _WavePainter(time: _elapsed)),
                    // Grassy banks framing the river.
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(height: 12, color: const Color(0xFF6FAE68)),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(height: 12, color: const Color(0xFF6FAE68)),
                    ),
                    const Positioned(top: 8, left: 10, child: Text('🌿', style: TextStyle(fontSize: 18))),
                    const Positioned(top: 8, right: 10, child: Text('🌾', style: TextStyle(fontSize: 18))),
                    const Positioned(bottom: 8, left: 14, child: Text('🌾', style: TextStyle(fontSize: 18))),
                    const Positioned(bottom: 8, right: 14, child: Text('🌿', style: TextStyle(fontSize: 18))),
                    for (final f in _floaters)
                      Positioned(
                        left: f.x - _itemSize / 2,
                        top: (f.yFactor * (constraints.maxHeight - _itemSize * 1.4)) +
                            _itemSize * 0.2 +
                            sin(_elapsed * 2 + f.bobPhase) * 6,
                        child: GestureDetector(
                          key: ValueKey(
                              'river-${f.id}-${f.item.isTrash ? 'trash' : 'animal'}'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _tapFloater(f),
                          child: AnimatedScale(
                            scale: f.tapped ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              width: _itemSize,
                              height: _itemSize,
                              alignment: Alignment.center,
                              decoration: f.item.isTrash
                                  ? BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                    )
                                  : null,
                              child: Text(
                                f.item.emoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Basura: +${RiverCleanupScreen.trashPoints} puntos   •   Animal: -${RiverCleanupScreen.animalPenalty} puntos',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5),
          ),
        ),
      ],
    );
  }

  Widget _buildEnding(BuildContext context) {
    final String emoji;
    final String title;
    final String message;
    if (_collected >= 15 && _mistakes <= 2) {
      emoji = '🏞️';
      title = '¡El río quedó cristalino!';
      message = 'Recogiste muchísima basura y respetaste a los animales. ¡Guardaparques honorario!';
    } else if (_collected >= 8) {
      emoji = '💧';
      title = '¡Buen trabajo de limpieza!';
      message = 'El río está mucho mejor gracias a vos. Con más práctica quedará impecable.';
    } else {
      emoji = '🐟';
      title = 'Los peces te lo agradecen';
      message = 'Cada pedacito de basura que sale del agua cuenta. ¡Intentalo de nuevo!';
    }

    return GameEndingView(
      emoji: emoji,
      title: title,
      message: message,
      color: _themeColor,
      stats: [
        EndingStat(icon: Icons.star_rounded, label: 'Puntaje', value: '$_score'),
        EndingStat(icon: Icons.delete_sweep_rounded, label: 'Basura recogida', value: '$_collected'),
        EndingStat(icon: Icons.pets_rounded, label: 'Animales tocados', value: '$_mistakes'),
      ],
      bestText: _bestScore == null
          ? null
          : _bestScore == _score
              ? '¡Nuevo mejor puntaje! 🏆'
              : 'Mejor puntaje: $_bestScore puntos',
      isNewBest: _bestScore != null && _bestScore == _score,
      onRestart: _restart,
    );
  }
}

/// Light translucent sine-wave streaks that drift with time, giving the
/// river a sense of current without any image assets.
class _WavePainter extends CustomPainter {
  _WavePainter({required this.time});

  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (var row = 0; row < 5; row++) {
      final y = size.height * (0.15 + row * 0.18);
      final phase = time * 40 + row * 60;
      for (var x = -40.0; x < size.width; x += 90) {
        final drift = (x - phase) % (size.width + 80);
        final startX = drift < -40 ? drift + size.width + 80 : drift;
        final path = Path()
          ..moveTo(startX, y)
          ..quadraticBezierTo(startX + 15, y - 6, startX + 30, y);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => oldDelegate.time != time;
}
