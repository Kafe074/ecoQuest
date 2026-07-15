import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// One thing that can float down the river: either trash the player should
/// tap to collect, or an animal they must leave alone.
class RiverItem {
  const RiverItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.isTrash,
  });

  final String name;
  final IconData icon;
  final Color color;
  final bool isTrash;
}

const List<RiverItem> riverTrash = [
  RiverItem(
    name: 'Botella plástica',
    icon: PhosphorIconsFill.beerBottle,
    color: Color(0xFF8D6E63),
    isTrash: true,
  ),
  RiverItem(
    name: 'Bolsa',
    icon: PhosphorIconsFill.bagSimple,
    color: Color(0xFF90A4AE),
    isTrash: true,
  ),
  RiverItem(
    name: 'Envase rociador',
    icon: PhosphorIconsFill.sprayBottle,
    color: Color(0xFF78909C),
    isTrash: true,
  ),
  RiverItem(
    name: 'Neumático',
    icon: PhosphorIconsFill.tire,
    color: Color(0xFF455A64),
    isTrash: true,
  ),
  RiverItem(
    name: 'Caja',
    icon: PhosphorIconsFill.package,
    color: Color(0xFFA1887F),
    isTrash: true,
  ),
  RiverItem(
    name: 'Bota vieja',
    icon: PhosphorIconsFill.boot,
    color: Color(0xFF6D4C41),
    isTrash: true,
  ),
  RiverItem(
    name: 'Zapato viejo',
    icon: PhosphorIconsFill.sneaker,
    color: Color(0xFF757575),
    isTrash: true,
  ),
];

const List<RiverItem> riverAnimals = [
  RiverItem(
    name: 'Un pez',
    icon: PhosphorIconsFill.fish,
    color: Color(0xFFFFB74D),
    isTrash: false,
  ),
  RiverItem(
    name: 'Un pececito',
    icon: PhosphorIconsFill.fishSimple,
    color: Color(0xFFFFD54F),
    isTrash: false,
  ),
  RiverItem(
    name: 'Un ave',
    icon: PhosphorIconsFill.bird,
    color: Color(0xFFE0F2F1),
    isTrash: false,
  ),
  RiverItem(
    name: 'Un camarón',
    icon: PhosphorIconsFill.shrimp,
    color: Color(0xFFFF8A65),
    isTrash: false,
  ),
  RiverItem(
    name: 'Una mariposa',
    icon: PhosphorIconsFill.butterfly,
    color: Color(0xFFCE93D8),
    isTrash: false,
  ),
];
