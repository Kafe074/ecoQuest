import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart' show IconData;

import 'icon_paint.dart';

enum CharacterFacing { up, down, left, right }

/// Shared humanoid placeholder renderer used by both [PlayerComponent] and
/// [NpcComponent]: a small body with legs/arms that swing while walking, a
/// head with eyes that shift to show facing, and an optional icon badge
/// for personality. Centralized here so both characters stay visually
/// consistent and any future sprite swap only touches one file.
class CharacterVisual {
  CharacterVisual._();

  static const Color skinTone = Color(0xFFF2C9A0);
  static const Color _eyeColor = Color(0xFF2D2A26);

  static void render(
    Canvas canvas, {
    required Offset center,
    required Paint torsoPaint,
    required Color limbColor,
    required double walkPhase,
    required bool isMoving,
    required CharacterFacing facing,
    IconData? badgeIcon,
    Color badgeColor = const Color(0xFF2E7D32),
    double scale = 1.0,
  }) {
    final legSwing = isMoving ? math.sin(walkPhase) * 4 * scale : 0.0;
    final armSwing = isMoving ? -math.sin(walkPhase) * 3 * scale : 0.0;
    final bodyBounce = isMoving ? math.sin(walkPhase * 2).abs() * 1.2 * scale : 0.0;

    final torsoTop = center + Offset(0, -6 * scale - bodyBounce);
    final torsoBottom = center + Offset(0, 8 * scale - bodyBounce);
    final headCenter = center + Offset(0, -16 * scale - bodyBounce);
    final limbPaint = Paint()..color = limbColor;

    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(0, 15 * scale), width: 18 * scale, height: 6 * scale),
      Paint()..color = const Color(0x33000000),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: torsoBottom + Offset(-4 * scale, 6 * scale + legSwing),
          width: 5 * scale,
          height: 12 * scale,
        ),
        Radius.circular(2.5 * scale),
      ),
      limbPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: torsoBottom + Offset(4 * scale, 6 * scale - legSwing),
          width: 5 * scale,
          height: 12 * scale,
        ),
        Radius.circular(2.5 * scale),
      ),
      limbPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - 9 * scale, torsoTop.dy + 6 * scale + armSwing),
          width: 4 * scale,
          height: 10 * scale,
        ),
        Radius.circular(2 * scale),
      ),
      limbPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + 9 * scale, torsoTop.dy + 6 * scale - armSwing),
          width: 4 * scale,
          height: 10 * scale,
        ),
        Radius.circular(2 * scale),
      ),
      limbPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(torsoTop - Offset(8 * scale, 0), torsoBottom + Offset(8 * scale, 0)),
        Radius.circular(7 * scale),
      ),
      torsoPaint,
    );

    canvas.drawCircle(headCenter, 9 * scale, Paint()..color = skinTone);
    canvas.drawCircle(
      headCenter,
      9 * scale,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x33000000),
    );

    final eyeOffset = switch (facing) {
      CharacterFacing.up => const Offset(0, -2),
      CharacterFacing.down => const Offset(0, 1),
      CharacterFacing.left => const Offset(-2, 0),
      CharacterFacing.right => const Offset(2, 0),
    };
    final eyePaint = Paint()..color = _eyeColor;
    canvas.drawCircle(headCenter + Offset(-3, -1) * scale + eyeOffset * scale, 1.3 * scale, eyePaint);
    canvas.drawCircle(headCenter + Offset(3, -1) * scale + eyeOffset * scale, 1.3 * scale, eyePaint);

    if (badgeIcon != null) {
      final badgeCenter = Offset(headCenter.dx + 10 * scale, headCenter.dy - 9 * scale);
      canvas.drawCircle(badgeCenter, 7.5 * scale, Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawCircle(
        badgeCenter,
        7.5 * scale,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = badgeColor.withValues(alpha: 0.55),
      );
      renderIcon(
        canvas,
        badgeIcon,
        position: Vector2(badgeCenter.dx, badgeCenter.dy),
        size: 10 * scale,
        color: badgeColor,
      );
    }
  }
}
