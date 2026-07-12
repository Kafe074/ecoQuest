import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'station_data.dart';

/// Solid footprint of each house, for [PlayerComponent] to collide against.
/// Kept here (next to the matching visuals) rather than duplicated.
final List<Vector2> kHouseObstacles = [
  Vector2(580, 430),
  Vector2(1020, 430),
  Vector2(580, 770),
  Vector2(1020, 770),
];
const double kHouseObstacleRadius = 30;

/// Purely decorative, static layer: dirt paths connecting the plaza to each
/// station, a handful of small houses, scattered trees/bushes, and a subtle
/// grass texture so the map doesn't read as an empty green field. Everything
/// here is placeholder shapes — swap this for a flame_tiled map later
/// without touching any gameplay code, since nothing else depends on this
/// component (besides [kHouseObstacles], which is plain data).
class SceneryComponent extends PositionComponent {
  // Added to the world after the ground rectangle and before stations/NPCs,
  // so keep the default priority — it must render above the ground fill but
  // below everything else, matching that add order.
  SceneryComponent() : super(position: Vector2.zero(), size: kWorldSize, anchor: Anchor.topLeft);

  static const Offset _plaza = Offset(800, 600);
  static const List<Offset> _pathTargets = [
    Offset(400, 300),
    Offset(1200, 300),
    Offset(400, 900),
    Offset(1200, 900),
  ];

  static final List<Offset> _houses = kHouseObstacles.map((v) => v.toOffset()).toList();

  static final List<_GrassTuft> _grassTufts = _generateGrassTufts();

  static List<_GrassTuft> _generateGrassTufts() {
    final random = math.Random(42);
    return List.generate(260, (_) {
      return _GrassTuft(
        position: Offset(random.nextDouble() * kWorldSize.x, random.nextDouble() * kWorldSize.y),
        light: random.nextBool(),
        angle: random.nextDouble() * math.pi,
      );
    });
  }

  static const List<Offset> _trees = [
    Offset(150, 150),
    Offset(150, 1050),
    Offset(1450, 150),
    Offset(1450, 1050),
    Offset(800, 110),
    Offset(800, 1090),
    Offset(110, 600),
    Offset(1490, 600),
    Offset(300, 780),
    Offset(1300, 420),
  ];

  static const List<Offset> _bushClusterCenters = [
    Offset(760, 560),
    Offset(840, 560),
    Offset(760, 640),
    Offset(840, 640),
  ];

  @override
  void render(Canvas canvas) {
    _renderGrass(canvas);
    _renderPaths(canvas);
    _renderTrees(canvas);
    _renderBushes(canvas);
    _renderHouses(canvas);
  }

  void _renderGrass(Canvas canvas) {
    for (final tuft in _grassTufts) {
      final color = tuft.light ? const Color(0xFF9FD79A) : const Color(0xFF6FAE68);
      final dx = math.cos(tuft.angle) * 5;
      final dy = math.sin(tuft.angle) * 5;
      canvas.drawLine(
        tuft.position,
        tuft.position + Offset(dx, dy),
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _renderPaths(Canvas canvas) {
    for (final target in _pathTargets) {
      canvas.drawLine(
        _plaza,
        target,
        Paint()
          ..color = const Color(0xFFB08A54)
          ..strokeWidth = 34
          ..strokeCap = StrokeCap.round,
      );
    }
    for (final target in _pathTargets) {
      canvas.drawLine(
        _plaza,
        target,
        Paint()
          ..color = const Color(0xFFC9A26D)
          ..strokeWidth = 26
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(_plaza, 46, Paint()..color = const Color(0xFFC9A26D));
  }

  void _renderTrees(Canvas canvas) {
    for (var i = 0; i < _trees.length; i++) {
      _drawTree(canvas, _trees[i], scale: i.isEven ? 1.0 : 0.85);
    }
  }

  void _drawTree(Canvas canvas, Offset base, {double scale = 1.0}) {
    canvas.drawOval(
      Rect.fromCenter(center: base + Offset(0, 6 * scale), width: 30 * scale, height: 12 * scale),
      Paint()..color = const Color(0x33000000),
    );
    canvas.drawRect(
      Rect.fromCenter(center: base, width: 7 * scale, height: 20 * scale),
      Paint()..color = const Color(0xFF6B4A2F),
    );
    canvas.drawCircle(base + Offset(0, -16 * scale), 16 * scale, Paint()..color = const Color(0xFF3E7D3A));
    canvas.drawCircle(base + Offset(-8 * scale, -22 * scale), 11 * scale, Paint()..color = const Color(0xFF4E9A47));
    canvas.drawCircle(base + Offset(9 * scale, -20 * scale), 12 * scale, Paint()..color = const Color(0xFF4E9A47));
  }

  void _renderBushes(Canvas canvas) {
    for (final center in _bushClusterCenters) {
      canvas.drawCircle(center, 10, Paint()..color = const Color(0xFF4E9A47));
      canvas.drawCircle(center + const Offset(6, 3), 7, Paint()..color = const Color(0xFF5FAE58));
    }
  }

  void _renderHouses(Canvas canvas) {
    const wallColors = [
      Color(0xFFE8C9A0),
      Color(0xFFD9C2E0),
      Color(0xFFC7DDE8),
      Color(0xFFE8D8A0),
    ];
    const roofColors = [
      Color(0xFFB35A46),
      Color(0xFF7C5A96),
      Color(0xFF3D6E8C),
      Color(0xFFB38A2E),
    ];

    for (var i = 0; i < _houses.length; i++) {
      final base = _houses[i];
      final wallColor = wallColors[i % wallColors.length];
      final roofColor = roofColors[i % roofColors.length];
      const w = 64.0;
      const h = 46.0;

      canvas.drawOval(
        Rect.fromCenter(center: base + const Offset(0, h * 0.62), width: w * 1.1, height: 16),
        Paint()..color = const Color(0x33000000),
      );

      final wallRect = Rect.fromCenter(center: base + Offset(0, h * 0.18), width: w, height: h * 0.65);
      canvas.drawRect(wallRect, Paint()..color = wallColor);

      final roofPath = Path()
        ..moveTo(base.dx - w * 0.62, base.dy - h * 0.15)
        ..lineTo(base.dx, base.dy - h * 0.62)
        ..lineTo(base.dx + w * 0.62, base.dy - h * 0.15)
        ..close();
      canvas.drawPath(roofPath, Paint()..color = roofColor);

      final doorRect = Rect.fromCenter(center: base + Offset(0, h * 0.42), width: w * 0.22, height: h * 0.32);
      canvas.drawRect(doorRect, Paint()..color = const Color(0xFF5B3E28));

      final windowPaint = Paint()..color = const Color(0xFFFFF3C4);
      canvas.drawRect(
        Rect.fromCenter(center: base + Offset(-w * 0.28, h * 0.1), width: 10, height: 10),
        windowPaint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: base + Offset(w * 0.28, h * 0.1), width: 10, height: 10),
        windowPaint,
      );
    }
  }
}

class _GrassTuft {
  const _GrassTuft({required this.position, required this.light, required this.angle});

  final Offset position;
  final bool light;
  final double angle;
}
