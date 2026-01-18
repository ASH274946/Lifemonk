import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/services/shared_prefs_service.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/services/firebase_service.dart';
import '../../../shared/widgets/lifemonk_logo.dart';

/// Splash Screen - Handles app initialization
/// Shows logo while services initialize in background
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup fade-in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    _fadeController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Initialize all services and navigate when ready
  Future<void> _initializeApp() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Initialize all services in parallel where possible
      await Future.wait([
        dotenv.load(fileName: '.env'),
        LocalStorageService.initialize(),
        SharedPrefsService.init(),
      ]);

      // Initialize Supabase (depends on dotenv)
      try {
        await SupabaseService.initialize();
        if (kDebugMode) {
          print('✅ Supabase initialized');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Supabase init skipped: $e');
        }
      }

      // Initialize Firebase (depends on dotenv)
      try {
        await FirebaseService.initialize();
        if (kDebugMode) {
          print('✅ Firebase initialized');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Firebase init skipped: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Init error: $e');
      }
    }

    stopwatch.stop();
    
    // Ensure minimum splash duration for branding (1.2 seconds)
    final elapsed = stopwatch.elapsedMilliseconds;
    final remaining = 1200 - elapsed;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }

    if (!mounted) return;
    await _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Check authentication status using SharedPrefs as primary source
    // Supabase session is checked in login flow
    
    bool isAuthenticated = false;
    bool isOnboardingComplete = false;
    
    try {
      // Use SharedPrefs as source of truth (set during login)
      isAuthenticated = SharedPrefsService.isAuthenticated;
      isOnboardingComplete = SharedPrefsService.isOnboardingComplete;
      
      if (kDebugMode) {
        print('🔐 Splash check - Auth: $isAuthenticated, Onboarding: $isOnboardingComplete');
      }
      
      // If authenticated but onboarding status not set, check database
      if (isAuthenticated && !isOnboardingComplete) {
        final currentUser = SupabaseService.currentUser;
        if (currentUser != null) {
          try {
            final client = SupabaseService.client;
            final response = await client
                .from('user_app_state')
                .select('onboarding_completed')
                .eq('user_id', currentUser.id)
                .maybeSingle();
            
            isOnboardingComplete = response?['onboarding_completed'] as bool? ?? false;
            await SharedPrefsService.setOnboardingComplete(isOnboardingComplete);
            
            if (kDebugMode) {
              print('✅ Updated onboarding status from DB: $isOnboardingComplete');
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error checking onboarding status: $e');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error in splash navigation: $e');
      }
      // Default to unauthenticated if error
      isAuthenticated = false;
      isOnboardingComplete = false;
    }

    if (!mounted) return;

    if (isAuthenticated) {
      if (isOnboardingComplete) {
        if (kDebugMode) print('🏠 Splash → Home');
        context.go(RouteConstants.home);
      } else {
        if (kDebugMode) print('📝 Splash → Onboarding');
        context.go(RouteConstants.onboarding);
      }
    } else {
      context.go(RouteConstants.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: const LifemonkLogo(fontSize: 48),
        ),
      ),
    );
  }
}
