import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../controllers/breathing_animation_controller.dart';

/// Air flow particles that move with breathing
class AirFlowLayer extends StatefulWidget {
  final BreathingPhase currentPhase;
  final bool isAnimating;

  const AirFlowLayer({
    super.key,
    required this.currentPhase,
    required this.isAnimating,
  });

  @override
  State<AirFlowLayer> createState() => _AirFlowLayerState();
}

class _AirFlowLayerState extends State<AirFlowLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _flowController;

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimating) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _flowController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: AirFlowPainter(
            progress: _flowController.value,
            phase: widget.currentPhase,
          ),
        );
      },
    );
  }
}

/// Custom painter for air flow particles
class AirFlowPainter extends CustomPainter {
  final double progress;
  final BreathingPhase phase;

  AirFlowPainter({required this.progress, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final circleRadius = 120.0;

    // Draw air flow lines/particles
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      _drawAirParticle(canvas, center, circleRadius, angle, i);
    }
  }

  void _drawAirParticle(
    Canvas canvas,
    Offset center,
    double circleRadius,
    double angle,
    int index,
  ) {
    final particleProgress = (progress + (index / 12)) % 1.0;

    // Determine particle movement based on breathing phase
    double startRadius, endRadius;
    if (phase == BreathingPhase.inhale) {
      // Particles move inward
      startRadius = circleRadius + 80;
      endRadius = circleRadius + 20;
    } else if (phase == BreathingPhase.exhale) {
      // Particles move outward
      startRadius = circleRadius + 20;
      endRadius = circleRadius + 80;
    } else {
      // Hold - minimal movement
      startRadius = circleRadius + 50;
      endRadius = circleRadius + 55;
    }

    final currentRadius =
        startRadius + (endRadius - startRadius) * particleProgress;

    // Calculate particle position
    final x = center.dx + math.cos(angle) * currentRadius;
    final y = center.dy + math.sin(angle) * currentRadius;

    // Opacity based on progress (fade in and out)
    final opacity = math.sin(particleProgress * math.pi) * 0.4;

    // Draw curved air line
    final path = Path();
    final curveLength = 30.0;

    // Start point
    final startX = x - math.cos(angle) * curveLength;
    final startY = y - math.sin(angle) * curveLength;

    path.moveTo(startX, startY);

    // Curved line toward/away from center
    final controlX = x - math.cos(angle) * (curveLength / 2);
    final controlY = y - math.sin(angle) * (curveLength / 2);

    path.quadraticBezierTo(controlX, controlY, x, y);

    // Draw the air particle
    final paint = Paint()
      ..color = _getAirColor().withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);

    // Add small dot at the end
    final dotPaint = Paint()
      ..color = _getAirColor().withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), 3, dotPaint);
  }

  Color _getAirColor() {
    switch (phase) {
      case BreathingPhase.inhale:
        return const Color(0xFF8ECAE6); // Blue
      case BreathingPhase.hold:
        return const Color(0xFF9DB4C0); // Gray-blue
      case BreathingPhase.exhale:
        return const Color(0xFF95E1D3); // Mint
    }
  }

  @override
  bool shouldRepaint(AirFlowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.phase != phase;
  }
}
