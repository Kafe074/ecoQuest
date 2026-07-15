import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';

/// One numeric result shown on the ending screen's stats card.
class EndingStat {
  const EndingStat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;
}

/// Shared celebration screen shown when a minigame ends: animated clay icon
/// badge, verdict, stats card, best-score badge and the restart/exit buttons.
class GameEndingView extends StatelessWidget {
  const GameEndingView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    this.stats = const [],
    this.bestText,
    this.isNewBest = false,
    this.extra,
    this.compact = false,
    required this.onRestart,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final List<EndingStat> stats;

  /// e.g. '¡Nuevo mejor puntaje!' or 'Mejor puntaje: 80%'. Rendered with a
  /// trophy icon when [isNewBest] is true.
  final String? bestText;
  final bool isNewBest;

  /// Optional game-specific content (e.g. the impact simulator's stat bars).
  final Widget? extra;

  /// When true the view sizes itself to its content and never scrolls,
  /// for hosts that provide their own scrolling (e.g. [GameModal]).
  final bool compact;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final darker = AppTheme.darken(color, 0.25);
    return ListView(
      shrinkWrap: compact,
      physics: compact ? const NeverScrollableScrollPhysics() : null,
      children: [
        SizedBox(height: compact ? 4 : 16),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: Container(
              width: 116,
              height: 116,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.lighten(color, 0.15), darker],
                ),
                borderRadius: BorderRadius.circular(38),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.65),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(color: AppTheme.darken(color, 0.4), offset: const Offset(0, 6)),
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: PhosphorIcon(icon, size: 56, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.fadedInk, fontSize: 15, height: 1.45),
        ),
        if (stats.isNotEmpty) ...[
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: AppTheme.claySurface(tint: color),
            child: Row(
              children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0)
                    Container(width: 1, height: 36, color: Colors.grey.shade200),
                  Expanded(
                    child: Column(
                      children: [
                        PhosphorIcon(stats[i].icon, color: color, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          stats[i].value,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stats[i].label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: AppTheme.fadedInk),
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
              decoration: AppTheme.clayDecoration(
                surface: isNewBest ? const Color(0xFFFFF3D6) : Colors.grey.shade100,
                edge: isNewBest
                    ? Colors.amber.withValues(alpha: 0.55)
                    : Colors.grey.withValues(alpha: 0.35),
                radius: 999,
                depth: 3,
                borderColor: isNewBest ? Colors.amber.shade600 : Colors.grey.shade300,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhosphorIcon(
                    isNewBest ? PhosphorIconsFill.trophy : PhosphorIconsBold.medal,
                    size: 16,
                    color: isNewBest ? Colors.amber.shade800 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    bestText!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isNewBest ? Colors.amber.shade900 : Colors.grey.shade700,
                    ),
                  ),
                ],
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
          icon: const PhosphorIcon(PhosphorIconsBold.arrowCounterClockwise, size: 20),
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
          icon: const PhosphorIcon(PhosphorIconsBold.mapTrifold, size: 20),
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
