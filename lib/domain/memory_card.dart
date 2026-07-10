/// A single card in the board. [pairId] links two cards that match.
class MemoryCard {
  MemoryCard({
    required this.id,
    required this.pairId,
    required this.symbol,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  final int id;
  final int pairId;
  final String symbol;
  final bool isFaceUp;
  final bool isMatched;

  MemoryCard copyWith({bool? isFaceUp, bool? isMatched}) {
    return MemoryCard(
      id: id,
      pairId: pairId,
      symbol: symbol,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
