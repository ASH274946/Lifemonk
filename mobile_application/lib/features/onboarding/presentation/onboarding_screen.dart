import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/feedback_overlay.dart';
import '../../../shared/widgets/animated_button.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

/// Student Onboarding Screen
/// Beautiful, child-friendly form with premium UX
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _studentNameController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _schoolNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    // Show error feedback if there's an error
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FeedbackOverlay.error(context, state.errorMessage!);
        notifier.clearError();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      
                      // Title
                      const Text(
                        'Tell us about yourself',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      Text(
                        'This helps us personalize your learning journey ✨',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Student Name Field
                      _buildFieldLabel('Your Name'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _studentNameController,
                        hintText: 'What should we call you?',
                        onChanged: notifier.setStudentName,
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // School Name Field
                      _buildFieldLabel('School Name'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _schoolNameController,
                        hintText: 'Where do you study?',
                        onChanged: notifier.setSchoolName,
                        prefixIcon: Icons.school_outlined,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Class Selection - Beautiful Chips
                      _buildFieldLabel('Select Your Class'),
                      const SizedBox(height: 12),
                      _buildClassChips(state, notifier),
                      
                      const SizedBox(height: 24),
                      
                      // City & State Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('City'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _cityController,
                                  hintText: 'Your city',
                                  onChanged: notifier.setCity,
                                  prefixIcon: Icons.location_city_outlined,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('State'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _stateController,
                                  hintText: 'Your state',
                                  onChanged: notifier.setStateName,
                                  prefixIcon: Icons.map_outlined,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              
              // Continue Button
              _buildContinueButton(context, state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () async {
              if (context.canPop()) {
                context.pop();
              } else {
                // If we can't pop (e.g. came from login via go()), 
                // we should log out to return to login screen
                if (kDebugMode) print('🔙 Cannot pop, signing out and going to login...');
                
                await LocalStorageService.clear(); 
                await ref.read(authStateProvider.notifier).signOut();
                
                if (context.mounted) {
                   context.go(RouteConstants.login);
                }
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                size: 28,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Centered title
          Expanded(
            child: Center(
              child: const Text(
                'Lifemonk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          
          // Placeholder for symmetry
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
    IconData? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 20,
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: prefixIcon != null ? 0 : 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  /// Beautiful class chip selector - child-friendly and animated
  Widget _buildClassChips(OnboardingState state, OnboardingNotifier notifier) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: StudentGrade.values.map((grade) {
        final isSelected = state.selectedGrade == grade;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            notifier.selectGrade(grade);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.buttonLightBlue : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected 
                    ? AppColors.buttonLightBlue 
                    : const Color(0xFFE8E8E8),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.buttonLightBlue.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              grade.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContinueButton(
    BuildContext context, 
    OnboardingState state, 
    OnboardingNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: AnimatedLightButton(
        text: "Let's begin! 🚀",
        isLoading: state.isLoading,
        onPressed: !state.isLoading
            ? () async {
                try {
                  if (kDebugMode) {
                    print('🚀 User tapped "Let\'s begin" button');
                  }
                  
                  final success = await notifier.completeOnboarding();
                  
                  if (kDebugMode) {
                    print('📊 Onboarding completion result: $success');
                  }
                  
                  if (success && context.mounted) {
                    FeedbackOverlay.success(
                      context, 
                      "You're all set! Let's explore",
                      emoji: '🎉',
                    );
                    // Delay navigation slightly for feedback to show
                    await Future.delayed(const Duration(milliseconds: 800));
                    if (context.mounted) {
                      if (kDebugMode) {
                        print('🏠 Navigating to home screen: ${RouteConstants.home}');
                      }
                      context.go(RouteConstants.home);
                    }
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print('❌ Exception in onboarding button handler: $e');
                  }
                  if (context.mounted) {
                    FeedbackOverlay.error(
                      context,
                      'Error: ${e.toString()}',
                    );
                  }
                }
              }
            : null,
      ),
    );
  }
}
