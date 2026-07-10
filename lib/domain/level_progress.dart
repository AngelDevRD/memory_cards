/// Pure unlock rule: a level is unlocked if it's level 1, or the previous
/// level has been completed (present as a key in [completedLevels], any star value).
class LevelProgress {
  static bool isUnlocked(int levelNumber, Map<int, int> completedLevels) {
    if (levelNumber <= 1) return true;
    return completedLevels.containsKey(levelNumber - 1);
  }

  static int highestUnlocked(Map<int, int> completedLevels, int totalLevels) {
    for (var n = totalLevels; n >= 1; n--) {
      if (isUnlocked(n, completedLevels)) return n;
    }
    return 1;
  }
}
