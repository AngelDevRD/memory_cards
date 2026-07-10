import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Landing screen: navigate to level select, achievements, stats, settings.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Cards')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.style_rounded,
                  size: 96,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Memory Cards',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 40),
                FilledButton.icon(
                  onPressed: () => context.go('/levels'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Jugar por niveles'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/quick-play'),
                  icon: const Icon(Icons.bolt_outlined),
                  label: const Text('Partida rápida'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/achievements'),
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: const Text('Logros'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/stats'),
                  icon: const Icon(Icons.bar_chart_rounded),
                  label: const Text('Estadísticas'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/settings'),
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Ajustes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
