import 'board_size.dart';

/// Simple, transparent score formula: a base score per board size, reduced by
/// extra moves and elapsed time beyond the theoretical minimum.
class ScoreCalculator {
  static int calculate({
    required BoardSize boardSize,
    required int elapsedSeconds,
    required int moves,
  }) {
    final base = boardSize.pairCount * 100;
    final minMoves = boardSize.pairCount;
    final extraMoves = (moves - minMoves).clamp(0, 1 << 30);
    final penalty = extraMoves * 5 + elapsedSeconds * 2;
    return (base - penalty).clamp(0, base);
  }
}
