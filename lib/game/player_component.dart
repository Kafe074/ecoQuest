import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'character_visual.dart';
import 'scenery_component.dart';
import 'sfx.dart';
import 'station_data.dart';
import 'world_game.dart';

class PlayerComponent extends PositionComponent
    with CollisionCallbacks, KeyboardHandler, HasGameReference<WorldGame> {
  PlayerComponent({super.position})
      : super(size: Vector2.all(32), anchor: Anchor.center);

  static const double speed = 220;
  static const double _collisionRadius = 14;
  static const double _walkAnimationSpeed = 9;
  static const double _dustInterval = 0.16;
  static const double _footstepInterval = 0.34;

  final Vector2 _keyboardDirection = Vector2.zero();
  final math.Random _random = math.Random();
  double _bobTime = 0;
  double _dustCooldown = 0;
  double _footstepCooldown = 0;
  bool _isMoving = false;
  CharacterFacing _facing = CharacterFacing.down;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: _collisionRadius));
  }

  /// Pushes the player back out of any house it's overlapping. Houses are
  /// purely decorative (see [SceneryComponent]), so this is plain manual
  /// circle-vs-circle resolution rather than Flame's collision system,
  /// which we deliberately use for proximity detection only elsewhere.
  void _resolveHouseCollisions() {
    for (final house in kHouseObstacles) {
      final delta = position - house;
      final distance = delta.length;
      final minDistance = _collisionRadius + kHouseObstacleRadius;
      if (distance > 0 && distance < minDistance) {
        position.add(delta.normalized() * (minDistance - distance));
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final joystick = game.joystick;
    final moveVector = joystick.direction != JoystickDirection.idle
        ? joystick.relativeDelta
        : _keyboardDirection;

    _isMoving = moveVector.x != 0 || moveVector.y != 0;
    if (_isMoving) {
      final direction = moveVector.normalized();
      position.x = (position.x + direction.x * speed * dt)
          .clamp(size.x / 2, kWorldSize.x - size.x / 2);
      position.y = (position.y + direction.y * speed * dt)
          .clamp(size.y / 2, kWorldSize.y - size.y / 2);
      _resolveHouseCollisions();
      _bobTime += dt * _walkAnimationSpeed;

      _facing = direction.x.abs() > direction.y.abs()
          ? (direction.x > 0 ? CharacterFacing.right : CharacterFacing.left)
          : (direction.y > 0 ? CharacterFacing.down : CharacterFacing.up);

      _dustCooldown -= dt;
      if (_dustCooldown <= 0) {
        _spawnDustPuff();
        _dustCooldown = _dustInterval;
      }

      _footstepCooldown -= dt;
      if (_footstepCooldown <= 0) {
        Sfx.footstep();
        _footstepCooldown = _footstepInterval;
      }
    } else {
      _bobTime = 0;
    }
  }

  void _spawnDustPuff() {
    final offset = Vector2((_random.nextDouble() - 0.5) * 6, size.y * 0.42);
    parent?.add(
      ParticleSystemComponent(
        position: position + offset,
        particle: ComputedParticle(
          lifespan: 0.4,
          renderer: (canvas, particle) {
            final progress = particle.progress;
            final radius = 2.5 + progress * 4;
            final opacity = (1 - progress) * 0.35;
            canvas.drawCircle(
              Offset.zero,
              radius,
              Paint()..color = const Color(0xFF7A5C3E).withValues(alpha: opacity),
            );
          },
        ),
      ),
    );
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboardDirection.setValues(0, 0);
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      _keyboardDirection.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS)) {
      _keyboardDirection.y += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _keyboardDirection.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      _keyboardDirection.x += 1;
    }

    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.enter)) {
      game.interact();
    }
    return true;
  }

  // Single, isolated placeholder-rendering method: swap this for a
  // SpriteComponent later without touching movement/collision logic.
  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();
    CharacterVisual.render(
      canvas,
      center: center,
      torsoPaint: Paint()
        ..shader = ui.Gradient.radial(
          center + const Offset(-6, -20),
          26,
          [AppTheme.accentGreen, AppTheme.primaryGreen],
        ),
      limbColor: AppTheme.primaryGreen,
      walkPhase: _bobTime,
      isMoving: _isMoving,
      facing: _facing,
      scale: 1.15,
    );
  }
}
