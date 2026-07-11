import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/level.dart';
import '../../providers/game_provider.dart';
import '../widgets/board_grid_widget.dart';

/// Active gameplay screen: board grid, move/timer HUD, end-of-game summary.
///
/// Holds the active [GameConfig] as local state (instead of a fixed widget
/// field) so that finishing a level can swap straight to the next one's
/// config in place — Riverpod's family provider then builds a fresh board
/// for the new config automatically, no navigation involved.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.config});

  final GameConfig config;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GameConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
  }

  Level? get _nextLevel {
    final currentNumber = _config.levelNumber;
    if (currentNumber == null) return null;
    final nextNumber = currentNumber + 1;
    if (nextNumber > LevelDefinitions.all.length) return null;
    return LevelDefinitions.byNumber(nextNumber);
  }

  void _retry() {
    ref.invalidate(gameProvider(_config));
  }

  void _goToNextLevel() {
    final next = _nextLevel;
    if (next == null) return;
    setState(() {
      _config = GameConfig(
        boardSize: next.boardSize,
        category: next.category,
        levelNumber: next.number,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider(_config));

    return Scaffold(
      appBar: AppBar(
        title: Text('${_config.boardSize.label} · ${_config.category.label}'),
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
              child: BoardGridWidget(key: ValueKey(_config), config: _config),
            ),
          ),
          if (state.isComplete)
            _CompletionBanner(
              state: state,
              hasNextLevel: _nextLevel != null,
              onRetry: _retry,
              onNextLevel: _goToNextLevel,
            ),
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
  const _CompletionBanner({
    required this.state,
    required this.hasNextLevel,
    required this.onRetry,
    required this.onNextLevel,
  });

  final GameUiState state;
  final bool hasNextLevel;
  final VoidCallback onRetry;
  final VoidCallback onNextLevel;

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
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver'),
              ),
              if (hasNextLevel)
                FilledButton(
                  onPressed: onNextLevel,
                  child: const Text('Siguiente nivel'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
