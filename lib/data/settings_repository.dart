import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    required this.darkMode,
    required this.soundOn,
    required this.vibrationOn,
    required this.tutorialSeen,
  });

  final bool darkMode;
  final bool soundOn;
  final bool vibrationOn;
  final bool tutorialSeen;

  AppSettings copyWith({
    bool? darkMode,
    bool? soundOn,
    bool? vibrationOn,
    bool? tutorialSeen,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      soundOn: soundOn ?? this.soundOn,
      vibrationOn: vibrationOn ?? this.vibrationOn,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
    );
  }

  static const initial = AppSettings(
    darkMode: false,
    soundOn: true,
    vibrationOn: true,
    tutorialSeen: false,
  );
}

class SettingsRepository {
  static const _kDarkMode = 'settings_dark_mode';
  static const _kSoundOn = 'settings_sound_on';
  static const _kVibrationOn = 'settings_vibration_on';
  static const _kTutorialSeen = 'settings_tutorial_seen';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      darkMode: prefs.getBool(_kDarkMode) ?? AppSettings.initial.darkMode,
      soundOn: prefs.getBool(_kSoundOn) ?? AppSettings.initial.soundOn,
      vibrationOn:
          prefs.getBool(_kVibrationOn) ?? AppSettings.initial.vibrationOn,
      tutorialSeen:
          prefs.getBool(_kTutorialSeen) ?? AppSettings.initial.tutorialSeen,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, settings.darkMode);
    await prefs.setBool(_kSoundOn, settings.soundOn);
    await prefs.setBool(_kVibrationOn, settings.vibrationOn);
    await prefs.setBool(_kTutorialSeen, settings.tutorialSeen);
  }
}
