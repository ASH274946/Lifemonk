import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/services/supabase_service.dart';
import '../../../shared/services/user_activity_service.dart';
import '../../workshops/data/supabase_workshop_repository.dart';
import '../domain/models/models.dart';

/// Repository for Home screen data
/// Fetches user profile, focus sessions, workshops, word of day, and categories from Supabase
class HomeRepository {
  final SupabaseClient _client;
  final IWorkshopRepository _workshopRepository = SupabaseWorkshopRepository();

  HomeRepository() : _client = SupabaseService.client;

  /// Get current user's profile with XP, level, and streak from app state
  Future<UserProfile?> getUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      // Fetch student profile
      final profileResponse = await _client
          .from('student_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      // Fetch app state for level and status
      final appState = await UserActivityService.getUserAppState(userId);

      if (profileResponse == null) return null;

      final level = appState?['level'] as int? ?? 1;
      return UserProfile(
        id: profileResponse['id'] as String,
        name: profileResponse['student_name'] as String? ?? 'Student',
        avatarUrl: null, // Can add avatar_url column to student_profiles later
        level: level,
        status: _getStatusForLevel(level),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user profile: $e');
      }
      return null;
    }
  }

  /// Get status text based on level
  String _getStatusForLevel(int level) {
    if (level >= 50) return 'Master';
    if (level >= 30) return 'Expert';
    if (level >= 20) return 'Scholar';
    if (level >= 10) return 'Learner';
    if (level >= 5) return 'Explorer';
    return 'Beginner';
  }

  /// Get active focus session
  Future<FocusSession?> getActiveFocusSession() async {
    try {
      final response = await _client
          .from('focus_sessions')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) return _getDummyFocusSession();

      return FocusSession(
        id: response['id'] as String,
        title: response['title'] as String,
        description: response['description'] as String? ?? '',
        durationMinutes: response['duration_minutes'] as int,
        iconType: response['icon_type'] as String? ?? 'meditation',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching focus session: $e');
      }
      return _getDummyFocusSession();
    }
  }

  FocusSession _getDummyFocusSession() {
    return const FocusSession(
      id: 'dummy-focus-1',
      title: 'Deep Focus Meditation',
      description: 'Enhance your concentration with this 5-minute session.',
      durationMinutes: 5,
      iconType: 'meditation',
    );
  }

  /// Get next upcoming workshop
  Future<Workshop?> getUpcomingWorkshop() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _client
          .from('workshops')
          .select()
          .eq('is_active', true)
          .gte('date_time', now)
          .order('date_time', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) return _getDummyWorkshop();

      final dateTime = DateTime.parse(response['date_time'] as String);
      
      final userId = _client.auth.currentUser?.id;
      bool isEnrolled = false;
      if (userId != null) {
        final enrollment = await _client
            .from('workshop_enrollments')
            .select()
            .eq('user_id', userId)
            .eq('workshop_id', response['id'] as String)
            .maybeSingle();
        isEnrolled = enrollment != null;
      }

      return Workshop(
        id: response['id'] as String,
        title: response['title'] as String,
        dateTime: dateTime,
        participantCount: 15,
        isEnrolled: isEnrolled,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching workshop: $e');
      }
      return _getDummyWorkshop();
    }
  }

  Workshop _getDummyWorkshop() {
    return Workshop(
      id: 'dummy-ws-1',
      title: 'Vedic Math Masterclass',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
      participantCount: 42,
    );
  }

  /// Get today's word of the day
  Future<WordOfDay?> getWordOfDay() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final response = await _client
          .from('word_of_day')
          .select()
          .lte('date', today)
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return _getDummyWordOfDay();

      return WordOfDay(
        id: response['id'] as String,
        word: response['word'] as String,
        meaning: response['meaning'] as String,
        date: DateTime.parse(response['date'] as String),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching word of day: $e');
      }
      return _getDummyWordOfDay();
    }
  }

  WordOfDay _getDummyWordOfDay() {
    return WordOfDay(
      id: 'dummy-word-1',
      word: 'Resilience',
      meaning: 'The capacity to recover quickly from difficulties.',
      date: DateTime.now(),
    );
  }

  /// Get learning categories for "Your Plan" section
  Future<List<LearningCategory>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .limit(8);

      final results = (response as List)
          .map((item) => LearningCategory(
                id: item['id'] as String,
                title: item['title'] as String,
                iconType: item['icon_type'] as String,
                lessonCount: item['lesson_count'] as int? ?? 0,
              ))
          .toList();

      if (results.isEmpty) return _getDummyCategories();
      return results;
    } catch (e) {
      return _getDummyCategories();
    }
  }

  List<LearningCategory> _getDummyCategories() {
    return [
      LearningCategory(id: 'cat-1', title: 'Mathematics', iconType: 'mathematics', lessonCount: 24),
      LearningCategory(id: 'cat-2', title: 'Geography', iconType: 'geography', lessonCount: 18),
      LearningCategory(id: 'cat-3', title: 'Science', iconType: 'science', lessonCount: 30),
      LearningCategory(id: 'cat-4', title: 'Cognitive', iconType: 'cognitive', lessonCount: 12),
    ];
  }


  /// Enroll the current user into a workshop using the shared workshop repository
  Future<bool> enrollInWorkshop(String workshopId) async {
    try {
      await _workshopRepository.enrollWorkshop(workshopId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error enrolling in workshop $workshopId: $e');
      }
      return false;
    }
  }

  /// Get user progress stats from activities and app state
  Future<UserProgress> getUserProgress() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return UserProgress(
          totalDays: 0,
          lessonsCompleted: 0,
          currentScore: 0,
          lastActive: DateTime.now(),
        );
      }

      // Get app state
      final appState = await UserActivityService.getUserAppState(userId);
      
      // Count completed chapters (lessons)
      final chaptersResponse = await _client
          .from('user_activities')
          .select('activity_id')
          .eq('user_id', userId)
          .eq('activity_type', 'chapter_completed');
      
      final lessonsCompleted = (chaptersResponse as List).length;

      // Count workshop enrollments
      final workshopsResponse = await _client
          .from('workshop_enrollments')
          .select('workshop_id')
          .eq('user_id', userId);
      
      final workshopsJoined = (workshopsResponse as List).length;

      // Count unique days active
      final activitiesResponse = await _client
          .from('user_activities')
          .select('created_at')
          .eq('user_id', userId);
      
      final uniqueDays = (activitiesResponse as List)
          .map((item) => (item['created_at'] as String).split('T')[0])
          .toSet()
          .length;

      return UserProgress(
        totalDays: uniqueDays,
        lessonsCompleted: lessonsCompleted,
        currentScore: appState?['xp'] as int? ?? 0,
        workshopsJoined: workshopsJoined,
        currentStreak: appState?['streak_days'] as int? ?? 0,
        lastActive: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user progress: $e');
      }
      return UserProgress(
        totalDays: 0,
        lessonsCompleted: 0,
        currentScore: 0,
        lastActive: DateTime.now(),
      );
    }
  }

  /// Get all home data in parallel
  Future<HomeData> getHomeData() async {
    try {
      // Check and award daily login bonus
      final userId = _client.auth.currentUser?.id;
      if (userId != null) {
        await UserActivityService.checkAndAwardDailyLogin(userId);
      }

      final results = await Future.wait([
        getUserProfile(),
        getActiveFocusSession(),
        getUpcomingWorkshop(),
        getWordOfDay(),
        getCategories(),
      ]);

      return HomeData(
        userProfile: results[0] as UserProfile?,
        focusSession: results[1] as FocusSession?,
        upcomingWorkshop: results[2] as Workshop?,
        wordOfDay: results[3] as WordOfDay?,
        categories: results[4] as List<LearningCategory>,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching home data: $e');
      }
      return HomeData(error: 'Failed to load data: $e');
    }
  }
}
