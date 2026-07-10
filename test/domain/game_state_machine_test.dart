import 'package:flutter_test/flutter_test.dart';
import 'package:memory_cards/domain/game_state_machine.dart';
import 'package:memory_cards/domain/memory_card.dart';

void main() {
  List<MemoryCard> twoPairBoard() => [
    MemoryCard(id: 0, pairId: 0, symbol: 'A'),
    MemoryCard(id: 1, pairId: 0, symbol: 'A'),
    MemoryCard(id: 2, pairId: 1, symbol: 'B'),
    MemoryCard(id: 3, pairId: 1, symbol: 'B'),
  ];

  group('GameStateMachine', () {
    test('starts idle', () {
      final machine = GameStateMachine(twoPairBoard());
      expect(machine.phase, GamePhase.idle);
      expect(machine.moves, 0);
    });

    test('first flip moves to oneFlipped, does not count a move', () {
      final machine = GameStateMachine(twoPairBoard());
      final result = machine.flipCard(0);
      expect(result.phase, GamePhase.oneFlipped);
      expect(result.moves, 0);
      expect(result.cards.firstWhere((c) => c.id == 0).isFaceUp, isTrue);
    });

    test('second flip moves to checking and counts a move', () {
      final machine = GameStateMachine(twoPairBoard());
      machine.flipCard(0);
      final result = machine.flipCard(2);
      expect(result.phase, GamePhase.checking);
      expect(result.moves, 1);
    });

    test('input is locked while checking: a third flip is ignored', () {
      final machine = GameStateMachine(twoPairBoard());
      machine.flipCard(0);
      machine.flipCard(2);
      final beforeThirdFlip = machine.cards;
      final result = machine.flipCard(3);
      expect(result.phase, GamePhase.checking);
      expect(result.cards, beforeThirdFlip);
      expect(
        result.cards.firstWhere((c) => c.id == 3).isFaceUp,
        isFalse,
        reason: 'card 3 must not flip while a pending pair is checking',
      );
    });

    test('resolveCheck marks a real match as matched and stays face up', () {
      final machine = GameStateMachine(twoPairBoard());
      machine.flipCard(0);
      machine.flipCard(1); // same pairId -> match
      final result = machine.resolveCheck();
      expect(result.cards.where((c) => c.isMatched).length, 2);
      expect(result.cards.every((c) => c.id > 1 || c.isFaceUp), isTrue);
      expect(result.phase, GamePhase.idle);
    });

    test('resolveCheck flips back a non-match', () {
      final machine = GameStateMachine(twoPairBoard());
      machine.flipCard(0);
      machine.flipCard(2); // different pairId -> no match
      final result = machine.resolveCheck();
      expect(result.cards.every((c) => !c.isFaceUp), isTrue);
      expect(result.cards.every((c) => !c.isMatched), isTrue);
      expect(result.phase, GamePhase.idle);
    });

    test('reaches won phase once all pairs matched', () {
      final machine = GameStateMachine(twoPairBoard());
      machine.flipCard(0);
      machine.flipCard(1);
      machine.resolveCheck();
      machine.flipCard(2);
      final result = machine.flipCard(3);
      expect(result.phase, GamePhase.checking);
      final finalResult = machine.resolveCheck();
      expect(finalResult.phase, GamePhase.won);
      expect(machine.isWon, isTrue);
    });

    test('flipping an already-matched card is ignored', () {
      final machine = GameStateMachine(twoPairBoard());
      machine.flipCard(0);
      machine.flipCard(1);
      machine.resolveCheck();
      final result = machine.flipCard(0);
      expect(result.phase, GamePhase.idle);
      expect(result.moves, 1);
    });
  });
}
