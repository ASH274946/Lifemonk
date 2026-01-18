/// User progress and statistics model
class UserProgress {
  final int totalDays;
  final int lessonsCompleted;
  final int currentScore;
  final int workshopsJoined;
  final int vocabularyLearned;
  final int currentStreak;
  final DateTime lastActive;

  const UserProgress({
    required this.totalDays,
    required this.lessonsCompleted,
    required this.currentScore,
    this.workshopsJoined = 0,
    this.vocabularyLearned = 0,
    this.currentStreak = 0,
    required this.lastActive,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalDays: json['total_days'] as int? ?? 0,
      lessonsCompleted: json['lessons_completed'] as int? ?? 0,
      currentScore: json['current_score'] as int? ?? 0,
      workshopsJoined: json['workshops_joined'] as int? ?? 0,
      vocabularyLearned: json['vocabulary_learned'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_days': totalDays,
      'lessons_completed': lessonsCompleted,
      'current_score': currentScore,
      'workshops_joined': workshopsJoined,
      'vocabulary_learned': vocabularyLearned,
      'current_streak': currentStreak,
      'last_active': lastActive.toIso8601String(),
    };
  }

  /// Default/mock progress for testing
  factory UserProgress.mock() {
    return UserProgress(
      totalDays: 42,
      lessonsCompleted: 28,
      currentScore: 850,
      workshopsJoined: 5,
      vocabularyLearned: 156,
      currentStreak: 7,
      lastActive: DateTime.now(),
    );
  }
}
