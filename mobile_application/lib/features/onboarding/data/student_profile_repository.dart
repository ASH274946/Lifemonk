import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';
import '../domain/student_profile.dart';

/// Repository for student profile data operations
/// Handles all Supabase database interactions for student profiles
class StudentProfileRepository {
  static const String _tableName = 'student_profiles';

  /// Save or update student profile
  /// Uses upsert to handle both new and existing profiles
  Future<StudentProfile> saveProfile({
    required String studentName,
    required String schoolName,
    required String grade,
    required String city,
    required String stateName,
  }) async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final data = {
      'user_id': user.id,
      'student_name': studentName.trim(),
      'school_name': schoolName.trim(),
      'grade': grade,
      'city': city.trim(),
      'state': stateName.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      // Check if profile exists
      final existingProfile = await getProfile();
      
      if (existingProfile != null) {
        // Update existing profile
        final response = await SupabaseService.client
            .from(_tableName)
            .update(data)
            .eq('user_id', user.id)
            .select()
            .single();
        
        return StudentProfile.fromJson(response);
      } else {
        // Insert new profile
        data['created_at'] = DateTime.now().toIso8601String();
        
        final response = await SupabaseService.client
            .from(_tableName)
            .insert(data)
            .select()
            .single();
        
        return StudentProfile.fromJson(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving student profile: $e');
      }
      rethrow;
    }
  }

  /// Get student profile for current user
  Future<StudentProfile?> getProfile() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return StudentProfile.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching student profile: $e');
      }
      return null;
    }
  }

  /// Check if student profile exists for current user
  Future<bool> hasProfile() async {
    final profile = await getProfile();
    return profile != null;
  }

  /// Delete student profile (for account deletion)
  Future<void> deleteProfile() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await SupabaseService.client
          .from(_tableName)
          .delete()
          .eq('user_id', user.id);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting student profile: $e');
      }
      rethrow;
    }
  }
}
