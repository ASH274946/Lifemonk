import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/cms/cms_providers.dart';
import '../../../../shared/cms/models.dart';

// --- Data Providers ---

/// Fetches a specific course by ID.
/// Invalidating this provider triggers a refresh of the UI (e.g. after marking complete).
final courseProvider = FutureProvider.family<CmsCourse, String>((ref, id) async {
  final repo = ref.watch(cmsRepositoryProvider);
  return repo.getCourseById(id);
});

/// Fetches the user's total XP.
final userXpProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(cmsRepositoryProvider);
  return repo.getUserXp();
});

/// Determines the chapter to resume for a given course.
final resumeChapterProvider = FutureProvider.autoDispose.family<CmsChapter, String>((ref, courseId) async {
  final repo = ref.watch(cmsRepositoryProvider);
  
  // 1. Try to get explicitly saved last viewed
  final lastId = await repo.getLastViewedChapter(courseId);
  final course = await repo.getCourseById(courseId);
  
  if (lastId != null) {
    try {
      return course.chapters.firstWhere((c) => c.id == lastId);
    } catch (_) {
      // logic fallthrough if ID not found
    }
  }

  // 2. Fallback: Find first unwatched chapter
  try {
    return course.chapters.firstWhere((c) => !c.watched);
  } catch (_) {
    // 3. If all watched, or none, return the first chapter (or last)
    if (course.chapters.isNotEmpty) {
      if (course.chapters.every((c) => c.watched)) {
        return course.chapters.last;
      }
      return course.chapters.first;
    }
  }
  
  throw Exception('No chapters found in course');
});

// --- Action Controller ---

/// Manages actions like marking chapters complete, watching bytes, etc.
class CourseController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CourseController(this.ref) : super(const AsyncData(null));

  Future<void> markChapterComplete(String courseId, String chapterId) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(cmsRepositoryProvider);
      await repo.markChapterComplete(courseId, chapterId);
      
      // Refresh data
      ref.invalidate(courseProvider(courseId));
      ref.invalidate(userXpProvider);
      ref.invalidate(resumeChapterProvider(courseId));
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> markByteWatched(String courseId, String byteId) async {
    // Silent update (don't necessarily show loading state for small actions like this if preferred,
    // but here we keep it simple)
    try {
      final repo = ref.read(cmsRepositoryProvider);
      await repo.markByteWatched(byteId);
      
      ref.invalidate(courseProvider(courseId));
    } catch (e) {
      // Log error but maybe don't block UI
      print('Error marking byte watched: $e');
    }
  }
  
  Future<void> updateLastViewed(String courseId, String chapterId) async {
    try {
      final repo = ref.read(cmsRepositoryProvider);
      await repo.saveLastViewedChapter(courseId, chapterId);
    } catch (e) {
      print('Error saving last viewed: $e');
    }
  }
}

final courseControllerProvider = StateNotifierProvider<CourseController, AsyncValue<void>>((ref) {
  return CourseController(ref);
});
