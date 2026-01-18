import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Character widget for the cute emoji-like mascots
class CharacterWidget extends StatelessWidget {
  final Color color;
  final double size;
  final CharacterExpression expression;
  final bool hasAntenna;
  final bool hasSpeechBubble;
  final String? speechText;

  const CharacterWidget({
    super.key,
    required this.color,
    this.size = 100,
    this.expression = CharacterExpression.happy,
    this.hasAntenna = false,
    this.hasSpeechBubble = false,
    this.speechText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 20,
      height: size + (hasAntenna ? 30 : 0) + (hasSpeechBubble ? 40 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Antenna
          if (hasAntenna)
            Positioned(
              top: 0,
              left: size / 2 + 5,
              child: Column(
                children: [
                  Container(width: 2, height: 20, color: Colors.black54),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black54, width: 1.5),
                    ),
                  ),
                ],
              ),
            ),

          // Main body
          Positioned(
            top: hasAntenna ? 30 : 0,
            left: 10,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: _buildFace(),
            ),
          ),

          // Speech bubble
          if (hasSpeechBubble && speechText != null)
            Positioned(
              top: hasAntenna ? 10 : 0,
              right: -20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  speechText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFace() {
    switch (expression) {
      case CharacterExpression.happy:
        return _buildHappyFace();
      case CharacterExpression.surprised:
        return _buildSurprisedFace();
      case CharacterExpression.sad:
        return _buildSadFace();
      case CharacterExpression.neutral:
        return _buildNeutralFace();
      case CharacterExpression.wink:
        return _buildWinkFace();
    }
  }

  Widget _buildHappyFace() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Eyes
        Positioned(
          top: size * 0.35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEye(size * 0.08),
              SizedBox(width: size * 0.2),
              _buildEye(size * 0.08),
            ],
          ),
        ),
        // Smile
        Positioned(
          bottom: size * 0.25,
          child: Container(
            width: size * 0.3,
            height: size * 0.08,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black87, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurprisedFace() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Big eyes
        Positioned(
          top: size * 0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBigEye(size * 0.18),
              SizedBox(width: size * 0.12),
              _buildBigEye(size * 0.18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSadFace() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Eyes
        Positioned(
          top: size * 0.35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLineEye(),
              SizedBox(width: size * 0.2),
              _buildLineEye(),
            ],
          ),
        ),
        // Frown
        Positioned(
          bottom: size * 0.28,
          child: Transform.rotate(
            angle: math.pi,
            child: Container(
              width: size * 0.2,
              height: size * 0.1,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black87, width: 2),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeutralFace() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Eyes - horizontal lines
        Positioned(
          top: size * 0.4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: size * 0.12, height: 2, color: Colors.black87),
              SizedBox(width: size * 0.15),
              Container(width: size * 0.12, height: 2, color: Colors.black87),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWinkFace() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Eyes
        Positioned(
          top: size * 0.35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEye(size * 0.08),
              SizedBox(width: size * 0.2),
              _buildEye(size * 0.08),
            ],
          ),
        ),
        // Small smile
        Positioned(
          bottom: size * 0.3,
          child: Container(
            width: size * 0.15,
            height: 2,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEye(double eyeSize) {
    return Container(
      width: eyeSize,
      height: eyeSize,
      decoration: const BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBigEye(double eyeSize) {
    return Container(
      width: eyeSize,
      height: eyeSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black87, width: 2),
      ),
      child: Center(
        child: Container(
          width: eyeSize * 0.5,
          height: eyeSize * 0.5,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildLineEye() {
    return Container(
      width: size * 0.1,
      height: 2,
      decoration: const BoxDecoration(color: Colors.black87),
    );
  }
}

enum CharacterExpression { happy, surprised, sad, neutral, wink }
