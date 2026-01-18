/// Practice history item model
class PracticeHistoryItem {
  final String id;
  final String word;
  final DateTime practicedAt;
  final int correctCount;
  final int totalAttempts;
  final double successRate;

  const PracticeHistoryItem({
    required this.id,
    required this.word,
    required this.practicedAt,
    required this.correctCount,
    required this.totalAttempts,
    required this.successRate,
  });

  factory PracticeHistoryItem.fromJson(Map<String, dynamic> json) {
    final correctCount = json['correct_count'] as int? ?? 0;
    final totalAttempts = json['total_attempts'] as int? ?? 1;
    final successRate = totalAttempts > 0 ? correctCount / totalAttempts : 0.0;

    return PracticeHistoryItem(
      id: json['id'] as String,
      word: json['word'] as String,
      practicedAt: DateTime.parse(json['practiced_at'] as String),
      correctCount: correctCount,
      totalAttempts: totalAttempts,
      successRate: successRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'practiced_at': practicedAt.toIso8601String(),
      'correct_count': correctCount,
      'total_attempts': totalAttempts,
      'success_rate': successRate,
    };
  }

  PracticeHistoryItem copyWith({
    String? id,
    String? word,
    DateTime? practicedAt,
    int? correctCount,
    int? totalAttempts,
    double? successRate,
  }) {
    return PracticeHistoryItem(
      id: id ?? this.id,
      word: word ?? this.word,
      practicedAt: practicedAt ?? this.practicedAt,
      correctCount: correctCount ?? this.correctCount,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      successRate: successRate ?? this.successRate,
    );
  }
}
