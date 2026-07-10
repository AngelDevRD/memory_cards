import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/stats_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (statsState) {
          final stats = statsState.stats;
          final minutes = stats.totalPlaySeconds ~/ 60;
          final seconds = stats.totalPlaySeconds % 60;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatTile(
                icon: Icons.videogame_asset_outlined,
                label: 'Partidas jugadas',
                value: '${stats.gamesPlayed}',
              ),
              _StatTile(
                icon: Icons.check_circle_outline,
                label: 'Parejas encontradas',
                value: '${stats.totalMatches}',
              ),
              _StatTile(
                icon: Icons.schedule,
                label: 'Tiempo total jugado',
                value: '${minutes}m ${seconds}s',
              ),
              const Divider(height: 32),
              Text(
                'Mejor tiempo por tablero',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (statsState.bestTimesByBoardSize.isEmpty)
                const Text('Aún no hay tiempos registrados.'),
              ...statsState.bestTimesByBoardSize.entries.map(
                (entry) => _StatTile(
                  icon: Icons.emoji_events_outlined,
                  label: entry.key.label,
                  value: '${entry.value}s',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
