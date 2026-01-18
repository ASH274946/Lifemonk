import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// Service for local storage operations using SharedPreferences
class LocalStorageService {
  LocalStorageService._();

  static SharedPreferences? _prefs;

  /// Initialize shared preferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'LocalStorageService not initialized. Call initialize() first.',
      );
    }
    return _prefs!;
  }

  // Onboarding status

  /// Check if onboarding is completed
  static bool get isOnboardingComplete {
    return prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
  }

  /// Set onboarding as completed
  static Future<bool> setOnboardingComplete(bool value) {
    return prefs.setBool(AppConstants.onboardingCompleteKey, value);
  }

  // Generic methods

  /// Get a string value
  static String? getString(String key) {
    return prefs.getString(key);
  }

  /// Set a string value
  static Future<bool> setString(String key, String value) {
    return prefs.setString(key, value);
  }

  /// Get a bool value
  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  /// Set a bool value
  static Future<bool> setBool(String key, bool value) {
    return prefs.setBool(key, value);
  }

  /// Remove a value
  static Future<bool> remove(String key) {
    return prefs.remove(key);
  }

  /// Clear all stored data
  static Future<bool> clear() {
    return prefs.clear();
  }
}
