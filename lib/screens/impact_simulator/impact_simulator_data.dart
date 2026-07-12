class ImpactOption {
  const ImpactOption({
    required this.text,
    required this.pollutionDelta,
    required this.resourcesDelta,
    required this.healthDelta,
    required this.feedback,
  });

  final String text;
  final int pollutionDelta;
  final int resourcesDelta;
  final int healthDelta;
  final String feedback;
}

class ImpactScenario {
  const ImpactScenario({required this.question, required this.options});

  final String question;
  final List<ImpactOption> options;
}

const List<ImpactScenario> impactScenarios = [
  ImpactScenario(
    question: 'Es hora de ir al trabajo o al estudio. ¿Cómo te movilizás?',
    options: [
      ImpactOption(
        text: 'En auto particular, yo solo/a',
        pollutionDelta: 15,
        resourcesDelta: -10,
        healthDelta: -5,
        feedback:
            'Un auto con una sola persona es de los medios de transporte que más CO2 emite por pasajero.',
      ),
      ImpactOption(
        text: 'En transporte público',
        pollutionDelta: 5,
        resourcesDelta: -3,
        healthDelta: 0,
        feedback:
            'El transporte público reparte las emisiones entre muchas personas, así que contamina mucho menos por pasajero.',
      ),
      ImpactOption(
        text: 'En bici o caminando',
        pollutionDelta: 0,
        resourcesDelta: 0,
        healthDelta: 10,
        feedback:
            'Moverte sin motor no emite contaminación y además mejora tu salud física.',
      ),
    ],
  ),
  ImpactScenario(
    question: 'Querés renovar tu ropa. ¿Qué hacés?',
    options: [
      ImpactOption(
        text: 'Comprar ropa nueva de bajo costo (fast fashion)',
        pollutionDelta: 12,
        resourcesDelta: -12,
        healthDelta: -2,
        feedback:
            'La industria textil de bajo costo consume enormes cantidades de agua y energía, y genera mucho descarte.',
      ),
      ImpactOption(
        text: 'Comprar ropa de segunda mano',
        pollutionDelta: 2,
        resourcesDelta: 2,
        healthDelta: 3,
        feedback:
            'Reutilizar ropa evita que se fabriquen prendas nuevas y le da más vida útil a lo que ya existe.',
      ),
      ImpactOption(
        text: 'Reparar y reutilizar lo que ya tenés',
        pollutionDelta: 0,
        resourcesDelta: 5,
        healthDelta: 5,
        feedback:
            'Reparar en vez de reemplazar es una de las formas más efectivas de reducir tu huella de consumo.',
      ),
    ],
  ),
  ImpactScenario(
    question: 'Es momento de sacar la basura de tu casa. ¿Cómo la manejás?',
    options: [
      ImpactOption(
        text: 'Todo junto, sin separar nada',
        pollutionDelta: 10,
        resourcesDelta: -8,
        healthDelta: -3,
        feedback:
            'Sin separar, los materiales reciclables terminan en rellenos sanitarios en vez de reutilizarse.',
      ),
      ImpactOption(
        text: 'Separo los reciclables (papel, plástico, vidrio)',
        pollutionDelta: -5,
        resourcesDelta: 8,
        healthDelta: 2,
        feedback:
            'Separar residuos permite que esos materiales vuelvan a convertirse en nuevos productos.',
      ),
      ImpactOption(
        text: 'Separo reciclables y además hago compost con los orgánicos',
        pollutionDelta: -8,
        resourcesDelta: 12,
        healthDelta: 5,
        feedback:
            'El compostaje evita emisiones de metano en los basurales y genera abono natural.',
      ),
    ],
  ),
  ImpactScenario(
    question: 'Tenés sed. ¿Qué elegís para tomar agua?',
    options: [
      ImpactOption(
        text: 'Comprar una botella de plástico descartable',
        pollutionDelta: 8,
        resourcesDelta: -6,
        healthDelta: 0,
        feedback:
            'La mayoría de las botellas plásticas se usan una sola vez y tardan siglos en degradarse.',
      ),
      ImpactOption(
        text: 'Usar una botella reutilizable',
        pollutionDelta: -3,
        resourcesDelta: 5,
        healthDelta: 3,
        feedback:
            'Una sola botella reutilizable puede reemplazar cientos de botellas descartables al año.',
      ),
    ],
  ),
  ImpactScenario(
    question: 'Vas al supermercado. ¿Qué llevás para cargar las compras?',
    options: [
      ImpactOption(
        text: 'Pido bolsas de plástico nuevas',
        pollutionDelta: 10,
        resourcesDelta: -8,
        healthDelta: 0,
        feedback:
            'Las bolsas plásticas descartables suelen usarse pocos minutos y contaminar durante años.',
      ),
      ImpactOption(
        text: 'Llevo mis propias bolsas reutilizables',
        pollutionDelta: -5,
        resourcesDelta: 5,
        healthDelta: 2,
        feedback:
            'Reutilizar bolsas reduce muchísimo la cantidad de plástico de un solo uso que se produce.',
      ),
    ],
  ),
  ImpactScenario(
    question: 'Hace mucho calor en tu casa. ¿Qué hacés?',
    options: [
      ImpactOption(
        text: 'Dejo el aire acondicionado prendido todo el día',
        pollutionDelta: 14,
        resourcesDelta: -10,
        healthDelta: -2,
        feedback:
            'El uso constante de aire acondicionado dispara el consumo eléctrico y las emisiones asociadas.',
      ),
      ImpactOption(
        text: 'Lo uso unas horas y después ventilo',
        pollutionDelta: 5,
        resourcesDelta: -3,
        healthDelta: 2,
        feedback: 'Un uso moderado reduce bastante el consumo de energía.',
      ),
      ImpactOption(
        text: 'Abro las ventanas y uso un ventilador',
        pollutionDelta: 0,
        resourcesDelta: 2,
        healthDelta: 3,
        feedback:
            'Ventilar de forma natural consume muchísima menos energía que climatizar.',
      ),
    ],
  ),
  ImpactScenario(
    question: 'Sobró comida después de comer. ¿Qué hacés?',
    options: [
      ImpactOption(
        text: 'La tiro a la basura común',
        pollutionDelta: 8,
        resourcesDelta: -6,
        healthDelta: -2,
        feedback:
            'El desperdicio de alimentos genera metano al descomponerse en basurales.',
      ),
      ImpactOption(
        text: 'La guardo para comer después',
        pollutionDelta: -2,
        resourcesDelta: 6,
        healthDelta: 3,
        feedback:
            'Aprovechar las sobras reduce el desperdicio y ahorra recursos usados en producir esa comida.',
      ),
      ImpactOption(
        text: 'La composto si ya no se puede comer',
        pollutionDelta: -5,
        resourcesDelta: 8,
        healthDelta: 4,
        feedback: 'Compostar los restos orgánicos les da una segunda vida útil como abono.',
      ),
    ],
  ),
  ImpactScenario(
    question: 'Tu celular se rompió. ¿Qué hacés?',
    options: [
      ImpactOption(
        text: 'Lo tiro y compro uno nuevo',
        pollutionDelta: 15,
        resourcesDelta: -12,
        healthDelta: -3,
        feedback:
            'Fabricar un dispositivo nuevo requiere minerales escasos y mucha energía; los electrónicos son de los residuos más contaminantes.',
      ),
      ImpactOption(
        text: 'Lo llevo a reparar',
        pollutionDelta: -3,
        resourcesDelta: 6,
        healthDelta: 4,
        feedback: 'Reparar dispositivos alarga su vida útil y evita nueva extracción de recursos.',
      ),
      ImpactOption(
        text: 'Lo llevo a un punto de reciclaje electrónico',
        pollutionDelta: -6,
        resourcesDelta: 8,
        healthDelta: 3,
        feedback:
            'El reciclaje electrónico recupera metales valiosos y evita que sustancias tóxicas contaminen el ambiente.',
      ),
    ],
  ),
  ImpactScenario(
    question: 'Es de noche y te vas a dormir. ¿Qué hacés con las luces y aparatos?',
    options: [
      ImpactOption(
        text: 'Dejo todo prendido o en stand-by',
        pollutionDelta: 8,
        resourcesDelta: -6,
        healthDelta: -1,
        feedback:
            'El consumo en stand-by de muchos aparatos juntos representa un gasto de energía innecesario.',
      ),
      ImpactOption(
        text: 'Apago las luces pero dejo aparatos en stand-by',
        pollutionDelta: 3,
        resourcesDelta: -2,
        healthDelta: 1,
        feedback: 'Apagar las luces ya es una mejora, aunque el stand-by sigue consumiendo algo.',
      ),
      ImpactOption(
        text: 'Apago todo, incluso el stand-by',
        pollutionDelta: -4,
        resourcesDelta: 6,
        healthDelta: 3,
        feedback: 'Cortar el stand-by de varios aparatos puede ahorrar bastante energía a lo largo del año.',
      ),
    ],
  ),
  ImpactScenario(
    question:
        'Un amigo te invita a plantar árboles el fin de semana en un espacio verde comunitario. ¿Qué hacés?',
    options: [
      ImpactOption(
        text: 'No voy, prefiero quedarme en casa',
        pollutionDelta: 2,
        resourcesDelta: -2,
        healthDelta: -2,
        feedback: 'Está bien descansar, pero te perdiste una oportunidad de generar un impacto positivo directo.',
      ),
      ImpactOption(
        text: 'Voy y participo activamente',
        pollutionDelta: -10,
        resourcesDelta: 12,
        healthDelta: 10,
        feedback:
            'Los árboles absorben CO2, generan oxígeno y mejoran la biodiversidad de tu comunidad.',
      ),
    ],
  ),
];
