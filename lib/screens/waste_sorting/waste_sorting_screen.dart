import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/game_ending.dart';
import '../../widgets/game_scaffold.dart';
import 'waste_sorting_data.dart';

class WasteSortingScreen extends StatefulWidget {
  const WasteSortingScreen({super.key});

  static const int gameSeconds = 45;

  @override
  State<WasteSortingScreen> createState() => _WasteSortingScreenState();
}

class _WasteSortingScreenState extends State<WasteSortingScreen> {
  static const Color _themeColor = AppTheme.earthBlue;

  late List<WasteItem> _items;
  int _index = 0;
  int _score = 0;
  int _mistakes = 0;
  int _secondsLeft = WasteSortingScreen.gameSeconds;
  Timer? _timer;
  String? _feedback;
  bool _feedbackCorrect = false;
  bool _scoreSaved = false;
  int? _bestAccuracy;

  bool get _timeUp => _secondsLeft <= 0;
  bool get _finished => _index >= _items.length || _timeUp;

  @override
  void initState() {
    super.initState();
    _items = List<WasteItem>.of(wasteItems)..shuffle(Random());
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
        if (_timeUp) timer.cancel();
      });
      if (_finished) _saveScore();
    });
  }

  Future<void> _saveScore() async {
    if (_scoreSaved) return;
    _scoreSaved = true;
    final accuracy = _index == 0 ? 0 : ((_score / _index) * 100).round();
    final best = await ScoreService.saveIfBest(
      ScoreService.wasteBestAccuracyKey,
      accuracy,
      higherIsBetter: true,
    );
    if (mounted) setState(() => _bestAccuracy = best);
  }

  void _handleDrop(WasteItem item, WasteCategory target) {
    if (_finished) return;
    final correct = item.category == target;
    setState(() {
      if (correct) {
        _score++;
      } else {
        _mistakes++;
      }
      _feedback = item.fact;
      _feedbackCorrect = correct;
      _index++;
      if (_finished) _timer?.cancel();
    });
    if (_finished) _saveScore();
  }

  void _restart() {
    setState(() {
      _items = List<WasteItem>.of(wasteItems)..shuffle(Random());
      _index = 0;
      _score = 0;
      _mistakes = 0;
      _secondsLeft = WasteSortingScreen.gameSeconds;
      _feedback = null;
      _scoreSaved = false;
      _bestAccuracy = null;
    });
    _timer?.cancel();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Clasificá los Residuos',
      emoji: '🗑️',
      color: _themeColor,
      subtitle: 'Arrastrá cada objeto a su tacho',
      child: _finished ? _buildEnding(context) : _buildGame(context),
    );
  }

  Widget _buildGame(BuildContext context) {
    final item = _items[_index];
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
              icon: Icons.star_rounded,
              label: 'Puntaje: $_score',
              color: AppTheme.primaryGreen,
            ),
          ],
        ),
        const SizedBox(height: 12),
        GameProgressBar(
          value: _secondsLeft / WasteSortingScreen.gameSeconds,
          label: 'Objeto ${_index + 1} de ${_items.length}',
          color: _themeColor,
        ),
        if (_feedback != null) ...[
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(_index),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_feedbackCorrect ? AppTheme.primaryGreen : Colors.redAccent)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (_feedbackCorrect ? AppTheme.primaryGreen : Colors.redAccent)
                      .withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _feedbackCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                    color: _feedbackCorrect ? AppTheme.primaryGreen : Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _feedback!,
                      style: const TextStyle(fontSize: 12.5, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Center(
          key: ValueKey(_index),
          child: Draggable<WasteItem>(
            data: item,
            feedback: _ItemCard(item: item, dragging: true),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _ItemCard(item: item),
            ),
            child: _ItemCard(item: item),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            '⬇ Arrastralo hasta el tacho correcto ⬇',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: WasteCategory.values
                .map((category) => _BinTarget(
                      category: category,
                      onAccept: (droppedItem) => _handleDrop(droppedItem, category),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEnding(BuildContext context) {
    final total = _items.length;
    final accuracy = total == 0 ? 0 : ((_score / total) * 100).round();

    final String emoji;
    final String title;
    final String message;
    if (accuracy >= 80) {
      emoji = '♻️';
      title = '¡Experto en reciclaje!';
      message = 'Clasificás los residuos con muy buena puntería. Seguí así en tu vida diaria.';
    } else if (accuracy >= 50) {
      emoji = '🌱';
      title = 'Vas bien encaminado';
      message = 'Acertaste varios, pero todavía hay algunas categorías para repasar.';
    } else {
      emoji = '🤔';
      title = 'A seguir practicando';
      message = 'Separar bien los residuos lleva práctica. ¡Intentalo de nuevo!';
    }

    return GameEndingView(
      emoji: emoji,
      title: title,
      message: message,
      color: _themeColor,
      stats: [
        EndingStat(icon: Icons.check_circle_outline, label: 'Aciertos', value: '$_score de $_index'),
        EndingStat(icon: Icons.close_rounded, label: 'Errores', value: '$_mistakes'),
        EndingStat(icon: Icons.percent_rounded, label: 'Precisión', value: '$accuracy%'),
      ],
      bestText: _bestAccuracy == null
          ? null
          : _bestAccuracy == accuracy
              ? '¡Nuevo mejor puntaje! 🏆'
              : 'Mejor puntaje: $_bestAccuracy%',
      isNewBest: _bestAccuracy != null && _bestAccuracy == accuracy,
      onRestart: _restart,
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, this.dragging = false});

  final WasteItem item;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 170,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.earthBlue.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.earthBlue.withValues(alpha: dragging ? 0.35 : 0.12),
              blurRadius: dragging ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item.category.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(item.emoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _BinTarget extends StatelessWidget {
  const _BinTarget({required this.category, required this.onAccept});

  final WasteCategory category;
  final void Function(WasteItem item) onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<WasteItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final highlighted = candidateData.isNotEmpty;
        return AnimatedScale(
          scale: highlighted ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  category.color.withValues(alpha: highlighted ? 0.35 : 0.14),
                  category.color.withValues(alpha: highlighted ? 0.45 : 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: category.color.withValues(alpha: highlighted ? 1 : 0.45),
                width: highlighted ? 2.5 : 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(category.icon, color: category.color, size: 18),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    category.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.lerp(category.color, Colors.black, 0.3),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
