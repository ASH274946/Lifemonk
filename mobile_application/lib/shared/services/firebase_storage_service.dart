import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

/// Firebase Storage Service for retrieving media files
/// Provides methods to get download URLs for videos and images
class FirebaseStorageService {
  static FirebaseStorage? _storage;

  /// Get Firebase Storage instance
  static FirebaseStorage get storage {
    if (_storage == null) {
      if (!FirebaseService.isInitialized) {
        throw Exception('Firebase not initialized. Call FirebaseService.initialize() first');
      }
      _storage = FirebaseStorage.instance;
    }
    return _storage!;
  }

  /// Get download URL for a file in Firebase Storage
  /// 
  /// Example paths:
  /// - 'videos/lesson1.mp4'
  /// - 'images/workshop-banner.jpg'
  /// - 'courses/math/intro-video.mp4'
  static Future<String> getDownloadUrl(String path) async {
    try {
      final ref = storage.ref(path);
      final url = await ref.getDownloadURL();
      
      if (kDebugMode) {
        print('✅ Got download URL for: $path');
      }
      
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting download URL for $path: $e');
      }
      rethrow;
    }
  }

  /// Get download URLs for multiple files
  static Future<Map<String, String>> getDownloadUrls(List<String> paths) async {
    final Map<String, String> urls = {};
    
    for (final path in paths) {
      try {
        urls[path] = await getDownloadUrl(path);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Failed to get URL for $path: $e');
        }
        // Continue with other files even if one fails
      }
    }
    
    return urls;
  }

  /// Get download URL for a video file
  /// Assumes videos are stored in 'videos/' folder
  static Future<String> getVideoUrl(String filename) async {
    return getDownloadUrl('videos/$filename');
  }

  /// Get download URL for an image file
  /// Assumes images are stored in 'images/' folder
  static Future<String> getImageUrl(String filename) async {
    return getDownloadUrl('images/$filename');
  }

  /// List all files in a specific folder
  static Future<List<String>> listFiles(String folderPath) async {
    try {
      final ref = storage.ref(folderPath);
      final result = await ref.listAll();
      
      final filePaths = result.items.map((item) => item.fullPath).toList();
      
      if (kDebugMode) {
        print('📂 Found ${filePaths.length} files in $folderPath');
      }
      
      return filePaths;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error listing files in $folderPath: $e');
      }
      rethrow;
    }
  }

  /// Get metadata for a file
  static Future<FullMetadata> getMetadata(String path) async {
    try {
      final ref = storage.ref(path);
      return await ref.getMetadata();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting metadata for $path: $e');
      }
      rethrow;
    }
  }

  /// Check if a file exists in storage
  static Future<bool> fileExists(String path) async {
    try {
      final ref = storage.ref(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all video URLs from the videos folder
  static Future<Map<String, String>> getAllVideoUrls() async {
    try {
      final videoPaths = await listFiles('videos');
      return await getDownloadUrls(videoPaths);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting all video URLs: $e');
      }
      return {};
    }
  }

  /// Get all image URLs from the images folder
  static Future<Map<String, String>> getAllImageUrls() async {
    try {
      final imagePaths = await listFiles('images');
      return await getDownloadUrls(imagePaths);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting all image URLs: $e');
      }
      return {};
    }
  }

  /// Get storage reference for a path
  static Reference getReference(String path) {
    return storage.ref(path);
  }

  /// Get the public URL format for Firebase Storage
  /// Note: This requires the file to have public read access
  static String getPublicUrl(String path) {
    final bucket = FirebaseService.storageBucket;
    final encodedPath = Uri.encodeComponent(path);
    return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
  }
}
