import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase Service for initialization and configuration
class FirebaseService {
  static FirebaseApp? _app;
  
  /// Check if Firebase is initialized
  static bool get isInitialized => _app != null;

  /// Initialize Firebase with configuration from .env
  static Future<void> initialize() async {
    try {
      if (_app != null) {
        if (kDebugMode) {
          print('🔥 Firebase already initialized');
        }
        return;
      }

      final apiKey = dotenv.env['FIREBASE_API_KEY'];
      final authDomain = dotenv.env['FIREBASE_AUTH_DOMAIN'];
      final projectId = dotenv.env['FIREBASE_PROJECT_ID'];
      final storageBucket = dotenv.env['FIREBASE_STORAGE_BUCKET'];
      final messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
      final appId = dotenv.env['FIREBASE_APP_ID'];
      final measurementId = dotenv.env['FIREBASE_MEASUREMENT_ID'];

      if (apiKey == null || projectId == null || appId == null) {
        throw Exception('Firebase configuration missing in .env file');
      }

      _app = await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: apiKey,
          authDomain: authDomain ?? '',
          projectId: projectId,
          storageBucket: storageBucket ?? '',
          messagingSenderId: messagingSenderId ?? '',
          appId: appId,
          measurementId: measurementId,
        ),
      );

      if (kDebugMode) {
        print('✅ Firebase initialized successfully');
        print('📦 Project: $projectId');
        print('🗄️ Storage: $storageBucket');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase initialization error: $e');
      }
      rethrow;
    }
  }

  /// Get Firebase app instance
  static FirebaseApp get app {
    if (_app == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first');
    }
    return _app!;
  }

  /// Get Firebase Storage bucket URL
  static String get storageBucket {
    return dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  }

  /// Get Firebase Auth domain
  static String get authDomain {
    return dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  }
}
