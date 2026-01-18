import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../controllers/breathing_animation_controller.dart';

/// Water-filled breathing circle with wave animation
class WaterBreathingCircle extends StatelessWidget {
  final Animation<double> animation;
  final BreathingPhase currentPhase;
  final String timeRemaining;
  final bool isNearEnd;
  final bool isAlmostDone;

  const WaterBreathingCircle({
    super.key,
    required this.animation,
    required this.currentPhase,
    required this.timeRemaining,
    this.isNearEnd = false,
    this.isAlmostDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Calculate water fill level based on breathing phase
        final waterLevel = _getWaterLevel();

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow (enhanced when near end)
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getGlowColor().withValues(
                      alpha: isNearEnd ? 0.4 : 0.2,
                    ),
                    blurRadius: isNearEnd ? 50 : 30,
                    spreadRadius: isNearEnd ? 15 : 8,
                  ),
                ],
              ),
            ),

            // Main circle with water
            Transform.scale(
              scale: 0.95 + (animation.value - 0.8) * 0.5, // Subtle scale pulse
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      // Water fill with waves
                      CustomPaint(
                        size: const Size(240, 240),
                        painter: WaterWavePainter(
                          waterLevel: waterLevel,
                          animationValue: animation.value,
                          phase: currentPhase,
                          isShimmering: isNearEnd,
                        ),
                      ),

                      // Timer text overlay
                      Center(
                        child: Text(
                          timeRemaining,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: waterLevel > 0.5
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                            letterSpacing: -1,
                            shadows: waterLevel > 0.5
                                ? [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _getWaterLevel() {
    final scale = animation.value;
    // Convert scale (0.8 to 1.2) to water level (0.2 to 0.8)
    return ((scale - 0.8) / 0.4) * 0.6 + 0.2;
  }

  Color _getGlowColor() {
    switch (currentPhase) {
      case BreathingPhase.inhale:
        return const Color(0xFF8ECAE6);
      case BreathingPhase.hold:
        return const Color(0xFF9DB4C0);
      case BreathingPhase.exhale:
        return const Color(0xFF95E1D3);
    }
  }
}

/// Custom painter for water wave effect
class WaterWavePainter extends CustomPainter {
  final double waterLevel;
  final double animationValue;
  final BreathingPhase phase;
  final bool isShimmering;

  WaterWavePainter({
    required this.waterLevel,
    required this.animationValue,
    required this.phase,
    this.isShimmering = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Water gradient colors based on phase
    final waterColors = _getWaterColors();

    // Draw water with gradient
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: waterColors,
      ).createShader(rect);

    // Calculate wave path
    final waterPath = Path();
    final waveHeight = phase == BreathingPhase.hold ? 3.0 : 6.0;
    final waveFrequency = 2.0;

    // Start from bottom left
    waterPath.moveTo(0, size.height);

    // Draw bottom line
    waterPath.lineTo(0, size.height * (1 - waterLevel));

    // Draw wave on top of water
    for (double x = 0; x <= size.width; x++) {
      final waveOffset =
          math.sin(
            (x / size.width * waveFrequency * math.pi * 2) +
                (animationValue * math.pi * 2),
          ) *
          waveHeight;

      final y = size.height * (1 - waterLevel) + waveOffset;
      waterPath.lineTo(x, y);
    }

    // Complete the path
    waterPath.lineTo(size.width, size.height);
    waterPath.close();

    canvas.drawPath(waterPath, waterPaint);

    // Add shimmer effect when near end
    if (isShimmering) {
      _drawShimmer(canvas, size);
    }
  }

  void _drawShimmer(Canvas canvas, Size size) {
    final shimmerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final shimmerPath = Path();
    final shimmerY = size.height * (1 - waterLevel) - 5;

    for (double x = 0; x <= size.width; x++) {
      final shimmerOffset =
          math.sin(
            (x / size.width * 3 * math.pi * 2) + (animationValue * math.pi * 4),
          ) *
          4;

      shimmerPath.moveTo(x, shimmerY + shimmerOffset);
      shimmerPath.lineTo(x, shimmerY + shimmerOffset + 2);
    }

    canvas.drawPath(shimmerPath, shimmerPaint);
  }

  List<Color> _getWaterColors() {
    switch (phase) {
      case BreathingPhase.inhale:
        return [
          const Color(0xFF8ECAE6), // Light blue
          const Color(0xFFB8E6F5), // Lighter blue
        ];
      case BreathingPhase.hold:
        return [
          const Color(0xFF9DB4C0), // Gray-blue
          const Color(0xFFD4E8F5), // Pale blue
        ];
      case BreathingPhase.exhale:
        return [
          const Color(0xFF95E1D3), // Mint
          const Color(0xFFC9E4CA), // Light mint
        ];
    }
  }

  @override
  bool shouldRepaint(WaterWavePainter oldDelegate) {
    return oldDelegate.waterLevel != waterLevel ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.phase != phase ||
        oldDelegate.isShimmering != isShimmering;
  }
}
