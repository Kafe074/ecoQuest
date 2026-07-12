import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, FontWeight, TextStyle;

import 'station_data.dart';

/// Purely decorative props scattered around each station, themed to hint
/// at that minigame before the player even opens it: little trees and a
/// globe near the impact simulator, recycling bins near waste sorting, a
/// question-mark signpost near the quiz, and face-down cards near memory.
class StationSceneryComponent extends PositionComponent {
  StationSceneryComponent() : super(position: Vector2.zero(), size: kWorldSize, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    for (final station in kStations) {
      final base = station.position.toOffset();
      switch (station.id) {
        case 'impact':
          _renderImpactProps(canvas, base);
        case 'waste':
          _renderWasteProps(canvas, base);
        case 'quiz':
          _renderQuizProps(canvas, base);
        case 'memory':
          _renderMemoryProps(canvas, base);
      }
    }
  }

  void _renderImpactProps(Canvas canvas, Offset base) {
    _drawMiniTree(canvas, base + const Offset(-95, 45));
    _drawMiniTree(canvas, base + const Offset(95, 50), scale: 0.85);
    _drawGlobeOnStand(canvas, base + const Offset(0, 95));
  }

  void _drawMiniTree(Canvas canvas, Offset base, {double scale = 1.0}) {
    canvas.drawOval(
      Rect.fromCenter(center: base + Offset(0, 5 * scale), width: 22 * scale, height: 9 * scale),
      Paint()..color = const Color(0x2E000000),
    );
    canvas.drawRect(
      Rect.fromCenter(center: base, width: 5 * scale, height: 14 * scale),
      Paint()..color = const Color(0xFF6B4A2F),
    );
    canvas.drawCircle(base + Offset(0, -11 * scale), 11 * scale, Paint()..color = const Color(0xFF3E7D3A));
    canvas.drawCircle(base + Offset(-6 * scale, -15 * scale), 7 * scale, Paint()..color = const Color(0xFF4E9A47));
  }

  void _drawGlobeOnStand(Canvas canvas, Offset base) {
    canvas.drawOval(
      Rect.fromCenter(center: base + const Offset(0, 4), width: 20, height: 7),
      Paint()..color = const Color(0x2E000000),
    );
    canvas.drawRect(
      Rect.fromCenter(center: base + const Offset(0, -4), width: 4, height: 16),
      Paint()..color = const Color(0xFF8A8A8A),
    );
    canvas.drawCircle(base + const Offset(0, -18), 12, Paint()..color = const Color(0xFF3F8FDB));
    canvas.drawCircle(base + const Offset(-4, -22), 5, Paint()..color = const Color(0xFF4EA84A));
    canvas.drawCircle(base + const Offset(4, -14), 4, Paint()..color = const Color(0xFF4EA84A));
    canvas.drawCircle(
      base + const Offset(0, -18),
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x55FFFFFF),
    );
  }

  void _renderWasteProps(Canvas canvas, Offset base) {
    _drawBin(canvas, base + const Offset(-85, 60), const Color(0xFF3F7FDB), '♻️');
    _drawBin(canvas, base + const Offset(0, 100), const Color(0xFF4E9A47), '🍂');
    _drawBin(canvas, base + const Offset(85, 60), const Color(0xFFE0B23C), '🧴');
  }

  void _drawBin(Canvas canvas, Offset base, Color color, String icon) {
    canvas.drawOval(
      Rect.fromCenter(center: base + const Offset(0, 15), width: 24, height: 8),
      Paint()..color = const Color(0x2E000000),
    );
    final bodyRect = Rect.fromCenter(center: base + const Offset(0, 4), width: 22, height: 24);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)), Paint()..color = color);
    canvas.drawRect(
      Rect.fromCenter(center: base + const Offset(0, -9), width: 26, height: 5),
      Paint()..color = Color.lerp(color, Colors.black, 0.2)!,
    );
    TextPaint(style: const TextStyle(fontSize: 12))
        .render(canvas, icon, Vector2(base.dx, base.dy + 4), anchor: Anchor.center);
  }

  void _renderQuizProps(Canvas canvas, Offset base) {
    _drawSignpost(canvas, base + const Offset(0, -95));
    _drawBookStack(canvas, base + const Offset(85, 65));
  }

  void _drawSignpost(Canvas canvas, Offset base) {
    canvas.drawRect(
      Rect.fromCenter(center: base + const Offset(0, 10), width: 4, height: 24),
      Paint()..color = const Color(0xFF6B4A2F),
    );
    final boardRect = Rect.fromCenter(center: base + const Offset(0, -8), width: 30, height: 22);
    canvas.drawRRect(RRect.fromRectAndRadius(boardRect, const Radius.circular(4)), Paint()..color = const Color(0xFF6B4A2F));
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect.deflate(3), const Radius.circular(3)),
      Paint()..color = Colors.orange.shade200,
    );
    TextPaint(
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
    ).render(canvas, '?', Vector2(base.dx, base.dy - 8), anchor: Anchor.center);
  }

  void _drawBookStack(Canvas canvas, Offset base) {
    const colors = [Color(0xFFB3542E), Color(0xFF3F7FDB), Color(0xFF4E9A47)];
    canvas.drawOval(
      Rect.fromCenter(center: base + const Offset(0, 13), width: 26, height: 8),
      Paint()..color = const Color(0x2E000000),
    );
    for (var i = 0; i < colors.length; i++) {
      final y = base.dy + 8 - i * 6.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(base.dx, y), width: 26 - i * 2, height: 7),
          const Radius.circular(1.5),
        ),
        Paint()..color = colors[i],
      );
    }
  }

  void _renderMemoryProps(Canvas canvas, Offset base) {
    _drawCard(canvas, base + const Offset(-85, 65), angle: -0.25);
    _drawCard(canvas, base + const Offset(0, 100), angle: 0.05);
    _drawCard(canvas, base + const Offset(85, 60), angle: 0.3);
  }

  void _drawCard(Canvas canvas, Offset base, {required double angle}) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 4), width: 22, height: 8),
      Paint()..color = const Color(0x2E000000),
    );
    final cardRect = Rect.fromCenter(center: Offset.zero, width: 18, height: 24);
    canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(3)), Paint()..color = Colors.purple.shade300);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cardRect.deflate(2.5), const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    TextPaint(style: const TextStyle(fontSize: 11)).render(canvas, '🧩', Vector2.zero(), anchor: Anchor.center);
    canvas.restore();
  }
}
