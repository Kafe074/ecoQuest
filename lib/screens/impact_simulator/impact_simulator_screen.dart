import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../services/score_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/eco_dialog.dart';
import '../../widgets/game_ending.dart';
import '../../widgets/game_modal.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/option_tile.dart';
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
      icon: PhosphorIconsFill.lightbulb,
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
    return GameModal(
      title: 'Simulador de Impacto',
      icon: PhosphorIconsFill.globeHemisphereWest,
      color: _themeColor,
      subtitle: 'Tus decisiones cambian el planeta',
      child: _finished ? _buildEnding(context) : _buildScenario(context),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: StatBar(
            label: 'Contaminación',
            value: _pollution,
            icon: PhosphorIconsFill.factory,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatBar(
            label: 'Recursos',
            value: _resources,
            icon: PhosphorIconsFill.leaf,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatBar(
            label: 'Calidad de vida',
            value: _health,
            icon: PhosphorIconsFill.heart,
            color: AppTheme.earthBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildScenario(BuildContext context) {
    final scenario = impactScenarios[_index];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStats(),
        const SizedBox(height: 14),
        GameProgressBar(
          value: _index / impactScenarios.length,
          label: 'Situación ${_index + 1} de ${impactScenarios.length}',
          color: _themeColor,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: AppTheme.claySurface(tint: _themeColor, radius: 18, depth: 3),
          child: Text(
            scenario.question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(scenario.options.length, (optionIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OptionTile(
              color: _themeColor,
              leadingText: String.fromCharCode(65 + optionIndex),
              label: scenario.options[optionIndex].text,
              onTap: () => _chooseOption(scenario.options[optionIndex]),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEnding(BuildContext context) {
    final ecoScore = _ecoScore;

    final IconData icon;
    final String title;
    final String message;
    if (ecoScore >= 80) {
      icon = PhosphorIconsFill.globeHemisphereWest;
      title = '¡Sos un héroe del planeta!';
      message =
          'Tus decisiones cotidianas generan un impacto muy positivo. Seguí eligiendo reutilizar, reciclar y ahorrar recursos.';
    } else if (ecoScore >= 60) {
      icon = PhosphorIconsFill.plant;
      title = 'Vas por buen camino';
      message =
          'Tomás varias decisiones responsables. Con pequeños cambios más podés reducir aún más tu impacto.';
    } else if (ecoScore >= 40) {
      icon = PhosphorIconsFill.lightbulb;
      title = 'Podés mejorar bastante';
      message =
          'Algunas de tus elecciones generan bastante contaminación. Pensá qué hábitos podrías cambiar en tu día a día.';
    } else {
      icon = PhosphorIconsFill.warning;
      title = 'El planeta necesita un cambio';
      message =
          'Tus decisiones generaron mucho impacto negativo. La buena noticia es que cada elección cuenta y siempre se puede empezar de nuevo.';
    }

    return GameEndingView(
      compact: true,
      icon: icon,
      title: title,
      message: message,
      color: _themeColor,
      stats: [
        EndingStat(icon: PhosphorIconsBold.trophy, label: 'Puntaje ecológico', value: '$ecoScore/100'),
        EndingStat(icon: PhosphorIconsBold.listChecks, label: 'Decisiones', value: '${impactScenarios.length}'),
      ],
      bestText: _bestEcoScore == null
          ? null
          : _bestEcoScore == ecoScore
              ? '¡Nuevo mejor puntaje!'
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
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhosphorIcon(
                  PhosphorIconsFill.handHeart,
                  size: 22,
                  color: _themeColor,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cada pequeña decisión suma: reutilizar, reciclar y consumir con conciencia son elecciones que están a tu alcance todos los días.',
                    style: TextStyle(fontStyle: FontStyle.italic, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onRestart: _restart,
    );
  }
}
