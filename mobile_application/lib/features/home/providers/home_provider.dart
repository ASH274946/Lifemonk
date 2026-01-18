import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_repository.dart';
import '../domain/models/models.dart';

/// Provider for HomeRepository
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

/// Provider for all home screen data
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getHomeData();
});

/// Provider for user profile only
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getUserProfile();
});

/// Provider for active focus session
final focusSessionProvider = FutureProvider<FocusSession?>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getActiveFocusSession();
});

/// Provider for upcoming workshop
final upcomingWorkshopProvider = FutureProvider<Workshop?>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getUpcomingWorkshop();
});

/// Provider for word of the day
final wordOfDayProvider = FutureProvider<WordOfDay?>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getWordOfDay();
});

/// Provider for learning categories
final categoriesProvider = FutureProvider<List<LearningCategory>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getCategories();
});

/// Provider for user progress stats
final userProgressProvider = FutureProvider<UserProgress>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getUserProgress();
});

/// State notifier for workshop enrollment
class WorkshopEnrollmentNotifier extends StateNotifier<AsyncValue<bool>> {
  final HomeRepository _repository;

  WorkshopEnrollmentNotifier(this._repository) : super(const AsyncValue.data(false));

  Future<bool> enroll(String workshopId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.enrollInWorkshop(workshopId);
      state = AsyncValue.data(success);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      if (kDebugMode) {
        print('❌ Enrollment error: $e');
      }
      return false;
    }
  }
}

/// Provider for workshop enrollment state
final workshopEnrollmentProvider =
    StateNotifierProvider<WorkshopEnrollmentNotifier, AsyncValue<bool>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return WorkshopEnrollmentNotifier(repository);
});
