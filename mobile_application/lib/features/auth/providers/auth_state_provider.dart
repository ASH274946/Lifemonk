import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/shared_prefs_service.dart';

/// Auth state model
class AuthState {
  final bool isAuthenticated;
  final String? authType; // 'google', 'phone', 'guest'
  final String? userToken;
  final String? phoneNumber;

  const AuthState({
    required this.isAuthenticated,
    this.authType,
    this.userToken,
    this.phoneNumber,
  });

  factory AuthState.initial() {
    return AuthState(
      isAuthenticated: SharedPrefsService.isAuthenticated,
      authType: SharedPrefsService.authType,
      userToken: SharedPrefsService.userToken,
      phoneNumber: SharedPrefsService.phoneNumber,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    String? authType,
    String? userToken,
    String? phoneNumber,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authType: authType ?? this.authType,
      userToken: userToken ?? this.userToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

/// Auth state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(AuthState.initial());

  /// Sign in with Google
  Future<void> signInWithGoogle(String token, [String? email]) async {
    await SharedPrefsService.setAuthType('google');
    await SharedPrefsService.setUserToken(token);
    state = state.copyWith(
      isAuthenticated: true,
      authType: 'google',
      userToken: token,
      // Store email if needed, or rely on currentUser provider which fetches from Supabase
    );
  }

  /// Sign in with Phone
  Future<void> signInWithPhone(String phoneNumber, String token) async {
    await SharedPrefsService.setAuthType('phone');
    await SharedPrefsService.setUserToken(token);
    await SharedPrefsService.setPhoneNumber(phoneNumber);
    state = state.copyWith(
      isAuthenticated: true,
      authType: 'phone',
      userToken: token,
      phoneNumber: phoneNumber,
    );
  }

  /// Continue as Guest
  Future<void> continueAsGuest() async {
    await SharedPrefsService.setAuthType('guest');
    await SharedPrefsService.setUserToken('guest_${DateTime.now().millisecondsSinceEpoch}');
    state = state.copyWith(
      isAuthenticated: true,
      authType: 'guest',
      userToken: 'guest',
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await SharedPrefsService.clearAll();
    state = AuthState.initial();
  }
}

/// Provider for auth state
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});
