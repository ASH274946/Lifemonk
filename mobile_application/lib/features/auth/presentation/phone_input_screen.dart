import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/feedback_overlay.dart';
import '../providers/auth_provider.dart';
import '../domain/auth_state.dart';

/// Phone Input / Login Screen
/// Main entry point with phone number input matching the design exactly
class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  String _countryCode = '+91';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  /// Send OTP to the entered phone number
  Future<void> _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();
    
    if (phoneNumber.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }
    
    // Validate exact 10 digits for Indian numbers
    if (_countryCode == '+91') {
      if (phoneNumber.length != 10) {
        _showError('Please enter a valid 10-digit mobile number');
        return;
      }
      // Indian mobile numbers must start with 6, 7, 8, or 9
      if (!RegExp(r'^[6-9]').hasMatch(phoneNumber)) {
        _showError('Indian mobile numbers must start with 6, 7, 8, or 9');
        return;
      }
    } else if (phoneNumber.length < 7 || phoneNumber.length > 15) {
      _showError('Please enter a valid phone number');
      return;
    }

    setState(() => _isLoading = true);

    final fullPhoneNumber = '$_countryCode$phoneNumber';

    try {
      await ref
          .read(authStateProvider.notifier)
          .sendOtp(phone: fullPhoneNumber);

      if (mounted) {
        setState(() => _isLoading = false);
        context.push('/otp-verification', extra: fullPhoneNumber);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Could not send OTP. Please try again');
      }
    }
  }

  void _showError(String message) {
    FeedbackOverlay.error(context, message);
  }

  /// Handle Google Sign-In using OAuth with mobile deep linking
  /// This opens the Google Sign-In page in a browser and redirects back to the app
  /// After authentication, navigates based on onboarding status
  Future<void> _onGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // Call the OAuth method which returns a navigation path
      final navigationPath = await ref.read(authStateProvider.notifier).signInWithGoogleOAuth();
      
      if (mounted && navigationPath != null) {
        // Navigate to the appropriate screen based on onboarding status
        // /home if onboarding is complete, /onboarding if new user
        context.go(navigationPath);
      } else if (mounted) {
        setState(() => _isLoading = false);
        // Error is already handled by auth provider's state
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Google Sign-In failed. Please try again.');
      }
    }
  }

  /// Handle Guest Mode - continue without authentication
  void _continueAsGuest() {
    // Set guest mode state
    ref.read(authStateProvider.notifier).continueAsGuest();
    // Navigate directly to onboarding
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state for errors and guest mode
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        setState(() => _isLoading = false);
        _showError(next.errorMessage!);
      } else if (next.status == AuthStatus.guest) {
        // Guest mode activated, navigation is handled in _continueAsGuest
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Lifemonk Logo - centered
              const Text(
                'lifemonk',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.0,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Welcome Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter your phone number to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Phone Input Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.inputBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Country Code Dropdown
                    Container(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _countryCode,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          items: const [
                            DropdownMenuItem(value: '+91', child: Text('+91')),
                            DropdownMenuItem(value: '+1', child: Text('+1')),
                            DropdownMenuItem(value: '+44', child: Text('+44')),
                            DropdownMenuItem(value: '+61', child: Text('+61')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _countryCode = value);
                            }
                          },
                        ),
                      ),
                    ),
                    
                    // Vertical Divider
                    Container(
                      height: 24,
                      width: 1,
                      color: AppColors.inputBorder,
                    ),
                    
                    // Phone Number Input
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Phone number',
                          hintStyle: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Send OTP Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
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
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Google Sign In Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New here?  ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: _onGoogleSignIn,
                    child: const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Guest Mode Button
              GestureDetector(
                onTap: _continueAsGuest,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.inputBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: AppColors.textPrimary.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Terms and Privacy Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: AppColors.textSecondary.withValues(alpha: 0.8),
                            ),
                          ),
                          const TextSpan(text: ' and\n'),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: AppColors.textSecondary.withValues(alpha: 0.8),
                            ),
                          ),
                          const TextSpan(text: '. We value your mindful journey.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
