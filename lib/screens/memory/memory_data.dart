class MemoryItem {
  const MemoryItem({required this.emoji, required this.label});

  final String emoji;
  final String label;
}

const List<MemoryItem> memoryItems = [
  MemoryItem(emoji: '♻️', label: 'Reciclar'),
  MemoryItem(emoji: '🔄', label: 'Reutilizar'),
  MemoryItem(emoji: '🌱', label: 'Compost'),
  MemoryItem(emoji: '🚲', label: 'Bicicleta'),
  MemoryItem(emoji: '💧', label: 'Ahorrar agua'),
  MemoryItem(emoji: '💡', label: 'Ahorrar energía'),
  MemoryItem(emoji: '🧴', label: 'Botella reutilizable'),
  MemoryItem(emoji: '🛍️', label: 'Bolsa de tela'),
];
