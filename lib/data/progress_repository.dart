import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-level completion (levelNumber -> stars earned) and the set of
/// unlocked achievement ids. Stored as JSON strings since shared_preferences
/// has no native map/set support.
class ProgressRepository {
  static const _kCompletedLevels = 'progress_completed_levels';
  static const _kAchievements = 'progress_achievements';

  Future<Map<int, int>> loadCompletedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCompletedLevels);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
  }

  Future<void> saveCompletedLevels(Map<int, int> levels) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(levels.map((k, v) => MapEntry(k.toString(), v)));
    await prefs.setString(_kCompletedLevels, encoded);
  }

  /// Records a level completion, keeping the best (highest) star count.
  Future<Map<int, int>> recordLevelCompletion(
    int levelNumber,
    int stars,
  ) async {
    final levels = await loadCompletedLevels();
    final existing = levels[levelNumber];
    if (existing == null || stars > existing) {
      levels[levelNumber] = stars;
      await saveCompletedLevels(levels);
    }
    return levels;
  }

  Future<Set<String>> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kAchievements);
    return raw?.toSet() ?? {};
  }

  Future<void> saveAchievements(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kAchievements, ids.toList());
  }

  Future<Set<String>> unlockAchievement(String id) async {
    final ids = await loadAchievements();
    if (ids.add(id)) {
      await saveAchievements(ids);
    }
    return ids;
  }
}
