import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import 'world_game.dart';

/// Ambient effect: periodically drops a leaf from the top of the screen.
/// Lives in screen space (added to `camera.viewport`) so leaves keep
/// drifting down regardless of where the player is in the world.
class LeafSpawnerComponent extends Component with HasGameReference<WorldGame> {
  final math.Random _random = math.Random();
  double _timeUntilNextLeaf = 0;

  static const _leafColors = [
    Color(0xFF6B8E23),
    Color(0xFFCC7722),
    Color(0xFFB8860B),
  ];

  @override
  void update(double dt) {
    super.update(dt);
    _timeUntilNextLeaf -= dt;
    if (_timeUntilNextLeaf <= 0) {
      _spawnLeaf();
      _timeUntilNextLeaf = 0.9 + _random.nextDouble() * 1.4;
    }
  }

  void _spawnLeaf() {
    final viewportSize = game.size;
    final startX = _random.nextDouble() * viewportSize.x;
    final fallDistance = viewportSize.y + 40;
    final horizontalDrift = 30 + _random.nextDouble() * 40;
    final swayDirection = _random.nextBool() ? 1.0 : -1.0;
    final spinDirection = _random.nextBool() ? 1.0 : -1.0;
    final color = _leafColors[_random.nextInt(_leafColors.length)];
    final lifespan = 4 + _random.nextDouble() * 3;

    parent?.add(
      ParticleSystemComponent(
        position: Vector2(startX, -20),
        particle: ComputedParticle(
          lifespan: lifespan,
          renderer: (canvas, particle) {
            final progress = particle.progress;
            final dy = fallDistance * progress;
            final dx = math.sin(progress * math.pi * 3) * horizontalDrift * swayDirection;
            final opacity = progress < 0.85 ? 1.0 : (1 - progress) / 0.15;
            canvas.save();
            canvas.translate(dx, dy);
            canvas.rotate(progress * math.pi * 4 * spinDirection);
            canvas.drawOval(
              Rect.fromCenter(center: Offset.zero, width: 9, height: 5),
              Paint()..color = color.withValues(alpha: opacity * 0.85),
            );
            canvas.restore();
          },
        ),
      ),
    );
  }
}
