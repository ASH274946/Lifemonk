import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_transitions.dart';
import '../../../shared/widgets/feedback_overlay.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../breathing/presentation/breathing_exercise_screen.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../courses/presentation/course_detail_screen.dart';
import '../../vocabulary/presentation/vocabulary_detail_screen.dart';
import '../../shell/presentation/providers/shell_providers.dart';
import '../providers/home_provider.dart';
import '../domain/models/models.dart';
import 'widgets/widgets.dart';
import 'word_of_day_detail_screen.dart';
import '../../auth/providers/auth_provider.dart';

/// Home Screen - Main dashboard after login
/// Shows greeting, focus session, upcoming workshop, word of day, and learning plan
/// All data is fetched in real-time from Supabase
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);
    final authState = ref.watch(authStateProvider);

    return homeDataAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (homeData) {
        // Get user name from multiple sources with priority:
        // 1. Profile name from database (includes onboarding name)
        // 2. Guest name from local storage
        // 3. Auth metadata name
        // 4. Default to first name from email or 'Student'
        String userName = homeData.userProfile?.name ?? 
            LocalStorageService.getString('guest_student_name') ??
            authState.user?.userMetadata?['name'] as String? ??
            authState.user?.email?.split('@').first ?? 
            'Student';

        return _buildHomeScrollView(
          context: context,
          ref: ref,
          userName: userName,
          userStatus: homeData.userProfile?.status ?? 'Beginner',
          userLevel: homeData.userProfile?.level ?? 1,
          focusSession: homeData.focusSession,
          workshop: homeData.upcomingWorkshop,
          wordOfDay: homeData.wordOfDay,
          categories: homeData.categories,
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSkeleton(),
            const SizedBox(height: 24),
            _buildCardSkeleton(height: 88),
            const SizedBox(height: 16),
            _buildCardSkeleton(height: 180),
            const SizedBox(height: 16),
            _buildCardSkeleton(height: 120),
            const SizedBox(height: 28),
            _buildCardSkeleton(height: 24, width: 100),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildCardSkeleton(height: 140)),
                const SizedBox(width: 12),
                Expanded(child: _buildCardSkeleton(height: 140)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildCardSkeleton({required double height, double? width}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load content',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your internet connection and database setup.',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Trigger a refresh
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScrollView({
    required BuildContext context,
    required WidgetRef ref,
    required String userName,
    required String userStatus,
    required int userLevel,
    FocusSession? focusSession,
    Workshop? workshop,
    WordOfDay? wordOfDay,
    required List<LearningCategory> categories,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            _buildHeader(context, ref, userName, userStatus, userLevel),

            const SizedBox(height: 24),

            // Focus Session Card (show if available)
            if (focusSession != null)
              FocusSessionCard(
                title: focusSession.title,
                duration: focusSession.durationText,
                onPlay: () => _onPlayFocusSession(context),
              )
            else
              _buildFocusPlaceholder(context),

            const SizedBox(height: 16),

            // Upcoming Workshop Card (show if available)
            if (workshop != null)
              UpcomingWorkshopCard(
                title: workshop.title,
                dateTime: workshop.formattedDateTime,
                participantCount: workshop.participantCount,
                isEnrolled: workshop.isEnrolled,
                onEnroll: () => _navigateToWorkshopDetail(context, ref, workshop.id),
                onTap: () => _navigateToWorkshops(context, ref),
              )
            else
              _buildWorkshopPlaceholder(context, ref),

            const SizedBox(height: 16),

            // Word of the Day Card (show if available)
            if (wordOfDay != null)
              WordOfDayCard(
                word: wordOfDay.word,
                meaning: wordOfDay.meaning,
                currentIndex: 1,
                totalWords: 25,
                onTap: () => _navigateToVocabularyDetail(context),
              )
            else
              _buildWordPlaceholder(),

            const SizedBox(height: 28),

            // Your Plan Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your plan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => _onSeeAllPlan(context, ref),
                  child: const Text(
                    'SEE ALL',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A7FD4),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Category Grid
            if (categories.isNotEmpty)
              _buildCategoryGrid(categories)
            else
              _buildCategoryPlaceholders(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    String userName,
    String userStatus,
    int userLevel,
  ) {
    return Row(
      children: [
        // Profile avatar (Tappable for Logout)
        GestureDetector(
          onTap: () => _showProfileMenu(context, ref),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4D6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.person_outline_rounded,
                color: const Color(0xFFD4A88E),
                size: 28,
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Greeting and level
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()},',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              Text(
                '$userName!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$userStatus • LEVEL $userLevel',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        // Notification bell
        GestureDetector(
          onTap: () => _onNotificationTap(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(List<LearningCategory> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        double childAspectRatio = 1.0;

        // Responsive grid based on screen width
        if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
          childAspectRatio = 1.05;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return CategoryCard(
              title: cat.title,
              iconType: cat.iconType,
              lessonCount: cat.lessonCount,
              iconColor: cat.iconColor,
              iconBgColor: cat.iconBgColor,
              onTap: () => _onCategoryTap(context, cat),
            );
          },
        );
      },
    );
  }

  /// Placeholder focus card to keep layout when no active session is available
  Widget _buildFocusPlaceholder(BuildContext context) {
    return FocusSessionCard(
      title: 'Mindful Breathing',
      duration: '5 mins',
      onPlay: () => _onPlayFocusSession(context),
    );
  }

  /// Placeholder workshop card to keep the hero section visible
  Widget _buildWorkshopPlaceholder(BuildContext context, WidgetRef ref) {
    return UpcomingWorkshopCard(
      title: 'Workshop coming soon',
      dateTime: 'Stay tuned',
      participantCount: 0,
      isEnrolled: false,
      onEnroll: () => _navigateToWorkshops(context, ref),
      onTap: () => _navigateToWorkshops(context, ref),
    );
  }

  /// Placeholder word card so the section is never empty
  Widget _buildWordPlaceholder() {
    return const WordOfDayCard(
      word: 'Welcome',
      meaning: 'Real-time data will appear here once available.',
    );
  }

  /// Placeholder grid to preserve layout when categories list is empty
  Widget _buildCategoryPlaceholders() {
    final placeholderCategories = List.generate(
      4,
      (index) => LearningCategory(
        id: 'placeholder-$index',
        title: 'Keep learning',
        iconType: 'book',
        lessonCount: 0,
      ),
    );

    return _buildCategoryGrid(placeholderCategories);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void _onPlayFocusSession(BuildContext context) {
    // Navigate to breathing exercise screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BreathingExerciseScreen(durationMinutes: 5),
      ),
    );
  }

  void _navigateToWorkshops(BuildContext context, WidgetRef ref) {
    // Switch to Workshops tab in bottom navigation
    ref.read(mainShellIndexProvider.notifier).state = 1; // Workshops is tab index 1
  }

  void _onWordOfDayTap(BuildContext context, WordOfDay word) {
    // Navigate to Word of Day detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordOfDayDetailScreen(word: word),
      ),
    );
  }

  void _onSeeAllPlan(BuildContext context, WidgetRef ref) {
    // Navigate to Categories screen to see all learning categories
    Navigator.push(
      context,
      AppTransitions.fadeSlide(
        page: const CategoriesScreen(),
      ),
    );
  }

  void _onCategoryTap(BuildContext context, LearningCategory category) {
    Navigator.push(
      context,
      AppTransitions.fadeSlide(
        page: CourseDetailScreen(courseId: category.id),
      ),
    );
  }

  void _onNotificationTap(BuildContext context) {
    // TODO: Navigate to notifications
    FeedbackOverlay.info(context, 'Checking notifications', emoji: '🔔');
  }

  void _navigateToWorkshopDetail(BuildContext context, WidgetRef ref, String workshopId) {
    // Switch to Workshops tab - user can find the workshop there
    ref.read(mainShellIndexProvider.notifier).state = 1; // Workshops is tab index 1
  }

  void _navigateToVocabularyDetail(BuildContext context) {
    Navigator.push(
      context,
      AppTransitions.fadeSlide(
        page: const VocabularyDetailScreen(initialIndex: 0),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
               leading: const Icon(Icons.logout, color: Colors.red),
               title: const Text('Log Out', style: TextStyle(color: Colors.red)),
               onTap: () async {
                 Navigator.pop(context); // Close sheet
                 // Clear preferences and sign out
                 await LocalStorageService.clear(); 
                 await ref.read(authStateProvider.notifier).signOut();
                 // Navigation to login is handled by auth state listener
               },
              ),
            ],
          ),
        );
      },
    );
  }
}
