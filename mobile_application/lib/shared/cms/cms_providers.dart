import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cms_repository.dart';
import 'models.dart';

/// Repository provider - Temporarily using Mock for rich data
final cmsRepositoryProvider = Provider<CmsRepository>((ref) {
  return MockCmsRepository();
});

final categoriesProvider = FutureProvider<List<CmsCategory>>((ref) async {
  final repo = ref.watch(cmsRepositoryProvider);
  final list = await repo.getCategories();
  // Only visible items, ordered by 'order'
  list.sort((a, b) => a.order.compareTo(b.order));
  return list.where((e) => e.visible).toList(growable: false);
});

/// Controller to handle mock enrollment actions
class EnrollmentController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  EnrollmentController(this.ref) : super(const AsyncValue.data(null));

  Future<void> toggleEnrollment(String workshopId) async {
    state = const AsyncValue.loading();
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Update the mock repository state directly (since we are using Mock)
    // This is a dev-only hack to make the mock feel real
    MockCmsRepository.toggleEnrollment(workshopId);

    // Refresh the providers
    ref.invalidate(workshopsProvider);
    ref.invalidate(filteredWorkshopsProvider);
    
    state = const AsyncValue.data(null);
  }
}

final planProvider = FutureProvider<List<CmsPlanSubject>>((ref) async {
  final repo = ref.watch(cmsRepositoryProvider);
  return repo.getPlan();
});

final workshopsProvider = FutureProvider<List<CmsWorkshop>>((ref) async {
  final repo = ref.watch(cmsRepositoryProvider);
  return repo.getWorkshops();
});

/// Selected category state filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Filtered workshops based on selection
final filteredWorkshopsProvider = FutureProvider<List<CmsWorkshop>>((ref) async {
  final allWorkshops = await ref.watch(workshopsProvider.future);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == null) {
    return allWorkshops;
  }
  
  return allWorkshops.where((w) => w.category == selectedCategory).toList();
});

final bytesFeedProvider = FutureProvider<List<CmsByte>>((ref) async {
  final repo = ref.watch(cmsRepositoryProvider);
  return repo.getBytesFeed();
});

final courseProvider = FutureProvider.family<CmsCourse, String>((ref, id) async {
  final repo = ref.watch(cmsRepositoryProvider);
  return repo.getCourseById(id);
});



final enrollmentControllerProvider = StateNotifierProvider<EnrollmentController, AsyncValue<void>>((ref) {
  return EnrollmentController(ref);
});
