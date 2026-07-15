import 'package:flame/game.dart' show Vector2;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Describes one wandering NPC: who they are, where they roam, and the
/// awareness messages they can share when the player talks to them.
@immutable
class NpcData {
  const NpcData({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.homePosition,
    required this.leashRadius,
    required this.messages,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final Vector2 homePosition;
  final double leashRadius;
  final List<String> messages;
}

final List<NpcData> kNpcs = [
  NpcData(
    id: 'rosa',
    name: 'Doña Rosa',
    icon: PhosphorIconsFill.flower,
    color: Colors.pink.shade300,
    homePosition: Vector2(620, 480),
    leashRadius: 90,
    messages: const [
      'El compost de tu casa puede convertirse en abono en pocas semanas. ¡Menos basura, más plantas!',
      'Plantar especies nativas ayuda a que las abejas y mariposas de la zona tengan dónde alimentarse.',
      'Un jardín con distintas plantas es un refugio para muchos bichitos útiles, no solo flores lindas.',
    ],
  ),
  NpcData(
    id: 'tomas',
    name: 'Tomás',
    icon: PhosphorIconsFill.student,
    color: Colors.lightBlue.shade300,
    homePosition: Vector2(1000, 480),
    leashRadius: 90,
    messages: const [
      '¡En mi escuela separamos los papeles para reciclar! Es más fácil de lo que pensás.',
      'Reutilizar un cuaderno hasta la última hoja también cuenta como cuidar el planeta.',
      'Le enseñé a mi hermanito a apagar la luz cuando sale de un cuarto. ¡Ahora lo hace solo!',
    ],
  ),
  NpcData(
    id: 'clara',
    name: 'Clara',
    icon: PhosphorIconsFill.personSimpleBike,
    color: Colors.teal.shade300,
    homePosition: Vector2(620, 750),
    leashRadius: 90,
    messages: const [
      'Voy en bici al trabajo casi todos los días. Además de no contaminar, llego con más energía.',
      'Compartir un viaje en auto con otras personas reduce muchísimo las emisiones por pasajero.',
      'Caminar distancias cortas en vez de usar el auto es una decisión simple con mucho impacto.',
    ],
  ),
  NpcData(
    id: 'beto',
    name: 'Don Beto',
    icon: PhosphorIconsFill.basket,
    color: Colors.deepOrange.shade300,
    homePosition: Vector2(1000, 750),
    leashRadius: 90,
    messages: const [
      'Comprá lo que está de temporada: gasta menos recursos en transportarse y almacenarse.',
      'Llevo mis propias bolsas y frascos al mercado. Cada vez hay más lugares que lo permiten.',
      'Comprarle a productores locales reduce el transporte de la comida y ayuda a tu barrio.',
    ],
  ),
];
