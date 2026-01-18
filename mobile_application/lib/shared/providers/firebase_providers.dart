import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_storage_service.dart';

/// Provider for Firebase Storage Service
final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

/// Provider to get a specific video URL
final videoUrlProvider = FutureProvider.family<String, String>((ref, filename) async {
  return FirebaseStorageService.getVideoUrl(filename);
});

/// Provider to get a specific image URL
final imageUrlProvider = FutureProvider.family<String, String>((ref, filename) async {
  return FirebaseStorageService.getImageUrl(filename);
});

/// Provider to get all video URLs
final allVideoUrlsProvider = FutureProvider<Map<String, String>>((ref) async {
  return FirebaseStorageService.getAllVideoUrls();
});

/// Provider to get all image URLs
final allImageUrlsProvider = FutureProvider<Map<String, String>>((ref) async {
  return FirebaseStorageService.getAllImageUrls();
});

/// Provider to check if a file exists
final fileExistsProvider = FutureProvider.family<bool, String>((ref, path) async {
  return FirebaseStorageService.fileExists(path);
});

/// Provider to list files in a folder
final listFilesProvider = FutureProvider.family<List<String>, String>((ref, folderPath) async {
  return FirebaseStorageService.listFiles(folderPath);
});
