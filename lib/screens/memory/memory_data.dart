import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// One concept to match in the memory game. [image] is a real photo bundled
/// under assets/images/memory/ (sources in ATTRIBUTIONS.md there); [icon]
/// doubles as loading/error fallback.
class MemoryItem {
  const MemoryItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.image,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String image;
}

const List<MemoryItem> memoryItems = [
  MemoryItem(
    icon: PhosphorIconsFill.recycle,
    color: Color(0xFF2E7D32),
    label: 'Reciclar',
    image: 'assets/images/memory/reciclar.jpg',
  ),
  MemoryItem(
    icon: PhosphorIconsFill.arrowsClockwise,
    color: Color(0xFF00838F),
    label: 'Reutilizar',
    image: 'assets/images/memory/reutilizar.jpg',
  ),
  MemoryItem(
    icon: PhosphorIconsFill.plant,
    color: Color(0xFF558B2F),
    label: 'Compost',
    image: 'assets/images/memory/compost.jpg',
  ),
  MemoryItem(
    icon: PhosphorIconsFill.bicycle,
    color: Color(0xFFEF6C00),
    label: 'Bicicleta',
    image: 'assets/images/memory/bicicleta.jpg',
  ),
  MemoryItem(
    icon: PhosphorIconsFill.drop,
    color: Color(0xFF1976D2),
    label: 'Ahorrar agua',
    image: 'assets/images/memory/agua.jpg',
  ),
  MemoryItem(
    icon: PhosphorIconsFill.lightbulb,
    color: Color(0xFFF9A825),
    label: 'Ahorrar energía',
    image: 'assets/images/memory/energia.jpg',
  ),
  MemoryItem(
    icon: PhosphorIconsFill.beerBottle,
    color: Color(0xFF6D4C41),
    label: 'Botella reutilizable',
    image: 'assets/images/memory/botella.jpg',
  ),
  MemoryItem(
    icon: PhosphorIconsFill.tote,
    color: Color(0xFF7B3FA0),
    label: 'Bolsa de tela',
    image: 'assets/images/memory/bolsa.jpg',
  ),
];
