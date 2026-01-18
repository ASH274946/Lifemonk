import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/firebase_providers.dart';

/// Example widget showing how to load and display images from Firebase Storage
class FirebaseImageExample extends ConsumerWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const FirebaseImageExample({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the imageUrlProvider to get the download URL
    final imageUrlAsync = ref.watch(imageUrlProvider(imagePath));

    return imageUrlAsync.when(
      loading: () => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
      data: (url) => Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }
}

/// Example widget showing how to list all images from a folder
class FirebaseImageGallery extends ConsumerWidget {
  final String folderPath;

  const FirebaseImageGallery({
    super.key,
    this.folderPath = 'images',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrlsAsync = ref.watch(allImageUrlsProvider);

    return imageUrlsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error loading images: $error'),
          ],
        ),
      ),
      data: (imageUrls) {
        if (imageUrls.isEmpty) {
          return const Center(
            child: Text('No images found'),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          padding: const EdgeInsets.all(16),
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            final entry = imageUrls.entries.elementAt(index);
            final filename = entry.key.split('/').last;
            final url = entry.value;

            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      filename,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Example widget showing video thumbnail with play button
class FirebaseVideoThumbnail extends ConsumerWidget {
  final String videoPath;
  final VoidCallback? onTap;

  const FirebaseVideoThumbnail({
    super.key,
    required this.videoPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoUrlAsync = ref.watch(videoUrlProvider(videoPath));

    return videoUrlAsync.when(
      loading: () => Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 200,
        color: Colors.grey[200],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 8),
            Text('Failed to load video'),
          ],
        ),
      ),
      data: (url) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // You can add a video thumbnail image here if available
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // Play button overlay
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              // Video URL info at bottom
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  videoPath.split('/').last,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example screen demonstrating Firebase Storage usage
class FirebaseStorageExampleScreen extends ConsumerWidget {
  const FirebaseStorageExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Single Image
            const Text(
              'Single Image Example',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const FirebaseImageExample(
              imagePath: 'banner.jpg', // filename in Firebase Storage
              height: 200,
              width: double.infinity,
            ),
            
            const SizedBox(height: 32),
            
            // Example 2: Video Thumbnail
            const Text(
              'Video Example',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FirebaseVideoThumbnail(
              videoPath: 'intro.mp4', // filename in Firebase Storage
              onTap: () {
                // Handle video play
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video player would open here')),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Example 3: Image Gallery
            const Text(
              'Image Gallery Example',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const SizedBox(
              height: 400,
              child: FirebaseImageGallery(),
            ),
          ],
        ),
      ),
    );
  }
}
