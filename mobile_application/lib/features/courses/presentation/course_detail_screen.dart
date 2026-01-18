import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/cms/models.dart';
import 'chapter_detail_screen.dart';
import 'providers/course_providers.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseProvider(widget.courseId));
    final resumeChapterAsync = ref.watch(resumeChapterProvider(widget.courseId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: courseAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load: $e')),
          data: (course) => NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // 1. Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRoundButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          _buildRoundButton(
                            icon: Icons.more_horiz_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // 2. Title & Progress
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: course.progress,
                          backgroundColor: const Color(0xFFF3F4F6),
                          color: const Color(0xFF3B82F6),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(course.progress * 100).toInt()}% COMPLETED',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // 3. Featured / Resume Chapter
                      resumeChapterAsync.when(
                        data: (chapter) => _buildFeaturedChapter(context, course, chapter),
                        loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              // 4. Tab Bar (Pinned)
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF111827),
                    unselectedLabelColor: const Color(0xFF9CA3AF),
                    indicatorColor: const Color(0xFF3B82F6),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Chapters'),
                      Tab(text: 'Bytes'),
                      Tab(text: 'Quiz'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildChaptersList(course),
                _buildBytesList(course),
                _buildQuizTab(course),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChaptersList(CmsCourse course) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: course.chapters.length,
      itemBuilder: (context, index) {
        final chapter = course.chapters[index];
        final isLocked = !chapter.unlocked && !chapter.watched; // Basic lock logic
        final isCompleted = chapter.watched;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: isLocked 
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Complete previous chapters to unlock!')),
                    );
                  } 
                : () {
                    Navigator.push(
                       context, 
                       MaterialPageRoute(builder: (_) => ChapterDetailScreen(chapter: chapter, courseId: widget.courseId, courseTitle: course.title))
                    );
                  },
            child: Opacity(
              opacity: isLocked ? 0.5 : 1.0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          isCompleted ? Icons.check_rounded : (isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded),
                          color: isCompleted ? const Color(0xFF166534) : const Color(0xFF6B7280),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chapter ${index + 1}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chapter.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                          ),
                        ],
                      ),
                    ),
                    if (chapter.duration > 0)
                      Text(
                        '${chapter.duration}m',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBytesList(CmsCourse course) {
    if (course.bytes.isEmpty) {
      return const Center(child: Text('No bytes available'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: course.bytes.length,
      itemBuilder: (context, index) {
        final byte = course.bytes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
             children: [
               Container(
                 width: 80,
                 height: 56,
                 decoration: BoxDecoration(
                   color: Colors.black12,
                   borderRadius: BorderRadius.circular(8),
                   image: byte.thumbnailUrl.isNotEmpty 
                     ? DecorationImage(image: NetworkImage(byte.thumbnailUrl), fit: BoxFit.cover)
                     : null, 
                 ),
                 child: byte.thumbnailUrl.isEmpty 
                    ? const Icon(Icons.play_circle_outline, color: Colors.black38) 
                    : null,
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(byte.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                     Text(byte.duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                   ],
                 ),
               )
             ],
          ),
        );
      },
    );
  }

  Widget _buildQuizTab(CmsCourse course) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('Quiz unlocks after course completion!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFeaturedChapter(BuildContext context, CmsCourse course, CmsChapter chapter) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTINUE LEARNING', // "Next Up" context
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B82F6),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => ChapterDetailScreen(chapter: chapter, courseId: widget.courseId, courseTitle: course.title)),
               );
            },
            child: Container(
              height: 200, // Increased height
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                // Use a subtle image/gradient or video thumbnail if available
                gradient: const LinearGradient(
                  colors: [Color(0xFFC2A578), Color(0xFF5D4037)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        // Add opacity pattern or image if desired
                        child: Container(color: Colors.black12),
                    ),
                  ),
                  Container(
                    width: 64, // Larger play button
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                           color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                           blurRadius: 16,
                           offset: const Offset(0, 8),
                         ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            chapter.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            chapter.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
