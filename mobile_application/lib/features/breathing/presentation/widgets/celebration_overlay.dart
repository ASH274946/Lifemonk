import 'package:flutter/material.dart';
import 'dart:math' as math;

export 'celebration_overlay.dart';

/// Celebration overlay with bubbles burst and success message
class CelebrationOverlay extends StatefulWidget {
  final VoidCallback? onComplete;

  const CelebrationOverlay({super.key, this.onComplete});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bubbleBurstAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
      ),
    );

    _bubbleBurstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Auto-dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.3 * _fadeAnimation.value),
          child: Stack(
            children: [
              // Bursting bubbles
              ...List.generate(16, (index) => _buildBurstingBubble(index)),

              // Confetti particles (lighter, fewer)
              ...List.generate(12, (index) => _buildConfetti(index)),

              // Success message
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌈', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          const Text(
                            'Great job!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You completed your breathing session',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBurstingBubble(int index) {
    final random = math.Random(index + 3000);
    final angle = (index / 16) * 2 * math.pi;
    final distance = 80.0 + random.nextDouble() * 120;

    final progress = _bubbleBurstAnimation.value;

    final x = math.cos(angle) * distance * progress;
    final y = math.sin(angle) * distance * progress - 20 * progress;

    final size = 12.0 + random.nextDouble() * 16;
    final opacity = (1.0 - progress) * 0.7;

    return Positioned(
      left: MediaQuery.of(context).size.width / 2 + x,
      top: MediaQuery.of(context).size.height / 2 + y,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.8),
                const Color(0xFF8ECAE6).withValues(alpha: 0.4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8ECAE6).withValues(alpha: opacity * 0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfetti(int index) {
    final random = math.Random(index);
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFF69B4),
      const Color(0xFF8ECAE6),
      const Color(0xFF95E1D3),
      const Color(0xFFFFA07A),
    ];

    final color = colors[random.nextInt(colors.length)];
    final startX = random.nextDouble();
    final endX = startX + (random.nextDouble() - 0.5) * 0.3;
    final rotation = random.nextDouble() * math.pi * 4;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Positioned(
          left: (startX + (endX - startX) * progress) * screenWidth,
          top: -20 + progress * screenHeight * 1.2,
          child: Transform.rotate(
            angle: rotation * progress,
            child: Opacity(
              opacity: 1.0 - progress,
              child: Container(
                width: 8 + random.nextDouble() * 8,
                height: 8 + random.nextDouble() * 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: random.nextBool()
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: random.nextBool()
                      ? BorderRadius.circular(2)
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating stars animation for near-end effect
class FloatingStarsEffect extends StatefulWidget {
  const FloatingStarsEffect({super.key});

  @override
  State<FloatingStarsEffect> createState() => _FloatingStarsEffectState();
}

class _FloatingStarsEffectState extends State<FloatingStarsEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(children: List.generate(8, (index) => _buildStar(index)));
      },
    );
  }

  Widget _buildStar(int index) {
    final random = math.Random(index);
    final angle = (index / 8) * 2 * math.pi;
    final radius = 100.0 + random.nextDouble() * 50;

    final x = math.cos(angle + _controller.value * 2 * math.pi) * radius;
    final y = math.sin(angle + _controller.value * 2 * math.pi) * radius;

    return Transform.translate(
      offset: Offset(x, y),
      child: Opacity(
        opacity: 0.3 + 0.4 * math.sin(_controller.value * 2 * math.pi + index),
        child: const Text('⭐', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
