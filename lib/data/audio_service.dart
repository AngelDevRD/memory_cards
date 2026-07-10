import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around audioplayers. No real audio asset files are bundled
/// (avoids shipping copyrighted/placeholder sound files) — playback is
/// best-effort and silently no-ops if the asset is missing, so the game is
/// fully playable without sound.
class AudioService {
  final _player = AudioPlayer();

  Future<void> playFlip() => _playSafely('sounds/flip.mp3');
  Future<void> playMatch() => _playSafely('sounds/match.mp3');
  Future<void> playWin() => _playSafely('sounds/win.mp3');

  Future<void> _playSafely(String assetPath) async {
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('AudioService: no se pudo reproducir $assetPath ($e)');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
