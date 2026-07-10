import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_cards/domain/board_generator.dart';
import 'package:memory_cards/domain/board_size.dart';
import 'package:memory_cards/domain/card_category.dart';

void main() {
  group('BoardGenerator', () {
    for (final boardSize in BoardSize.values) {
      test('generates correct pair count for ${boardSize.label}', () {
        final cards = BoardGenerator.generate(
          boardSize: boardSize,
          category: CardCategory.animales,
          random: Random(42),
        );

        expect(cards.length, boardSize.totalCards);

        final counts = <int, int>{};
        for (final card in cards) {
          counts[card.pairId] = (counts[card.pairId] ?? 0) + 1;
        }
        expect(counts.length, boardSize.pairCount);
        expect(counts.values.every((c) => c == 2), isTrue);
      });
    }

    test('no duplicate symbols across different pairs', () {
      final cards = BoardGenerator.generate(
        boardSize: BoardSize.size8x8,
        category: CardCategory.emojis,
        random: Random(1),
      );

      final symbolToPairId = <String, int>{};
      for (final card in cards) {
        final existingPairId = symbolToPairId[card.symbol];
        if (existingPairId != null) {
          expect(existingPairId, card.pairId);
        } else {
          symbolToPairId[card.symbol] = card.pairId;
        }
      }
      // Exactly pairCount unique symbols used.
      expect(symbolToPairId.length, BoardSize.size8x8.pairCount);
    });

    test('every category has enough symbols for the largest board', () {
      for (final category in CardCategory.values) {
        expect(
          category.symbols.length,
          greaterThanOrEqualTo(BoardSize.size8x8.pairCount),
          reason: '${category.label} pool too small',
        );
        expect(
          category.symbols.toSet().length,
          category.symbols.length,
          reason: '${category.label} pool has duplicate symbols',
        );
      }
    });

    test('ids are unique across the generated board', () {
      final cards = BoardGenerator.generate(
        boardSize: BoardSize.size6x6,
        category: CardCategory.comida,
        random: Random(7),
      );
      final ids = cards.map((c) => c.id).toSet();
      expect(ids.length, cards.length);
    });
  });
}
