import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/feedback_overlay.dart';
import '../providers/auth_provider.dart';
import '../domain/auth_state.dart';

/// OTP Verification Screen
/// User enters the 6-digit OTP code sent to their phone
/// Matches design exactly with individual digit boxes
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _canResend = false;
  bool _hasError = false;
  int _resendCountdown = 30;
  Timer? _resendTimer;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    
    // Initialize shake animation for error feedback
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  /// Start countdown timer for resend OTP (30 seconds as per design)
  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 30;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  /// Resend OTP to phone number
  Future<void> _resendOtp() async {
    if (!_canResend) return;

    try {
      await ref
          .read(authStateProvider.notifier)
          .sendOtp(phone: widget.phoneNumber);
      _startResendTimer();
      _showMessage('OTP sent successfully!', isError: false);
    } catch (e) {
      _showMessage('Failed to resend OTP. Please try again.');
    }
  }

  /// Verify the entered OTP code
  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showMessage('Please enter all 6 digits');
      _shakeController.forward();
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // verifyOtp now returns a navigation path string instead of void
      final navigationPath = await ref
          .read(authStateProvider.notifier)
          .verifyOtp(phone: widget.phoneNumber, token: otp);
      
      if (mounted && navigationPath != null) {
        // Navigate to the appropriate screen based on onboarding status
        context.go(navigationPath);
      } else if (mounted) {
        // If no navigation path returned, show error
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        _showMessage('Verification failed. Please try again.');
        _shakeController.forward();
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          _clearOtpFields();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        _showMessage('Invalid OTP. Please check and try again.');
        _shakeController.forward();
        // Don't clear fields immediately - let user see what they entered
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          _clearOtpFields();
        }
      }
    }
  }

  /// Clear all OTP input fields
  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    setState(() => _hasError = false);
    _focusNodes[0].requestFocus();
  }

  void _showMessage(String message, {bool isError = true}) {
    if (isError) {
      FeedbackOverlay.error(context, message);
    } else {
      FeedbackOverlay.success(context, message, emoji: '✅');
    }
  }

  /// Handle OTP digit input with keyboard navigation
  void _onOtpDigitChanged(int index, String value) {
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    } else if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  /// Handle backspace key
  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  /// Format countdown time as MM:SS
  String _formatCountdown() {
    final minutes = (_resendCountdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (_resendCountdown % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(RouteConstants.onboarding);
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        setState(() => _isLoading = false);
        _showMessage(next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Back Button
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.chevron_left,
                  size: 32,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Verify your number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              const Text(
                'Enter the 6-digit code sent to your phone',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // OTP Input Boxes with shake animation
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final hasValue = _controllers[index].text.isNotEmpty;
                    return SizedBox(
                      width: 50,
                      height: 56,
                      child: KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: (event) => _onKeyEvent(index, event),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              autofocus: index == 0,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _hasError ? Colors.red : AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: _hasError 
                                    ? Colors.red.withValues(alpha: 0.05)
                                    : AppColors.inputBackground,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _hasError ? Colors.red : AppColors.inputBorder,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _hasError ? Colors.red : AppColors.inputBorder,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _hasError ? Colors.red : AppColors.textPrimary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() => _hasError = false);
                                _onOtpDigitChanged(index, value);
                              },
                            ),
                            // Show placeholder dot when empty
                            if (!hasValue && !_focusNodes[index].hasFocus)
                              IgnorePointer(
                                child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.textHint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
              
              const SizedBox(height: 24),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBlack,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.buttonBlack.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend OTP
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _canResend ? _resendOtp : null,
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _canResend 
                              ? AppColors.textPrimary 
                              : AppColors.textPrimary,
                          decoration: TextDecoration.underline,
                          decorationColor: _canResend 
                              ? AppColors.textPrimary 
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!_canResend) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatCountdown(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

