import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/user_models.dart';
import '../data/user_repository.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/services/local_storage_service.dart';

/// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// User repository provider
final userRepositoryProvider = Provider<IUserRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseUserRepository(supabase);
});

/// Current auth user provider
/// Returns the currently authenticated user from Supabase Auth
/// Returns null if no user is signed in
final currentAuthUserProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange.map((data) => data.session?.user);
});

/// Current user ID provider
/// Convenience provider to get just the user ID
/// For guest users, returns a locally stored guest ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  final authUser = ref.watch(currentAuthUserProvider).value;
  
  // If authenticated user exists, return their ID
  if (authUser != null) {
    return authUser.id;
  }
  
  // If in guest mode, return or create guest ID
  if (authState.isGuest) {
    String? guestId = LocalStorageService.getString('guest_user_id');
    if (guestId == null) {
      // Generate a simple guest ID using timestamp
      guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      LocalStorageService.setString('guest_user_id', guestId);
    }
    return guestId;
  }
  
  return null;
});

/// Current user profile provider
/// Fetches the complete user profile from the users table
/// Auto-refreshes when auth state changes
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  // Watch auth user to auto-refresh when it changes
  final authUser = ref.watch(currentAuthUserProvider).value;
  if (authUser == null) return null;

  final repository = ref.watch(userRepositoryProvider);
  return repository.getCurrentUserProfile();
});

/// User app state provider
/// Fetches the user's app state (onboarding, level, streak, etc.)
final userAppStateProvider = FutureProvider<UserAppState?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserAppState(userId);
});

/// Complete user data provider
/// Combines profile and app state into single UserData object
/// This is the main provider most features should use
final currentUserDataProvider = FutureProvider<UserData?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserData(userId);
});

/// User onboarding status provider
/// Convenience provider to check if user has completed onboarding
final userOnboardingStatusProvider = Provider<bool>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  return userData?.appState.onboardingCompleted ?? false;
});

/// User level provider
/// Convenience provider to get user's current level
final userLevelProvider = Provider<int>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  return userData?.appState.currentLevel ?? 1;
});

/// User XP provider
/// Convenience provider to get user's XP
final userXpProvider = Provider<int>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  return userData?.appState.xp ?? 0;
});

/// User streak provider
/// Convenience provider to get user's streak days
final userStreakProvider = Provider<int>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  return userData?.appState.streakDays ?? 0;
});

/// User actions notifier
/// Provides methods to perform user-related actions
/// Use this for mutations (create, update, etc.)
class UserActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final IUserRepository _repository;
  final Ref _ref;

  UserActionsNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  /// Create user profile after signup
  Future<UserProfile> createUserProfile({
    required String userId,
    required String phone,
    required String name,
    String? email,
  }) async {
    state = const AsyncValue.loading();

    try {
      final profile = await _repository.createUserProfile(
        userId: userId,
        phone: phone,
        name: name,
        email: email,
      );

      state = const AsyncValue.data(null);

      // Invalidate providers to refresh data
      _ref.invalidate(currentUserProfileProvider);
      _ref.invalidate(currentUserDataProvider);

      return profile;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncValue.loading();

    try {
      await _repository.updateUserProfile(profile);
      state = const AsyncValue.data(null);

      // Invalidate providers to refresh data
      _ref.invalidate(currentUserProfileProvider);
      _ref.invalidate(currentUserDataProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding(String userId) async {
    state = const AsyncValue.loading();

    try {
      await _repository.completeOnboarding(userId);
      state = const AsyncValue.data(null);

      // Invalidate providers to refresh data
      _ref.invalidate(userAppStateProvider);
      _ref.invalidate(currentUserDataProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update user app state
  Future<void> updateAppState(UserAppState appState) async {
    state = const AsyncValue.loading();

    try {
      await _repository.updateUserAppState(appState);
      state = const AsyncValue.data(null);

      // Invalidate providers to refresh data
      _ref.invalidate(userAppStateProvider);
      _ref.invalidate(currentUserDataProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update last active timestamp
  Future<void> updateLastActive(String userId) async {
    // Don't change state for this - it's a background operation
    try {
      await _repository.updateLastActive(userId);
    } catch (e) {
      // Silently fail - not critical
      print('Failed to update last active: $e');
    }
  }

  /// Add XP to user
  Future<void> addXp(String userId, int xpToAdd) async {
    state = const AsyncValue.loading();

    try {
      final appState = await _repository.getUserAppState(userId);
      if (appState == null) {
        throw UserNotFoundException('User app state not found');
      }

      final newXp = appState.xp + xpToAdd;
      final updatedState = appState.copyWith(xp: newXp);

      await _repository.updateUserAppState(updatedState);
      state = const AsyncValue.data(null);

      _ref.invalidate(userAppStateProvider);
      _ref.invalidate(currentUserDataProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update streak
  Future<void> updateStreak(String userId) async {
    state = const AsyncValue.loading();

    try {
      final appState = await _repository.getUserAppState(userId);
      if (appState == null) {
        throw UserNotFoundException('User app state not found');
      }

      final today = DateTime.now();
      final lastStreakDate = appState.lastStreakDate;

      int newStreak = appState.streakDays;

      if (lastStreakDate == null) {
        // First time - start streak
        newStreak = 1;
      } else {
        final daysSinceLastActivity = today.difference(lastStreakDate).inDays;

        if (daysSinceLastActivity == 1) {
          // Consecutive day - increase streak
          newStreak = appState.streakDays + 1;
        } else if (daysSinceLastActivity > 1) {
          // Streak broken - reset
          newStreak = 1;
        }
        // Same day - no change
      }

      final newLongestStreak = newStreak > appState.longestStreak
          ? newStreak
          : appState.longestStreak;

      final updatedState = appState.copyWith(
        streakDays: newStreak,
        longestStreak: newLongestStreak,
        lastStreakDate: today,
      );

      await _repository.updateUserAppState(updatedState);
      state = const AsyncValue.data(null);

      _ref.invalidate(userAppStateProvider);
      _ref.invalidate(currentUserDataProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// User actions provider
/// Use this to perform mutations on user data
final userActionsProvider =
    StateNotifierProvider<UserActionsNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(userRepositoryProvider);
      return UserActionsNotifier(repository, ref);
    });
