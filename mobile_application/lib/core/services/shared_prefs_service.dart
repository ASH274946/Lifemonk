import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// Centralized service for SharedPreferences access
/// Provides type-safe getters and setters for app state
class SharedPrefsService {
  static SharedPreferences? _prefs;

  // Keys
  // Consolidating keys with AppConstants
  static const String _keyAuthType = 'authType'; // 'google', 'phone', 'guest'
  static const String _keyUserToken = 'userToken';
  static const String _keyStudentName = 'studentName';
  static const String _keySchoolName = 'schoolName';
  static const String _keyGrade = 'grade';
  static const String _keyCity = 'city';
  static const String _keyPhoneNumber = 'phoneNumber';

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPrefsService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Onboarding
  static bool get isOnboardingComplete => prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
  static Future<void> setOnboardingComplete(bool value) => prefs.setBool(AppConstants.onboardingCompleteKey, value);

  // Auth
  static String? get authType => prefs.getString(_keyAuthType);
  static Future<void> setAuthType(String value) => prefs.setString(_keyAuthType, value);
  
  static String? get userToken => prefs.getString(_keyUserToken);
  static Future<void> setUserToken(String value) => prefs.setString(_keyUserToken, value);
  
  static String? get phoneNumber => prefs.getString(_keyPhoneNumber);
  static Future<void> setPhoneNumber(String value) => prefs.setString(_keyPhoneNumber, value);

  // Student Details
  static String? get studentName => prefs.getString(_keyStudentName);
  static Future<void> setStudentName(String value) => prefs.setString(_keyStudentName, value);
  
  static String? get schoolName => prefs.getString(_keySchoolName);
  static Future<void> setSchoolName(String value) => prefs.setString(_keySchoolName, value);
  
  static String? get grade => prefs.getString(_keyGrade);
  static Future<void> setGrade(String value) => prefs.setString(_keyGrade, value);
  
  static String? get city => prefs.getString(_keyCity);
  static Future<void> setCity(String value) => prefs.setString(_keyCity, value);

  /// Clear all data (logout)
  static Future<void> clearAll() => prefs.clear();
  
  /// Clear only auth-related data (for sign-out)
  static Future<void> clearAuthData() async {
    await prefs.remove(_keyAuthType);
    await prefs.remove(_keyUserToken);
    await prefs.remove(_keyPhoneNumber);
    await prefs.remove(AppConstants.onboardingCompleteKey);
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => authType != null && userToken != null;
}
