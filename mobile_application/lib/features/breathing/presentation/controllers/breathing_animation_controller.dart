import 'package:flutter/material.dart';

/// Controls the breathing animation cycle: Inhale → Hold → Exhale
class BreathingAnimationController {
  final TickerProvider vsync;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Breathing phase tracking
  BreathingPhase _currentPhase = BreathingPhase.inhale;

  // Callbacks
  final VoidCallback? onPhaseChange;

  // Duration for each phase (in seconds)
  static const int inhaleDuration = 4;
  static const int holdDuration = 1;
  static const int exhaleDuration = 4;
  static const int totalCycleDuration =
      inhaleDuration + holdDuration + exhaleDuration;

  BreathingAnimationController({required this.vsync, this.onPhaseChange}) {
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: totalCycleDuration),
    );

    // Create a multi-step animation:
    // 0.0 - 0.44 (4s): Inhale (scale 0.8 → 1.2)
    // 0.44 - 0.55 (1s): Hold (stay at 1.2)
    // 0.55 - 1.0 (4s): Exhale (scale 1.2 → 0.8)

    _scaleAnimation = TweenSequence<double>([
      // Inhale phase
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.8,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: inhaleDuration.toDouble(),
      ),
      // Hold phase
      TweenSequenceItem(
        tween: ConstantTween<double>(1.2),
        weight: holdDuration.toDouble(),
      ),
      // Exhale phase
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 0.8,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: exhaleDuration.toDouble(),
      ),
    ]).animate(_controller);

    // Listen for animation progress to update phase
    _controller.addListener(_updatePhase);

    // Loop the animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0.0);
      }
    });
  }

  void _updatePhase() {
    final progress = _controller.value;
    BreathingPhase newPhase;

    if (progress < inhaleDuration / totalCycleDuration) {
      newPhase = BreathingPhase.inhale;
    } else if (progress <
        (inhaleDuration + holdDuration) / totalCycleDuration) {
      newPhase = BreathingPhase.hold;
    } else {
      newPhase = BreathingPhase.exhale;
    }

    if (newPhase != _currentPhase) {
      _currentPhase = newPhase;
      onPhaseChange?.call();
    }
  }

  /// Start the breathing animation
  void start() {
    _controller.forward(from: 0.0);
  }

  /// Pause the breathing animation
  void pause() {
    _controller.stop();
  }

  /// Resume the breathing animation
  void resume() {
    _controller.forward();
  }

  /// Stop and reset the breathing animation
  void stop() {
    _controller.stop();
    _controller.reset();
    _currentPhase = BreathingPhase.inhale;
  }

  /// Get the current scale value
  double get scale => _scaleAnimation.value;

  /// Get the current phase
  BreathingPhase get currentPhase => _currentPhase;

  /// Get the animation for AnimatedBuilder
  Animation<double> get animation => _scaleAnimation;

  /// Check if animation is running
  bool get isAnimating => _controller.isAnimating;

  /// Dispose the controller
  void dispose() {
    _controller.dispose();
  }
}

/// Breathing phases
enum BreathingPhase {
  inhale,
  hold,
  exhale;

  String get instruction {
    switch (this) {
      case BreathingPhase.inhale:
        return 'Breathe in slowly...';
      case BreathingPhase.hold:
        return 'Hold...';
      case BreathingPhase.exhale:
        return 'Breathe out gently';
    }
  }

  String get emoji {
    switch (this) {
      case BreathingPhase.inhale:
        return '🌬️';
      case BreathingPhase.hold:
        return '⏸️';
      case BreathingPhase.exhale:
        return '😌';
    }
  }
}
