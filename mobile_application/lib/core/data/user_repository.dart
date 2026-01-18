import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/user_models.dart';

/// Custom exceptions for user operations
class UserNotFoundException implements Exception {
  final String message;
  UserNotFoundException(this.message);

  @override
  String toString() => 'UserNotFoundException: $message';
}

class UserCreationException implements Exception {
  final String message;
  UserCreationException(this.message);

  @override
  String toString() => 'UserCreationException: $message';
}

class UserUpdateException implements Exception {
  final String message;
  UserUpdateException(this.message);

  @override
  String toString() => 'UserUpdateException: $message';
}

/// User Repository Interface
/// Defines contract for user data operations
abstract class IUserRepository {
  /// Get current authenticated user's profile
  Future<UserProfile?> getCurrentUserProfile();

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId);

  /// Create new user profile
  Future<UserProfile> createUserProfile({
    required String userId,
    required String phone,
    required String name,
    String? email,
    String? school,
    String? grade,
    String? city,
    String? state,
    String? language,
  });

  /// Update user profile
  Future<UserProfile> updateUserProfile(UserProfile profile);

  /// Get user app state
  Future<UserAppState?> getUserAppState(String userId);

  /// Update user app state
  Future<UserAppState> updateUserAppState(UserAppState appState);

  /// Complete onboarding
  Future<void> completeOnboarding(String userId);

  /// Update user activity
  Future<void> updateLastActive(String userId);

  /// Get complete user data (profile + app state)
  Future<UserData?> getUserData(String userId);

  /// Check if user exists
  Future<bool> userExists(String userId);
}

/// Supabase User Repository Implementation
/// Production-ready implementation using Supabase
class SupabaseUserRepository implements IUserRepository {
  final SupabaseClient _supabase;

  SupabaseUserRepository(this._supabase);

  /// Get current authenticated user's profile
  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      return await getUserProfile(userId);
    } catch (e) {
      throw UserNotFoundException('Failed to get current user profile: $e');
    }
  }

  /// Get user profile by ID
  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile.fromJson(response);
    } catch (e) {
      throw UserNotFoundException('Failed to get user profile: $e');
    }
  }

  /// Create new user profile
  @override
  Future<UserProfile> createUserProfile({
    required String userId,
    required String phone,
    required String name,
    String? email,
    String? school,
    String? grade,
    String? city,
    String? state,
    String? language,
  }) async {
    try {
      final now = DateTime.now();

      // Create profile data
      final profileData = {
        'id': userId,
        'phone': phone,
        'email': email,
        'name': name,
        'school': school,
        'grade': grade,
        'city': city,
        'state': state,
        'language': language ?? 'en',
        'role': 'student',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      // Insert into users table
      final response = await _supabase
          .from('users')
          .insert(profileData)
          .select()
          .single();

      // Create app state record
      await _supabase.from('user_app_state').insert({
        'user_id': userId,
        'onboarding_completed': false,
        'last_active_at': now.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      return UserProfile.fromJson(response);
    } catch (e) {
      throw UserCreationException('Failed to create user profile: $e');
    }
  }

  /// Update user profile
  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      final updateData = {
        'phone': profile.phone,
        'email': profile.email,
        'name': profile.name,
        'school': profile.school,
        'grade': profile.grade,
        'city': profile.city,
        'state': profile.state,
        'language': profile.language,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('users')
          .update(updateData)
          .eq('id', profile.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw UserUpdateException('Failed to update user profile: $e');
    }
  }

  /// Get user app state
  @override
  Future<UserAppState?> getUserAppState(String userId) async {
    try {
      final response = await _supabase
          .from('user_app_state')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserAppState.fromJson(response);
    } catch (e) {
      throw UserNotFoundException('Failed to get user app state: $e');
    }
  }

  /// Update user app state
  @override
  Future<UserAppState> updateUserAppState(UserAppState appState) async {
    try {
      final updateData = {
        'onboarding_completed': appState.onboardingCompleted,
        'onboarding_completed_at': appState.onboardingCompletedAt
            ?.toIso8601String(),
        'last_active_at': appState.lastActiveAt.toIso8601String(),
        'total_sessions': appState.totalSessions,
        'current_level': appState.currentLevel,
        'xp': appState.xp,
        'streak_days': appState.streakDays,
        'longest_streak': appState.longestStreak,
        'last_streak_date': appState.lastStreakDate?.toIso8601String(),
        'theme': appState.theme,
        'notifications_enabled': appState.notificationsEnabled,
        'sound_enabled': appState.soundEnabled,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('user_app_state')
          .update(updateData)
          .eq('user_id', appState.userId)
          .select()
          .single();

      return UserAppState.fromJson(response);
    } catch (e) {
      throw UserUpdateException('Failed to update user app state: $e');
    }
  }

  /// Complete onboarding
  @override
  Future<void> completeOnboarding(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      // Use upsert to ensure record exists (handles both new and existing users)
      await _supabase
          .from('user_app_state')
          .upsert({
            'user_id': userId,
            'onboarding_completed': true,
            'onboarding_completed_at': now,
            'updated_at': now,
            'last_active_at': now,
          });
    } catch (e) {
      throw UserUpdateException('Failed to complete onboarding: $e');
    }
  }

  /// Update user activity
  @override
  Future<void> updateLastActive(String userId) async {
    try {
      await _supabase
          .from('user_app_state')
          .update({
            'last_active_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      // Silently fail - not critical
      print('Failed to update last active: $e');
    }
  }

  /// Get complete user data (profile + app state)
  @override
  Future<UserData?> getUserData(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      if (profile == null) return null;

      final appState = await getUserAppState(userId);
      if (appState == null) return null;

      return UserData(profile: profile, appState: appState);
    } catch (e) {
      throw UserNotFoundException('Failed to get user data: $e');
    }
  }

  /// Check if user exists
  @override
  Future<bool> userExists(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
