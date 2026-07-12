import 'package:flutter/material.dart';

import '../../services/score_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_bar.dart';
import 'impact_simulator_data.dart';

class ImpactSimulatorScreen extends StatefulWidget {
  const ImpactSimulatorScreen({super.key});

  @override
  State<ImpactSimulatorScreen> createState() => _ImpactSimulatorScreenState();
}

class _ImpactSimulatorScreenState extends State<ImpactSimulatorScreen> {
  static const _startValue = 50;

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

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¿Sabías que...?'),
        content: Text(option.feedback),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Impacto')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _finished ? _buildEnding(context) : _buildScenario(context),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Column(
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
    );
  }

  Widget _buildScenario(BuildContext context) {
    final scenario = impactScenarios[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStats(),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: _index / impactScenarios.length,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 6),
        Text(
          'Situación ${_index + 1} de ${impactScenarios.length}',
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
                    scenario.question,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...scenario.options.map(
                (option) => Padding(
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
                      onPressed: () => _chooseOption(option),
                      child: Text(option.text),
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

    final String title;
    final String message;
    if (ecoScore >= 80) {
      title = '¡Sos un héroe del planeta! 🌎💚';
      message =
          'Tus decisiones cotidianas generan un impacto muy positivo. Seguí eligiendo reutilizar, reciclar y ahorrar recursos.';
    } else if (ecoScore >= 60) {
      title = 'Vas por buen camino 🌱';
      message =
          'Tomás varias decisiones responsables. Con pequeños cambios más podés reducir aún más tu impacto.';
    } else if (ecoScore >= 40) {
      title = 'Podés mejorar bastante 🤔';
      message =
          'Algunas de tus elecciones generan bastante contaminación. Pensá qué hábitos podrías cambiar en tu día a día.';
    } else {
      title = 'El planeta necesita un cambio 🚨';
      message =
          'Tus decisiones generaron mucho impacto negativo. La buena noticia es que cada elección cuenta y siempre se puede empezar de nuevo.';
    }

    return ListView(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.emoji_events_outlined, size: 72, color: AppTheme.primaryGreen),
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
        const SizedBox(height: 28),
        _buildStats(),
        const SizedBox(height: 12),
        Text(
          'Puntaje ecológico: $ecoScore/100',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (_bestEcoScore != null) ...[
          const SizedBox(height: 6),
          Text(
            _bestEcoScore == ecoScore
                ? '¡Nuevo mejor puntaje! 🏆'
                : 'Mejor puntaje: $_bestEcoScore/100',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
        const SizedBox(height: 28),
        Card(
          color: AppTheme.primaryGreen.withValues(alpha: 0.08),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Cada pequeña decisión suma: reutilizar, reciclar y consumir con conciencia son elecciones que están a tu alcance todos los días.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
        const SizedBox(height: 24),
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
