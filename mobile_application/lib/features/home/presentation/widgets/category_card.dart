import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Category Card for "Your Plan" section
/// Shows icon, title, and lesson count
class CategoryCard extends StatelessWidget {
  final String title;
  final String iconType;
  final int lessonCount;
  final Color? iconColor;
  final Color? iconBgColor;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.iconType,
    required this.lessonCount,
    this.iconColor,
    this.iconBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor ?? _getDefaultBgColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _buildIcon(),
              ),
            ),
            
            const Spacer(),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Lesson count
            Text(
              '$lessonCount LESSONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDefaultBgColor() {
    switch (iconType.toLowerCase()) {
      case 'math':
      case 'mathematics':
      case 'applied_maths':
        return const Color(0xFFFFE8D6); // Light orange/peach
      case 'vedic':
      case 'vedic_maths':
        return const Color(0xFFE8D6FF); // Light purple
      case 'trigonometry':
        return const Color(0xFFD6FFE8); // Light green/mint
      case 'nutrition':
        return const Color(0xFFFFD6D6); // Light pink/red
      case 'geography':
        return const Color(0xFFD6E8FF); // Light blue
      case 'cognitive':
        return const Color(0xFFFFF0D6); // Light yellow
      case 'creative':
        return const Color(0xFFFFD6F0); // Light pink
      case 'discovery':
        return const Color(0xFFD6FFF0); // Light cyan
      case 'languages':
        return const Color(0xFFF0D6FF); // Light lavender
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Widget _buildIcon() {
    final color = iconColor ?? _getDefaultIconColor();
    
    switch (iconType.toLowerCase()) {
      case 'math':
      case 'mathematics':
      case 'applied_maths':
        return Icon(
          Icons.calculate_rounded,
          color: color,
          size: 24,
        );
      case 'vedic':
      case 'vedic_maths':
        return Icon(
          Icons.auto_stories_rounded,
          color: color,
          size: 24,
        );
      case 'trigonometry':
        return Icon(
          Icons.change_history_rounded,
          color: color,
          size: 24,
        );
      case 'nutrition':
        return Icon(
          Icons.favorite_rounded,
          color: color,
          size: 24,
        );
      case 'geography':
        return Icon(
          Icons.public_rounded,
          color: color,
          size: 24,
        );
      case 'cognitive':
        return Icon(
          Icons.psychology_rounded,
          color: color,
          size: 24,
        );
      case 'creative':
        return Icon(
          Icons.palette_rounded,
          color: color,
          size: 24,
        );
      case 'discovery':
        return Icon(
          Icons.science_rounded,
          color: color,
          size: 24,
        );
      case 'languages':
        return Icon(
          Icons.translate_rounded,
          color: color,
          size: 24,
        );
      default:
        return Icon(
          Icons.school_rounded,
          color: color,
          size: 24,
        );
    }
  }

  Color _getDefaultIconColor() {
    switch (iconType.toLowerCase()) {
      case 'math':
      case 'mathematics':
      case 'applied_maths':
        return const Color(0xFFFF8C42); // Orange
      case 'vedic':
      case 'vedic_maths':
        return const Color(0xFF9B59B6); // Purple
      case 'trigonometry':
        return const Color(0xFF2ECC71); // Green
      case 'nutrition':
        return const Color(0xFFE74C3C); // Red
      case 'geography':
        return const Color(0xFF3498DB); // Blue
      case 'cognitive':
        return const Color(0xFFF39C12); // Yellow/Gold
      case 'creative':
        return const Color(0xFFE91E63); // Pink
      case 'discovery':
        return const Color(0xFF1ABC9C); // Teal
      case 'languages':
        return const Color(0xFF8E44AD); // Purple
      default:
        return const Color(0xFF666666);
    }
  }
}
