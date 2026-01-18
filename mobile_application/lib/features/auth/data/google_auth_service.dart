import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/supabase_service.dart';

/// Service for Google Sign-In authentication
class GoogleAuthService {
  // Try WITHOUT serverClientId first to see if basic Google Sign-In works
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '549236270142-olp8knhbase8vjbmjbkp26dsvugvsbs2.apps.googleusercontent.com',
  );

  /// Sign in with Google
  /// Returns user email on success, null on failure
  static Future<AuthResponse?> signIn() async {
    try {
      print('📱 Step 1: Starting Google Sign-In picker...');
      print('📱 Using serverClientId: 853088014526-u2hpn3ucna5pj02qltmviundhkm57s68.apps.googleusercontent.com');
      
      // Sign in with Google to get the ID token
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Step 1 FAILED: googleUser is NULL');
        print('❌ Possible causes:');
        print('   1. User cancelled (tapped back)');
        print('   2. Google Play Services issue');
        print('   3. SHA-1 not added to Google Cloud Console');
        print('   4. OAuth client ID not configured correctly');
        print('❌ Current SHA-1 should be: 6F:64:B8:D0:A6:42:18:1D:EA:3E:A9:AB:E4:C8:F7:E3:12:AA:91:07');
        return null;
      }
      
      print('✅ Step 1: Google account selected: ${googleUser.email}');
      print('✅ Google user ID: ${googleUser.id}');
      print('📱 Step 2: Getting authentication tokens...');

      // Get the authentication details (idToken and accessToken)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      print('✅ Step 2: Tokens received - accessToken: ${accessToken != null}, idToken: ${idToken != null}');

      if (accessToken == null) {
        print('❌ Step 2 FAILED: No access token');
        throw 'No Access Token found.';
      }
      
      if (idToken == null) {
        print('❌ Step 2 FAILED: No ID token');
        throw 'No ID Token found.';
      }

      print('📱 Step 3: Signing in to Supabase...');
      
      // Sign in to Supabase with the ID Token
      final response = await SupabaseService.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      print('✅ Step 3: Supabase sign-in successful');
      print('✅ User: ${response.user?.email} (${response.user?.id})');
      print('✅ Session: ${response.session != null}');
      
      return response;
    } catch (e, stackTrace) {
      print('❌ Google Sign-In FAILED at some step');
      print('❌ Error: $e');
      print('❌ Stack trace: $stackTrace');
      
      // Check for common errors
      if (e.toString().contains('ApiException: 10')) {
        print('⚠️ Error 10: Fingerprint mismatch. SHA-1 key not added to Firebase Console.');
      } else if (e.toString().contains('ApiException: 12500')) {
        print('⚠️ Error 12500: Support email not configured in Firebase Console.');
      } else if (e.toString().contains('PlatformException')) {
        print('⚠️ Platform error: Google Play Services issue or configuration problem.');
      }
      
      return null;
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      if (kDebugMode) {
        print('✅ Google Sign-Out successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Google Sign-Out error: $e');
      }
    }
  }
  
  /// Disconnect from Google (clears cached account selection)
  /// Use this when user wants to switch accounts
  static Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      if (kDebugMode) {
        print('✅ Google Disconnect successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Google Disconnect error: $e');
      }
    }
  }

  /// Get currently signed-in user
  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Check if user is signed in
  static bool get isSignedIn => _googleSignIn.currentUser != null;
}
