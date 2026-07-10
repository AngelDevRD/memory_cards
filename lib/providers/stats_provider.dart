import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/best_times_repository.dart';
import '../data/stats_repository.dart';
import '../domain/board_size.dart';
import '../domain/card_category.dart';

final statsRepositoryProvider = Provider((ref) => StatsRepository());
final bestTimesRepositoryProvider = Provider((ref) => BestTimesRepository());

class StatsState {
  const StatsState({required this.stats, required this.bestTimesByBoardSize});

  final GameStats stats;
  final Map<BoardSize, int> bestTimesByBoardSize;

  static const empty = StatsState(
    stats: GameStats.initial,
    bestTimesByBoardSize: {},
  );
}

class StatsNotifier extends AsyncNotifier<StatsState> {
  @override
  Future<StatsState> build() async {
    final stats = await ref.read(statsRepositoryProvider).load();
    final bestTimes = await ref
        .read(bestTimesRepositoryProvider)
        .loadBestPerBoardSize();
    return StatsState(stats: stats, bestTimesByBoardSize: bestTimes);
  }

  Future<void> recordGameCompletion({
    required BoardSize boardSize,
    required CardCategory category,
    required int matches,
    required int playSeconds,
  }) async {
    final stats = await ref
        .read(statsRepositoryProvider)
        .recordGameCompletion(matches: matches, playSeconds: playSeconds);
    await ref
        .read(bestTimesRepositoryProvider)
        .recordIfBetter(boardSize, category, playSeconds);
    final bestTimes = await ref
        .read(bestTimesRepositoryProvider)
        .loadBestPerBoardSize();
    state = AsyncData(
      StatsState(stats: stats, bestTimesByBoardSize: bestTimes),
    );
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, StatsState>(
  StatsNotifier.new,
);
