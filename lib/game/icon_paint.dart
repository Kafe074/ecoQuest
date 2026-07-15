import 'dart:ui';

import 'package:flame/components.dart' show Anchor, TextPaint, Vector2;
import 'package:flutter/widgets.dart' show IconData, TextStyle;

/// Renders a font-based [IconData] (e.g. a Phosphor icon) straight onto a
/// Flame canvas, so world components can share the exact same icon set as
/// the Flutter UI instead of falling back to emoji glyphs.
void renderIcon(
  Canvas canvas,
  IconData icon, {
  required Vector2 position,
  required double size,
  required Color color,
  Anchor anchor = Anchor.center,
}) {
  TextPaint(
    style: TextStyle(
      fontSize: size,
      fontFamily: icon.fontFamily,
      package: icon.fontPackage,
      color: color,
    ),
  ).render(
    canvas,
    String.fromCharCode(icon.codePoint),
    position,
    anchor: anchor,
  );
}
