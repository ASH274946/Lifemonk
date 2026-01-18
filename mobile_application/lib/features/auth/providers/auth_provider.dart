import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../data/auth_repository.dart';
import '../domain/auth_state.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../core/services/shared_prefs_service.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for reactive auth state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Provider that streams auth state changes from Supabase
final authStreamProvider = StreamProvider<User?>((ref) {
  try {
    return SupabaseService.authStateChanges.map((state) => state.session?.user);
  } catch (e) {
    // Supabase not initialized
    return Stream.value(null);
  }
});

/// Notifier class for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState.initial()) {
    _initialize();
  }

  /// Initialize auth state from current session
  void _initialize() {
    try {
      final user = _repository.currentUser;
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }

      // Listen to auth state changes
      _repository.authStateChanges.listen((authState) {
        final user = authState.session?.user;
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = AuthState.unauthenticated();
        }
      });
    } catch (e) {
      // Supabase not initialized, treat as unauthenticated
      if (kDebugMode) {
        print('⚠️ Auth initialization skipped: Supabase not configured');
      }
      state = AuthState.unauthenticated();
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();
    try {
      final response = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      if (response.user != null) {
        state = AuthState.authenticated(response.user!);
      } else {
        state = AuthState.error('Sign in failed');
      }
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error('An unexpected error occurred');
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();
    try {
      final response = await _repository.signUpWithEmail(
        email: email,
        password: password,
      );
      if (response.user != null) {
        state = AuthState.authenticated(response.user!);
      } else {
        state = AuthState.error('Sign up failed');
      }
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error('An unexpected error occurred');
    }
  }

  /// Sign in with Google using OAuth with proper mobile redirect
  /// This method uses Supabase OAuth with deep linking for mobile apps.
  /// It opens Google Sign-In in the browser and redirects back to the app.
  /// After successful auth, checks onboarding status and returns navigation instruction
  Future<String?> signInWithGoogleOAuth() async {
    state = AuthState.loading();
    try {
      // Launch OAuth flow - this will open browser and return via deep link
      // Note: The OAuth completion is handled by Supabase's deep link handler
      // which will update the auth state automatically
      final success = await _repository.signInWithGoogleOAuth();

      if (success) {
        // Wait longer for the auth state to update from the deep link callback
        // The Supabase SDK handles the OAuth callback asynchronously
        await Future.delayed(const Duration(milliseconds: 1500));

        // Check if user is now authenticated
        final user = _repository.currentUser;
        if (user != null) {
          state = AuthState.authenticated(user);
          
          // CRITICAL: Persist auth state immediately to SharedPrefs
          // This prevents redirect loops when app is backgrounded/foregrounded
          try {
            await SharedPrefsService.setAuthType('google');
            await SharedPrefsService.setUserToken(user.id);
            if (kDebugMode) {
              print('✅ Persisted auth state to SharedPrefs: ${user.email}');
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Failed to persist auth state: $e');
            }
          }

          // Check if user record exists in our users table
          final client = SupabaseService.client;
          try {
            final userExists = await client
                .from('users')
                .select('id')
                .eq('id', user.id)
                .maybeSingle();

            if (userExists == null) {
              // Create user record if trigger didn't work
              try {
                await client.from('users').insert({
                  'id': user.id,
                  'email': user.email,
                });
                if (kDebugMode) {
                  print('✅ Created user record for: ${user.id}');
                }
              } catch (e) {
                // If user record creation fails, it's okay - user is still authenticated
                if (kDebugMode) {
                  print('⚠️ User record creation failed (but OAuth succeeded): $e');
                }
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error managing user record: $e');
            }
          }

          // Check if user has completed onboarding
          bool onboardingComplete = await _checkOnboardingComplete(user.id);

          if (kDebugMode) {
            print(
              '🔐 Google Sign-In successful. Onboarding: $onboardingComplete',
            );
          }

          // Return navigation path: '/home' or '/onboarding'
          return onboardingComplete ? '/home' : '/onboarding';
        } else {
          state = AuthState.error('Google Sign-In was cancelled.');
          if (kDebugMode) {
            print('❌ No user after OAuth success - session may have expired');
          }
          return null;
        }
      } else {
        state = AuthState.error('Google Sign-In failed. Please try again.');
        if (kDebugMode) {
          print('❌ OAuth flow returned false');
        }
        return null;
      }
    } on AuthException catch (e) {
      // Handle Supabase auth exceptions
      // Note: "Database error saving new user" can happen but OAuth still succeeds
      if (kDebugMode) {
        print('❌ Auth exception during Google Sign-In: ${e.message}');
      }
      
      // Even if there's a database error, the user might still be authenticated
      // Wait a bit and check if user is authenticated despite the error
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final user = _repository.currentUser;
      if (user != null) {
        if (kDebugMode) {
          print('✅ User authenticated despite error: ${user.email}');
        }
        state = AuthState.authenticated(user);
        
        // Persist to SharedPrefs
        try {
          await SharedPrefsService.setAuthType('google');
          await SharedPrefsService.setUserToken(user.id);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Failed to persist auth state: $e');
          }
        }
        
        // Check onboarding
        bool onboardingComplete = await _checkOnboardingComplete(user.id);
        return onboardingComplete ? '/home' : '/onboarding';
      }
      
      state = AuthState.error(e.message);
      return null;
    } catch (e) {
      state = AuthState.error('Google Sign-In failed. Please try again.');
      if (kDebugMode) {
        print('❌ Unexpected error during Google Sign-In: $e');
      }
      return null;
    }
  }

  /// Sign in with Google using native Google Sign-In
  /// Provides better UX than OAuth browser flow
  Future<void> signInWithGoogle({
    required String idToken,
    required String accessToken,
  }) async {
    state = AuthState.loading();
    try {
      final response = await _repository.signInWithGoogleIdToken(
        idToken: idToken,
        accessToken: accessToken,
      );
      if (response.user != null) {
        state = AuthState.authenticated(response.user!);
      } else {
        state = AuthState.error('Google Sign-In failed. Please try again.');
      }
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error('Google Sign-In failed. Please try again.');
    }
  }

  /// Send OTP to phone number
  /// SMS will be sent via Supabase configured provider (Twilio)
  Future<void> sendOtp({required String phone}) async {
    state = AuthState.loading();
    try {
      await _repository.sendOtp(phone: phone);
      // Return to unauthenticated state, waiting for OTP verification
      state = AuthState.unauthenticated();
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
      rethrow;
    } catch (e) {
      state = AuthState.error('Failed to send OTP. Please check your phone number and try again.');
      rethrow;
    }
  }

  /// Verify OTP code
  /// Validates the 6-digit code sent to user's phone
  /// After successful verification, checks onboarding status and returns navigation path
  Future<String?> verifyOtp({
    required String phone,
    required String token,
  }) async {
    state = AuthState.loading();
    try {
      final response = await _repository.verifyOtp(phone: phone, token: token);
      if (response.user != null) {
        state = AuthState.authenticated(response.user!);

        // Check if user record exists in our users table
        // The database trigger should auto-create it, but verify
        final client = SupabaseService.client;
        final userExists = await client
            .from('users')
            .select('id')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (userExists == null) {
          // Create user record if trigger didn't work
          await client.from('users').insert({
            'id': response.user!.id,
            'phone': phone,
          });
          if (kDebugMode) {
            print('✅ Created user record for: ${response.user!.id}');
          }
        }

        // Check if user has completed onboarding
        bool onboardingComplete = await _checkOnboardingComplete(
          response.user!.id,
        );

        if (kDebugMode) {
          print(
            '🔐 Phone OTP verified successfully. Onboarding: $onboardingComplete',
          );
        }

        // Return navigation path: '/home' or '/onboarding'
        return onboardingComplete ? '/home' : '/onboarding';
      } else {
        state = AuthState.error('OTP verification failed. Please try again.');
        return null;
      }
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
      return null;
    } catch (e) {
      state = AuthState.error('Invalid OTP code. Please check and try again.');
      return null;
    }
  }

  /// Check if user has completed onboarding by querying users table
  /// Returns true if user exists and onboarding is complete, false if new user
  Future<bool> checkOnboardingComplete(String userId) async {
    return await _checkOnboardingComplete(userId);
  }

  /// Check if user has completed onboarding by querying users table
  /// Returns true if user exists and onboarding is complete, false if new user
  Future<bool> _checkOnboardingComplete(String userId) async {
    try {
      // Use the new user repository to check onboarding status
      final client = SupabaseService.client;
      final response = await client
          .from('user_app_state')
          .select('onboarding_completed')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // No record yet, user needs onboarding
        return false;
      }

      return response['onboarding_completed'] as bool? ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error checking onboarding status: $e');
      }
      // If we can't query, assume not onboarded (safer - user goes to onboarding)
      return false;
    }
  }

  Future<void> signOut() async {
    state = AuthState.loading();
    try {
      await _repository.signOut();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('Failed to sign out');
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    state = AuthState.loading();
    try {
      await _repository.resetPassword(email: email);
      state = AuthState.unauthenticated();
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error('Failed to send reset email');
    }
  }

  /// Clear error state
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = AuthState.unauthenticated();
    }
  }

  /// Continue as guest without authentication
  void continueAsGuest() {
    state = AuthState.guest();
  }
}
