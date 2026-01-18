import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for Supabase initialization and access
class SupabaseService {
  SupabaseService._();

  static SupabaseClient? _client;

  /// Initialize Supabase with credentials from .env file
  static Future<void> initialize() async {
    // Prevent re-initialization
    if (_client != null) return;
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      print('⚠️ Supabase credentials missing');
      return;
    }

    if (supabaseUrl == 'your_supabase_url_here' ||
        supabaseAnonKey == 'your_supabase_anon_key_here') {
      print('⚠️ Placeholder Supabase credentials found. Skipping init.');
      return;
    }

    try {
      // Add timeout to prevent app hang
      await Supabase.initialize(
        url: supabaseUrl, 
        anonKey: supabaseAnonKey,
      ).timeout(const Duration(seconds: 3));
      
      _client = Supabase.instance.client;
    } catch (e) {
      print('❌ Supabase initialization failed: $e');
      // Do NOT rethrow - allow app to start in offline/guest mode
    }
  }

  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Get the current auth instance
  static GoTrueClient get auth => client.auth;

  /// Get the current user
  static User? get currentUser => auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes
  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
}
