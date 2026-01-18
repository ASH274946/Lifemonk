import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/phone_input_screen.dart';
import '../../features/auth/presentation/otp_verification_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../constants/route_constants.dart';

/// Custom page transition builder for smooth animations
CustomTransitionPage _buildPageWithFadeTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = 0.0;
      const end = 1.0;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end);
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
      );

      return FadeTransition(
        opacity: tween.animate(curvedAnimation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Provider for the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const SplashScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/phone-input',
        name: 'phone-input',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const PhoneInputScreen(),
        ),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        pageBuilder: (context, state) {
          final phoneNumber = state.extra as String?;
          if (phoneNumber == null) {
            return _buildPageWithFadeTransition(
              context,
              state,
              const PhoneInputScreen(),
            );
          }
          return _buildPageWithFadeTransition(
            context,
            state,
            OtpVerificationScreen(phoneNumber: phoneNumber),
          );
        },
      ),
      GoRoute(
        path: RouteConstants.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const MainShell(),
        ),
      ),
      GoRoute(
        path: RouteConstants.categories,
        name: 'categories',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const CategoriesScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
});
