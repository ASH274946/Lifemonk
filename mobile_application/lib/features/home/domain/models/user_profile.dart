/// User profile model for home screen header
class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final int level;
  final String status;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.level,
    required this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['student_name'] as String? ?? 'Student',
      avatarUrl: json['avatar_url'] as String?,
      level: json['level'] as int? ?? 1,
      status: json['status'] as String? ?? 'Explorer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': name,
      'avatar_url': avatarUrl,
      'level': level,
      'status': status,
    };
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Get first name for display
  String get firstName => name.split(' ').first;
}
