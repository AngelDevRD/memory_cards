import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/level.dart';
import '../../providers/game_provider.dart';
import '../../providers/progress_provider.dart';

/// Numbered level list. Each level fixes a board size + category combo
/// (see [LevelDefinitions]); levels unlock in order as previous ones finish.
class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levels = ref.watch(levelListProvider);
    final progressAsync = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona un nivel')),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (progress) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              final unlocked = progress.isLevelUnlocked(level.number);
              final stars = progress.completedLevels[level.number] ?? 0;
              return Card(
                child: ListTile(
                  enabled: unlocked,
                  leading: CircleAvatar(child: Text('${level.number}')),
                  title: Text(
                    '${level.boardSize.label} · ${level.category.label}',
                  ),
                  subtitle: unlocked
                      ? Row(
                          children: List.generate(
                            3,
                            (i) => Icon(
                              i < stars ? Icons.star : Icons.star_border,
                              size: 18,
                              color: Colors.amber,
                            ),
                          ),
                        )
                      : const Text('Bloqueado'),
                  trailing: unlocked
                      ? const Icon(Icons.chevron_right)
                      : const Icon(Icons.lock_outline),
                  onTap: unlocked
                      ? () => context.push(
                          '/game',
                          extra: GameConfig(
                            boardSize: level.boardSize,
                            category: level.category,
                            levelNumber: level.number,
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
