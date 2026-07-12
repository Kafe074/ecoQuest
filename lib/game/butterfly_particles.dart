import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import 'world_game.dart';

/// Ambient wildlife: occasionally sends a butterfly drifting across the
/// screen. Lives in screen space (added to `camera.viewport`), same
/// approach as [LeafSpawnerComponent], just horizontal instead of falling.
class ButterflySpawnerComponent extends Component with HasGameReference<WorldGame> {
  final math.Random _random = math.Random();
  double _timeUntilNextButterfly = 4;

  static const _butterflyColors = [
    Color(0xFFE9967A),
    Color(0xFFEED202),
    Color(0xFFB0A8E8),
  ];

  @override
  void update(double dt) {
    super.update(dt);
    _timeUntilNextButterfly -= dt;
    if (_timeUntilNextButterfly <= 0) {
      _spawnButterfly();
      _timeUntilNextButterfly = 8 + _random.nextDouble() * 10;
    }
  }

  void _spawnButterfly() {
    final viewportSize = game.size;
    final fromLeft = _random.nextBool();
    final startY = viewportSize.y * (0.15 + _random.nextDouble() * 0.55);
    final startX = fromLeft ? -20.0 : viewportSize.x + 20;
    final travelDistance = viewportSize.x + 40;
    final direction = fromLeft ? 1.0 : -1.0;
    final bobHeight = 12 + _random.nextDouble() * 10;
    final color = _butterflyColors[_random.nextInt(_butterflyColors.length)];
    final lifespan = 6 + _random.nextDouble() * 3;
    final flapSpeed = 10 + _random.nextDouble() * 4;

    parent?.add(
      ParticleSystemComponent(
        position: Vector2(startX, startY),
        particle: ComputedParticle(
          lifespan: lifespan,
          renderer: (canvas, particle) {
            final progress = particle.progress;
            final dx = travelDistance * progress * direction;
            final dy = math.sin(progress * math.pi * 4) * bobHeight;
            final flap = math.sin(progress * lifespan * flapSpeed).abs();
            final opacity = progress < 0.9 ? 1.0 : (1 - progress) / 0.1;

            canvas.save();
            canvas.translate(dx, dy);
            final paint = Paint()..color = color.withValues(alpha: opacity * 0.9);
            // Two wings that scale horizontally to fake a flapping motion.
            canvas.save();
            canvas.scale(0.3 + flap * 0.7, 1);
            canvas.drawOval(const Rect.fromLTWH(-6, -5, 6, 5), paint);
            canvas.drawOval(const Rect.fromLTWH(-6, 0, 6, 5), paint);
            canvas.restore();
            canvas.save();
            canvas.scale(0.3 + flap * 0.7, 1);
            canvas.drawOval(const Rect.fromLTWH(0, -5, 6, 5), paint);
            canvas.drawOval(const Rect.fromLTWH(0, 0, 6, 5), paint);
            canvas.restore();
            canvas.restore();
          },
        ),
      ),
    );
  }
}
