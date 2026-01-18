import '../domain/workshop_model.dart';

/// Exception thrown when a workshop is not found
class WorkshopNotFoundException implements Exception {
  final String message;
  WorkshopNotFoundException(this.message);

  @override
  String toString() => 'WorkshopNotFoundException: $message';
}

/// Repository interface for workshops
/// This abstraction allows switching between mock and real API implementations
abstract class IWorkshopRepository {
  /// Get all workshops from CMS
  /// FUTURE: Replace mock implementation with API call
  /// Expected CMS endpoint: GET /api/workshops
  Future<List<Workshop>> getAllWorkshops();

  /// Get a single workshop by ID from CMS
  /// FUTURE: Replace mock implementation with API call
  /// Expected CMS endpoint: GET /api/workshops/{id}
  Future<Workshop> getWorkshopById(String id);

  /// Get upcoming workshops only
  /// FUTURE: Replace mock implementation with API query parameter
  /// Expected CMS endpoint: GET /api/workshops?status=upcoming,starting_soon
  Future<List<Workshop>> getUpcomingWorkshops();

  /// Get completed workshops
  /// FUTURE: CMS endpoint: GET /api/workshops?status=completed
  Future<List<Workshop>> getCompletedWorkshops();

  /// Enroll user in a workshop
  /// FUTURE: POST /api/workshops/{id}/enroll
  Future<void> enrollWorkshop(String workshopId);

  /// Unenroll user from a workshop
  /// FUTURE: POST /api/workshops/{id}/unenroll
  Future<void> unenrollWorkshop(String workshopId);
}

/// Mock implementation of workshop repository
/// This provides the same interface as the real API
/// When CMS APIs are ready, create an [ApiWorkshopRepository] and swap this out
class MockWorkshopRepository implements IWorkshopRepository {
  @override
  Future<List<Workshop>> getAllWorkshops() async {
    // Simulate network latency for realistic testing
    await Future.delayed(const Duration(milliseconds: 300));
    return MockWorkshops.workshops;
  }

  @override
  Future<Workshop> getWorkshopById(String id) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 200));

    final workshop = MockWorkshops.getById(id);
    if (workshop == null) {
      throw WorkshopNotFoundException('Workshop with id "$id" not found');
    }
    return workshop;
  }

  @override
  Future<List<Workshop>> getUpcomingWorkshops() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));

    return MockWorkshops.workshops
        .where((w) => w.status != WorkshopStatus.completed)
        .toList();
  }

  @override
  Future<List<Workshop>> getCompletedWorkshops() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));

    return MockWorkshops.workshops
        .where((w) => w.status == WorkshopStatus.completed)
        .toList();
  }

  @override
  Future<void> enrollWorkshop(String workshopId) async {
    // Simulate network latency and enrollment processing
    await Future.delayed(const Duration(milliseconds: 500));

    // Validate workshop exists
    final workshop = MockWorkshops.getById(workshopId);
    if (workshop == null) {
      throw WorkshopNotFoundException(
        'Cannot enroll: Workshop "$workshopId" not found',
      );
    }

    // In a real implementation, this would:
    // 1. Send enrollment request to CMS
    // 2. Update user's local enrollment state
    // 3. Trigger any necessary notifications
    // For now, we just simulate the delay
  }

  @override
  Future<void> unenrollWorkshop(String workshopId) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 500));

    // Validate workshop exists
    final workshop = MockWorkshops.getById(workshopId);
    if (workshop == null) {
      throw WorkshopNotFoundException(
        'Cannot unenroll: Workshop "$workshopId" not found',
      );
    }

    // In a real implementation, this would update server state
  }
}

/// FUTURE: Real API implementation
/// Uncomment and implement when CMS APIs are available
/*
class ApiWorkshopRepository implements IWorkshopRepository {
  final HttpClient _httpClient;
  final String _baseUrl;

  ApiWorkshopRepository({
    required HttpClient httpClient,
    required String baseUrl,
  })  : _httpClient = httpClient,
        _baseUrl = baseUrl;

  @override
  Future<List<Workshop>> getAllWorkshops() async {
    try {
      final response = await _httpClient.get('$_baseUrl/workshops');
      // Parse JSON response and map to Workshop objects
      // Handle pagination if needed
      throw UnimplementedError('Implement API parsing');
    } catch (e) {
      throw WorkshopRepositoryException('Failed to fetch workshops: $e');
    }
  }

  // ... implement other methods
}
*/
