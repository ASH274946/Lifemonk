import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../../core/services/shared_prefs_service.dart';
import '../data/student_profile_repository.dart';
import '../../../core/providers/user_providers.dart';
import '../../auth/providers/auth_provider.dart';

/// Grade/Class options for students (Class 1-10 for school students)
enum StudentGrade {
  class1('Class 1', '1'),
  class2('Class 2', '2'),
  class3('Class 3', '3'),
  class4('Class 4', '4'),
  class5('Class 5', '5'),
  class6('Class 6', '6'),
  class7('Class 7', '7'),
  class8('Class 8', '8'),
  class9('Class 9', '9'),
  class10('Class 10', '10');

  final String label;
  final String shortLabel;
  const StudentGrade(this.label, this.shortLabel);
}

/// State for student onboarding
class OnboardingState {
  final String studentName;
  final String schoolName;
  final StudentGrade? selectedGrade;
  final String city;
  final String state;
  final bool isComplete;
  final bool isLoading;
  final String? errorMessage;

  const OnboardingState({
    this.studentName = '',
    this.schoolName = '',
    this.selectedGrade,
    this.city = '',
    this.state = '',
    this.isComplete = false,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get canContinue =>
      studentName.trim().isNotEmpty &&
      schoolName.trim().isNotEmpty &&
      selectedGrade != null &&
      city.trim().isNotEmpty &&
      state.trim().isNotEmpty;

  OnboardingState copyWith({
    String? studentName,
    String? schoolName,
    StudentGrade? selectedGrade,
    String? city,
    String? state,
    bool? isComplete,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      studentName: studentName ?? this.studentName,
      schoolName: schoolName ?? this.schoolName,
      selectedGrade: selectedGrade ?? this.selectedGrade,
      city: city ?? this.city,
      state: state ?? this.state,
      isComplete: isComplete ?? this.isComplete,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Provider for StudentProfileRepository
final studentProfileRepositoryProvider = Provider<StudentProfileRepository>((
  ref,
) {
  return StudentProfileRepository();
});

/// Provider for onboarding state
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      final repository = ref.watch(studentProfileRepositoryProvider);
      return OnboardingNotifier(repository, ref);
    });

/// Provider to check if onboarding is complete
final isOnboardingCompleteProvider = Provider<bool>((ref) {
  return LocalStorageService.isOnboardingComplete;
});

/// Notifier for managing onboarding state
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(StudentProfileRepository repository, this._ref)
    : super(const OnboardingState());

  /// Update student name
  void setStudentName(String name) {
    state = state.copyWith(studentName: name);
  }

  /// Update school name
  void setSchoolName(String name) {
    state = state.copyWith(schoolName: name);
  }

  /// Select grade
  void selectGrade(StudentGrade grade) {
    state = state.copyWith(selectedGrade: grade);
  }

  /// Update city
  void setCity(String city) {
    state = state.copyWith(city: city);
  }

  /// Update state
  void setStateName(String stateName) {
    state = state.copyWith(state: stateName);
  }

  /// Complete onboarding: save to new user system in Supabase
  Future<bool> completeOnboarding() async {
    if (!state.canContinue) {
      state = state.copyWith(errorMessage: 'Please fill all required fields');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Get current user ID
      // Get current user ID or treat as guest if null
      String? userId = _ref.read(currentUserIdProvider);
      
      // If user is not authenticated, treat as guest for now
      // This handles the "Let's Begin" flow for users who skipped login
      bool isGuest = false;
      if (userId == null) {
        if (kDebugMode) {
          print('⚠️ User not authenticated, initializing guest session automatically');
        }
        
        // Generate a guest ID
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        userId = 'guest_$timestamp';
        
        // Save guest ID to local storage so it persists
        await LocalStorageService.setString('guest_user_id', userId);
        isGuest = true;
        
        // Explicitly set guest mode in auth provider so other providers know
        _ref.read(authStateProvider.notifier).continueAsGuest();
      } else {
        isGuest = userId.startsWith('guest_');
      }

      if (kDebugMode) {
        print('🔍 Starting onboarding for user: $userId (Is Guest: $isGuest)');
      }

      if (kDebugMode) {
        print('🔍 Starting onboarding for user: $userId (Guest: $isGuest)');
        print(
          '📝 Data: ${state.studentName}, ${state.schoolName}, ${state.selectedGrade?.label}, ${state.city}, ${state.state}',
        );
      }

      // If guest user, save locally using SharedPrefsService for consistency with Splash
      if (isGuest) {
        // Save guest details
        await SharedPrefsService.setStudentName(state.studentName);
        await SharedPrefsService.setSchoolName(state.schoolName);
        await SharedPrefsService.setGrade(state.selectedGrade?.label ?? '');
        await SharedPrefsService.setCity(state.city);
        
        // CRITICAL: Set auth flags so Splash screen recognizes user
        await SharedPrefsService.setAuthType('guest');
        await SharedPrefsService.setUserToken(userId); // Ensure token is set
        await SharedPrefsService.setOnboardingComplete(true);
        
        if (kDebugMode) {
          print('✅ Guest onboarding data saved to SharedPrefs');
          print('✅ AuthType: guest, Token: $userId, Onboarding: true');
        }
        
        state = state.copyWith(isComplete: true, isLoading: false);
        return true;
      }

      // Get user repository
      final userRepo = _ref.read(userRepositoryProvider);

      // Check if user profile exists, if not create it
      final existingProfile = await userRepo.getUserProfile(userId);

      if (kDebugMode) {
        print(
          '👤 Existing profile: ${existingProfile != null ? "Found" : "Not found"}',
        );
      }

      if (existingProfile == null) {
        // Profile doesn't exist, create it
        // Get phone/email from auth user
        final supabase = _ref.read(supabaseClientProvider);
        final authUser = supabase.auth.currentUser;

        // Use phone if available, otherwise use email, otherwise use a placeholder
        String phone = authUser?.phone ?? '';
        String? email = authUser?.email;

        // If no phone, use email as identifier
        if (phone.isEmpty && email != null) {
          phone = email; // Supabase allows this
        }

        // If still empty, there's a problem
        if (phone.isEmpty) {
          throw Exception(
            'No phone or email found for user. Cannot create profile.',
          );
        }

        if (kDebugMode) {
          print('🆕 Creating new profile with phone: $phone, email: $email');
        }

        await userRepo.createUserProfile(
          userId: userId,
          phone: phone,
          name: state.studentName,
          email: email,
          school: state.schoolName,
          grade: state.selectedGrade!.label,
          city: state.city,
          state: state.state,
        );
      } else {
        // Update existing profile
        if (kDebugMode) {
          print('🔄 Updating existing profile');
        }

        final updatedProfile = existingProfile.copyWith(
          name: state.studentName,
          school: state.schoolName,
          grade: state.selectedGrade!.label,
          city: state.city,
          state: state.state,
        );

        await userRepo.updateUserProfile(updatedProfile);
      }

      // Mark onboarding as complete in user_app_state
      if (kDebugMode) {
        print('✅ Marking onboarding complete in database for user: $userId');
      }
      await userRepo.completeOnboarding(userId);
      
      if (kDebugMode) {
        print('✅ Database onboarding flag updated successfully');
      }

      // Invalidate providers to refresh data
      _ref.invalidate(currentUserDataProvider);
      _ref.invalidate(currentUserProfileProvider);
      _ref.invalidate(userAppStateProvider);

      // Mark onboarding as complete locally using the SAME key as splash screen
      // Using LocalStorageService which now aligns with AppConstants.onboardingCompleteKey
      await LocalStorageService.setOnboardingComplete(true);
      
      if (kDebugMode) {
        print('✅ Local storage onboarding flag set to true');
      }

      state = state.copyWith(isComplete: true, isLoading: false);

      if (kDebugMode) {
        print('✅ User profile saved to new system successfully');
        print('🎉 Onboarding complete! User should navigate to home now.');
      }

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error saving user profile: $e');
        print('📚 Stack trace: $stackTrace');
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );

      return false;
    }
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset onboarding (for testing purposes)
  Future<void> resetOnboarding() async {
    await LocalStorageService.setOnboardingComplete(false);
    state = const OnboardingState();
  }
}
