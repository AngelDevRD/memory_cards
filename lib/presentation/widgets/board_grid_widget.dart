import 'package:flutter/material.dart';

import '../../domain/board_size.dart';
import '../../domain/memory_card.dart';
import 'memory_card_widget.dart';

/// Lays out cards in a square grid that scales with available space
/// (LayoutBuilder + AspectRatio), so it adapts to phones and tablets alike.
class BoardGridWidget extends StatelessWidget {
  const BoardGridWidget({
    super.key,
    required this.boardSize,
    required this.cards,
    required this.onCardTap,
  });

  final BoardSize boardSize;
  final List<MemoryCard> cards;
  final void Function(int cardId) onCardTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: boardSize.cols,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return MemoryCardWidget(
                  card: card,
                  onTap: () => onCardTap(card.id),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
