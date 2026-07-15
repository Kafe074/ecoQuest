import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';
import '../theme/eco_textures.dart';

/// Shared shell for every minigame screen: a textured gradient header with a
/// clay icon badge and title, over a softly tinted body. This replaces the
/// classic [AppBar] so all games share the same claymorphism look.
class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final darker = AppTheme.darken(color, 0.30);
    return Scaffold(
      backgroundColor: Color.lerp(AppTheme.cream, color, 0.04),
      body: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.lighten(color, 0.08), darker],
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: AppTheme.darken(color, 0.45), offset: const Offset(0, 4)),
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: CustomPaint(
                foregroundPainter: LeafScatterPainter(
                  color: Colors.white.withValues(alpha: 0.08),
                  density: 0.30,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 16, 14),
                    child: Row(
                      children: [
                        const BackButton(color: Colors.white),
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.55),
                              width: 1.6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.darken(color, 0.35)
                                    .withValues(alpha: 0.6),
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: PhosphorIcon(icon, color: Colors.white, size: 23),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                              ),
                              if (subtitle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    subtitle!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.88),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: LeafScatterPainter(
                color: color.withValues(alpha: 0.045),
                seed: 21,
                density: 0.10,
                minSize: 14,
                maxSize: 24,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small clay pill for game HUDs (score, time, moves).
class HudChip extends StatelessWidget {
  const HudChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: AppTheme.clayDecoration(
        surface: Colors.white,
        edge: color.withValues(alpha: 0.35),
        radius: 999,
        depth: 3,
        borderColor: color.withValues(alpha: 0.25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(icon, size: 17, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: AppTheme.darken(color, 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chunky rounded progress bar with a caption below, shared by all games.
class GameProgressBar extends StatelessWidget {
  const GameProgressBar({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  final double value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.20)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              widthFactor: value.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.lighten(color, 0.25), color],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppTheme.fadedInk, fontSize: 12)),
      ],
    );
  }
}
