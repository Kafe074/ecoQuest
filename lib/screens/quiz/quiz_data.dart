class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

const List<QuizQuestion> quizQuestions = [
  QuizQuestion(
    question: '¿Cuál de estos gases es el principal responsable del efecto invernadero de origen humano?',
    options: ['Oxígeno', 'Dióxido de carbono (CO2)', 'Nitrógeno', 'Hidrógeno'],
    correctIndex: 1,
    explanation:
        'El CO2, liberado principalmente al quemar combustibles fósiles, es el gas de efecto invernadero más emitido por la actividad humana.',
  ),
  QuizQuestion(
    question: '¿Cuánto puede tardar una botella de plástico en degradarse en el ambiente?',
    options: ['Unos meses', 'Alrededor de 10 años', 'Hasta 450 años', 'Solo 1 año'],
    correctIndex: 2,
    explanation:
        'Las botellas de plástico (PET) pueden tardar cientos de años en degradarse, y nunca lo hacen por completo.',
  ),
  QuizQuestion(
    question: '¿Qué material es 100% reciclable y se puede reutilizar infinitas veces sin perder calidad?',
    options: ['El vidrio', 'El plástico', 'El poliestireno expandido', 'El papel aluminio usado'],
    correctIndex: 0,
    explanation: 'El vidrio se puede fundir y reciclar una y otra vez sin perder sus propiedades.',
  ),
  QuizQuestion(
    question: '¿Cuál de estas opciones consume menos agua para producirse?',
    options: [
      'Una hamburguesa de carne vacuna',
      'Un kilo de legumbres',
      'Un par de jeans nuevo',
      'Una remera de algodón',
    ],
    correctIndex: 1,
    explanation:
        'Producir un kilo de legumbres requiere muchísima menos agua que la carne vacuna o los textiles de algodón.',
  ),
  QuizQuestion(
    question: '¿Qué práctica ayuda más a reducir el desperdicio de alimentos en casa?',
    options: [
      'Comprar todo en grandes cantidades',
      'Planificar las comidas y aprovechar las sobras',
      'Tirar la comida apenas sobra un poco',
      'No usar heladera',
    ],
    correctIndex: 1,
    explanation: 'Planificar compras y comidas, y aprovechar las sobras, es clave para reducir el desperdicio.',
  ),
  QuizQuestion(
    question: '¿Cuál de estos medios de transporte genera menos emisiones de CO2 por pasajero?',
    options: ['Auto particular con una persona', 'Avión', 'Bicicleta', 'Motocicleta'],
    correctIndex: 2,
    explanation: 'La bicicleta no emite CO2 durante su uso y además no requiere combustibles fósiles.',
  ),
  QuizQuestion(
    question: '¿Qué es el compostaje?',
    options: [
      'Quemar residuos orgánicos',
      'Un proceso para convertir residuos orgánicos en abono natural',
      'Un tipo de plástico biodegradable',
      'Un sistema de recolección de basura',
    ],
    correctIndex: 1,
    explanation: 'El compostaje transforma restos orgánicos en un abono rico en nutrientes para las plantas.',
  ),
  QuizQuestion(
    question: '¿Cuál de estas fuentes de energía es renovable?',
    options: ['Carbón', 'Petróleo', 'Gas natural', 'Energía solar'],
    correctIndex: 3,
    explanation: 'La energía solar proviene del sol, una fuente prácticamente inagotable a escala humana.',
  ),
  QuizQuestion(
    question: '¿Qué son las "3R" de la sostenibilidad?',
    options: [
      'Reducir, reutilizar, reciclar',
      'Reemplazar, remover, renovar',
      'Repetir, resistir, recuperar',
      'Reparar, remodelar, reforzar',
    ],
    correctIndex: 0,
    explanation:
        'Reducir el consumo, reutilizar lo que ya existe y reciclar lo que ya no sirve son la base de un consumo más responsable.',
  ),
  QuizQuestion(
    question: '¿Por qué la deforestación contribuye al cambio climático?',
    options: [
      'Porque los árboles absorben CO2 y al talarlos se pierde esa capacidad',
      'Porque hace que llueva menos',
      'Porque reduce la temperatura del suelo',
      'No tiene relación con el clima',
    ],
    correctIndex: 0,
    explanation:
        'Los árboles capturan CO2 de la atmósfera; al talarlos (y sobre todo al quemarlos) se pierde ese sumidero de carbono y muchas veces se libera el carbono almacenado.',
  ),
];
