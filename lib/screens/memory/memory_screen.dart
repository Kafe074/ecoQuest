import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';
import '../../theme/app_theme.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Memoria Verde')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _finished ? _buildEnding(context) : _buildGame(context),
        ),
      ),
    );
  }

  Widget _buildGame(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.timer_outlined, color: AppTheme.earthBlue),
            const SizedBox(width: 6),
            Text('$_seconds s', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            Text(
              'Movimientos: $_moves',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: _matches / _totalPairs,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 6),
        Text(
          'Parejas encontradas: $_matches de $_totalPairs',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            itemCount: _cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) => _MemoryCard(
              card: _cards[index],
              onTap: () => _tapCard(index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnding(BuildContext context) {
    final String title;
    final String message;
    if (_moves <= _totalPairs + 2) {
      title = '¡Memoria de elefante! 🐘💚';
      message = 'Encontraste todas las parejas con muy pocos movimientos.';
    } else if (_moves <= _totalPairs * 2) {
      title = '¡Buen trabajo! 🌱';
      message = 'Completaste el juego con un buen número de intentos.';
    } else {
      title = '¡Lo lograste! 🎉';
      message = 'Encontraste todas las parejas. ¡Probá superar tu marca la próxima vez!';
    }

    return ListView(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.grid_view_rounded, size: 72, color: AppTheme.primaryGreen),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
        ),
        const SizedBox(height: 24),
        Text(
          'Tiempo: $_seconds s   •   Movimientos: $_moves',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (_bestMoves != null) ...[
          const SizedBox(height: 6),
          Text(
            _bestMoves == _moves
                ? '¡Nuevo mejor puntaje! 🏆'
                : 'Mejor puntaje: $_bestMoves movimientos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: _restart,
          child: const Text('Jugar de nuevo'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver al menú'),
        ),
      ],
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.card, required this.onTap});

  final _CardData card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final revealed = card.faceUp || card.matched;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: card.matched
              ? AppTheme.primaryGreen.withValues(alpha: 0.15)
              : revealed
                  ? Colors.white
                  : AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(14),
          border: card.matched
              ? Border.all(color: AppTheme.primaryGreen, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Center(
          child: revealed
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(card.item.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 4),
                    Text(
                      card.item.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              : const Icon(Icons.eco_outlined, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
