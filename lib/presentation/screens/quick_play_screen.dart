import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/board_size.dart';
import '../../domain/card_category.dart';
import '../../providers/game_provider.dart';

/// Free-play mode: pick any board size + category combo directly (as
/// opposed to the fixed level progression in LevelSelectScreen).
class QuickPlayScreen extends StatefulWidget {
  const QuickPlayScreen({super.key});

  @override
  State<QuickPlayScreen> createState() => _QuickPlayScreenState();
}

class _QuickPlayScreenState extends State<QuickPlayScreen> {
  BoardSize _boardSize = BoardSize.size4x4;
  CardCategory _category = CardCategory.animales;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partida rápida')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tamaño del tablero',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: BoardSize.values.map((size) {
                return ChoiceChip(
                  label: Text(size.label),
                  selected: _boardSize == size,
                  onSelected: (_) => setState(() => _boardSize = size),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Categoría', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CardCategory.values.map((category) {
                return ChoiceChip(
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push(
                  '/game',
                  extra: GameConfig(boardSize: _boardSize, category: _category),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Comenzar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
