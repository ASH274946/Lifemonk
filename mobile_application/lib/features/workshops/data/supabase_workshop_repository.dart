import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/services/user_activity_service.dart';
import '../domain/workshop_model.dart';

/// Exception thrown when a workshop is not found
class WorkshopNotFoundException implements Exception {
  final String message;
  WorkshopNotFoundException(this.message);

  @override
  String toString() => 'WorkshopNotFoundException: $message';
}

/// Repository exception for workshop operations
class WorkshopRepositoryException implements Exception {
  final String message;
  WorkshopRepositoryException(this.message);

  @override
  String toString() => 'WorkshopRepositoryException: $message';
}

/// Repository interface for workshops
abstract class IWorkshopRepository {
  Future<List<Workshop>> getAllWorkshops();
  Future<Workshop> getWorkshopById(String id);
  Future<List<Workshop>> getUpcomingWorkshops();
  Future<List<Workshop>> getCompletedWorkshops();
  Future<void> enrollWorkshop(String workshopId);
  Future<void> unenrollWorkshop(String workshopId);
  Future<List<Workshop>> getJoinedWorkshops();
}

/// Real Supabase implementation of workshop repository
class SupabaseWorkshopRepository implements IWorkshopRepository {
  final SupabaseClient _client = SupabaseService.client;

  @override
  Future<List<Workshop>> getAllWorkshops() async {
    try {
        final raw = await _client
          .from('workshops')
          .select()
          .eq('is_active', true)
          .order('date_time', ascending: true) as List<dynamic>;

        final workshops = raw.cast<Map<String, dynamic>>();
        return Future.wait(workshops.map(_mapToWorkshop));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching workshops: $e');
      }
      throw WorkshopRepositoryException('Failed to fetch workshops: $e');
    }
  }

  @override
  Future<Workshop> getWorkshopById(String id) async {
    try {
          final workshopResponse = await _client
            .from('workshops')
            .select()
            .eq('id', id)
            .eq('is_active', true)
            .single();

          return _mapToWorkshop(workshopResponse);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching workshop $id: $e');
      }
      throw WorkshopNotFoundException('Workshop with id "$id" not found');
    }
  }

  @override
  Future<List<Workshop>> getUpcomingWorkshops() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      // Fetch upcoming workshops
        final raw = await _client
          .from('workshops')
          .select()
          .eq('is_active', true)
          .gte('date_time', now)
          .order('date_time', ascending: true) as List<dynamic>;

        final workshops = raw.cast<Map<String, dynamic>>();
        return Future.wait(workshops.map(_mapToWorkshop));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching upcoming workshops: $e');
      }
      return [];
    }
  }

  @override
  Future<List<Workshop>> getCompletedWorkshops() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      // Fetch past workshops
        final raw = await _client
          .from('workshops')
          .select()
          .eq('is_active', true)
          .lt('date_time', now)
          .order('date_time', ascending: false) as List<dynamic>;

        final workshops = raw.cast<Map<String, dynamic>>();
        return Future.wait(workshops.map(_mapToWorkshop));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching completed workshops: $e');
      }
      return [];
    }
  }

  @override
  Future<void> enrollWorkshop(String workshopId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw WorkshopRepositoryException('User not authenticated');
      }

      // Log enrollment via activity service (which handles the insert)
      await UserActivityService.logWorkshopEnrollment(
        userId: userId,
        workshopId: workshopId,
      );

      if (kDebugMode) {
        print('✅ Enrolled in workshop: $workshopId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error enrolling in workshop: $e');
      }
      throw WorkshopRepositoryException('Failed to enroll: $e');
    }
  }

  @override
  Future<void> unenrollWorkshop(String workshopId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw WorkshopRepositoryException('User not authenticated');
      }

      await _client
          .from('workshop_enrollments')
          .delete()
          .eq('user_id', userId)
          .eq('workshop_id', workshopId);

      if (kDebugMode) {
        print('✅ Unenrolled from workshop: $workshopId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unenrolling from workshop: $e');
      }
      throw WorkshopRepositoryException('Failed to unenroll: $e');
    }
  }

  @override
  Future<List<Workshop>> getJoinedWorkshops() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final enrollments = await _client
          .from('workshop_enrollments')
          .select('workshop_id')
          .eq('user_id', userId);
      
      final workshopIds = (enrollments as List).map((e) => e['workshop_id'] as String).toList();
      
      if (workshopIds.isEmpty) return [];

      final raw = await _client
          .from('workshops')
          .select()
          .filter('id', 'in', workshopIds)
          .eq('is_active', true)
          .order('date_time', ascending: true) as List<dynamic>;

      final workshops = raw.cast<Map<String, dynamic>>();
      return Future.wait(workshops.map(_mapToWorkshop));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching joined workshops: $e');
      }
      return [];
    }
  }

  /// Map raw Supabase row into the UI-friendly Workshop model
  Future<Workshop> _mapToWorkshop(Map<String, dynamic> data) async {
    final startTime = DateTime.parse(data['date_time'] as String);
    final tags = (data['tags'] as List?)?.cast<String>() ?? const <String>[];
    final status = _statusFromStartTime(startTime);
    final id = data['id'] as String;

    // Check enrollment
    bool isEnrolled = false;
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      final enrollment = await _client
          .from('workshop_enrollments')
          .select()
          .eq('user_id', userId)
          .eq('workshop_id', id)
          .maybeSingle();
      isEnrolled = enrollment != null;
    }

    return Workshop(
      id: id,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      category: tags.isNotEmpty ? tags.first : 'Workshop',
      startTime: startTime,
      duration: data['duration_minutes'] as int? ?? 60,
      ageGroup: 'All Ages',
      status: status,
      outcomes: const <String>[],
      mentor: (data['instructor_name'] as String?) != null
          ? WorkshopMentor(
              name: data['instructor_name'] as String,
              role: 'Instructor',
              avatarUrl: data['cover_image_url'] as String?,
            )
          : null,
      isJoinEnabled:
          (data['is_active'] as bool? ?? true) && status != WorkshopStatus.completed,
      participantCount: 0,
      isEnrolled: isEnrolled,
    );
  }
}

WorkshopStatus _statusFromStartTime(DateTime startTime) {
  final now = DateTime.now();
  if (startTime.isBefore(now)) {
    return WorkshopStatus.completed;
  }

  final hoursUntilStart = startTime.difference(now).inHours;
  if (hoursUntilStart <= 24) {
    return WorkshopStatus.startingSoon;
  }

  return WorkshopStatus.upcoming;
}
