// lib/core/audio/game_audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GameSfx {
  pop('audio/sfx_pop.wav'),
  sizzle('audio/sfx_sizzle.wav'),
  serve('audio/sfx_serve.wav'),
  coin('audio/sfx_coin.wav');

  final String assetPath;
  const GameSfx(this.assetPath);
}

final audioMutedProvider = StateProvider<bool>((ref) => false);

final gameAudioServiceProvider = Provider<GameAudioService>((ref) {
  final service = GameAudioService(ref);
  ref.onDispose(service.dispose);
  return service;
});

class GameAudioService {
  final Ref _ref;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _isBgmPlaying = false;

  GameAudioService(this._ref) {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bgmPlayer.setVolume(0.32);
    _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    _sfxPlayer.setVolume(0.85);
  }

  Future<void> startBgm() async {
    final isMuted = _ref.read(audioMutedProvider);
    if (isMuted || _isBgmPlaying) return;
    try {
      await _bgmPlayer.play(AssetSource('audio/bgm_korean_cafe.wav'));
      _isBgmPlaying = true;
    } catch (_) {
      // Safe fallback on simulators without audio hardware
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      _isBgmPlaying = false;
    } catch (_) {}
  }

  Future<void> playSfx(GameSfx sfx) async {
    final isMuted = _ref.read(audioMutedProvider);
    if (isMuted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(sfx.assetPath));
    } catch (_) {}
  }

  Future<void> toggleMute() async {
    final nextMuted = !_ref.read(audioMutedProvider);
    _ref.read(audioMutedProvider.notifier).state = nextMuted;
    if (nextMuted) {
      await stopBgm();
    } else {
      await startBgm();
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
