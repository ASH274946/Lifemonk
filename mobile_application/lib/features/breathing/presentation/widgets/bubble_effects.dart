import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Rising bubbles/sparkles effect for near-completion
class RisingBubblesEffect extends StatefulWidget {
  const RisingBubblesEffect({super.key});

  @override
  State<RisingBubblesEffect> createState() => _RisingBubblesEffectState();
}

class _RisingBubblesEffectState extends State<RisingBubblesEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
        return Stack(
          children: List.generate(12, (index) => _buildBubble(index)),
        );
      },
    );
  }

  Widget _buildBubble(int index) {
    final random = math.Random(index + 1000);
    final startX = -40.0 + random.nextDouble() * 80;
    final sway = random.nextDouble() * 30 - 15; // Left-right sway
    final size = 6.0 + random.nextDouble() * 8;
    final speed = 0.8 + random.nextDouble() * 0.4;

    // Stagger the start time
    final progress = (_controller.value * speed + (index / 12)) % 1.0;

    final x = startX + math.sin(progress * math.pi * 2) * sway;
    final y = 120 - progress * 240; // Rise from bottom to top

    return Transform.translate(
      offset: Offset(x, y),
      child: Opacity(
        opacity: (1.0 - progress) * 0.6,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                const Color(0xFF8ECAE6).withValues(alpha: 0.5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gentle sparkle effect for near-end
class GentleSparklesEffect extends StatefulWidget {
  const GentleSparklesEffect({super.key});

  @override
  State<GentleSparklesEffect> createState() => _GentleSparklesEffectState();
}

class _GentleSparklesEffectState extends State<GentleSparklesEffect>
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
        return Stack(
          children: List.generate(8, (index) => _buildSparkle(index)),
        );
      },
    );
  }

  Widget _buildSparkle(int index) {
    final random = math.Random(index + 2000);
    final angle = (index / 8) * 2 * math.pi;
    final radius = 80.0 + random.nextDouble() * 40;

    // Gentle floating motion
    final floatOffset = math.sin(_controller.value * 2 * math.pi + index) * 10;

    final x = math.cos(angle) * radius;
    final y = math.sin(angle) * radius + floatOffset;

    final twinkle = (math.sin(_controller.value * 4 * math.pi + index) + 1) / 2;

    return Transform.translate(
      offset: Offset(x, y),
      child: Opacity(
        opacity: 0.3 + twinkle * 0.4,
        child: Transform.rotate(
          angle: _controller.value * math.pi * 2,
          child: const Text('✨', style: TextStyle(fontSize: 16, height: 1)),
        ),
      ),
    );
  }
}
