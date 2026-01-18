import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../workshops/domain/workshop_model.dart';

/// Reusable workshop card widget
class WorkshopCard extends StatelessWidget {
  final Workshop workshop;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  const WorkshopCard({
    super.key,
    required this.workshop,
    this.onTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = workshop.status == WorkshopStatus.completed;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workshop.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDisabled
                              ? AppColors.textSecondary.withValues(alpha: 0.5)
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workshop.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusBadge(),
              ],
            ),

            const SizedBox(height: 16),

            // Date and time row
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  workshop.formattedDate,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  workshop.formattedTime,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Duration and age group row
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  workshop.formattedDuration,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.people_outline_rounded,
                  size: 16,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  workshop.ageGroup,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action button
            if (!isDisabled)
              Row(children: [Expanded(child: _buildActionButton(context))]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final colors = workshop.status.badgeColors;
    final bgColor = _hexToColor(colors.$1);
    final textColor = _hexToColor(colors.$2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        workshop.status.displayText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    // Check if enrollment is disabled (CMS-controlled)
    if (!workshop.isJoinEnabled) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Not Available',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // Show Join button if enrollment is enabled
    return ElevatedButton(
      onPressed: workshop.isEnrolled ? null : (onJoin ?? onTap),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: workshop.isEnrolled ? const Color(0xFFDBEAFE) : const Color(0xFF111827),
        foregroundColor: workshop.isEnrolled ? const Color(0xFF1E3A8A) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        workshop.isEnrolled ? 'Joined ✓' : 'Join',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
