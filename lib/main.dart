import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'presentation/app_theme.dart';
import 'presentation/screens/achievements_screen.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/level_select_screen.dart';
import 'presentation/screens/quick_play_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/stats_screen.dart';
import 'presentation/widgets/tutorial_overlay.dart';
import 'providers/game_provider.dart';
import 'providers/settings_provider.dart';

void main() {
  runApp(const ProviderScope(child: MemoryCardsApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const LevelSelectScreen(),
    ),
    GoRoute(
      path: '/quick-play',
      builder: (context, state) => const QuickPlayScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) =>
          GameScreen(config: state.extra as GameConfig),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class MemoryCardsApp extends ConsumerStatefulWidget {
  const MemoryCardsApp({super.key});

  @override
  ConsumerState<MemoryCardsApp> createState() => _MemoryCardsAppState();
}

class _MemoryCardsAppState extends ConsumerState<MemoryCardsApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final darkMode = settingsAsync.valueOrNull?.darkMode ?? false;

    return MaterialApp(
      title: 'Memory Cards',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: _showSplash
          ? SplashScreen(onFinished: () => setState(() => _showSplash = false))
          : _AppWithTutorial(router: _router),
    );
  }
}

/// Wraps the router in a Material app scaffold and overlays the one-time
/// tutorial on first launch, gated by SettingsRepository.tutorialSeen.
class _AppWithTutorial extends ConsumerWidget {
  const _AppWithTutorial({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final tutorialSeen = settingsAsync.valueOrNull?.tutorialSeen ?? true;

    return Stack(
      children: [
        Router.withConfig(config: router),
        if (!tutorialSeen)
          TutorialOverlay(
            onDismiss: () =>
                ref.read(settingsProvider.notifier).markTutorialSeen(),
          ),
      ],
    );
  }
}
