import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_provider.dart';
import '../widgets/board_grid_widget.dart';

/// Active gameplay screen: board grid, move/timer HUD, end-of-game summary.
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key, required this.config});

  final GameConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider(config));
    final notifier = ref.read(gameProvider(config).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('${config.boardSize.label} · ${config.category.label}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HudChip(icon: Icons.touch_app, label: '${state.moves}'),
                _HudChip(
                  icon: Icons.timer_outlined,
                  label: _formatTime(state.elapsedSeconds),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: BoardGridWidget(
                boardSize: config.boardSize,
                cards: state.cards,
                onCardTap: notifier.flipCard,
              ),
            ),
          ),
          if (state.isComplete) _CompletionBanner(state: state),
        ],
      ),
    );
  }

  static String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner({required this.state});

  final GameUiState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('¡Completado!', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Icon(
                i < state.stars ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Puntuación: ${state.score}'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}
