import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/progress_repository.dart';
import '../domain/achievement.dart';
import '../domain/level.dart';
import '../domain/level_progress.dart';

final progressRepositoryProvider = Provider((ref) => ProgressRepository());

class ProgressState {
  const ProgressState({
    required this.completedLevels,
    required this.unlockedAchievements,
  });

  final Map<int, int> completedLevels;
  final Set<String> unlockedAchievements;

  bool isLevelUnlocked(int levelNumber) =>
      LevelProgress.isUnlocked(levelNumber, completedLevels);

  static const empty = ProgressState(
    completedLevels: {},
    unlockedAchievements: {},
  );
}

class ProgressNotifier extends AsyncNotifier<ProgressState> {
  @override
  Future<ProgressState> build() async {
    final repo = ref.read(progressRepositoryProvider);
    final levels = await repo.loadCompletedLevels();
    final achievements = await repo.loadAchievements();
    return ProgressState(
      completedLevels: levels,
      unlockedAchievements: achievements,
    );
  }

  Future<void> recordLevelCompletion(int levelNumber, int stars) async {
    final repo = ref.read(progressRepositoryProvider);
    final levels = await repo.recordLevelCompletion(levelNumber, stars);
    final current = state.valueOrNull ?? ProgressState.empty;
    state = AsyncData(
      ProgressState(
        completedLevels: levels,
        unlockedAchievements: current.unlockedAchievements,
      ),
    );
    await _checkThreeStarAchievement(levels);
  }

  Future<void> _checkThreeStarAchievement(Map<int, int> levels) async {
    final threeStarCount = levels.values.where((s) => s == 3).length;
    if (threeStarCount >= 5) {
      await unlockAchievement(Achievements.threeStarsFiveLevels.id);
    }
  }

  Future<void> unlockAchievement(String id) async {
    final repo = ref.read(progressRepositoryProvider);
    final achievements = await repo.unlockAchievement(id);
    final current = state.valueOrNull ?? ProgressState.empty;
    state = AsyncData(
      ProgressState(
        completedLevels: current.completedLevels,
        unlockedAchievements: achievements,
      ),
    );
  }
}

final progressProvider = AsyncNotifierProvider<ProgressNotifier, ProgressState>(
  ProgressNotifier.new,
);

final levelListProvider = Provider<List<Level>>((ref) => LevelDefinitions.all);
