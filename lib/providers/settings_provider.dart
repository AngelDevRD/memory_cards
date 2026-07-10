import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> _update(AppSettings Function(AppSettings) transform) async {
    final current = state.valueOrNull ?? AppSettings.initial;
    final updated = transform(current);
    state = AsyncData(updated);
    await ref.read(settingsRepositoryProvider).save(updated);
  }

  Future<void> toggleDarkMode() =>
      _update((s) => s.copyWith(darkMode: !s.darkMode));
  Future<void> toggleSound() => _update((s) => s.copyWith(soundOn: !s.soundOn));
  Future<void> toggleVibration() =>
      _update((s) => s.copyWith(vibrationOn: !s.vibrationOn));
  Future<void> markTutorialSeen() =>
      _update((s) => s.copyWith(tutorialSeen: true));
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
