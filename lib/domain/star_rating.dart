import 'board_size.dart';

/// Computes 1-3 stars from elapsed seconds + moves, against thresholds that
/// scale with board size (bigger boards get looser time/move budgets).
class StarRating {
  static int calculate({
    required BoardSize boardSize,
    required int elapsedSeconds,
    required int moves,
  }) {
    final thresholds = _thresholdsFor(boardSize.pairCount);

    if (elapsedSeconds <= thresholds.threeStarSeconds &&
        moves <= thresholds.threeStarMoves) {
      return 3;
    }
    if (elapsedSeconds <= thresholds.twoStarSeconds &&
        moves <= thresholds.twoStarMoves) {
      return 2;
    }
    return 1;
  }

  /// Thresholds are derived from [pairCount] (the theoretical minimum move
  /// count) instead of a fixed per-size table, so every board size — up to
  /// the 2048-pair 64x64 board — gets a sensible, progressively looser
  /// budget without needing a manually maintained entry. The multipliers
  /// below were fitted to match the original hand-tuned 4x4/6x6/8x8 values.
  static _Thresholds _thresholdsFor(int pairCount) {
    final threeStarSeconds = pairCount * 5;
    final threeStarMoves = (pairCount * 1.6).ceil();
    final twoStarSeconds = (threeStarSeconds * 1.7).round();
    final twoStarMoves = (threeStarMoves * 1.7).round();
    return _Thresholds(
      threeStarSeconds: threeStarSeconds,
      threeStarMoves: threeStarMoves,
      twoStarSeconds: twoStarSeconds,
      twoStarMoves: twoStarMoves,
    );
  }
}

class _Thresholds {
  const _Thresholds({
    required this.threeStarSeconds,
    required this.threeStarMoves,
    required this.twoStarSeconds,
    required this.twoStarMoves,
  });

  final int threeStarSeconds;
  final int threeStarMoves;
  final int twoStarSeconds;
  final int twoStarMoves;
}
