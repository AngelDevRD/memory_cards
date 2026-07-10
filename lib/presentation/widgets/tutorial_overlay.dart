import 'package:flutter/material.dart';

/// First-launch overlay explaining the core mechanic. Shown once; caller is
/// responsible for persisting the "seen" flag (see SettingsRepository.tutorialSeen).
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '¿Cómo se juega?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Toca una carta para voltearla. Luego toca otra: '
                'si los dibujos coinciden, la pareja queda emparejada. '
                'Si no coinciden, ambas se voltean de nuevo. '
                '¡Encuentra todas las parejas lo más rápido posible!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onDismiss,
                child: const Text('Entendido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
