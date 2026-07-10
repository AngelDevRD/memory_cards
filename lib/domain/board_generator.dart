import 'dart:math';

import 'board_size.dart';
import 'card_category.dart';
import 'memory_card.dart';

/// Builds a shuffled list of [MemoryCard]s for a board size + category.
class BoardGenerator {
  /// [random] is injectable for deterministic tests.
  static List<MemoryCard> generate({
    required BoardSize boardSize,
    required CardCategory category,
    Random? random,
  }) {
    final pairCount = boardSize.pairCount;
    final symbols = category.symbols;
    assert(
      symbols.length >= pairCount,
      'Not enough symbols for this board size',
    );

    final chosenSymbols = symbols.take(pairCount).toList();
    final cards = <MemoryCard>[];
    var id = 0;
    for (var pairId = 0; pairId < chosenSymbols.length; pairId++) {
      cards.add(
        MemoryCard(id: id++, pairId: pairId, symbol: chosenSymbols[pairId]),
      );
      cards.add(
        MemoryCard(id: id++, pairId: pairId, symbol: chosenSymbols[pairId]),
      );
    }
    cards.shuffle(random ?? Random());
    return cards;
  }
}
