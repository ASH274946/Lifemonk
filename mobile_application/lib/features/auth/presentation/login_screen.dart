import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/shared_prefs_service.dart';
import '../providers/auth_provider.dart';
import '../domain/auth_state.dart';

/// Login Screen with animated characters
/// Displays logo, character illustrations, and sign-in options
/// Supports Google Sign-In (native) and Phone OTP authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _floatController;
  late AnimationController _blinkController;
  late AnimationController _bounceController;
  late AnimationController _waveController;
  late AnimationController _speechController;
  late AnimationController _logoController;
  late AnimationController _buttonController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    // Floating animation for characters
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Blinking animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _startBlinking();

    // Bouncing animation
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Rotate animation
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Speech bubble animation
    _speechController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animateSpeech();

    // Logo fade in animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Button slide up animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  void _startBlinking() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  void _animateSpeech() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _speechController.forward().then((_) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _speechController.reverse().then((_) {
                _animateSpeech();
              });
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _blinkController.dispose();
    _bounceController.dispose();
    _waveController.dispose();
    _speechController.dispose();
    _logoController.dispose();
    _buttonController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    // Navigate to Google Sign-In via AuthNotifier
    // The AuthNotifier handles the OAuth flow and state updates
    // The state listener in build() will handle navigation on success
    final redirectUrl = await ref.read(authStateProvider.notifier).signInWithGoogleOAuth();
    
    if (redirectUrl != null && mounted) {
      context.go(redirectUrl);
    }
  }

  Future<void> _signInWithPhone() async {
    context.push('/phone-input');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(RouteConstants.onboarding);
      } else if (next.status == AuthStatus.guest) {
        context.go(RouteConstants.onboarding);
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Column(
          children: [
            // Animated Logo
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoController.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _logoController.value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'lifemonk',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                ),
              ),
            ),

            // Animated Characters
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _floatController,
                  _blinkController,
                  _bounceController,
                  _waveController,
                  _speechController,
                  _pulseController,
                  _rotateController,
                ]),
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Green character (top left) - floating
                      Positioned(
                        top:
                            80 +
                            (math.sin(_floatController.value * 2 * math.pi) *
                                10),
                        left:
                            40 +
                            (math.cos(_floatController.value * 2 * math.pi) *
                                5),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.5 + (value * 0.5),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Transform.rotate(
                            angle:
                                math.sin(_waveController.value * 2 * math.pi) *
                                0.1,
                            child: _buildCharacter(
                              color: const Color(0xFFB8E986),
                              size: 140,
                              eyeType: 'normal',
                              mouthType: 'sad',
                              hasAntenna: true,
                              blinkValue: _blinkController.value,
                            ),
                          ),
                        ),
                      ),

                      // Pink character (top right) - bouncing
                      Positioned(
                        top:
                            40 +
                            (math.sin(_bounceController.value * 2 * math.pi) *
                                    15)
                                .abs(),
                        right: 60,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.5 + (value * 0.5),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: _buildCharacter(
                            color: const Color(0xFFFFB3D9),
                            size: 110,
                            eyeType: 'dots',
                            mouthType: 'smile',
                            hasAntenna: true,
                            blinkValue: 0,
                          ),
                        ),
                      ),

                      // Blue character (middle left) - rotating with happy bounce
                      Positioned(
                        top:
                            200 +
                            (math.cos(
                                  _floatController.value * 2 * math.pi + 1,
                                ) *
                                12) +
                            (math.sin(_pulseController.value * 2 * math.pi) *
                                5),
                        left:
                            60 +
                            (math.sin(_waveController.value * 2 * math.pi + 1) *
                                6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.5 + (value * 0.5),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Transform.scale(
                            scale:
                                1.0 +
                                (math.sin(
                                      _pulseController.value * 2 * math.pi + 2,
                                    ) *
                                    0.07),
                            child: Transform.rotate(
                              angle:
                                  math.sin(
                                    _waveController.value * 2 * math.pi + 1,
                                  ) *
                                  0.12,
                              child: _buildCharacter(
                                color: const Color(0xFF87CEEB),
                                size: 130,
                                eyeType: 'big',
                                mouthType: 'smile',
                                hasAntenna: true,
                                blinkValue: _blinkController.value,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Small orange character (center) - quick bounce with wiggle
                      Positioned(
                        top:
                            280 +
                            (math.sin(_bounceController.value * 4 * math.pi) *
                                    12)
                                .abs(),
                        left:
                            180 +
                            (math.sin(_rotateController.value * 3 * math.pi) *
                                8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1200),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.3 + (value * 0.7),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Transform.rotate(
                            angle:
                                math.sin(_waveController.value * 4 * math.pi) *
                                0.4,
                            child: Transform.scale(
                              scale:
                                  1.0 +
                                  (math.sin(
                                        _pulseController.value * 3 * math.pi,
                                      ) *
                                      0.15),
                              child: _buildCharacter(
                                color: const Color(0xFFFFB366),
                                size: 50,
                                eyeType: 'dots',
                                mouthType: 'smile',
                                hasAntenna: false,
                                blinkValue: 0,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Speech bubble with scale animation
                      Positioned(
                        top: 230,
                        right: 100,
                        child: Transform.scale(
                          scale: 0.8 + (_speechController.value * 0.2),
                          child: Opacity(
                            opacity: _speechController.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Hello!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Yellow character (bottom right) - gentle sway
                      Positioned(
                        bottom: 120,
                        right:
                            40 +
                            (math.sin(_waveController.value * 2 * math.pi + 2) *
                                8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1400),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.5 + (value * 0.5),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Transform.rotate(
                            angle:
                                math.sin(
                                  _floatController.value * 2 * math.pi + 2,
                                ) *
                                0.12,
                            child: _buildCharacter(
                              color: const Color(0xFFFFD966),
                              size: 160,
                              eyeType: 'normal',
                              mouthType: 'smile',
                              hasAntenna: true,
                              blinkValue: _blinkController.value,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Animated Bottom Section
            AnimatedBuilder(
              animation: _buttonController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _buttonController.value)),
                  child: Opacity(
                    opacity: _buttonController.value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Sign in to get started',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Google Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            (_isLoading ||
                                authState.status == AuthStatus.loading)
                            ? null
                            : _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonWhite,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 2,
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child:
                            (_isLoading ||
                                authState.status == AuthStatus.loading)
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.buttonBlack,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: CustomPaint(
                                      painter: _GoogleLogoPainter(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            (_isLoading ||
                                authState.status == AuthStatus.loading)
                            ? null
                            : _signInWithPhone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBlack,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 2,
                          disabledBackgroundColor: Colors.grey[700],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.phone_android, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Sign in with Phone',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Guest Login Button
                    TextButton(
                      onPressed: () {
                        ref.read(authStateProvider.notifier).continueAsGuest();
                      },
                      child: Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacter({
    required Color color,
    required double size,
    required String eyeType,
    required String mouthType,
    required bool hasAntenna,
    required double blinkValue,
  }) {
    return SizedBox(
      width: size,
      height: size + (hasAntenna ? 20 : 0),
      child: CustomPaint(
        painter: _CharacterPainter(
          color: color,
          eyeType: eyeType,
          mouthType: mouthType,
          hasAntenna: hasAntenna,
          blinkValue: blinkValue,
        ),
      ),
    );
  }
}

/// Custom painter for animated characters
class _CharacterPainter extends CustomPainter {
  final Color color;
  final String eyeType;
  final String mouthType;
  final bool hasAntenna;
  final double blinkValue;

  _CharacterPainter({
    required this.color,
    required this.eyeType,
    required this.mouthType,
    required this.hasAntenna,
    required this.blinkValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final radius = size.width / 2;
    final center = Offset(radius, hasAntenna ? radius + 20 : radius);

    // Draw antenna
    if (hasAntenna) {
      canvas.drawLine(Offset(radius, 20), Offset(radius, 5), outlinePaint);
      canvas.drawCircle(Offset(radius, 5), 5, paint);
      canvas.drawCircle(Offset(radius, 5), 5, outlinePaint);
    }

    // Draw main circle with shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(
      Offset(center.dx + 3, center.dy + 5),
      radius - 3,
      shadowPaint,
    );
    canvas.drawCircle(center, radius - 3, paint);
    canvas.drawCircle(center, radius - 3, outlinePaint);

    // Draw eyes with blink animation
    final eyePaint = Paint()..color = Colors.black;
    final eyeHeight = 1.0 - blinkValue;

    if (eyeType == 'normal') {
      final eyeRadius = radius * 0.12;
      canvas.save();
      canvas.scale(1.0, eyeHeight);
      canvas.drawCircle(
        Offset(
          center.dx - radius * 0.3,
          (center.dy - radius * 0.15) / eyeHeight,
        ),
        eyeRadius,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(
          center.dx + radius * 0.3,
          (center.dy - radius * 0.15) / eyeHeight,
        ),
        eyeRadius,
        eyePaint,
      );
      canvas.restore();
    } else if (eyeType == 'dots') {
      canvas.drawCircle(
        Offset(center.dx - radius * 0.25, center.dy - radius * 0.1),
        radius * 0.08,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + radius * 0.25, center.dy - radius * 0.1),
        radius * 0.08,
        eyePaint,
      );
    } else if (eyeType == 'big') {
      final bigEyePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(center.dx - radius * 0.3, center.dy - radius * 0.1),
        radius * 0.25,
        bigEyePaint,
      );
      canvas.drawCircle(
        Offset(center.dx - radius * 0.3, center.dy - radius * 0.1),
        radius * 0.25,
        outlinePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + radius * 0.3, center.dy - radius * 0.1),
        radius * 0.25,
        bigEyePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + radius * 0.3, center.dy - radius * 0.1),
        radius * 0.25,
        outlinePaint,
      );

      canvas.save();
      canvas.scale(1.0, eyeHeight);
      canvas.drawCircle(
        Offset(
          center.dx - radius * 0.3,
          (center.dy - radius * 0.05) / eyeHeight,
        ),
        radius * 0.12,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(
          center.dx + radius * 0.3,
          (center.dy - radius * 0.05) / eyeHeight,
        ),
        radius * 0.12,
        eyePaint,
      );
      canvas.restore();
    }

    // Draw mouth
    if (mouthType == 'smile') {
      final smilePath = Path();
      smilePath.moveTo(center.dx - radius * 0.3, center.dy + radius * 0.25);
      smilePath.quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.45,
        center.dx + radius * 0.3,
        center.dy + radius * 0.25,
      );
      canvas.drawPath(smilePath, outlinePaint);
    } else if (mouthType == 'sad') {
      final sadPath = Path();
      sadPath.moveTo(center.dx - radius * 0.3, center.dy + radius * 0.35);
      sadPath.quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.2,
        center.dx + radius * 0.3,
        center.dy + radius * 0.35,
      );
      canvas.drawPath(sadPath, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(_CharacterPainter oldDelegate) {
    return oldDelegate.blinkValue != blinkValue;
  }
}

/// Google logo painter
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2.2;

    // Blue arc (right)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      -0.4,
      1.2,
      false,
      bluePaint,
    );

    // Green arc (bottom right)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      0.8,
      1.2,
      false,
      greenPaint,
    );

    // Yellow arc (bottom left)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      2.0,
      1.0,
      false,
      yellowPaint,
    );

    // Red arc (top)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      3.0,
      1.3,
      false,
      redPaint,
    );

    // Blue bar
    final blueFillPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(centerX, centerY - 2, radius, 4),
      blueFillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
