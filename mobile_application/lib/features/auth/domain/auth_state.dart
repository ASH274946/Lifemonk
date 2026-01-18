import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents different authentication states
enum AuthStatus { initial, loading, authenticated, unauthenticated, guest, error }

/// State class for authentication
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isGuest;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isGuest = false,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  /// Loading state
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);

  /// Authenticated state
  factory AuthState.authenticated(User user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  /// Unauthenticated state
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  /// Guest state
  factory AuthState.guest() => const AuthState(status: AuthStatus.guest, isGuest: true);

  /// Error state
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Check if loading
  bool get isLoading => status == AuthStatus.loading;

  /// Copy with method
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isGuest,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.email}, isGuest: $isGuest, error: $errorMessage)';
  }
}
