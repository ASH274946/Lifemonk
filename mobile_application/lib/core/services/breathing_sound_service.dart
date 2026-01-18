import 'package:audioplayers/audioplayers.dart';

/// Breathing Sound Service - Manages sounds synced with breathing animation
/// Each breathing phase has a dedicated sound file
class BreathingSoundService {
  static final BreathingSoundService _instance = BreathingSoundService._internal();
  factory BreathingSoundService() => _instance;
  BreathingSoundService._internal();

  // Separate audio players for different sound types
  final AudioPlayer _breathingPlayer = AudioPlayer();
  final AudioPlayer _buttonPlayer = AudioPlayer();
  
  bool _isInitialized = false;
  bool _soundEnabled = true;
  double _volume = 0.6;

  // Dedicated sound URLs for each breathing phase
  static const String _inhaleSound = 'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3';
  static const String _holdSound = 'https://cdn.pixabay.com/download/audio/2021/08/04/audio_12b0c7443c.mp3';
  static const String _exhaleSound = 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_c4e3f3f3e7.mp3';
  
  // Button interaction sounds
  static const String _startSound = 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_d1718ab41b.mp3';
  static const String _pauseSound = 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_c2c0d0c3c8.mp3';
  static const String _stopSound = 'https://cdn.pixabay.com/download/audio/2022/03/20/audio_e2e0f75d8a.mp3';

  String? _currentPhase;

  /// Initialize and preload all sound files
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _breathingPlayer.setVolume(_volume);
      await _buttonPlayer.setVolume(_volume * 0.7);
      
      // Preload sounds for faster playback
      await _preloadSound(_inhaleSound);
      await _preloadSound(_exhaleSound);
      await _preloadSound(_holdSound);
      
      _isInitialized = true;
    } catch (e) {
      // Silent fail - audio is optional
    }
  }

  Future<void> _preloadSound(String url) async {
    try {
      final player = AudioPlayer();
      await player.setSource(UrlSource(url));
      await player.setVolume(0);
      await player.resume();
      await Future.delayed(const Duration(milliseconds: 100));
      await player.stop();
      await player.dispose();
    } catch (e) {
      // Silent fail
    }
  }

  /// Play inhale sound with fade-in
  Future<void> playInhale() async {
    if (!_soundEnabled || !_isInitialized || _currentPhase == 'inhale') return;
    _currentPhase = 'inhale';
    
    try {
      await _breathingPlayer.stop();
      await _breathingPlayer.setSource(UrlSource(_inhaleSound));
      await _breathingPlayer.setVolume(0);
      await _breathingPlayer.resume();
      
      _fadeVolume(_breathingPlayer, 0, _volume, 1000);
    } catch (e) {
      // Silent fail
    }
  }

  /// Play hold sound
  Future<void> playHold() async {
    if (!_soundEnabled || !_isInitialized || _currentPhase == 'hold') return;
    _currentPhase = 'hold';
    
    try {
      await _fadeVolume(_breathingPlayer, _volume, 0, 500);
      await _breathingPlayer.stop();
      
      await _breathingPlayer.setSource(UrlSource(_holdSound));
      await _breathingPlayer.setVolume(_volume * 0.2);
      await _breathingPlayer.resume();
    } catch (e) {
      // Silent fail
    }
  }

  /// Play exhale sound with fade-out
  Future<void> playExhale() async {
    if (!_soundEnabled || !_isInitialized || _currentPhase == 'exhale') return;
    _currentPhase = 'exhale';
    
    try {
      await _breathingPlayer.stop();
      await _breathingPlayer.setSource(UrlSource(_exhaleSound));
      await _breathingPlayer.setVolume(_volume);
      await _breathingPlayer.resume();
      
      Future.delayed(const Duration(milliseconds: 2500), () {
        _fadeVolume(_breathingPlayer, _volume, 0, 1500);
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Play start button sound
  Future<void> playStartSound() async {
    if (!_soundEnabled || !_isInitialized) return;
    await _playButtonSound(_startSound);
  }

  /// Play pause button sound
  Future<void> playPauseSound() async {
    if (!_soundEnabled || !_isInitialized) return;
    await _playButtonSound(_pauseSound);
  }

  /// Play stop button sound
  Future<void> playStopSound() async {
    if (!_soundEnabled || !_isInitialized) return;
    await _playButtonSound(_stopSound);
  }

  Future<void> _playButtonSound(String soundUrl) async {
    try {
      await _buttonPlayer.stop();
      await _buttonPlayer.setSource(UrlSource(soundUrl));
      await _buttonPlayer.setVolume(_volume * 0.7);
      await _buttonPlayer.resume();
    } catch (e) {
      // Silent fail
    }
  }

  /// Fade volume smoothly
  Future<void> _fadeVolume(
    AudioPlayer player,
    double fromVolume,
    double toVolume,
    int durationMs,
  ) async {
    const steps = 20;
    final stepDuration = durationMs ~/ steps;
    final volumeStep = (toVolume - fromVolume) / steps;

    for (int i = 0; i <= steps; i++) {
      final currentVolume = fromVolume + (volumeStep * i);
      await player.setVolume(currentVolume.clamp(0.0, 1.0));
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }

  /// Stop all sounds immediately
  Future<void> stopAllSounds() async {
    try {
      await _breathingPlayer.stop();
      await _buttonPlayer.stop();
      _currentPhase = null;
    } catch (e) {
      // Silent fail
    }
  }

  /// Set volume
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _breathingPlayer.setVolume(_volume);
    _buttonPlayer.setVolume(_volume * 0.7);
  }

  /// Enable or disable sounds
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      stopAllSounds();
    }
  }

  /// Check if sounds are enabled
  bool get isSoundEnabled => _soundEnabled;

  /// Dispose resources
  Future<void> dispose() async {
    await _breathingPlayer.dispose();
    await _buttonPlayer.dispose();
    _isInitialized = false;
    _currentPhase = null;
  }
}
