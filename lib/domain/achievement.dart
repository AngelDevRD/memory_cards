class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

/// Static catalog of achievements. Unlock checks happen in the game provider
/// (needs live game context: board size, elapsed time, stats, level stars).
class Achievements {
  static const complete8x8 = Achievement(
    id: 'complete_8x8',
    title: 'Maestro del tablero',
    description: 'Completa un tablero de 8x8',
  );
  static const threeStarsFiveLevels = Achievement(
    id: 'three_stars_five_levels',
    title: 'Coleccionista de estrellas',
    description: 'Consigue 3 estrellas en 5 niveles',
  );
  static const under30Seconds4x4 = Achievement(
    id: 'under_30s_4x4',
    title: 'Rápido como el rayo',
    description: 'Gana en menos de 30 segundos en un tablero 4x4',
  );
  static const play20Games = Achievement(
    id: 'play_20_games',
    title: 'Jugador dedicado',
    description: 'Juega 20 partidas',
  );

  static const List<Achievement> all = [
    complete8x8,
    threeStarsFiveLevels,
    under30Seconds4x4,
    play20Games,
  ];
}
