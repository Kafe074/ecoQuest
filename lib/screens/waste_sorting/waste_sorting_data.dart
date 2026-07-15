import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
        return PhosphorIconsFill.sprayBottle;
      case WasteCategory.papel:
        return PhosphorIconsFill.newspaper;
      case WasteCategory.vidrio:
        return PhosphorIconsFill.jar;
      case WasteCategory.organico:
        return PhosphorIconsFill.plant;
      case WasteCategory.noReciclable:
        return PhosphorIconsFill.trashSimple;
    }
  }
}

class WasteItem {
  const WasteItem({
    required this.name,
    required this.icon,
    required this.category,
    required this.fact,
  });

  final String name;
  final IconData icon;
  final WasteCategory category;
  final String fact;
}

const List<WasteItem> wasteItems = [
  WasteItem(
    name: 'Botella de plástico',
    icon: PhosphorIconsFill.beerBottle,
    category: WasteCategory.plastico,
    fact: 'Una botella de plástico puede tardar hasta 450 años en degradarse.',
  ),
  WasteItem(
    name: 'Bolsa de plástico',
    icon: PhosphorIconsFill.bagSimple,
    category: WasteCategory.plastico,
    fact: 'Las bolsas de plástico suelen usarse minutos pero contaminar durante siglos.',
  ),
  WasteItem(
    name: 'Vaso de yogur',
    icon: PhosphorIconsFill.pintGlass,
    category: WasteCategory.plastico,
    fact: 'Enjuagar los envases antes de tirarlos mejora mucho su reciclabilidad.',
  ),
  WasteItem(
    name: 'Diario viejo',
    icon: PhosphorIconsFill.newspaperClipping,
    category: WasteCategory.papel,
    fact: 'El papel puede reciclarse varias veces antes de perder calidad.',
  ),
  WasteItem(
    name: 'Caja de cartón',
    icon: PhosphorIconsFill.package,
    category: WasteCategory.papel,
    fact: 'Reciclar cartón ahorra árboles, agua y energía frente a fabricar cartón nuevo.',
  ),
  WasteItem(
    name: 'Hoja de cuaderno',
    icon: PhosphorIconsFill.fileText,
    category: WasteCategory.papel,
    fact: 'Reciclar una tonelada de papel ahorra alrededor de 17 árboles.',
  ),
  WasteItem(
    name: 'Botella de vidrio',
    icon: PhosphorIconsFill.wine,
    category: WasteCategory.vidrio,
    fact: 'El vidrio es 100% reciclable y puede reutilizarse infinitas veces sin perder calidad.',
  ),
  WasteItem(
    name: 'Frasco de mermelada',
    icon: PhosphorIconsFill.jarLabel,
    category: WasteCategory.vidrio,
    fact: 'Los frascos de vidrio se pueden reutilizar en casa antes de reciclarlos.',
  ),
  WasteItem(
    name: 'Cáscara de fruta',
    icon: PhosphorIconsFill.orangeSlice,
    category: WasteCategory.organico,
    fact: 'Los residuos orgánicos se pueden compostar y convertir en abono natural.',
  ),
  WasteItem(
    name: 'Restos de comida',
    icon: PhosphorIconsFill.bowlFood,
    category: WasteCategory.organico,
    fact: 'En un basural, la materia orgánica genera metano, un gas de efecto invernadero potente.',
  ),
  WasteItem(
    name: 'Yerba usada',
    icon: PhosphorIconsFill.teaBag,
    category: WasteCategory.organico,
    fact: 'La yerba usada es un excelente aporte de nitrógeno para el compost.',
  ),
  WasteItem(
    name: 'Pila usada',
    icon: PhosphorIconsFill.batteryWarning,
    category: WasteCategory.noReciclable,
    fact: 'Las pilas contienen metales pesados y deben llevarse a puntos de recolección especiales.',
  ),
  WasteItem(
    name: 'Colilla de cigarrillo',
    icon: PhosphorIconsFill.cigarette,
    category: WasteCategory.noReciclable,
    fact: 'Las colillas contienen plástico (acetato de celulosa) y tardan años en degradarse.',
  ),
  WasteItem(
    name: 'Pañal descartable',
    icon: PhosphorIconsFill.baby,
    category: WasteCategory.noReciclable,
    fact: 'Los pañales descartables combinan materiales que no se pueden separar para reciclar.',
  ),
  WasteItem(
    name: 'Envoltorio de golosina',
    icon: PhosphorIconsFill.cookie,
    category: WasteCategory.noReciclable,
    fact: 'Los envoltorios multicapa mezclan plástico y aluminio, muy difíciles de reciclar.',
  ),
];
