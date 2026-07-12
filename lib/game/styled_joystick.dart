import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A [JoystickComponent] styled with gradients and direction ticks instead
/// of Flame's default flat-colored circles.
JoystickComponent buildStyledJoystick({required EdgeInsets margin}) {
  return JoystickComponent(
    knob: _JoystickKnob(),
    background: _JoystickBackground(),
    margin: margin,
  );
}

class _JoystickBackground extends PositionComponent {
  _JoystickBackground() : super(size: Vector2.all(100), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();
    const radius = 50.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(center, radius, [
          const Color(0x66000000),
          const Color(0x22000000),
        ]),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x66FFFFFF),
    );

    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final tickStart = center + Offset(math.cos(angle), math.sin(angle)) * (radius - 12);
      final tickEnd = center + Offset(math.cos(angle), math.sin(angle)) * (radius - 4);
      canvas.drawLine(
        tickStart,
        tickEnd,
        Paint()
          ..color = const Color(0x99FFFFFF)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

class _JoystickKnob extends PositionComponent {
  _JoystickKnob() : super(size: Vector2.all(40), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();
    const radius = 20.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(center - const Offset(6, 6), radius * 1.4, [
          Colors.white,
          AppTheme.accentGreen,
        ]),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppTheme.primaryGreen,
    );
  }
}
