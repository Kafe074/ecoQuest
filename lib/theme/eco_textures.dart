import 'dart:math';

import 'package:flutter/material.dart';

/// Procedural texture painters shared across the app so surfaces never look
/// flat: dotted grids for headers, scattered leaves for backdrops and soft
/// blob circles for hero areas. All of them are deterministic (seeded) and
/// cheap to paint, so they can live behind static content without a
/// RepaintBoundary.

/// Subtle polka-dot grid, offset every other row like fabric weave.
class DotGridPainter extends CustomPainter {
  const DotGridPainter({
    required this.color,
    this.spacing = 22,
    this.dotRadius = 1.6,
  });

  final Color color;
  final double spacing;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    var row = 0;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      final shift = row.isOdd ? spacing / 2 : 0.0;
      for (var x = spacing / 2 + shift; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(DotGridPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.spacing != spacing ||
      oldDelegate.dotRadius != dotRadius;
}

/// Scattered rotated leaf silhouettes; density is leaves per 10k px².
class LeafScatterPainter extends CustomPainter {
  const LeafScatterPainter({
    required this.color,
    this.seed = 7,
    this.density = 0.16,
    this.minSize = 9,
    this.maxSize = 17,
  });

  final Color color;
  final int seed;
  final double density;
  final double minSize;
  final double maxSize;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint()..color = color;
    final count = (size.width * size.height / 10000 * density).ceil();
    for (var i = 0; i < count; i++) {
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final leafSize = minSize + random.nextDouble() * (maxSize - minSize);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(random.nextDouble() * 2 * pi);
      _drawLeaf(canvas, leafSize, paint);
      canvas.restore();
    }
  }

  void _drawLeaf(Canvas canvas, double size, Paint paint) {
    final path = Path()
      ..moveTo(0, -size / 2)
      ..quadraticBezierTo(size * 0.42, -size * 0.1, 0, size / 2)
      ..quadraticBezierTo(-size * 0.42, -size * 0.1, 0, -size / 2)
      ..close();
    canvas.drawPath(path, paint);
    // Central vein, slightly darker.
    canvas.drawLine(
      Offset(0, -size * 0.32),
      Offset(0, size * 0.36),
      Paint()
        ..color = paint.color.withValues(alpha: paint.color.a * 0.8)
        ..strokeWidth = size * 0.07
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(LeafScatterPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.seed != seed ||
      oldDelegate.density != density;
}

/// A few big translucent circles bleeding off the edges, for hero headers.
class SoftBlobsPainter extends CustomPainter {
  const SoftBlobsPainter({required this.color, this.seed = 3});

  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    for (var i = 0; i < 4; i++) {
      final radius = size.shortestSide * (0.5 + random.nextDouble() * 0.6);
      final center = Offset(
        random.nextDouble() * size.width,
        (random.nextDouble() - 0.15) * size.height,
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = color.withValues(alpha: 0.05 + random.nextDouble() * 0.05),
      );
    }
  }

  @override
  bool shouldRepaint(SoftBlobsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.seed != seed;
}

/// Little grass tufts along a horizontal strip, used for river banks and
/// ground edges instead of emoji props.
class GrassFringePainter extends CustomPainter {
  const GrassFringePainter({
    required this.color,
    this.seed = 11,
    this.pointsUp = true,
  });

  final Color color;
  final int seed;

  /// Whether blades grow upwards (bottom bank) or downwards (top bank).
  final bool pointsUp;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final baseY = pointsUp ? size.height : 0.0;
    final direction = pointsUp ? -1.0 : 1.0;
    for (var x = 6.0; x < size.width; x += 9 + random.nextDouble() * 14) {
      final height = 7 + random.nextDouble() * 9;
      final lean = (random.nextDouble() - 0.5) * 6;
      canvas.drawLine(
        Offset(x, baseY),
        Offset(x + lean, baseY + direction * height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GrassFringePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.seed != seed ||
      oldDelegate.pointsUp != pointsUp;
}
