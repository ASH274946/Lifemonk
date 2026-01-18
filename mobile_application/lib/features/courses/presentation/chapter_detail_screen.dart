import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/cms/models.dart';
import 'providers/course_providers.dart';

class ChapterDetailScreen extends ConsumerStatefulWidget {
  final CmsChapter chapter;
  final String courseId;
  final String? courseTitle;

  const ChapterDetailScreen({
    super.key,
    required this.chapter,
    required this.courseId,
    this.courseTitle,
  });

  @override
  ConsumerState<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends ConsumerState<ChapterDetailScreen> {
  int _selectedTabIndex = 0;
  bool _isPlaying = false; // Mock video player state

  @override
  Widget build(BuildContext context) {
    // Watch course to get context for Next/Prev and up-to-date completion status
    final courseAsync = ref.watch(courseProvider(widget.courseId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: courseAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (course) {
            // Find current chapter index and verified object from the list to ensure we have latest state
            final currentIndex = course.chapters.indexWhere((c) => c.id == widget.chapter.id);
            final currentChapter = currentIndex != -1 ? course.chapters[currentIndex] : widget.chapter;
            
            final hasPrevious = currentIndex > 0;
            final hasNext = currentIndex < course.chapters.length - 1;

            return Column(
              children: [
                // 1. Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      _buildRoundButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.courseTitle ?? course.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9CA3AF),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildRoundButton(
                        icon: Icons.more_horiz_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        
                        // 2. Title
                        Text(
                          currentChapter.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 3. Progress Bar ("1 of 4")
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (currentIndex + 1) / course.chapters.length,
                                  backgroundColor: const Color(0xFFF3F4F6),
                                  color: const Color(0xFF3B82F6),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${currentIndex + 1} of ${course.chapters.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 4. Video Player
                        _buildVideoPlayerCard(currentChapter),

                        const SizedBox(height: 16),
                        
                        // 5. Metadata & Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${currentChapter.duration} min • ${currentChapter.watched ? "Completed" : "In Progress"}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                            
                            // Mark as Complete Button (if not watched)
                            if (!currentChapter.watched)
                              TextButton.icon(
                                onPressed: () {
                                  _handleMarkAsComplete(currentChapter);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  foregroundColor: const Color(0xFF3B82F6),
                                ),
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                label: const Text('Mark Complete'),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        // 6. Tabs
                        _buildTabNavigation(),

                        const SizedBox(height: 24),

                        // 7. Tab Content
                        _buildTabContent(currentChapter),
                        
                       const SizedBox(height: 32),
                        
                       // 8. Navigation Footer
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           // Previous
                           if (hasPrevious)
                             OutlinedButton.icon(
                               onPressed: () {
                                 Navigator.pushReplacement(
                                   context,
                                   MaterialPageRoute(builder: (_) => ChapterDetailScreen(
                                     chapter: course.chapters[currentIndex - 1],
                                     courseId: widget.courseId,
                                     courseTitle: widget.courseTitle,
                                    ))
                                 );
                               },
                               icon: const Icon(Icons.arrow_back_rounded, size: 16),
                               label: const Text('Previous'),
                               style: OutlinedButton.styleFrom(
                                 foregroundColor: const Color(0xFF6B7280),
                                 side: const BorderSide(color: Color(0xFFE5E7EB)),
                               ),
                             )
                           else
                             const SizedBox(width: 16),

                           // Next
                           if (hasNext)
                             ElevatedButton.icon(
                               onPressed: currentChapter.watched 
                                ? () {
                                   Navigator.pushReplacement(
                                     context,
                                     MaterialPageRoute(builder: (_) => ChapterDetailScreen(
                                       chapter: course.chapters[currentIndex + 1],
                                       courseId: widget.courseId,
                                       courseTitle: widget.courseTitle,
                                      ))
                                   );
                                  }
                                : null, // Disable until current is watched/completed
                               icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                               label: const Text('Next Chapter'),
                               style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF111827),
                                  foregroundColor: Colors.white,
                               ),
                             )
                         ],
                       ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleMarkAsComplete(CmsChapter chapter) async {
    await ref.read(courseControllerProvider.notifier).markChapterComplete(widget.courseId, chapter.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.star_rounded, color: Colors.yellowAccent),
              SizedBox(width: 12),
              Text('Chapter Completed! +150 XP'),
            ],
          ),
          backgroundColor: const Color(0xFF111827),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildVideoPlayerCard(CmsChapter chapter) {
    return GestureDetector(
      onTap: () => setState(() => _isPlaying = !_isPlaying),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!_isPlaying) ...[
               // Gradient Overlay
              Container(
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(20),
                   gradient: LinearGradient(
                     colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.5)],
                     begin: Alignment.topCenter,
                     end: Alignment.bottomCenter,
                   ),
                 ),
              ),
              // Play Button
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
              ),
              Positioned(
                 bottom: 12,
                 right: 12,
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: Colors.black.withValues(alpha: 0.7),
                     borderRadius: BorderRadius.circular(6),
                   ),
                   child: Text('${chapter.duration} MIN', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                 ),
               ),
            ] else 
              // Mock Video Playing State
              const Center(
                child: Text(
                  'Video Playing...',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    final tabs = ['Overview', 'Bytes', 'Quiz'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent, // Light blue if selected
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(CmsChapter chapter) {
    if (_selectedTabIndex == 1) { // Bytes
        if (chapter.relatedBytes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No related bytes for this chapter.', style: TextStyle(color: Colors.grey)),
          );
        }
        return Column(
          children: chapter.relatedBytes.map((byte) => ListTile(
            leading: Container(width: 50, height: 30, color: Colors.grey[200]),
            title: Text(byte.title),
            subtitle: Text(byte.duration),
            trailing: const Icon(Icons.play_circle_outline),
          )).toList(),
        );
    }
    
    // Default Overview
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chapter.outcomes.isNotEmpty) ...[
          const Text(
            'Learning Outcomes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...chapter.outcomes.map((outcome) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF3B82F6)),
                const SizedBox(width: 8),
                Text(outcome, style: const TextStyle(color: Color(0xFF4B5563))),
              ],
            ),
          )),
          const SizedBox(height: 24),
        ],

        const Text(
          'Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          chapter.summary,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildRoundButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF111827), size: 20),
      ),
    );
  }
}
