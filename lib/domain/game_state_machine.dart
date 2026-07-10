import 'memory_card.dart';

/// Phases of a single game session.
///
/// [checking] is the key state: exactly two cards are face up and we are
/// waiting on a timed pause before resolving them. While in [checking], input
/// must be locked (no third card can be flipped) so the pending pair can't be
/// disturbed before it resolves to matched or flipped-back.
enum GamePhase { idle, oneFlipped, checking, won }

class GameStateMachineResult {
  const GameStateMachineResult({
    required this.cards,
    required this.phase,
    required this.moves,
  });

  final List<MemoryCard> cards;
  final GamePhase phase;
  final int moves;
}

/// Pure logic for flipping/matching cards. No Flutter, no timers — callers
/// drive the "checking" pause with their own delay and call [resolveCheck].
class GameStateMachine {
  GameStateMachine(List<MemoryCard> initialCards)
    : cards = List.unmodifiable(initialCards),
      phase = GamePhase.idle,
      moves = 0,
      _firstFlippedId = null,
      _secondFlippedId = null;

  List<MemoryCard> cards;
  GamePhase phase;
  int moves;
  int? _firstFlippedId;
  int? _secondFlippedId;

  bool get isWon => cards.every((c) => c.isMatched);

  /// Attempts to flip [cardId]. Ignored if input is locked (phase == checking),
  /// or the card is already matched/face up.
  GameStateMachineResult flipCard(int cardId) {
    if (phase == GamePhase.checking || phase == GamePhase.won) {
      return _result();
    }
    final card = cards.firstWhere((c) => c.id == cardId);
    if (card.isMatched || card.isFaceUp) {
      return _result();
    }

    cards = cards
        .map((c) => c.id == cardId ? c.copyWith(isFaceUp: true) : c)
        .toList();

    if (phase == GamePhase.idle) {
      _firstFlippedId = cardId;
      phase = GamePhase.oneFlipped;
    } else if (phase == GamePhase.oneFlipped) {
      _secondFlippedId = cardId;
      moves++;
      phase = GamePhase.checking;
    }
    return _result();
  }

  /// Called after the UI's pause delay elapses while in [GamePhase.checking].
  /// Resolves the pending pair: marks matched, or flips both back down.
  GameStateMachineResult resolveCheck() {
    if (phase != GamePhase.checking ||
        _firstFlippedId == null ||
        _secondFlippedId == null) {
      return _result();
    }
    final first = cards.firstWhere((c) => c.id == _firstFlippedId);
    final second = cards.firstWhere((c) => c.id == _secondFlippedId);
    final isMatch = first.pairId == second.pairId;

    cards = cards.map((c) {
      if (c.id == first.id || c.id == second.id) {
        return isMatch
            ? c.copyWith(isMatched: true, isFaceUp: true)
            : c.copyWith(isFaceUp: false);
      }
      return c;
    }).toList();

    _firstFlippedId = null;
    _secondFlippedId = null;
    phase = isWon ? GamePhase.won : GamePhase.idle;
    return _result();
  }

  GameStateMachineResult _result() =>
      GameStateMachineResult(cards: cards, phase: phase, moves: moves);
}
