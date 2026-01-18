import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/shared_prefs_service.dart';

/// Onboarding state model
class OnboardingState {
  final bool isComplete;
  final String? studentName;
  final String? schoolName;
  final String? grade;
  final String? city;

  const OnboardingState({
    required this.isComplete,
    this.studentName,
    this.schoolName,
    this.grade,
    this.city,
  });

  factory OnboardingState.initial() {
    return OnboardingState(
      isComplete: SharedPrefsService.isOnboardingComplete,
      studentName: SharedPrefsService.studentName,
      schoolName: SharedPrefsService.schoolName,
      grade: SharedPrefsService.grade,
      city: SharedPrefsService.city,
    );
  }

  OnboardingState copyWith({
    bool? isComplete,
    String? studentName,
    String? schoolName,
    String? grade,
    String? city,
  }) {
    return OnboardingState(
      isComplete: isComplete ?? this.isComplete,
      studentName: studentName ?? this.studentName,
      schoolName: schoolName ?? this.schoolName,
      grade: grade ?? this.grade,
      city: city ?? this.city,
    );
  }
}

/// Onboarding state notifier
class OnboardingStateNotifier extends StateNotifier<OnboardingState> {
  OnboardingStateNotifier() : super(OnboardingState.initial());

  /// Complete onboarding with student details
  Future<void> completeOnboarding({
    required String studentName,
    required String schoolName,
    required String grade,
    required String city,
  }) async {
    await SharedPrefsService.setStudentName(studentName);
    await SharedPrefsService.setSchoolName(schoolName);
    await SharedPrefsService.setGrade(grade);
    await SharedPrefsService.setCity(city);
    await SharedPrefsService.setOnboardingComplete(true);

    state = state.copyWith(
      isComplete: true,
      studentName: studentName,
      schoolName: schoolName,
      grade: grade,
      city: city,
    );
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    await SharedPrefsService.setOnboardingComplete(false);
    state = state.copyWith(isComplete: false);
  }
}

/// Provider for onboarding state
final onboardingStateProvider = StateNotifierProvider<OnboardingStateNotifier, OnboardingState>((ref) {
  return OnboardingStateNotifier();
});
