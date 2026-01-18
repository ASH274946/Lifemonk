import 'package:flutter/foundation.dart';import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../core/services/shared_prefs_service.dart';

/// Repository for authentication operations
class AuthRepository {
  /// Check if Supabase is initialized
  bool get isSupabaseInitialized {
    try {
      SupabaseService.client;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await SupabaseService.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await SupabaseService.auth.signUp(email: email, password: password);
  }

  /// Sign in with Google using OAuth (Mobile Deep Linking)
  /// This method uses Supabase OAuth with proper mobile redirect handling.
  /// The redirectTo parameter is REQUIRED for mobile apps to handle the OAuth callback
  /// via deep linking, preventing the "Server not found" error in the browser.
  Future<bool> signInWithGoogleOAuth() async {
    return await SupabaseService.auth.signInWithOAuth(
      OAuthProvider.google,
      // CRITICAL: redirectTo must match the deep link scheme configured in AndroidManifest.xml
      // This tells Supabase where to redirect after successful Google authentication.
      // Format: <scheme>://<host> must match the intent-filter in Android config
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  /// Sign in with Google using ID Token (Native Google Sign-In)
  /// Uses google_sign_in package for better UX
  Future<AuthResponse> signInWithGoogleIdToken({
    required String idToken,
    required String accessToken,
  }) async {
    return await SupabaseService.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  /// Send OTP to phone number
  /// Supabase will send SMS via configured provider (e.g., Twilio)
  Future<void> sendOtp({required String phone}) async {
    try {
      await SupabaseService.auth.signInWithOtp(phone: phone);
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('❌ OTP Send Error: ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ OTP Send Error: $e');
      }
      rethrow;
    }
  }

  /// Verify OTP code sent to phone
  /// Returns AuthResponse with user data on successful verification
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return await SupabaseService.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    if (isSupabaseInitialized) {
      await SupabaseService.auth.signOut();
    }
    // Clear SharedPrefs cache
    await SharedPrefsService.clearAuthData();
  }

  /// Get current user
  User? get currentUser {
    if (!isSupabaseInitialized) return null;
    return SupabaseService.currentUser;
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    if (!isSupabaseInitialized) return false;
    return SupabaseService.isAuthenticated;
  }

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges {
    if (!isSupabaseInitialized) {
      return Stream.value(AuthState(AuthChangeEvent.signedOut, null));
    }
    return SupabaseService.authStateChanges;
  }

  /// Check if student profile exists for a user
  /// Returns true if the user has completed onboarding, false otherwise
  /// Queries the student_profiles table to see if this user ID has data
  Future<bool> hasStudentProfile(String userId) async {
    if (!isSupabaseInitialized) return false;
    
    try {
      final response = await SupabaseService.client
          .from('student_profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      
      // If response is not null, profile exists
      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error checking student profile: $e');
      }
      // On error, return false to be safe (user goes to onboarding)
      return false;
    }
  }
  /// Reset password for email
  Future<void> resetPassword({required String email}) async {
    await SupabaseService.auth.resetPasswordForEmail(email);
  }
}