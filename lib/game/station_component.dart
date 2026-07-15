import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../services/score_service.dart';
import 'icon_paint.dart';
import 'player_component.dart';
import 'station_data.dart';
import 'world_game.dart';

class StationComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<WorldGame> {
  StationComponent({required this.data})
      : super(
          position: data.position,
          size: Vector2.all(interactionRadius * 2),
          anchor: Anchor.center,
        );

  final StationData data;

  static const double visualRadius = 26;
  static const double interactionRadius = 70;
  static const double _pulsePeriod = 1.8;

  double _pulseTime = 0;
  bool _isPlayed = false;

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime = (_pulseTime + dt) % _pulsePeriod;
  }

  @override
  Future<void> onLoad() async {
    // isSolid: the player's small hitbox is fully contained within this
    // interaction radius rather than crossing its edge, and Flame's
    // circle-circle intersection only reports a collision for full
    // containment when the outer circle is solid.
    add(
      CircleHitbox(radius: interactionRadius, isSolid: true)
        ..collisionType = CollisionType.passive,
    );
    unawaited(refreshPlayed());
  }

  Future<void> refreshPlayed() async {
    final best = await ScoreService.getBest(data.scoreKey);
    _isPlayed = best != null;
  }

  // Isolated placeholder-rendering method: same swap point as the player.
  @override
  void render(Canvas canvas) {
    final center = size / 2;
    final centerOffset = center.toOffset();

    // Pulsing "beacon" ring hinting that the station is interactive.
    final pulseProgress = _pulseTime / _pulsePeriod;
    canvas.drawCircle(
      centerOffset,
      visualRadius + pulseProgress * 18,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = data.color.withValues(alpha: (1 - pulseProgress) * 0.5),
    );

    // Pedestal: a small platform the station circle rests on.
    final pedestalCenter = Offset(centerOffset.dx, centerOffset.dy + visualRadius * 0.95);
    canvas.drawOval(
      Rect.fromCenter(center: pedestalCenter, width: visualRadius * 2.1, height: visualRadius * 0.7),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: pedestalCenter,
        width: visualRadius * 1.9,
        height: visualRadius * 0.55,
      ),
      Paint()..color = const Color(0xFF9C7A4F),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: pedestalCenter - const Offset(0, 2),
        width: visualRadius * 1.7,
        height: visualRadius * 0.4,
      ),
      Paint()..color = const Color(0xFFB8935F),
    );

    canvas.drawCircle(
      centerOffset,
      visualRadius,
      Paint()
        ..shader = ui.Gradient.radial(
          centerOffset - Offset(visualRadius * 0.35, visualRadius * 0.35),
          visualRadius * 1.4,
          [
            Color.lerp(data.color, Colors.white, 0.35)!,
            Color.lerp(data.color, Colors.black, 0.15)!,
          ],
        ),
    );
    canvas.drawCircle(
      centerOffset,
      visualRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white,
    );
    renderIcon(
      canvas,
      data.icon,
      position: center,
      size: 26,
      color: Colors.white,
    );
    TextPaint(
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ).render(
      canvas,
      data.title,
      Vector2(center.x, center.y + visualRadius + 6),
      anchor: Anchor.topCenter,
    );

    if (_isPlayed) {
      final badgeCenter = centerOffset + Offset(visualRadius * 0.72, -visualRadius * 0.72);
      canvas.drawCircle(badgeCenter, 10, Paint()..color = Colors.white);
      canvas.drawCircle(
        badgeCenter,
        10,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.amber.shade700,
      );
      renderIcon(
        canvas,
        PhosphorIconsFill.star,
        position: Vector2(badgeCenter.dx, badgeCenter.dy),
        size: 13,
        color: Colors.amber.shade600,
      );
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) game.setNearbyStation(data);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is PlayerComponent) game.clearNearbyStation(data);
  }
}
