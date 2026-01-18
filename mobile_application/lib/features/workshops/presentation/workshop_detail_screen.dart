import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/cms/models.dart';
import '../../../shared/cms/cms_providers.dart';
import '../../../shared/widgets/feedback_overlay.dart';
import '../../../shared/widgets/workshop_join_success_sheet.dart';

class WorkshopDetailScreen extends ConsumerWidget {
  final CmsWorkshop workshop;

  const WorkshopDetailScreen({
    super.key,
    required this.workshop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for updates to this specific workshop in the list
    // This ensures that when enrollment changes, the UI updates
    final allWorkshops = ref.watch(workshopsProvider).valueOrNull;
    final currentWorkshop = allWorkshops?.firstWhere(
      (w) => w.id == workshop.id,
      orElse: () => workshop,
    ) ?? workshop;

    final enrollmentState = ref.watch(enrollmentControllerProvider);
    final isLoading = enrollmentState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header with Back Button and Banner
            _buildHeader(context, currentWorkshop),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Instructor
                  Text(
                    currentWorkshop.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInstructorRow(currentWorkshop.instructor),

                  const SizedBox(height: 24),

                  // Info Chips (Date, Time, Duration)
                  _buildInfoChips(currentWorkshop),

                  const SizedBox(height: 24),

                  // Description
                  _buildSectionHeader('ABOUT THIS WORKSHOP'),
                  const SizedBox(height: 12),
                  Text(
                    currentWorkshop.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: const Color(0xFF4B5563),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Enrollment Stats
                  _buildEnrollmentStats(currentWorkshop),

                  const SizedBox(height: 24),

                  // Learning Outcomes (Mock)
                  _buildSectionHeader('WHAT YOU\'LL LEARN'),
                  const SizedBox(height: 12),
                  _buildBulletPoint('Master the fundamental techniques'),
                  _buildBulletPoint('Practical exercises and real-world examples'),
                  _buildBulletPoint('Q&A session with the instructor'),
                  _buildBulletPoint('Certificate of completion'),

                  const SizedBox(height: 40),

                  // Enroll Button
                  _buildEnrollButton(context, ref, currentWorkshop, isLoading),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CmsWorkshop workshop) {
    return Stack(
      children: [
        // Banner Image
        SizedBox(
          height: 260,
          width: double.infinity,
          child: workshop.imageUrl.isNotEmpty
              ? (workshop.imageUrl.startsWith('http')
                  ? Image.network(
                      workshop.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade400,
                          child: Center(
                            child: Icon(Icons.broken_image, size: 64, color: Colors.white.withValues(alpha: 0.5)),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      workshop.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade400,
                          child: Center(
                            child: Icon(Icons.broken_image, size: 64, color: Colors.white.withValues(alpha: 0.5)),
                          ),
                        );
                      },
                    ))
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFD1D5DB), const Color(0xFF9CA3AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.image_rounded, size: 80, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ),
        ),
        
        // Gradient Overlay for visibility
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Back Button
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF111827)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructorRow(String instructor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
          ),
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFDBEAFE),
            child: Icon(Icons.person, size: 20, color: Color(0xFF1D4ED8)),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              instructor,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const Text(
              'Instructor',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChips(CmsWorkshop workshop) {
    final endTime = workshop.dateTime.add(Duration(minutes: workshop.durationMinutes));
    final timeFormat = DateFormat('h:mm a');
    final timeRange = '${timeFormat.format(workshop.dateTime)} - ${timeFormat.format(endTime)}';

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildChip(
          Icons.calendar_today_rounded,
          DateFormat('MMM dd, yyyy').format(workshop.dateTime),
        ),
        _buildChip(
          Icons.access_time_rounded,
          timeRange,
        ),
        _buildChip(
          Icons.timer_outlined,
          '${workshop.durationMinutes} mins',
        ),
        _buildChip(
          Icons.videocam_outlined,
          workshop.type,
          color: const Color(0xFFEFF6FF),
          textColor: const Color(0xFF1E40AF),
          iconColor: const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildChip(
    IconData icon,
    String label, {
    Color? color,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color != null ? Colors.transparent : const Color(0xFFF3F4F6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor ?? const Color(0xFF4B5563)),
          const SizedBox(width: 8),
          Flexible( // Changed from Expanded to Flexible for Wrap
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor ?? const Color(0xFF374151),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildEnrollmentStats(CmsWorkshop workshop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${workshop.enrollmentPercentage}%', 'ENROLLED'),
          Container(width: 1, height: 40, color: const Color(0xFFDBEAFE)),
          _buildStatItem('${workshop.durationMinutes}m', 'DURATION'),
          Container(width: 1, height: 40, color: const Color(0xFFDBEAFE)),
          _buildStatItem(workshop.category, 'CATEGORY'),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E40AF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF60A5FA),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollButton(BuildContext context, WidgetRef ref, CmsWorkshop workshop, bool isLoading) {
    final isEnrolled = workshop.enrolled;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnrolled ? const Color(0xFFF3F4F6) : const Color(0xFF3B82F6),
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: isEnrolled ? 0 : 4,
          shadowColor: const Color(0xFF3B82F6).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: isLoading ? null : () async {
          if (!isEnrolled) {
            await ref.read(enrollmentControllerProvider.notifier).toggleEnrollment(workshop.id);
            if (context.mounted) {
              WorkshopJoinSuccessSheet.show(
                context,
                workshopTitle: workshop.title,
              );
            }
          } else {
            // Already enrolled, maybe show unenroll dialog
            final shouldUnenroll = await _showUnenrollDialog(context);
            if (shouldUnenroll == true) {
              await ref.read(enrollmentControllerProvider.notifier).toggleEnrollment(workshop.id);
              if (context.mounted) {
                FeedbackOverlay.info(context, 'You have left the workshop');
              }
            }
          }
        },
        child: isLoading 
          ? const SizedBox(
              width: 24, 
              height: 24, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(
              isEnrolled ? 'YOU ARE ENROLLED' : 'ENROLL IN WORKSHOP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isEnrolled ? const Color(0xFF4B5563) : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
      ),
    );
  }

  Future<bool?> _showUnenrollDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Workshop?'),
        content: const Text('Are you sure you want to unenroll from this workshop? You may lose your spot.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Leave'),
          ),
        ],
      ),
    );
  }
}
