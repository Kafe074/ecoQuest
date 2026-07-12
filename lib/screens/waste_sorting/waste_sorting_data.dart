import 'package:flutter/material.dart';

enum WasteCategory { plastico, papel, vidrio, organico, noReciclable }

extension WasteCategoryInfo on WasteCategory {
  String get label {
    switch (this) {
      case WasteCategory.plastico:
        return 'Plástico';
      case WasteCategory.papel:
        return 'Papel y cartón';
      case WasteCategory.vidrio:
        return 'Vidrio';
      case WasteCategory.organico:
        return 'Orgánico';
      case WasteCategory.noReciclable:
        return 'No reciclable';
    }
  }

  Color get color {
    switch (this) {
      case WasteCategory.plastico:
        return const Color(0xFFFBC02D);
      case WasteCategory.papel:
        return const Color(0xFF1976D2);
      case WasteCategory.vidrio:
        return const Color(0xFF00897B);
      case WasteCategory.organico:
        return const Color(0xFF6D4C29);
      case WasteCategory.noReciclable:
        return const Color(0xFF616161);
    }
  }

  IconData get icon {
    switch (this) {
      case WasteCategory.plastico:
        return Icons.local_drink_outlined;
      case WasteCategory.papel:
        return Icons.description_outlined;
      case WasteCategory.vidrio:
        return Icons.liquor_outlined;
      case WasteCategory.organico:
        return Icons.eco_outlined;
      case WasteCategory.noReciclable:
        return Icons.delete_forever_outlined;
    }
  }
}

class WasteItem {
  const WasteItem({
    required this.name,
    required this.emoji,
    required this.category,
    required this.fact,
  });

  final String name;
  final String emoji;
  final WasteCategory category;
  final String fact;
}

const List<WasteItem> wasteItems = [
  WasteItem(
    name: 'Botella de plástico',
    emoji: '🧴',
    category: WasteCategory.plastico,
    fact: 'Una botella de plástico puede tardar hasta 450 años en degradarse.',
  ),
  WasteItem(
    name: 'Bolsa de plástico',
    emoji: '🛍️',
    category: WasteCategory.plastico,
    fact: 'Las bolsas de plástico suelen usarse minutos pero contaminar durante siglos.',
  ),
  WasteItem(
    name: 'Vaso de yogur',
    emoji: '🥣',
    category: WasteCategory.plastico,
    fact: 'Enjuagar los envases antes de tirarlos mejora mucho su reciclabilidad.',
  ),
  WasteItem(
    name: 'Diario viejo',
    emoji: '📰',
    category: WasteCategory.papel,
    fact: 'El papel puede reciclarse varias veces antes de perder calidad.',
  ),
  WasteItem(
    name: 'Caja de cartón',
    emoji: '📦',
    category: WasteCategory.papel,
    fact: 'Reciclar cartón ahorra árboles, agua y energía frente a fabricar cartón nuevo.',
  ),
  WasteItem(
    name: 'Hoja de cuaderno',
    emoji: '📄',
    category: WasteCategory.papel,
    fact: 'Reciclar una tonelada de papel ahorra alrededor de 17 árboles.',
  ),
  WasteItem(
    name: 'Botella de vidrio',
    emoji: '🍾',
    category: WasteCategory.vidrio,
    fact: 'El vidrio es 100% reciclable y puede reutilizarse infinitas veces sin perder calidad.',
  ),
  WasteItem(
    name: 'Frasco de mermelada',
    emoji: '🫙',
    category: WasteCategory.vidrio,
    fact: 'Los frascos de vidrio se pueden reutilizar en casa antes de reciclarlos.',
  ),
  WasteItem(
    name: 'Cáscara de banana',
    emoji: '🍌',
    category: WasteCategory.organico,
    fact: 'Los residuos orgánicos se pueden compostar y convertir en abono natural.',
  ),
  WasteItem(
    name: 'Restos de comida',
    emoji: '🍲',
    category: WasteCategory.organico,
    fact: 'En un basural, la materia orgánica genera metano, un gas de efecto invernadero potente.',
  ),
  WasteItem(
    name: 'Yerba usada',
    emoji: '🧉',
    category: WasteCategory.organico,
    fact: 'La yerba usada es un excelente aporte de nitrógeno para el compost.',
  ),
  WasteItem(
    name: 'Pila usada',
    emoji: '🔋',
    category: WasteCategory.noReciclable,
    fact: 'Las pilas contienen metales pesados y deben llevarse a puntos de recolección especiales.',
  ),
  WasteItem(
    name: 'Colilla de cigarrillo',
    emoji: '🚬',
    category: WasteCategory.noReciclable,
    fact: 'Las colillas contienen plástico (acetato de celulosa) y tardan años en degradarse.',
  ),
  WasteItem(
    name: 'Pañal descartable',
    emoji: '🩲',
    category: WasteCategory.noReciclable,
    fact: 'Los pañales descartables combinan materiales que no se pueden separar para reciclar.',
  ),
  WasteItem(
    name: 'Envoltorio de golosina',
    emoji: '🍬',
    category: WasteCategory.noReciclable,
    fact: 'Los envoltorios multicapa mezclan plástico y aluminio, muy difíciles de reciclar.',
  ),
];
