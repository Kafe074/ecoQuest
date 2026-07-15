import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../services/score_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/eco_dialog.dart';
import '../../widgets/game_ending.dart';
import '../../widgets/game_modal.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/option_tile.dart';
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
      title: correct ? '¡Correcto!' : 'No era esa',
      message: question.explanation,
      color: correct ? Colors.green.shade700 : Colors.redAccent,
      icon: correct ? PhosphorIconsFill.confetti : PhosphorIconsFill.lightbulb,
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
    return GameModal(
      title: 'Quiz Ambiental',
      icon: PhosphorIconsFill.question,
      color: _themeColor,
      subtitle: 'Demostrá cuánto sabés del planeta',
      child: _finished ? _buildEnding(context) : _buildQuestion(context),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final question = _questions[_index];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            HudChip(
              icon: PhosphorIconsFill.star,
              label: 'Puntaje: $_score',
              color: _themeColor,
            ),
            const Spacer(),
            HudChip(
              icon: PhosphorIconsBold.question,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: AppTheme.claySurface(tint: _themeColor, radius: 18, depth: 3),
          child: Text(
            question.question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(question.options.length, (optionIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OptionTile(
              color: _themeColor,
              leadingText: String.fromCharCode(65 + optionIndex),
              label: question.options[optionIndex],
              onTap: () => _selectOption(question, optionIndex),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEnding(BuildContext context) {
    final total = _questions.length;
    final accuracy = total == 0 ? 0 : ((_score / total) * 100).round();

    final IconData icon;
    final String title;
    final String message;
    if (accuracy >= 80) {
      icon = PhosphorIconsFill.globeHemisphereWest;
      title = '¡Sos un experto ambiental!';
      message = 'Sabés muchísimo sobre el cuidado del planeta. ¡Compartí lo que aprendiste!';
    } else if (accuracy >= 50) {
      icon = PhosphorIconsFill.plant;
      title = 'Buen conocimiento';
      message = 'Conocés varios conceptos clave. Seguí aprendiendo para saber aún más.';
    } else {
      icon = PhosphorIconsFill.lightbulb;
      title = 'Hay mucho para aprender';
      message = 'No te preocupes, cada dato nuevo suma. ¡Volvé a intentarlo!';
    }

    return GameEndingView(
      compact: true,
      icon: icon,
      title: title,
      message: message,
      color: _themeColor,
      stats: [
        EndingStat(icon: PhosphorIconsBold.checkCircle, label: 'Correctas', value: '$_score de $total'),
        EndingStat(icon: PhosphorIconsBold.percent, label: 'Precisión', value: '$accuracy%'),
      ],
      bestText: _bestAccuracy == null
          ? null
          : _bestAccuracy == accuracy
              ? '¡Nuevo mejor puntaje!'
              : 'Mejor puntaje: $_bestAccuracy%',
      isNewBest: _bestAccuracy != null && _bestAccuracy == accuracy,
      onRestart: _restart,
    );
  }
}
