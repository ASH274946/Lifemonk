/// Fill-in-the-blank practice question model
class PracticeQuestion {
  final String id;
  final String sentence;
  final String correctAnswer;
  final List<String> options;
  final int blankPosition;
  final String emoji;
  final int questionIndex;
  final int totalQuestions;

  const PracticeQuestion({
    required this.id,
    required this.sentence,
    required this.correctAnswer,
    required this.options,
    required this.blankPosition,
    this.emoji = '😊',
    required this.questionIndex,
    required this.totalQuestions,
  });

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) {
    return PracticeQuestion(
      id: json['id'] as String,
      sentence: json['sentence'] as String,
      correctAnswer: json['correct_answer'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      blankPosition: json['blank_position'] as int? ?? 0,
      emoji: json['emoji'] as String? ?? '😊',
      questionIndex: json['question_index'] as int? ?? 1,
      totalQuestions: json['total_questions'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sentence': sentence,
      'correct_answer': correctAnswer,
      'options': options,
      'blank_position': blankPosition,
      'emoji': emoji,
      'question_index': questionIndex,
      'total_questions': totalQuestions,
    };
  }

  /// Get the sentence with a blank placeholder
  String get sentenceWithBlank {
    final words = sentence.split(' ');
    if (blankPosition >= 0 && blankPosition < words.length) {
      words[blankPosition] = '_____';
    }
    return words.join(' ');
  }

  /// Get the part of sentence before the blank
  String get beforeBlank {
    final words = sentence.split(' ');
    if (blankPosition > 0) {
      return '${words.sublist(0, blankPosition).join(' ')} ';
    }
    return '';
  }

  /// Get the part of sentence after the blank
  String get afterBlank {
    final words = sentence.split(' ');
    if (blankPosition < words.length - 1) {
      return ' ${words.sublist(blankPosition + 1).join(' ')}';
    }
    return '';
  }
}
