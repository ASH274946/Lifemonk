import 'package:flutter/material.dart';

/// Lifemonk logo widget with custom styling
/// Displays "lifemonk" in bold black lowercase letters
class LifemonkLogo extends StatelessWidget {
  final double fontSize;
  final Color color;

  const LifemonkLogo({
    super.key,
    this.fontSize = 32,
    this.color = const Color(0xFF1A1A1A),
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'lifemonk',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: -1.5,
        height: 1.0,
      ),
    );
  }
}
