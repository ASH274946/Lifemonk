import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/supabase_workshop_repository.dart';
import '../../domain/workshop_model.dart';
import '../../../../shared/cms/cms_providers.dart';
import '../../../../shared/cms/models.dart';

// NEW PROVIDERS FOR CATEGORY FILTERING
// ======================================

/// Tracks which category user selected (null = show all)
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Returns ALL workshops or filtered by selected category
final filteredWorkshopsProvider = FutureProvider<List<CmsWorkshop>>((ref) async {
  final allWorkshops = await ref.watch(workshopsProvider.future);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == null) {
    return allWorkshops;
  }

  return allWorkshops
    .where((w) => w.category.toLowerCase() == selectedCategory.toLowerCase())
    .toList();
});

/// Get list of unique categories
final categoriesListProvider = FutureProvider<List<String>>((ref) async {
  final allWorkshops = await ref.watch(workshopsProvider.future);
  final uniqueCategories = allWorkshops
    .map((w) => w.category)
    .toSet()
    .toList()
    ..sort();
  return uniqueCategories;
});

// EXISTING PROVIDERS (keep as is)
// ==============================

/// Provides the real Supabase workshop repository instance
final workshopRepositoryProvider = Provider<IWorkshopRepository>((ref) {
  return SupabaseWorkshopRepository();
});

/// Fetches all workshops from the repository
/// Handles loading, error, and data states automatically
final allWorkshopsProvider = FutureProvider<List<Workshop>>((ref) async {
  final repository = ref.watch(workshopRepositoryProvider);
  return repository.getAllWorkshops();
});

/// Fetches upcoming workshops (excluding completed)
final upcomingWorkshopsProvider = FutureProvider<List<Workshop>>((ref) async {
  final repository = ref.watch(workshopRepositoryProvider);
  return repository.getUpcomingWorkshops();
});

/// Fetches completed workshops only
final completedWorkshopsProvider = FutureProvider<List<Workshop>>((ref) async {
  final repository = ref.watch(workshopRepositoryProvider);
  return repository.getCompletedWorkshops();
});

/// Fetches workshops the user has joined
final joinedWorkshopsProvider = FutureProvider<List<Workshop>>((ref) async {
  final repository = ref.watch(workshopRepositoryProvider);
  return repository.getJoinedWorkshops();
});

/// Fetches a single workshop by ID
/// Used when navigating to detail screen
/// Parameter: Workshop ID from CMS
final workshopDetailProvider = FutureProvider.family<Workshop, String>((
  ref,
  workshopId,
) async {
  final repository = ref.watch(workshopRepositoryProvider);
  return repository.getWorkshopById(workshopId);
});

/// State notifier for managing enrollment/unenrollment
class EnrollmentNotifier extends StateNotifier<AsyncValue<void>> {
  final IWorkshopRepository _repository;

  EnrollmentNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Enroll user in a workshop
  Future<void> enroll(String workshopId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.enrollWorkshop(workshopId),
    );
  }

  /// Unenroll user from a workshop
  Future<void> unenroll(String workshopId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.unenrollWorkshop(workshopId),
    );
  }
}

/// Provider for managing user enrollment state
final enrollmentProvider =
    StateNotifierProvider<EnrollmentNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(workshopRepositoryProvider);
      return EnrollmentNotifier(repository);
    });
