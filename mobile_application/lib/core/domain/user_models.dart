/// User Profile Model
/// Represents a user's core profile data
/// Maps to Supabase 'users' table
class UserProfile {
  final String id; // UUID matching auth.users.id
  final String phone;
  final String? email;
  final String name;
  final String? school;
  final String? grade;
  final String? city;
  final String? state;
  final String language;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.phone,
    this.email,
    required this.name,
    this.school,
    this.grade,
    this.city,
    this.state,
    this.language = 'en',
    this.role = UserRole.student,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Supabase JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      name: json['name'] as String,
      school: json['school'] as String?,
      grade: json['grade'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      language: json['language'] as String? ?? 'en',
      role: UserRole.fromString(json['role'] as String? ?? 'student'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'school': school,
      'grade': grade,
      'city': city,
      'state': state,
      'language': language,
      'role': role.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  UserProfile copyWith({
    String? phone,
    String? email,
    String? name,
    String? school,
    String? grade,
    String? city,
    String? state,
    String? language,
    UserRole? role,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      school: school ?? this.school,
      grade: grade ?? this.grade,
      city: city ?? this.city,
      state: state ?? this.state,
      language: language ?? this.language,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Check if profile is complete
  bool get isComplete {
    return name.isNotEmpty &&
        school != null &&
        grade != null &&
        city != null &&
        state != null;
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, phone: $phone, role: ${role.value})';
  }
}

/// User Role Enum
enum UserRole {
  student('student'),
  parent('parent'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }
}

/// User App State Model
/// Represents user's app behavior and progress
/// Maps to Supabase 'user_app_state' table
class UserAppState {
  final String userId;
  final bool onboardingCompleted;
  final DateTime? onboardingCompletedAt;
  final DateTime lastActiveAt;
  final int totalSessions;
  final int currentLevel;
  final int xp;
  final int streakDays;
  final int longestStreak;
  final DateTime? lastStreakDate;
  final String theme;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserAppState({
    required this.userId,
    this.onboardingCompleted = false,
    this.onboardingCompletedAt,
    required this.lastActiveAt,
    this.totalSessions = 0,
    this.currentLevel = 1,
    this.xp = 0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.lastStreakDate,
    this.theme = 'light',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Supabase JSON
  factory UserAppState.fromJson(Map<String, dynamic> json) {
    return UserAppState(
      userId: json['user_id'] as String,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      onboardingCompletedAt: json['onboarding_completed_at'] != null
          ? DateTime.parse(json['onboarding_completed_at'] as String)
          : null,
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
      totalSessions: json['total_sessions'] as int? ?? 0,
      currentLevel: json['current_level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastStreakDate: json['last_streak_date'] != null
          ? DateTime.parse(json['last_streak_date'] as String)
          : null,
      theme: json['theme'] as String? ?? 'light',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'onboarding_completed': onboardingCompleted,
      'onboarding_completed_at': onboardingCompletedAt?.toIso8601String(),
      'last_active_at': lastActiveAt.toIso8601String(),
      'total_sessions': totalSessions,
      'current_level': currentLevel,
      'xp': xp,
      'streak_days': streakDays,
      'longest_streak': longestStreak,
      'last_streak_date': lastStreakDate?.toIso8601String(),
      'theme': theme,
      'notifications_enabled': notificationsEnabled,
      'sound_enabled': soundEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  UserAppState copyWith({
    bool? onboardingCompleted,
    DateTime? onboardingCompletedAt,
    DateTime? lastActiveAt,
    int? totalSessions,
    int? currentLevel,
    int? xp,
    int? streakDays,
    int? longestStreak,
    DateTime? lastStreakDate,
    String? theme,
    bool? notificationsEnabled,
    bool? soundEnabled,
    DateTime? updatedAt,
  }) {
    return UserAppState(
      userId: userId,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      totalSessions: totalSessions ?? this.totalSessions,
      currentLevel: currentLevel ?? this.currentLevel,
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'UserAppState(userId: $userId, level: $currentLevel, xp: $xp, streak: $streakDays)';
  }
}

/// Complete User Data
/// Combines profile and app state for convenient access
class UserData {
  final UserProfile profile;
  final UserAppState appState;

  const UserData({required this.profile, required this.appState});

  String get id => profile.id;
  String get name => profile.name;
  bool get onboardingCompleted => appState.onboardingCompleted;
  int get level => appState.currentLevel;
  int get xp => appState.xp;
  int get streakDays => appState.streakDays;

  @override
  String toString() {
    return 'UserData(name: $name, level: $level, onboarded: $onboardingCompleted)';
  }
}
