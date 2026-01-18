import 'package:flutter/material.dart';

/// Creative Popup Dialog
/// Shows attractive, age-appropriate messages for registrations and actions
class CreativePopup {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? emoji,
    Color? accentColor,
    VoidCallback? onConfirm,
    String confirmText = 'Got it!',
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(); // Placeholder
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        
        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor?.withOpacity(0.1) ?? const Color(0xFFF3F4F6),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emoji/Icon
                    if (emoji != null) ...[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: (accentColor ?? const Color(0xFF6366F1)).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Message
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor ?? const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show success popup
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    show(
      context,
      title: title,
      message: message,
      emoji: '🎉',
      accentColor: const Color(0xFF10B981),
      onConfirm: onConfirm,
      confirmText: 'Awesome!',
    );
  }

  /// Show info popup
  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    show(
      context,
      title: title,
      message: message,
      emoji: '💡',
      accentColor: const Color(0xFF3B82F6),
      onConfirm: onConfirm,
    );
  }

  /// Show workshop enrollment popup
  static void showWorkshopEnrollment(
    BuildContext context, {
    required String workshopTitle,
    VoidCallback? onConfirm,
  }) {
    show(
      context,
      title: 'You\'re In!',
      message: 'Get ready for an amazing learning experience in "$workshopTitle". We\'ll send you a reminder before it starts!',
      emoji: '🚀',
      accentColor: const Color(0xFF8B5CF6),
      onConfirm: onConfirm,
      confirmText: 'Can\'t Wait!',
    );
  }
}
