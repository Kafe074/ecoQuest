/// One thing that can float down the river: either trash the player should
/// tap to collect, or an animal they must leave alone.
class RiverItem {
  const RiverItem({
    required this.name,
    required this.emoji,
    required this.isTrash,
  });

  final String name;
  final String emoji;
  final bool isTrash;
}

const List<RiverItem> riverTrash = [
  RiverItem(name: 'Botella plástica', emoji: '🥤', isTrash: true),
  RiverItem(name: 'Bolsa', emoji: '🛍️', isTrash: true),
  RiverItem(name: 'Lata', emoji: '🥫', isTrash: true),
  RiverItem(name: 'Neumático', emoji: '🛞', isTrash: true),
  RiverItem(name: 'Caja', emoji: '📦', isTrash: true),
  RiverItem(name: 'Envase', emoji: '🧴', isTrash: true),
  RiverItem(name: 'Zapato viejo', emoji: '👟', isTrash: true),
];

const List<RiverItem> riverAnimals = [
  RiverItem(name: 'Pez', emoji: '🐟', isTrash: false),
  RiverItem(name: 'Pato', emoji: '🦆', isTrash: false),
  RiverItem(name: 'Rana', emoji: '🐸', isTrash: false),
  RiverItem(name: 'Tortuga', emoji: '🐢', isTrash: false),
  RiverItem(name: 'Cisne', emoji: '🦢', isTrash: false),
];
