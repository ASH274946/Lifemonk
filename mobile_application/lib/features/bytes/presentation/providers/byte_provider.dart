import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/byte_content.dart';
import '../../../../shared/services/cloudinary_service.dart';

/// Repository for byte content from Cloudinary
class ByteRepository {
  /// Fetch all educational bytes from Cloudinary
  /// Retrieves videos and images from the configured folder
  Future<List<ByteContent>> getAllBytes() async {
    try {
      if (kDebugMode) {
        print('📂 Fetching bytes from Cloudinary...');
      }

      // List all resources in the folder
      final resources = await CloudinaryService.listResources();
      
      if (resources.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No resources found in Cloudinary folder');
        }
        return _getFallbackBytes();
      }

      final List<ByteContent> bytes = [];
      
      for (final resource in resources) {
        try {
          final String publicId = resource['public_id'];
          final String secureUrl = resource['secure_url'];
          final String resourceType = resource['resource_type']; // 'image' or 'video'
          final String format = resource['format'] ?? '';
          final String createdAtStr = resource['created_at'];
          
          // Use filename or metadata for name
          final fileName = publicId.split('/').last;
          final nameWithoutExt = fileName;
          
          final isVideo = resourceType == 'video';
          final isImage = resourceType == 'image';
          
          if (!isVideo && !isImage) {
            continue; // Skip unsupported resource types
          }
          
          bytes.add(ByteContent(
            id: publicId,
            url: secureUrl,
            type: isVideo ? 'video' : 'image',
            name: _formatTitle(nameWithoutExt),
            description: resource['context']?['custom']?['description'] ?? 'Educational content',
            createdAt: DateTime.tryParse(createdAtStr) ?? DateTime.now(),
          ));
          
          if (kDebugMode) {
            print('✅ Loaded byte: ${bytes.last.name} (${bytes.last.type})');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Failed to parse Cloudinary resource: $e');
          }
          continue;
        }
      }
      
      if (kDebugMode) {
        print('✅ Successfully loaded ${bytes.length} bytes from Cloudinary');
      }
      
      return bytes.isNotEmpty ? bytes : _getFallbackBytes();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching bytes from Cloudinary: $e');
      }
      return _getFallbackBytes();
    }
  }
  
  /// Format filename to readable title
  String _formatTitle(String filename) {
    // Replace underscores and hyphens with spaces
    String title = filename.replaceAll('_', ' ').replaceAll('-', ' ');
    // Capitalize first letter of each word
    return title.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  /// Fallback bytes when Cloudinary is not available or empty
  List<ByteContent> _getFallbackBytes() {
    if (kDebugMode) {
      print('📝 Using fallback byte data with categories');
    }
    return [
      // Arts & Crafts
      ByteContent(
        id: 'byte-1',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        type: 'video',
        name: 'DIY Paper Crafts',
        description: 'Learn to make beautiful paper crafts',
        category: 'Arts & Crafts',
        createdAt: DateTime.now(),
      ),
      ByteContent(
        id: 'byte-2',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        type: 'video',
        name: 'Origami Tutorial',
        description: 'Easy origami for beginners',
        category: 'Arts & Crafts',
        createdAt: DateTime.now(),
      ),
      
      // English
      ByteContent(
        id: 'byte-3',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        type: 'video',
        name: 'English Grammar Tips',
        description: 'Master English grammar quickly',
        category: 'English',
        createdAt: DateTime.now(),
      ),
      ByteContent(
        id: 'byte-4',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        type: 'video',
        name: 'Vocabulary Builder',
        description: 'Expand your English vocabulary',
        category: 'English',
        createdAt: DateTime.now(),
      ),
      
      // Science
      ByteContent(
        id: 'byte-5',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        type: 'video',
        name: 'Science Experiments',
        description: 'Fun science experiments at home',
        category: 'Science',
        createdAt: DateTime.now(),
      ),
      ByteContent(
        id: 'byte-6',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        type: 'video',
        name: 'Physics Explained',
        description: 'Understanding basic physics',
        category: 'Science',
        createdAt: DateTime.now(),
      ),
      
      // Math
      ByteContent(
        id: 'byte-7',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
        type: 'video',
        name: 'Math Tricks',
        description: 'Quick math calculation tricks',
        category: 'Math',
        createdAt: DateTime.now(),
      ),
      ByteContent(
        id: 'byte-8',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        type: 'video',
        name: 'Algebra Basics',
        description: 'Learn algebra fundamentals',
        category: 'Math',
        createdAt: DateTime.now(),
      ),
      
      // History
      ByteContent(
        id: 'byte-9',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
        type: 'video',
        name: 'World History',
        description: 'Important historical events',
        category: 'History',
        createdAt: DateTime.now(),
      ),
      ByteContent(
        id: 'byte-10',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        type: 'video',
        name: 'Ancient Civilizations',
        description: 'Explore ancient cultures',
        category: 'History',
        createdAt: DateTime.now(),
      ),
    ];
  }
}

/// Provider for byte repository
final byteRepositoryProvider = Provider<ByteRepository>((ref) {
  return ByteRepository();
});

/// Provider for byte content
/// Fetches all educational bytes from Cloudinary
final byteContentProvider = FutureProvider<List<ByteContent>>((ref) async {
  final repository = ref.watch(byteRepositoryProvider);
  return repository.getAllBytes();
});
