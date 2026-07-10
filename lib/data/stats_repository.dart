import 'package:shared_preferences/shared_preferences.dart';

class GameStats {
  const GameStats({
    required this.gamesPlayed,
    required this.totalMatches,
    required this.totalPlaySeconds,
  });

  final int gamesPlayed;
  final int totalMatches;
  final int totalPlaySeconds;

  static const initial = GameStats(
    gamesPlayed: 0,
    totalMatches: 0,
    totalPlaySeconds: 0,
  );
}

class StatsRepository {
  static const _kGamesPlayed = 'stats_games_played';
  static const _kTotalMatches = 'stats_total_matches';
  static const _kTotalPlaySeconds = 'stats_total_play_seconds';

  Future<GameStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    return GameStats(
      gamesPlayed: prefs.getInt(_kGamesPlayed) ?? 0,
      totalMatches: prefs.getInt(_kTotalMatches) ?? 0,
      totalPlaySeconds: prefs.getInt(_kTotalPlaySeconds) ?? 0,
    );
  }

  Future<GameStats> recordGameCompletion({
    required int matches,
    required int playSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await load();
    final updated = GameStats(
      gamesPlayed: current.gamesPlayed + 1,
      totalMatches: current.totalMatches + matches,
      totalPlaySeconds: current.totalPlaySeconds + playSeconds,
    );
    await prefs.setInt(_kGamesPlayed, updated.gamesPlayed);
    await prefs.setInt(_kTotalMatches, updated.totalMatches);
    await prefs.setInt(_kTotalPlaySeconds, updated.totalPlaySeconds);
    return updated;
  }
}
