import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';
import 'quiz_data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<QuizQuestion> _questions;
  int _index = 0;
  int _score = 0;
  int? _selectedIndex;
  int? _bestAccuracy;

  bool get _finished => _index >= _questions.length;
  bool get _answered => _selectedIndex != null;

  @override
  void initState() {
    super.initState();
    _questions = List<QuizQuestion>.of(quizQuestions)..shuffle(Random());
  }

  Future<void> _selectOption(QuizQuestion question, int optionIndex) async {
    if (_answered) return;

    final correct = optionIndex == question.correctIndex;
    setState(() {
      _selectedIndex = optionIndex;
      if (correct) _score++;
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(correct ? '¡Correcto! ✅' : 'No era esa ❌'),
        content: Text(question.explanation),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    setState(() {
      _index++;
      _selectedIndex = null;
    });
    if (_finished) await _saveScore();
  }

  Future<void> _saveScore() async {
    final accuracy = ((_score / _questions.length) * 100).round();
    final best = await ScoreService.saveIfBest(
      ScoreService.quizBestAccuracyKey,
      accuracy,
      higherIsBetter: true,
    );
    if (mounted) setState(() => _bestAccuracy = best);
  }

  void _restart() {
    setState(() {
      _questions = List<QuizQuestion>.of(quizQuestions)..shuffle(Random());
      _index = 0;
      _score = 0;
      _selectedIndex = null;
      _bestAccuracy = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Ambiental')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _finished ? _buildEnding(context) : _buildQuestion(context),
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final question = _questions[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.quiz_outlined, color: Colors.orange),
            const SizedBox(width: 6),
            Text(
              'Puntaje: $_score',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: _index / _questions.length,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 6),
        Text(
          'Pregunta ${_index + 1} de ${_questions.length}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    question.question,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(question.options.length, (optionIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () => _selectOption(question, optionIndex),
                      child: Text(question.options[optionIndex]),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnding(BuildContext context) {
    final total = _questions.length;
    final accuracy = total == 0 ? 0 : ((_score / total) * 100).round();

    final String title;
    final String message;
    if (accuracy >= 80) {
      title = '¡Sos un experto ambiental! 🌎';
      message = 'Sabés muchísimo sobre el cuidado del planeta. ¡Compartí lo que aprendiste!';
    } else if (accuracy >= 50) {
      title = 'Buen conocimiento 🌱';
      message = 'Conocés varios conceptos clave. Seguí aprendiendo para saber aún más.';
    } else {
      title = 'Hay mucho para aprender 🤔';
      message = 'No te preocupes, cada dato nuevo suma. ¡Volvé a intentarlo!';
    }

    return ListView(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.quiz_outlined, size: 72, color: Colors.orange),
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
          'Puntaje final: $_score de $total ($accuracy%)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
