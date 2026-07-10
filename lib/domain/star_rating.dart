import 'board_size.dart';

/// Computes 1-3 stars from elapsed seconds + moves, against thresholds that
/// scale with board size (bigger boards get looser time/move budgets).
class StarRating {
  static int calculate({
    required BoardSize boardSize,
    required int elapsedSeconds,
    required int moves,
  }) {
    final thresholds = _thresholds[boardSize]!;

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

/// pairCount is the minimum possible moves; thresholds are multiples of it.
const Map<BoardSize, _Thresholds> _thresholds = {
  BoardSize.size2x2: _Thresholds(
    threeStarSeconds: 10,
    threeStarMoves: 2,
    twoStarSeconds: 20,
    twoStarMoves: 4,
  ),
  BoardSize.size4x4: _Thresholds(
    threeStarSeconds: 40,
    threeStarMoves: 12,
    twoStarSeconds: 70,
    twoStarMoves: 20,
  ),
  BoardSize.size6x6: _Thresholds(
    threeStarSeconds: 90,
    threeStarMoves: 30,
    twoStarSeconds: 150,
    twoStarMoves: 46,
  ),
  BoardSize.size8x8: _Thresholds(
    threeStarSeconds: 160,
    threeStarMoves: 56,
    twoStarSeconds: 260,
    twoStarMoves: 84,
  ),
};
