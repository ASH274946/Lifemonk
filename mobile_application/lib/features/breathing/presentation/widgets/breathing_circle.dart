import 'package:flutter/material.dart';
import '../controllers/breathing_animation_controller.dart';

/// Animated breathing circle widget
class BreathingCircle extends StatelessWidget {
  final Animation<double> animation;
  final BreathingPhase currentPhase;
  final String timeRemaining;

  const BreathingCircle({
    super.key,
    required this.animation,
    required this.currentPhase,
    required this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getGradientColor(currentPhase).withValues(alpha: 0.3),
                  _getGradientColor(currentPhase).withValues(alpha: 0.1),
                ],
                stops: const [0.6, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getGlowColor(currentPhase).withValues(alpha: 0.3),
                  blurRadius: 40 * animation.value,
                  spreadRadius: 10 * animation.value,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getCircleColor(currentPhase),
                ),
                child: Center(
                  child: Text(
                    timeRemaining,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCircleColor(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return const Color(0xFFB8E6F5); // Light blue
      case BreathingPhase.hold:
        return const Color(0xFFD4E8F5); // Pale blue
      case BreathingPhase.exhale:
        return const Color(0xFFC9E4CA); // Light green
    }
  }

  Color _getGradientColor(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return const Color(0xFF8ECAE6); // Blue
      case BreathingPhase.hold:
        return const Color(0xFF9DB4C0); // Gray-blue
      case BreathingPhase.exhale:
        return const Color(0xFF95E1D3); // Mint
    }
  }

  Color _getGlowColor(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return const Color(0xFF8ECAE6);
      case BreathingPhase.hold:
        return const Color(0xFF8ECAE6);
      case BreathingPhase.exhale:
        return const Color(0xFF95E1D3);
    }
  }
}
