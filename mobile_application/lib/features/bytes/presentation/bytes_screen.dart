import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'providers/byte_provider.dart';
import '../domain/byte_content.dart';

class ByteScreen extends ConsumerStatefulWidget {
  const ByteScreen({super.key});

  @override
  ConsumerState<ByteScreen> createState() => _ByteScreenState();
}

class _ByteScreenState extends ConsumerState<ByteScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isScreenVisible = true;
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Arts & Crafts',
    'English',
    'Science',
    'Math',
    'History',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isScreenVisible = state == AppLifecycleState.resumed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final byteContentAsync = ref.watch(byteContentProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          byteContentAsync.when(
            data: (contents) {
              if (contents.isEmpty) {
                return const Center(child: Text('No content available', style: TextStyle(color: Colors.white)));
              }
              
              // Filter contents by category
              final filteredContents = _selectedCategory == 'All'
                  ? contents
                  : contents.where((item) => item.category == _selectedCategory).toList();
              
              if (filteredContents.isEmpty) {
                return const Center(
                  child: Text(
                    'No content in this category',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              
              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: filteredContents.length,
                onPageChanged: (index) {
                   setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final item = filteredContents[index];
                  return _ByteReelItem(
                    item: item, 
                    shouldPlay: index == _currentIndex && _isScreenVisible,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
          ),
          
          // Header with title and category filter
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Header row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Byte Learning',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Category chips - minimalistic design
                    Container(
                      height: 36,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                  _currentIndex = 0;
                                });
                                _pageController.jumpToPage(0);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(isSelected ? 1.0 : 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ByteReelItem extends ConsumerStatefulWidget {
  final ByteContent item;
  final bool shouldPlay; // New parameter

  const _ByteReelItem({required this.item, required this.shouldPlay});

  @override
  ConsumerState<_ByteReelItem> createState() => _ByteReelItemState();
}

class _ByteReelItemState extends ConsumerState<_ByteReelItem> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  // ... existing state ...
  bool _isLiked = false;
  int _likeCount = 124;

  @override
  void initState() {
    super.initState();
    _likeCount = 100 + widget.item.id.hashCode % 500;
    // Only initialize video if it should play initially
    if (widget.item.type == 'video' && widget.shouldPlay) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(_ByteReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle shouldPlay changes
    if (widget.shouldPlay != oldWidget.shouldPlay) {
      if (widget.shouldPlay) {
        // Need to play - initialize if not already done
        if (_videoController == null && widget.item.type == 'video') {
          _initializeVideo();
        } else if (_videoController != null && _isVideoInitialized) {
          _videoController!.play();
        }
      } else {
        // Need to pause
        if (_videoController != null && _isVideoInitialized) {
          _videoController!.pause();
          _videoController!.seekTo(Duration.zero);
        }
      }
    }
  }

  // ... Update _initializeVideo to respect initial shouldPlay ...
  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.item.url));
    try {
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      
      if (widget.shouldPlay) {
         await _videoController!.play();
      }
      
      if (mounted) setState(() => _isVideoInitialized = true);
    } catch (e) { /* handle error */ }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _onLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _onComment() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Text('No comments yet. Be the first to share your thoughts!'),
            const Spacer(),
            TextField(
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => Navigator.pop(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${widget.item.name}"...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Remove existing ref.listen in build() as we rely on widget.shouldPlay
  @override
  Widget build(BuildContext context) {
      // ... content implementation ...
      // use _videoController as normal
      // ...
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Media
        widget.item.type == 'image'
            ? Image.network(
                widget.item.url,
                fit: BoxFit.cover,
                // ... loading/error builders
                 loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54),
              )
            : _isVideoInitialized && _videoController != null
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                         if (_videoController!.value.isPlaying) {
                           _videoController!.pause();
                         } else {
                           _videoController!.play();
                         }
                      });
                    },
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController!.value.size.width,
                          height: _videoController!.value.size.height,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.black87,
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),

        // Bottom Gradient Overlay for readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
          ),
        ),


        // Right side actions (Like, Save, Add to Learning, Share - Reels style)
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              _ReelAction(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: '$_likeCount',
                color: _isLiked ? Colors.red : Colors.white,
                onTap: _onLike,
              ),
              const SizedBox(height: 24),
              _ReelAction(
                icon: Icons.bookmark_border_rounded,
                label: 'Save',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saved to your collection'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _ReelAction(
                icon: Icons.add_circle_outline_rounded,
                label: 'Add to\nLearning',
                fontSize: 10,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to Learning Path'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _ReelAction(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: _onShare,
              ),
            ],
          ),
        ),

        // Content description (Bottom left)
        Positioned(
          left: 16,
          bottom: 30,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Creator info with Follow button
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.school_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Lifemonk Learning',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  // Follow Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Audio attribution
              Row(
                children: [
                  const Icon(Icons.music_note_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Original audio • Lifemonk Creator',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        shadows: const [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReelAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double fontSize;

  const _ReelAction({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                shadows: const [Shadow(blurRadius: 10, color: Colors.black)],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
