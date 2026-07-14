import 'package:flutter/material.dart';

import '../../services/score_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/eco_dialog.dart';
import '../../widgets/game_ending.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/stat_bar.dart';
import 'impact_simulator_data.dart';

class ImpactSimulatorScreen extends StatefulWidget {
  const ImpactSimulatorScreen({super.key});

  @override
  State<ImpactSimulatorScreen> createState() => _ImpactSimulatorScreenState();
}

class _ImpactSimulatorScreenState extends State<ImpactSimulatorScreen> {
  static const _startValue = 50;
  static const Color _themeColor = AppTheme.primaryGreen;

  int _index = 0;
  int _pollution = _startValue;
  int _resources = _startValue;
  int _health = _startValue;
  int? _bestEcoScore;

  bool get _finished => _index >= impactScenarios.length;
  int get _ecoScore => (((100 - _pollution) + _resources + _health) / 3).round();

  int _clamp(int value) => value.clamp(0, 100);

  Future<void> _chooseOption(ImpactOption option) async {
    setState(() {
      _pollution = _clamp(_pollution + option.pollutionDelta);
      _resources = _clamp(_resources + option.resourcesDelta);
      _health = _clamp(_health + option.healthDelta);
    });

    await showEcoDialog(
      context,
      title: '¿Sabías que...?',
      message: option.feedback,
      color: _themeColor,
      emoji: '💡',
    );

    setState(() => _index++);
    if (_finished) await _saveScore();
  }

  Future<void> _saveScore() async {
    final best = await ScoreService.saveIfBest(
      ScoreService.impactBestScoreKey,
      _ecoScore,
      higherIsBetter: true,
    );
    if (mounted) setState(() => _bestEcoScore = best);
  }

  void _restart() {
    setState(() {
      _index = 0;
      _pollution = _startValue;
      _resources = _startValue;
      _health = _startValue;
      _bestEcoScore = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Simulador de Impacto',
      emoji: '🌍',
      color: _themeColor,
      subtitle: 'Tus decisiones cambian el planeta',
      child: _finished ? _buildEnding(context) : _buildScenario(context),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          StatBar(
            label: 'Contaminación',
            value: _pollution,
            icon: Icons.cloud_outlined,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 10),
          StatBar(
            label: 'Recursos naturales',
            value: _resources,
            icon: Icons.eco_outlined,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 10),
          StatBar(
            label: 'Calidad de vida',
            value: _health,
            icon: Icons.favorite_border,
            color: AppTheme.earthBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildScenario(BuildContext context) {
    final scenario = impactScenarios[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStats(),
        const SizedBox(height: 16),
        GameProgressBar(
          value: _index / impactScenarios.length,
          label: 'Situación ${_index + 1} de ${impactScenarios.length}',
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
                  border: const Border(
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
                  scenario.question,
                  style: const TextStyle(fontSize: 18.5, fontWeight: FontWeight.w700, height: 1.35),
                ),
              ),
              const SizedBox(height: 16),
              ...scenario.options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: _themeColor.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () => _chooseOption(option),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 18,
                          color: _themeColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option.text,
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnding(BuildContext context) {
    final ecoScore = _ecoScore;

    final String emoji;
    final String title;
    final String message;
    if (ecoScore >= 80) {
      emoji = '🌎';
      title = '¡Sos un héroe del planeta!';
      message =
          'Tus decisiones cotidianas generan un impacto muy positivo. Seguí eligiendo reutilizar, reciclar y ahorrar recursos.';
    } else if (ecoScore >= 60) {
      emoji = '🌱';
      title = 'Vas por buen camino';
      message =
          'Tomás varias decisiones responsables. Con pequeños cambios más podés reducir aún más tu impacto.';
    } else if (ecoScore >= 40) {
      emoji = '🤔';
      title = 'Podés mejorar bastante';
      message =
          'Algunas de tus elecciones generan bastante contaminación. Pensá qué hábitos podrías cambiar en tu día a día.';
    } else {
      emoji = '🚨';
      title = 'El planeta necesita un cambio';
      message =
          'Tus decisiones generaron mucho impacto negativo. La buena noticia es que cada elección cuenta y siempre se puede empezar de nuevo.';
    }

    return GameEndingView(
      emoji: emoji,
      title: title,
      message: message,
      color: _themeColor,
      stats: [
        EndingStat(icon: Icons.emoji_events_outlined, label: 'Puntaje ecológico:', value: '$ecoScore/100'),
        EndingStat(icon: Icons.fact_check_outlined, label: 'Decisiones', value: '${impactScenarios.length}'),
      ],
      bestText: _bestEcoScore == null
          ? null
          : _bestEcoScore == ecoScore
              ? '¡Nuevo mejor puntaje! 🏆'
              : 'Mejor puntaje: $_bestEcoScore/100',
      isNewBest: _bestEcoScore != null && _bestEcoScore == ecoScore,
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStats(),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _themeColor.withValues(alpha: 0.2)),
            ),
            child: const Text(
              '💚 Cada pequeña decisión suma: reutilizar, reciclar y consumir con conciencia son elecciones que están a tu alcance todos los días.',
              style: TextStyle(fontStyle: FontStyle.italic, height: 1.4),
            ),
          ),
        ],
      ),
      onRestart: _restart,
    );
  }
}
