import 'package:flutter/material.dart';

/// Premium animated button with press effect and loading state
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSuccess;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final String? successText;
  final String? successEmoji;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSuccess = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.successText,
    this.successEmoji,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _pressController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null && !widget.isLoading;
    final bgColor = widget.backgroundColor ?? const Color(0xFF1A1A1A);
    final fgColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.isSuccess
                ? const Color(0xFF4CAF50)
                : isDisabled
                    ? bgColor.withValues(alpha: 0.5)
                    : bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: isDisabled || widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                      ),
                    )
                  : widget.isSuccess
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.successEmoji != null) ...[
                              Text(
                                widget.successEmoji!,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.successText ?? widget.text,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: fgColor,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDisabled
                                ? fgColor.withValues(alpha: 0.7)
                                : fgColor,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Light blue variant for secondary actions
class AnimatedLightButton extends AnimatedButton {
  const AnimatedLightButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isSuccess,
    super.width,
    super.height = 56,
    super.borderRadius = 16,
    super.successText,
    super.successEmoji,
  }) : super(
          backgroundColor: const Color(0xFF8ECAE6),
          textColor: Colors.white,
        );
}
