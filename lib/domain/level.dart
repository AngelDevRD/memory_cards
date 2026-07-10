import 'board_size.dart';
import 'card_category.dart';

class Level {
  const Level({
    required this.number,
    required this.boardSize,
    required this.category,
  });

  final int number;
  final BoardSize boardSize;
  final CardCategory category;
}

/// Fixed progression: board size grows every few levels, categories cycle.
/// This is the "progressive difficulty" ladder — later levels use bigger
/// boards, which in turn have tighter star thresholds (see star_rating.dart).
class LevelDefinitions {
  static const int levelsPerBoardSize = 3;

  static final List<Level> all = List.generate(
    _boardOrder.length * levelsPerBoardSize,
    (i) {
      final boardSize = _boardOrder[i ~/ levelsPerBoardSize];
      final category = CardCategory.values[i % CardCategory.values.length];
      return Level(number: i + 1, boardSize: boardSize, category: category);
    },
  );

  static const List<BoardSize> _boardOrder = [
    BoardSize.size2x2,
    BoardSize.size4x4,
    BoardSize.size6x6,
    BoardSize.size8x8,
  ];

  static Level byNumber(int number) =>
      all.firstWhere((l) => l.number == number);
}
