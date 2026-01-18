/// Practice Sentence Model
/// Represents a single sentence practice exercise
class PracticeSentence {
  final String sentenceTemplate; // e.g., "She showed great {blank} in finishing the race"
  final String correctAnswer;
  final List<String> distractors; // 2 incorrect options
  final String fullSentence; // Complete sentence for reference

  const PracticeSentence({
    required this.sentenceTemplate,
    required this.correctAnswer,
    required this.distractors,
    required this.fullSentence,
  });

  /// Get all options shuffled
  List<String> get allOptions {
    final options = [correctAnswer, ...distractors];
    options.shuffle();
    return options;
  }

  /// Get sentence with blank placeholder
  String get sentenceWithBlank {
    return sentenceTemplate.replaceAll('{blank}', '____');
  }
}
