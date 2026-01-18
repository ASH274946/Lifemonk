import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_transitions.dart';
import '../../courses/presentation/course_detail_screen.dart';

/// Category Topics Screen - Shows all topics for a specific category (e.g., Mathematics)
class CategoryTopicsScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryTitle;
  final String categoryColor;

  const CategoryTopicsScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get topics for this category
    final topics = _getTopicsForCategory(categoryTitle);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Back Button and Category Title
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      categoryTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Topics List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                itemCount: topics.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return _TopicCard(
                    topic: topic,
                    categoryColor: categoryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        AppTransitions.fadeSlide(
                          page: CourseDetailScreen(courseId: categoryId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get topics based on category
  List<Map<String, dynamic>> _getTopicsForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'mathematics':
        return [
          {'title': 'Addition & Subtraction', 'lessons': 12, 'icon': Icons.add},
          {'title': 'Multiplication & Division', 'lessons': 15, 'icon': Icons.close},
          {'title': 'Fractions & Decimals', 'lessons': 10, 'icon': Icons.pie_chart},
          {'title': 'Geometry Basics', 'lessons': 8, 'icon': Icons.square},
          {'title': 'Measurement', 'lessons': 6, 'icon': Icons.straighten},
          {'title': 'Time & Money', 'lessons': 9, 'icon': Icons.access_time},
        ];
      case 'science':
        return [
          {'title': 'Living Things', 'lessons': 10, 'icon': Icons.eco},
          {'title': 'Plants & Animals', 'lessons': 12, 'icon': Icons.pets},
          {'title': 'Weather & Seasons', 'lessons': 8, 'icon': Icons.wb_sunny},
          {'title': 'Matter & Materials', 'lessons': 9, 'icon': Icons.science},
          {'title': 'Energy & Forces', 'lessons': 11, 'icon': Icons.flash_on},
          {'title': 'Earth & Space', 'lessons': 7, 'icon': Icons.public},
        ];
      case 'english':
      case 'languages':
        return [
          {'title': 'Reading Comprehension', 'lessons': 15, 'icon': Icons.menu_book},
          {'title': 'Grammar Basics', 'lessons': 12, 'icon': Icons.spellcheck},
          {'title': 'Vocabulary Building', 'lessons': 20, 'icon': Icons.abc},
          {'title': 'Writing Skills', 'lessons': 10, 'icon': Icons.edit},
          {'title': 'Phonics & Pronunciation', 'lessons': 14, 'icon': Icons.record_voice_over},
          {'title': 'Story Writing', 'lessons': 8, 'icon': Icons.auto_stories},
        ];
      case 'geography':
        return [
          {'title': 'Continents & Oceans', 'lessons': 7, 'icon': Icons.map},
          {'title': 'Countries & Capitals', 'lessons': 12, 'icon': Icons.flag},
          {'title': 'Landforms', 'lessons': 8, 'icon': Icons.terrain},
          {'title': 'Climate Zones', 'lessons': 6, 'icon': Icons.thermostat},
          {'title': 'Natural Resources', 'lessons': 9, 'icon': Icons.water_drop},
        ];
      default:
        return [
          {'title': 'Introduction', 'lessons': 5, 'icon': Icons.star},
          {'title': 'Fundamentals', 'lessons': 10, 'icon': Icons.school},
          {'title': 'Advanced Topics', 'lessons': 8, 'icon': Icons.trending_up},
        ];
    }
  }
}

/// Individual Topic Card Widget
class _TopicCard extends StatelessWidget {
  final Map<String, dynamic> topic;
  final String categoryColor;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(categoryColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                topic['icon'] as IconData,
                size: 28,
                color: color,
              ),
            ),

            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic['title'] as String,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${topic['lessons']} LESSONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  /// Parse hex color string to Color
  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppColors.buttonLightBlue;
    }
  }
}
