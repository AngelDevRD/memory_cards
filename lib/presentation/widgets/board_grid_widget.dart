import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_provider.dart';
import 'memory_card_widget.dart';

/// Lays out cards in a square grid that scales with available space.
///
/// Cells never shrink below [_minCellSize], so boards up to 64x64 stay
/// tappable: when the full grid can't fit the viewport at a legible size, it
/// is wrapped in an [InteractiveViewer] so the player can pinch-zoom and pan
/// instead of the board getting clipped or overflowing the layout.
class BoardGridWidget extends StatelessWidget {
  const BoardGridWidget({super.key, required this.config});

  final GameConfig config;

  static const double _minCellSize = 40;
  static const double _maxCellSize = 96;
  static const double _gridPadding = 16;

  @override
  Widget build(BuildContext context) {
    final boardSize = config.boardSize;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final availableSide = (side - _gridPadding).clamp(1.0, double.infinity);
        final cellSize = (availableSide / boardSize.cols).clamp(
          _minCellSize,
          _maxCellSize,
        );
        final contentSize = cellSize * boardSize.cols + _gridPadding;
        final minScale = (side / contentSize).clamp(0.05, 1.0);

        return Center(
          child: InteractiveViewer(
            constrained: false,
            minScale: minScale,
            maxScale: 4,
            boundaryMargin: const EdgeInsets.all(80),
            child: SizedBox(
              width: contentSize,
              height: contentSize,
              child: GridView.builder(
                padding: const EdgeInsets.all(_gridPadding / 2),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: boardSize.cols,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                itemCount: boardSize.totalCards,
                itemBuilder: (context, index) {
                  return _BoardCell(config: config, index: index);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Watches only its own card (via Riverpod `select`) so flipping one card
/// only rebuilds the 1-2 affected cells instead of the entire grid — the
/// difference between a snappy flip and a full rebuild of up to 4096 cells.
class _BoardCell extends ConsumerWidget {
  const _BoardCell({required this.config, required this.index});

  final GameConfig config;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(
      gameProvider(config).select((state) => state.cards[index]),
    );
    final notifier = ref.read(gameProvider(config).notifier);
    return MemoryCardWidget(
      card: card,
      onTap: () => notifier.flipCard(card.id),
    );
  }
}
