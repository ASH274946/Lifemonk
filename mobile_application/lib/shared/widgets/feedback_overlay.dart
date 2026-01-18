import 'package:flutter/material.dart';

/// Premium in-app feedback system
/// Replaces ugly SnackBars with soft, branded floating cards
class FeedbackOverlay {
  static OverlayEntry? _currentOverlay;

  /// Show a soft floating feedback card
  /// Auto-dismisses after [duration] (default 2 seconds)
  static void show(
    BuildContext context, {
    required String message,
    String? emoji,
    FeedbackType type = FeedbackType.info,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onDismiss,
  }) {
    // Dismiss any existing overlay
    dismiss();

    final overlay = Overlay.of(context);
    
    _currentOverlay = OverlayEntry(
      builder: (context) => _FeedbackCard(
        message: message,
        emoji: emoji,
        type: type,
        duration: duration,
        onDismiss: () {
          dismiss();
          onDismiss?.call();
        },
      ),
    );

    overlay.insert(_currentOverlay!);
  }

  /// Dismiss current overlay
  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// Quick success feedback
  static void success(BuildContext context, String message, {String? emoji}) {
    show(context, message: message, emoji: emoji ?? '✨', type: FeedbackType.success);
  }

  /// Quick info feedback
  static void info(BuildContext context, String message, {String? emoji}) {
    show(context, message: message, emoji: emoji ?? '💡', type: FeedbackType.info);
  }

  /// Quick error feedback
  static void error(BuildContext context, String message, {String? emoji}) {
    show(context, message: message, emoji: emoji ?? '😔', type: FeedbackType.error, duration: const Duration(seconds: 3));
  }
}

enum FeedbackType { success, info, error }

class _FeedbackCard extends StatefulWidget {
  final String message;
  final String? emoji;
  final FeedbackType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _FeedbackCard({
    required this.message,
    this.emoji,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<_FeedbackCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismissWithAnimation();
      }
    });
  }

  void _dismissWithAnimation() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 100,
      left: 24,
      right: 24,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _dismissWithAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getShadowColor(),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.emoji != null) ...[
                        Text(
                          widget.emoji!,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _getTextColor(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case FeedbackType.success:
        return const Color(0xFFE8F5E9); // Soft green
      case FeedbackType.info:
        return const Color(0xFFFFFBEB); // Soft cream/yellow
      case FeedbackType.error:
        return const Color(0xFFFFEBEE); // Soft red
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case FeedbackType.success:
        return const Color(0xFF2E7D32); // Dark green
      case FeedbackType.info:
        return const Color(0xFF5D4037); // Warm brown
      case FeedbackType.error:
        return const Color(0xFFC62828); // Dark red
    }
  }

  Color _getShadowColor() {
    switch (widget.type) {
      case FeedbackType.success:
        return const Color(0xFF4CAF50).withValues(alpha: 0.2);
      case FeedbackType.info:
        return const Color(0xFFFFB74D).withValues(alpha: 0.2);
      case FeedbackType.error:
        return const Color(0xFFE57373).withValues(alpha: 0.2);
    }
  }
}
