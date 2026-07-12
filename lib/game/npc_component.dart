import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, FontWeight, TextStyle;

import 'character_visual.dart';
import 'npc_data.dart';
import 'player_component.dart';
import 'world_game.dart';

/// A wandering NPC: walks to random points within [NpcData.leashRadius] of
/// its home, pauses, then picks a new point. Interaction works the same way
/// as [StationComponent] (proximity hitbox + explicit interact), but talking
/// to an NPC shows a message instead of opening a minigame.
class NpcComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<WorldGame> {
  NpcComponent({required this.data})
      : super(
          position: data.homePosition.clone(),
          size: Vector2.all(interactionRadius * 2),
          anchor: Anchor.center,
        );

  final NpcData data;

  static const double labelOffset = 24;
  static const double interactionRadius = 55;
  static const double _speed = 45;
  static const double _walkAnimationSpeed = 7;

  final math.Random _random = math.Random();
  Vector2? _target;
  double _waitTimer = 0;
  double _bobTime = 0;
  bool _isMoving = false;
  CharacterFacing _facing = CharacterFacing.down;

  @override
  Future<void> onLoad() async {
    add(
      CircleHitbox(radius: interactionRadius, isSolid: true)
        ..collisionType = CollisionType.passive,
    );
    _waitTimer = _random.nextDouble() * 2;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final target = _target;
    if (target == null) {
      _waitTimer -= dt;
      _isMoving = false;
      if (_waitTimer <= 0) _pickNewTarget();
      return;
    }

    final toTarget = target - position;
    final distance = toTarget.length;
    if (distance < 4) {
      _target = null;
      _waitTimer = 1 + _random.nextDouble() * 2.5;
      _isMoving = false;
      return;
    }

    _isMoving = true;
    final direction = toTarget.normalized();
    final step = direction * math.min(_speed * dt, distance);
    position.add(step);
    _bobTime += dt * _walkAnimationSpeed;

    _facing = direction.x.abs() > direction.y.abs()
        ? (direction.x > 0 ? CharacterFacing.right : CharacterFacing.left)
        : (direction.y > 0 ? CharacterFacing.down : CharacterFacing.up);
  }

  void _pickNewTarget() {
    final angle = _random.nextDouble() * math.pi * 2;
    final distance = _random.nextDouble() * data.leashRadius;
    _target = data.homePosition + Vector2(math.cos(angle), math.sin(angle)) * distance;
  }

  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();
    CharacterVisual.render(
      canvas,
      center: center,
      torsoPaint: Paint()..color = data.color,
      limbColor: Color.lerp(data.color, Colors.black, 0.25)!,
      walkPhase: _bobTime,
      isMoving: _isMoving,
      facing: _facing,
      badgeEmoji: data.emoji,
      scale: 0.85,
    );
    TextPaint(
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
    ).render(
      canvas,
      data.name,
      Vector2(center.dx, center.dy + labelOffset),
      anchor: Anchor.topCenter,
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) game.setNearbyNpc(data);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is PlayerComponent) game.clearNearbyNpc(data);
  }
}
