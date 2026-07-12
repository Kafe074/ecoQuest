# EcoQuest

Aplicación Flutter con minijuegos para tomar conciencia sobre el cuidado del medio ambiente: contaminación, reciclaje y reutilización de recursos.

## Minijuegos

- **Simulador de Impacto**: tomás decisiones cotidianas (movilidad, consumo, residuos) y ves cómo afectan la contaminación, los recursos naturales y la calidad de vida. Termina con un puntaje ecológico sobre 100.
- **Clasificá los Residuos**: arrastrás cada objeto al contenedor correcto (reciclable, orgánico, etc.) antes de que se acabe el tiempo.
- **Quiz Ambiental**: preguntas rápidas de opción múltiple con explicación al responder.
- **Memoria Verde**: juego de memoria con parejas de cartas sobre reciclaje y reutilización.

Cada juego guarda tu mejor puntaje localmente en el dispositivo (`shared_preferences`), así que podés ver si superaste tu marca anterior al terminar una partida.

## Estructura del proyecto

```
lib/
  main.dart                    Punto de entrada de la app
  theme/app_theme.dart         Colores y tema de Material 3
  services/score_service.dart  Persistencia de mejores puntajes
  widgets/                     Widgets compartidos (tarjetas, barras de estadística)
  screens/
    home_screen.dart           Menú principal
    impact_simulator/          Simulador de Impacto
    waste_sorting/             Clasificá los Residuos
    quiz/                      Quiz Ambiental
    memory/                    Memoria Verde
```

## Cómo correr el proyecto

```bash
flutter pub get
flutter run                # elige el dispositivo/emulador conectado
flutter run -d chrome       # correr en el navegador
```

## Tests

```bash
flutter test
```
