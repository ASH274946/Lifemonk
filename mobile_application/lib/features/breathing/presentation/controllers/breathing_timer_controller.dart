import 'dart:async';
import 'package:flutter/material.dart';

/// Controls the breathing session timer and time-based effects
class BreathingTimerController {
  final int sessionDurationSeconds;
  final VoidCallback? onTick;
  final VoidCallback? onComplete;
  final VoidCallback? onThirtySecondsLeft;
  final VoidCallback? onTenSecondsLeft;

  Timer? _timer;
  int _remainingSeconds;
  bool _isRunning = false;

  BreathingTimerController({
    required this.sessionDurationSeconds,
    this.onTick,
    this.onComplete,
    this.onThirtySecondsLeft,
    this.onTenSecondsLeft,
  }) : _remainingSeconds = sessionDurationSeconds;

  /// Start the timer
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        onTick?.call();

        // Trigger callbacks at specific thresholds
        if (_remainingSeconds == 30) {
          onThirtySecondsLeft?.call();
        } else if (_remainingSeconds == 10) {
          onTenSecondsLeft?.call();
        }
      } else {
        stop();
        onComplete?.call();
      }
    });
  }

  /// Pause the timer
  void pause() {
    _isRunning = false;
    _timer?.cancel();
  }

  /// Resume the timer
  void resume() {
    start();
  }

  /// Stop and reset the timer
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Reset timer to initial duration
  void reset() {
    stop();
    _remainingSeconds = sessionDurationSeconds;
  }

  /// Get remaining time in seconds
  int get remainingSeconds => _remainingSeconds;

  /// Get remaining time formatted as MM:SS
  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get progress as a value between 0.0 and 1.0
  double get progress {
    return 1.0 - (_remainingSeconds / sessionDurationSeconds);
  }

  /// Check if timer is running
  bool get isRunning => _isRunning;

  /// Check if session is complete
  bool get isComplete => _remainingSeconds <= 0;

  /// Check if less than 30 seconds remaining
  bool get isNearEnd => _remainingSeconds <= 30 && _remainingSeconds > 10;

  /// Check if less than 10 seconds remaining
  bool get isAlmostDone => _remainingSeconds <= 10 && _remainingSeconds > 0;

  /// Dispose the timer
  void dispose() {
    stop();
  }
}
