import 'package:flutter/material.dart';

/// One numeric result shown on the ending screen's stats card.
class EndingStat {
  const EndingStat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;
}

/// Shared celebration screen shown when a minigame ends: animated emoji
/// badge, verdict, stats card, best-score badge and the restart/exit buttons.
class GameEndingView extends StatelessWidget {
  const GameEndingView({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
    required this.color,
    this.stats = const [],
    this.bestText,
    this.isNewBest = false,
    this.extra,
    required this.onRestart,
  });

  final String emoji;
  final String title;
  final String message;
  final Color color;
  final List<EndingStat> stats;

  /// e.g. '¡Nuevo mejor puntaje! 🏆' or 'Mejor puntaje: 80%'.
  final String? bestText;
  final bool isNewBest;

  /// Optional game-specific content (e.g. the impact simulator's stat bars).
  final Widget? extra;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final darker = Color.lerp(color, Colors.black, 0.25)!;
    return ListView(
      children: [
        const SizedBox(height: 16),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: Container(
              width: 110,
              height: 110,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.85), darker],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 52)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 15, height: 1.45),
        ),
        if (stats.isNotEmpty) ...[
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
            child: Row(
              children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0)
                    Container(width: 1, height: 36, color: Colors.grey.shade200),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(stats[i].icon, color: color, size: 20),
                        const SizedBox(height: 6),
                        Text(
                          stats[i].value,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stats[i].label,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (bestText != null) ...[
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isNewBest ? Colors.amber.withValues(alpha: 0.18) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isNewBest ? Colors.amber.shade600 : Colors.grey.shade300,
                ),
              ),
              child: Text(
                bestText!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isNewBest ? Colors.amber.shade900 : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
        if (extra != null) ...[
          const SizedBox(height: 22),
          extra!,
        ],
        const SizedBox(height: 26),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: onRestart,
          icon: const Icon(Icons.replay_rounded),
          label: const Text(
            'Jugar de nuevo',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: darker,
            side: BorderSide(color: color.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.map_outlined),
          label: const Text(
            'Volver al mundo',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
