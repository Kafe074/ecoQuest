import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';
import '../../theme/app_theme.dart';
import 'waste_sorting_data.dart';

class WasteSortingScreen extends StatefulWidget {
  const WasteSortingScreen({super.key});

  static const int gameSeconds = 45;

  @override
  State<WasteSortingScreen> createState() => _WasteSortingScreenState();
}

class _WasteSortingScreenState extends State<WasteSortingScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Clasificá los Residuos')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _finished ? _buildEnding(context) : _buildGame(context),
        ),
      ),
    );
  }

  Widget _buildGame(BuildContext context) {
    final item = _items[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.timer_outlined, color: AppTheme.earthBlue),
            const SizedBox(width: 6),
            Text(
              '$_secondsLeft s',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            Text(
              'Puntaje: $_score',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: _secondsLeft / WasteSortingScreen.gameSeconds,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 6),
        Text(
          'Objeto ${_index + 1} de ${_items.length}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        if (_feedback != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (_feedbackCorrect ? AppTheme.primaryGreen : Colors.redAccent)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  _feedbackCorrect ? Icons.check_circle_outline : Icons.info_outline,
                  color: _feedbackCorrect ? AppTheme.primaryGreen : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_feedback!, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
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
        const SizedBox(height: 24),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
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

    final String title;
    final String message;
    if (accuracy >= 80) {
      title = '¡Experto en reciclaje! ♻️';
      message = 'Clasificás los residuos con muy buena puntería. Seguí así en tu vida diaria.';
    } else if (accuracy >= 50) {
      title = 'Vas bien encaminado 🌱';
      message = 'Acertaste varios, pero todavía hay algunas categorías para repasar.';
    } else {
      title = 'A seguir practicando 🤔';
      message = 'Separar bien los residuos lleva práctica. ¡Intentalo de nuevo!';
    }

    return ListView(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.recycling, size: 72, color: AppTheme.primaryGreen),
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
          'Acertaste $_score de $_index objetos ($accuracy%)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          'Errores: $_mistakes',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        if (_bestAccuracy != null) ...[
          const SizedBox(height: 6),
          Text(
            _bestAccuracy == accuracy
                ? '¡Nuevo mejor puntaje! 🏆'
                : 'Mejor puntaje: $_bestAccuracy%',
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

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, this.dragging = false});

  final WasteItem item;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dragging ? 0.2 : 0.08),
              blurRadius: dragging ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
        return Container(
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: highlighted ? 0.28 : 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: category.color.withValues(alpha: highlighted ? 0.9 : 0.4),
              width: highlighted ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, color: category.color, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  category.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: category.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
