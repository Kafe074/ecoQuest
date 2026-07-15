import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';
import '../theme/eco_textures.dart';

/// Centered modal shell for the "card sized" minigames (quiz and impact
/// simulator): a fitted clay card with a compact gradient header and a
/// close button, floating over the dimmed world instead of a full screen
/// full of empty space. Content taller than the card scrolls internally.
///
/// Push the screen with [modalRoute] so the world stays visible behind the
/// barrier.
class GameModal extends StatelessWidget {
  const GameModal({
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

  /// Transparent route with a dimmed barrier and a soft scale-in, so the
  /// modal appears over the world instead of replacing it.
  static Route<void> modalRoute(Widget Function() builder) {
    return PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (_, _, _) => builder(),
      transitionsBuilder: (_, animation, _, page) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(curved), child: page),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final darker = AppTheme.darken(color, 0.30);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: AppTheme.clayDecoration(
                  surface: Colors.white,
                  edge: darker.withValues(alpha: 0.5),
                  radius: 26,
                  depth: 5,
                  borderColor: Colors.white.withValues(alpha: 0.7),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.lighten(color, 0.08), darker],
                        ),
                      ),
                      child: CustomPaint(
                        foregroundPainter: LeafScatterPainter(
                          color: Colors.white.withValues(alpha: 0.08),
                          density: 0.35,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    width: 1.4,
                                  ),
                                ),
                                child: PhosphorIcon(icon, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            height: 1.1,
                                          ),
                                    ),
                                    if (subtitle != null)
                                      Text(
                                        subtitle!,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.88),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).maybePop(),
                                tooltip: 'Cerrar',
                                icon: const PhosphorIcon(
                                  PhosphorIconsBold.x,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
