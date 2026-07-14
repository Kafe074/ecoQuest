import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/score_service.dart';
import '../../widgets/eco_dialog.dart';
import '../../widgets/game_ending.dart';
import '../../widgets/game_scaffold.dart';
import 'quiz_data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const Color _themeColor = Color(0xFFEF8A17);

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

    await showEcoDialog(
      context,
      title: correct ? '¡Correcto! ✅' : 'No era esa ❌',
      message: question.explanation,
      color: correct ? Colors.green.shade700 : Colors.redAccent,
      emoji: correct ? '🎉' : '💡',
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
    return GameScaffold(
      title: 'Quiz Ambiental',
      emoji: '❓',
      color: _themeColor,
      subtitle: 'Demostrá cuánto sabés del planeta',
      child: _finished ? _buildEnding(context) : _buildQuestion(context),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final question = _questions[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            HudChip(
              icon: Icons.star_rounded,
              label: 'Puntaje: $_score',
              color: _themeColor,
            ),
            const Spacer(),
            HudChip(
              icon: Icons.help_outline_rounded,
              label: '${_index + 1}/${_questions.length}',
              color: _themeColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        GameProgressBar(
          value: _index / _questions.length,
          label: 'Pregunta ${_index + 1} de ${_questions.length}',
          color: _themeColor,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border(
                    left: BorderSide(color: _themeColor, width: 5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  question.question,
                  style: const TextStyle(fontSize: 18.5, fontWeight: FontWeight.w700, height: 1.35),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(question.options.length, (optionIndex) {
                final letter = String.fromCharCode(65 + optionIndex);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: _themeColor.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () => _selectOption(question, optionIndex),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _themeColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color.lerp(_themeColor, Colors.black, 0.25),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.options[optionIndex],
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
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

    final String emoji;
    final String title;
    final String message;
    if (accuracy >= 80) {
      emoji = '🌎';
      title = '¡Sos un experto ambiental!';
      message = 'Sabés muchísimo sobre el cuidado del planeta. ¡Compartí lo que aprendiste!';
    } else if (accuracy >= 50) {
      emoji = '🌱';
      title = 'Buen conocimiento';
      message = 'Conocés varios conceptos clave. Seguí aprendiendo para saber aún más.';
    } else {
      emoji = '🤔';
      title = 'Hay mucho para aprender';
      message = 'No te preocupes, cada dato nuevo suma. ¡Volvé a intentarlo!';
    }

    return GameEndingView(
      emoji: emoji,
      title: title,
      message: message,
      color: _themeColor,
      stats: [
        EndingStat(icon: Icons.check_circle_outline, label: 'Correctas', value: '$_score de $total'),
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
