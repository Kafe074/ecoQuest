import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../services/score_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/game_ending.dart';
import '../../widgets/game_scaffold.dart';
import 'memory_data.dart';

class _CardData {
  _CardData({required this.pairId, required this.item});

  final int pairId;
  final MemoryItem item;
  bool faceUp = false;
  bool matched = false;
}

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  static const Color _themeColor = Color(0xFF7B3FA0);

  late List<_CardData> _cards;
  final List<int> _flippedIndices = [];
  int _moves = 0;
  int _matches = 0;
  bool _busy = false;
  int _seconds = 0;
  Timer? _timer;
  int? _bestMoves;

  int get _totalPairs => memoryItems.length;
  bool get _finished => _matches == _totalPairs;

  @override
  void initState() {
    super.initState();
    _setupCards();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setupCards() {
    _cards = [
      for (var i = 0; i < memoryItems.length; i++) ...[
        _CardData(pairId: i, item: memoryItems[i]),
        _CardData(pairId: i, item: memoryItems[i]),
      ],
    ]..shuffle(Random());
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_finished) {
        timer.cancel();
        return;
      }
      setState(() => _seconds++);
    });
  }

  void _tapCard(int index) {
    final card = _cards[index];
    if (_busy || card.faceUp || card.matched) return;

    setState(() => card.faceUp = true);
    _flippedIndices.add(index);

    if (_flippedIndices.length < 2) return;

    _moves++;
    final first = _cards[_flippedIndices[0]];
    final second = _cards[_flippedIndices[1]];

    if (first.pairId == second.pairId) {
      setState(() {
        first.matched = true;
        second.matched = true;
        _matches++;
      });
      _flippedIndices.clear();
      if (_finished) _saveScore();
      return;
    }

    _busy = true;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        first.faceUp = false;
        second.faceUp = false;
        _busy = false;
      });
      _flippedIndices.clear();
    });
  }

  Future<void> _saveScore() async {
    final best = await ScoreService.saveIfBest(
      ScoreService.memoryBestMovesKey,
      _moves,
      higherIsBetter: false,
    );
    if (mounted) setState(() => _bestMoves = best);
  }

  void _restart() {
    _timer?.cancel();
    setState(() {
      _setupCards();
      _flippedIndices.clear();
      _moves = 0;
      _matches = 0;
      _busy = false;
      _seconds = 0;
      _bestMoves = null;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Memoria Verde',
      icon: PhosphorIconsFill.puzzlePiece,
      color: _themeColor,
      subtitle: 'Encontrá las parejas ecológicas',
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
              icon: PhosphorIconsBold.timer,
              label: '$_seconds s',
              color: AppTheme.earthBlue,
            ),
            const Spacer(),
            HudChip(
              icon: PhosphorIconsBold.handTap,
              label: 'Movimientos: $_moves',
              color: _themeColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        GameProgressBar(
          value: _matches / _totalPairs,
          label: 'Parejas encontradas: $_matches de $_totalPairs',
          color: _themeColor,
        ),
        const SizedBox(height: 14),
        // Cap the board width so cards stay small and tidy on wide screens
        // instead of stretching to fill the whole viewport.
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: _cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) => _MemoryCard(
                  card: _cards[index],
                  themeColor: _themeColor,
                  onTap: () => _tapCard(index),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnding(BuildContext context) {
    final IconData icon;
    final String title;
    final String message;
    if (_moves <= _totalPairs + 2) {
      icon = PhosphorIconsFill.brain;
      title = '¡Memoria de elefante!';
      message = 'Encontraste todas las parejas con muy pocos movimientos.';
    } else if (_moves <= _totalPairs * 2) {
      icon = PhosphorIconsFill.plant;
      title = '¡Buen trabajo!';
      message = 'Completaste el juego con un buen número de intentos.';
    } else {
      icon = PhosphorIconsFill.confetti;
      title = '¡Lo lograste!';
      message = 'Encontraste todas las parejas. ¡Probá superar tu marca la próxima vez!';
    }

    return GameEndingView(
      icon: icon,
      title: title,
      message: message,
      color: _themeColor,
      stats: [
        EndingStat(icon: PhosphorIconsBold.timer, label: 'Tiempo', value: '$_seconds s'),
        EndingStat(icon: PhosphorIconsBold.handTap, label: 'Movimientos', value: '$_moves'),
        EndingStat(icon: PhosphorIconsBold.puzzlePiece, label: 'Parejas', value: '$_matches'),
      ],
      bestText: _bestMoves == null
          ? null
          : _bestMoves == _moves
              ? '¡Nuevo mejor puntaje!'
              : 'Mejor puntaje: $_bestMoves movimientos',
      isNewBest: _bestMoves != null && _bestMoves == _moves,
      onRestart: _restart,
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.card,
    required this.themeColor,
    required this.onTap,
  });

  final _CardData card;
  final Color themeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final revealed = card.faceUp || card.matched;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: card.matched ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 250),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: revealed
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeColor,
                      Color.lerp(themeColor, Colors.black, 0.25)!,
                    ],
                  ),
            color: revealed ? Colors.white : null,
            borderRadius: BorderRadius.circular(14),
            border: card.matched
                ? Border.all(color: AppTheme.primaryGreen, width: 2)
                : revealed
                    ? Border.all(color: themeColor.withValues(alpha: 0.3))
                    : null,
            boxShadow: [
              BoxShadow(
                color: revealed
                    ? Colors.black.withValues(alpha: 0.08)
                    : themeColor.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: revealed ? _buildFace() : _buildBack(),
        ),
      ),
    );
  }

  /// Revealed face: the real photo filling the card with the concept label
  /// on a small strip below, plus a check badge once matched.
  Widget _buildFace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                card.item.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: card.item.color.withValues(alpha: 0.12),
                  child: Center(
                    child: PhosphorIcon(
                      card.item.icon,
                      size: 24,
                      color: card.item.color,
                    ),
                  ),
                ),
              ),
              if (card.matched)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const PhosphorIcon(
                      PhosphorIconsBold.check,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          color: card.matched
              ? AppTheme.primaryGreen.withValues(alpha: 0.10)
              : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          child: Text(
            card.item.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Center(
      child: PhosphorIcon(
        PhosphorIconsFill.leaf,
        color: Colors.white.withValues(alpha: 0.9),
        size: 24,
      ),
    );
  }
}
