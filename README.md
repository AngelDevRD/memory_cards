# Memory Cards

Juego de memoria (parejas) hecho en Flutter para portafolio: Material 3,
Riverpod, Clean Architecture ligera y persistencia local.

## Qué incluye

- Tableros de 2x2, 4x4, 6x6 y 8x8.
- 6 categorías temáticas (Animales, Comida, Objetos, Tecnología, Viajes,
  Emojis), cada una con suficientes símbolos únicos para el tablero más
  grande (32 parejas en 8x8).
- Animación de volteo de carta en 3D (Transform + AnimationController), no un
  simple fade.
- Máquina de estados que bloquea el input mientras se comprueba la pareja
  (evita voltear una tercera carta a mitad de la comprobación).
- Cronómetro en vivo, sistema de estrellas (1-3) con umbrales reales por
  tamaño de tablero, progresión de niveles con desbloqueo secuencial.
- Estadísticas (partidas jugadas, mejor tiempo por tablero, coincidencias
  totales, tiempo total jugado) y logros persistidos.
- Ajustes: tema claro/oscuro/sistema, sonido y vibración, todo persistido.
- Tutorial de primer lanzamiento, splash animado, grid responsive.

## Simplificaciones deliberadas frente al listado original

- **`shared_preferences` en vez de Hive/Isar**: cubre niveles/estrellas/
  logros/estadísticas/mejores tiempos sin generación de código.
- **Iconos/emoji en vez de imágenes**: las "categorías" se representan con
  `Icons`/emoji curados en vez de assets de imagen bajados de internet —
  evita un pipeline de assets con licencias inciertas.
- **Sin archivos de audio reales**: `AudioService` está cableado con
  `audioplayers`, pero si el asset no existe el error se captura y se
  loguea con `debugPrint` en vez de romper la app.
- **Un solo idioma (español)**: sin infraestructura ARB/flutter_intl
  completa.

## Arquitectura

- `lib/domain`: generación/mezcla del tablero, máquina de estados de
  coincidencia, umbrales de estrellas, progresión de niveles — Dart puro,
  testeable de forma aislada.
- `lib/data`: repositorios sobre `shared_preferences` + `AudioService`.
- `lib/providers`: notifiers de Riverpod (temporizador con `Ticker`).
- `lib/presentation`: pantallas y widgets, navegación con `go_router`.

## Cómo correr

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

Cubren la generación del tablero (conteo de parejas, sin duplicados) y la
máquina de estados de coincidencia (bloqueo de input, resolución de
aciertos/fallos, victoria).
