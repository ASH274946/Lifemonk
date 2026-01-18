import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service for tracking user activities and calculating XP/streaks
/// Automatically logs activities and updates user progress
class UserActivityService {
  static final SupabaseClient _client = SupabaseService.client;

  /// Activity types with default XP values
  static const Map<String, int> activityXP = {
    'focus_session': 10,
    'workshop_attended': 50,
    'workshop_enrolled': 5,
    'byte_viewed': 3,
    'chapter_started': 5,
    'chapter_completed': 20,
    'quiz_completed': 30,
    'quiz_perfect_score': 50,
    'daily_login': 5,
    'streak_milestone_7': 100,
    'streak_milestone_30': 500,
  };

  /// Initialize user app state when user signs up
  static Future<void> initializeUserState(String userId) async {
    try {
      // Check if user state already exists
      final existing = await _client
          .from('user_app_state')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        if (kDebugMode) {
          print('✅ User state already exists for $userId');
        }
        return;
      }

      // Create new user state
      await _client.from('user_app_state').insert({
        'user_id': userId,
        'level': 1,
        'xp': 0,
        'streak_days': 1,
        'last_active_date': DateTime.now().toIso8601String().split('T')[0],
        'total_sessions': 0,
        'total_time_minutes': 0,
      });

      // Log initial activity
      await logActivity(
        userId: userId,
        activityType: 'daily_login',
        xpEarned: activityXP['daily_login']!,
      );

      if (kDebugMode) {
        print('✅ Initialized user state for $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing user state: $e');
      }
    }
  }

  /// Log a user activity
  static Future<void> logActivity({
    required String userId,
    required String activityType,
    String? activityId,
    int? xpEarned,
    int? durationMinutes,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final xp = xpEarned ?? activityXP[activityType] ?? 0;

      await _client.from('user_activities').insert({
        'user_id': userId,
        'activity_type': activityType,
        'activity_id': activityId,
        'xp_earned': xp,
        'duration_minutes': durationMinutes,
        'metadata': metadata,
      });

      if (kDebugMode) {
        print('✅ Logged activity: $activityType (+$xp XP)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging activity: $e');
      }
    }
  }

  /// Get user's current app state
  static Future<Map<String, dynamic>?> getUserAppState(String userId) async {
    try {
      final response = await _client
          .from('user_app_state')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user app state: $e');
      }
      return null;
    }
  }

  /// Check if user has been active today (for daily login bonus)
  static Future<bool> hasLoggedInToday(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final response = await _client
          .from('user_activities')
          .select('id')
          .eq('user_id', userId)
          .eq('activity_type', 'daily_login')
          .gte('created_at', today)
          .maybeSingle();

      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking daily login: $e');
      }
      return false;
    }
  }

  /// Award daily login bonus if not already given today
  static Future<void> checkAndAwardDailyLogin(String userId) async {
    try {
      final hasLogged = await hasLoggedInToday(userId);
      
      if (!hasLogged) {
        await logActivity(
          userId: userId,
          activityType: 'daily_login',
          xpEarned: activityXP['daily_login']!,
        );

        // Check for streak milestones
        final state = await getUserAppState(userId);
        if (state != null) {
          final streakDays = state['streak_days'] as int? ?? 0;
          
          if (streakDays == 7) {
            await logActivity(
              userId: userId,
              activityType: 'streak_milestone_7',
              xpEarned: activityXP['streak_milestone_7']!,
            );
          } else if (streakDays == 30) {
            await logActivity(
              userId: userId,
              activityType: 'streak_milestone_30',
              xpEarned: activityXP['streak_milestone_30']!,
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error awarding daily login: $e');
      }
    }
  }

  /// Log focus session completion
  static Future<void> logFocusSessionCompleted({
    required String userId,
    required String sessionId,
    required int durationMinutes,
    int? rating,
  }) async {
    try {
      // Log completion in focus completions table
      await _client.from('user_focus_completions').insert({
        'user_id': userId,
        'session_id': sessionId,
        'duration_minutes': durationMinutes,
        'rating': rating,
      });

      // Log activity for XP
      await logActivity(
        userId: userId,
        activityType: 'focus_session',
        activityId: sessionId,
        xpEarned: activityXP['focus_session']!,
        durationMinutes: durationMinutes,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging focus session: $e');
      }
    }
  }

  /// Log workshop enrollment
  static Future<void> logWorkshopEnrollment({
    required String userId,
    required String workshopId,
  }) async {
    try {
      // Add enrollment
      await _client.from('workshop_enrollments').insert({
        'user_id': userId,
        'workshop_id': workshopId,
      });

      // Log activity for XP
      await logActivity(
        userId: userId,
        activityType: 'workshop_enrolled',
        activityId: workshopId,
        xpEarned: activityXP['workshop_enrolled']!,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging workshop enrollment: $e');
      }
    }
  }

  /// Log workshop attendance
  static Future<void> logWorkshopAttendance({
    required String userId,
    required String workshopId,
  }) async {
    try {
      // Update enrollment to mark attendance
      await _client
          .from('workshop_enrollments')
          .update({
            'attended': true,
            'attended_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('workshop_id', workshopId);

      // Log activity for XP
      await logActivity(
        userId: userId,
        activityType: 'workshop_attended',
        activityId: workshopId,
        xpEarned: activityXP['workshop_attended']!,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging workshop attendance: $e');
      }
    }
  }

  /// Log byte view
  static Future<void> logByteView({
    required String userId,
    required String bytePath,
    int? watchDurationSeconds,
    bool? liked,
  }) async {
    try {
      await _client.from('user_byte_views').insert({
        'user_id': userId,
        'byte_path': bytePath,
        'watch_duration_seconds': watchDurationSeconds,
        'liked': liked,
      });

      // Award XP for watching byte
      await logActivity(
        userId: userId,
        activityType: 'byte_viewed',
        activityId: bytePath,
        xpEarned: activityXP['byte_viewed']!,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging byte view: $e');
      }
    }
  }

  /// Update course progress
  static Future<void> updateCourseProgress({
    required String userId,
    required String courseId,
    String? chapterId,
    required double progressPercent,
    bool completed = false,
  }) async {
    try {
      final existing = await _client
          .from('user_course_progress')
          .select()
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .eq('chapter_id', chapterId ?? '')
          .maybeSingle();

      final data = {
        'user_id': userId,
        'course_id': courseId,
        'chapter_id': chapterId,
        'progress_percent': progressPercent,
        'completed': completed,
        'last_accessed_at': DateTime.now().toIso8601String(),
        if (completed) 'completed_at': DateTime.now().toIso8601String(),
      };

      if (existing == null) {
        await _client.from('user_course_progress').insert(data);
        
        // Log chapter started
        if (chapterId != null) {
          await logActivity(
            userId: userId,
            activityType: 'chapter_started',
            activityId: chapterId,
            xpEarned: activityXP['chapter_started']!,
          );
        }
      } else {
        await _client
            .from('user_course_progress')
            .update(data)
            .eq('user_id', userId)
            .eq('course_id', courseId)
            .eq('chapter_id', chapterId ?? '');
      }

      // Log completion
      if (completed && chapterId != null) {
        await logActivity(
          userId: userId,
          activityType: 'chapter_completed',
          activityId: chapterId,
          xpEarned: activityXP['chapter_completed']!,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating course progress: $e');
      }
    }
  }

  /// Log quiz completion
  static Future<void> logQuizCompleted({
    required String userId,
    required String quizId,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      final isPerfectScore = score == totalQuestions;
      final xp = isPerfectScore 
          ? activityXP['quiz_perfect_score']! 
          : activityXP['quiz_completed']!;

      await logActivity(
        userId: userId,
        activityType: isPerfectScore ? 'quiz_perfect_score' : 'quiz_completed',
        activityId: quizId,
        xpEarned: xp,
        metadata: {
          'score': score,
          'total_questions': totalQuestions,
          'percentage': (score / totalQuestions * 100).round(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging quiz completion: $e');
      }
    }
  }

  /// Get user activity stats
  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final state = await getUserAppState(userId);
      
      if (state == null) {
        return {
          'level': 1,
          'xp': 0,
          'streak_days': 0,
          'total_sessions': 0,
          'total_time_minutes': 0,
        };
      }

      return {
        'level': state['level'] ?? 1,
        'xp': state['xp'] ?? 0,
        'streak_days': state['streak_days'] ?? 0,
        'total_sessions': state['total_sessions'] ?? 0,
        'total_time_minutes': state['total_time_minutes'] ?? 0,
        'last_active_date': state['last_active_date'],
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user stats: $e');
      }
      return {
        'level': 1,
        'xp': 0,
        'streak_days': 0,
        'total_sessions': 0,
        'total_time_minutes': 0,
      };
    }
  }
}
