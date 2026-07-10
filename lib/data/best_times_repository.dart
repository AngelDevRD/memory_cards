import 'package:shared_preferences/shared_preferences.dart';

import '../domain/board_size.dart';
import '../domain/card_category.dart';

/// Best completion time in seconds, keyed by "boardSize_category".
class BestTimesRepository {
  String _key(BoardSize boardSize, CardCategory category) =>
      'best_time_${boardSize.name}_${category.name}';

  Future<int?> load(BoardSize boardSize, CardCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(boardSize, category));
  }

  /// Returns the resulting best time (may be unchanged if [seconds] isn't better).
  Future<int> recordIfBetter(
    BoardSize boardSize,
    CardCategory category,
    int seconds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(boardSize, category);
    final current = prefs.getInt(key);
    if (current == null || seconds < current) {
      await prefs.setInt(key, seconds);
      return seconds;
    }
    return current;
  }

  /// Best time per board size, taking the minimum across all categories.
  Future<Map<BoardSize, int>> loadBestPerBoardSize() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <BoardSize, int>{};
    for (final boardSize in BoardSize.values) {
      int? best;
      for (final category in CardCategory.values) {
        final value = prefs.getInt(_key(boardSize, category));
        if (value != null && (best == null || value < best)) {
          best = value;
        }
      }
      if (best != null) result[boardSize] = best;
    }
    return result;
  }
}
