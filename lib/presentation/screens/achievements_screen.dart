import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/achievement.dart';
import '../../providers/progress_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Logros')),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (progress) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: Achievements.all.length,
          itemBuilder: (context, index) {
            final achievement = Achievements.all[index];
            final unlocked = progress.unlockedAchievements.contains(
              achievement.id,
            );
            return Card(
              child: ListTile(
                leading: Icon(
                  unlocked ? Icons.emoji_events : Icons.emoji_events_outlined,
                  color: unlocked ? Colors.amber : null,
                ),
                title: Text(achievement.title),
                subtitle: Text(achievement.description),
                trailing: unlocked
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
