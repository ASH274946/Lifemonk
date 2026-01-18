import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'models.dart';

/// Real Supabase implementation of CMS Repository
/// Fetches all content from Supabase database
class SupabaseCmsRepository implements CmsRepository {
  final SupabaseClient _client;

  SupabaseCmsRepository() : _client = SupabaseService.client;


  @override
  Future<CmsCourse> getCourseById(String courseId) async {
    try {
      // Fetch course details
      final courseResponse = await _client
          .from('courses')
          .select()
          .eq('id', courseId)
          .single();

      // Fetch chapters for this course
      final chaptersResponse = await _client
          .from('chapters')
          .select()
          .eq('course_id', courseId)
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final chapters = (chaptersResponse as List).map((item) {
        return CmsChapter(
          id: item['id'] as String,
          title: item['title'] as String,
          summary: item['summary'] as String? ?? '',
        );
      }).toList();

      return CmsCourse(
        id: courseResponse['id'] as String,
        title: courseResponse['title'] as String,
        description: courseResponse['description'] as String? ?? '',
        coverImageUrl: courseResponse['cover_image_url'] as String? ?? '',
        chapters: chapters,
        bytes: [], // Bytes are fetched separately via getBytesFeed
        quizAvailable: courseResponse['quiz_available'] as bool? ?? false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching course $courseId: $e');
      }
      // Return empty course on error
      return CmsCourse(
        id: courseId,
        title: 'Course',
        description: '',
        coverImageUrl: '',
        chapters: [],
        bytes: [],
        quizAvailable: false,
      );
    }
  }

  @override
  Future<List<CmsByte>> getBytesFeed({String? categoryId}) async {
    // Bytes are now handled by Cloudinary via ByteRepository
    // This method is deprecated in favor of ByteRepository
    return [];
  }

  @override
  Future<List<CmsPlanSubject>> getPlan() async {
    try {
      // Get user's course progress
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('user_course_progress')
          .select('course_id, progress_percent, courses(title)')
          .eq('user_id', userId);

      return (response as List).map((item) {
        final courseData = item['courses'] as Map<String, dynamic>?;
        return CmsPlanSubject(
          id: item['course_id'] as String,
          title: courseData?['title'] as String? ?? 'Course',
          progress: (item['progress_percent'] as num? ?? 0).toDouble() / 100,
          colorHex: _getColorForCourse(item['course_id'] as String),
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user plan: $e');
      }
      return [];
    }
  }

  @override
  Future<List<CmsWorkshop>> getWorkshops() async {
    try {
      final userId = _client.auth.currentUser?.id;
      
      // Fetch workshops and check enrollment status
      final workshopsResponse = await _client
          .from('workshops')
          .select()
          .eq('is_active', true)
          .gte('date_time', DateTime.now().toIso8601String())
          .order('date_time', ascending: true);

      List<String> enrolledWorkshopIds = [];
      if (userId != null) {
        final enrollmentsResponse = await _client
            .from('workshop_enrollments')
            .select('workshop_id')
            .eq('user_id', userId);
        
        enrolledWorkshopIds = (enrollmentsResponse as List)
            .map((e) => e['workshop_id'] as String)
            .toList();
      }

      final results = (workshopsResponse as List).map((item) {
        final workshopId = item['id'] as String;
        return CmsWorkshop(
          id: workshopId,
          title: item['title'] as String,
          instructor: 'Expert Instructor', // Default for now
          dateTime: DateTime.parse(item['date_time'] as String),
          description: item['description'] as String? ?? '',
          enrolled: enrolledWorkshopIds.contains(workshopId),
          enrollmentPercentage: item['enrollment_percentage'] as int? ?? 0,
          imageUrl: item['image_url'] as String? ?? '',
          category: item['category'] as String? ?? 'General',
          durationMinutes: item['duration_minutes'] as int? ?? 60,
        );
      }).toList();

      if (results.isEmpty) {
        return _getDummyWorkshops();
      }
      return results;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching workshops: $e');
      }
      return _getDummyWorkshops();
    }
  }

  List<CmsWorkshop> _getDummyWorkshops() {
    return [
      CmsWorkshop(
        id: 'ws-1',
        title: 'Mastering Vedic Math Secrets',
        instructor: 'Dr. Rao',
        dateTime: DateTime.now().add(const Duration(days: 2, hours: 5)),
        description: 'Learn rapid calculation techniques in this live session.',
        enrolled: true,
        enrollmentPercentage: 80,
        imageUrl: '',
        category: 'Math',
        durationMinutes: 90,
      ),
      CmsWorkshop(
        id: 'ws-2',
        title: 'Exploring World Geography',
        instructor: 'Sarah J.',
        dateTime: DateTime.now().add(const Duration(days: 5, hours: 2)),
        description: 'A deep dive into continents and cultures.',
        enrolled: false,
        enrollmentPercentage: 65,
        imageUrl: '',
        category: 'Geography',
        durationMinutes: 60,
      ),
      CmsWorkshop(
        id: 'ws-3',
        title: 'Creative Art & Origami',
        instructor: 'Artist Mia',
        dateTime: DateTime.now().add(const Duration(days: 7)),
        description: 'Release your creativity with simple paper folding.',
        enrolled: false,
        enrollmentPercentage: 40,
        imageUrl: '',
        category: 'Arts',
        durationMinutes: 120,
      ),
    ];
  }

  @override
  Future<List<CmsCategory>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final results = (response as List).map((item) {
        return CmsCategory(
          id: item['id'] as String,
          title: item['title'] as String,
          iconType: item['icon_type'] as String,
          lessonCount: item['lesson_count'] as int? ?? 0,
          iconColor: item['icon_color'] as String? ?? '#4A90E2',
          visible: true,
          order: item['sort_order'] as int? ?? 0,
        );
      }).toList();

      if (results.isEmpty) return _getDummyCategories();
      return results;
    } catch (e) {
      return _getDummyCategories();
    }
  }

  List<CmsCategory> _getDummyCategories() {
    return [
      CmsCategory(id: 'cat-1', title: 'Vedic Maths', iconType: 'mathematics', lessonCount: 24, iconColor: '#9DB8FF', visible: true, order: 1),
      CmsCategory(id: 'cat-2', title: 'Geography', iconType: 'geography', lessonCount: 18, iconColor: '#4A90E2', visible: true, order: 2),
      CmsCategory(id: 'cat-3', title: 'Cognitive', iconType: 'cognitive', lessonCount: 12, iconColor: '#A855F7', visible: true, order: 3),
      CmsCategory(id: 'cat-4', title: 'Science', iconType: 'science', lessonCount: 30, iconColor: '#86EFAC', visible: true, order: 4),
    ];
  }

  /// Helper to get color for a course (simple hash-based color assignment)
  String _getColorForCourse(String courseId) {
    final colors = [
      '#9DB8FF',
      '#FFB2B2',
      '#FFD58C',
      '#C7E4FF',
      '#A855F7',
      '#86EFAC',
      '#4A90E2',
    ];
    final index = courseId.hashCode.abs() % colors.length;
    return colors[index];
  }
}


/// Abstract repository describing the CMS contract.
/// Replace this with a real implementation (Supabase/Firestore/Headless CMS)
/// without changing UI code.
abstract class CmsRepository {
  Future<List<CmsCategory>> getCategories();
  Future<CmsCourse> getCourseById(String courseId);
  Future<List<CmsByte>> getBytesFeed({String? categoryId});
  Future<List<CmsPlanSubject>> getPlan();
  Future<List<CmsWorkshop>> getWorkshops();
}
