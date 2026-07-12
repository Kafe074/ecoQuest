import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

/// Thin wrapper around [FlameAudio] for the world's placeholder sound
/// effects. Playback failures are swallowed here: sound is a non-critical
/// enhancement, and audio hardware/platform support can't be guaranteed
/// (this also keeps unit tests, which have no audio plugin, from crashing).
class Sfx {
  Sfx._();

  static const footstepFile = 'footstep.wav';
  static const chimeFile = 'chime.wav';

  static Future<void> preload() async {
    try {
      await FlameAudio.audioCache.loadAll([footstepFile, chimeFile]);
    } catch (_) {
      // Ignore: sound is optional polish, not required for gameplay.
    }
  }

  static void footstep() => unawaited(_safePlay(footstepFile, 0.35));

  static void chime() => unawaited(_safePlay(chimeFile, 0.5));

  static Future<void> _safePlay(String file, double volume) async {
    try {
      await FlameAudio.play(file, volume: volume);
    } catch (_) {
      // Ignore: see class doc.
    }
  }
}
