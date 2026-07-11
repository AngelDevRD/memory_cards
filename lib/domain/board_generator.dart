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
    final chosenSymbols = _symbolsFor(category, pairCount);
    assert(
      chosenSymbols.length >= pairCount,
      'Not enough symbols for this board size',
    );

    final cards = <MemoryCard>[];
    var id = 0;
    for (var pairId = 0; pairId < pairCount; pairId++) {
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

  /// Picks [pairCount] unique visual symbols for [category].
  ///
  /// Small boards (<= 32 pairs) fit entirely within the category's own emoji
  /// pool, same as before. Larger boards (up to 64x64 == 2048 pairs) need far
  /// more unique faces than any single category (or even all categories
  /// combined, ~190 emoji) can offer, so once the merged pool runs out this
  /// synthesizes extra symbols by pairing up two emoji into one glyph
  /// (e.g. "🐶🍎"), which yields tens of thousands of unique combinations —
  /// comfortably enough for the largest board.
  static List<String> _symbolsFor(CardCategory category, int pairCount) {
    final ownSymbols = category.symbols;
    if (pairCount <= ownSymbols.length) {
      return ownSymbols.take(pairCount).toList();
    }

    final merged = <String>[];
    final seen = <String>{};
    void addAll(Iterable<String> symbols) {
      for (final symbol in symbols) {
        if (seen.add(symbol)) merged.add(symbol);
      }
    }

    addAll(ownSymbols);
    for (final other in CardCategory.values) {
      if (other == category) continue;
      addAll(other.symbols);
    }

    if (pairCount <= merged.length) {
      return merged.take(pairCount).toList();
    }

    final combos = <String>[];
    outer:
    for (var i = 0; i < merged.length; i++) {
      for (var j = i + 1; j < merged.length; j++) {
        combos.add(merged[i] + merged[j]);
        if (merged.length + combos.length >= pairCount) break outer;
      }
    }

    return [...merged, ...combos];
  }
}
