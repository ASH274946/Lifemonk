import 'practice_sentence_model.dart';

/// Sentence Generator Service
/// Generates practice sentences for vocabulary words
class SentenceGenerator {
  /// Generate practice sentences for a given word
  static List<PracticeSentence> generateSentences(String word, String definition) {
    // For now, use predefined templates based on common words
    // This can be extended with AI generation or a larger database
    
    final wordLower = word.toLowerCase();
    
    // Try to find predefined sentences for this word
    if (_sentenceDatabase.containsKey(wordLower)) {
      return _sentenceDatabase[wordLower]!;
    }
    
    // Generate generic sentences if word not in database
    return _generateGenericSentences(word, definition);
  }

  static List<PracticeSentence> _generateGenericSentences(String word, String definition) {
    return [
      PracticeSentence(
        sentenceTemplate: 'The concept of {blank} is important in this context.',
        correctAnswer: word,
        distractors: ['understanding', 'knowledge'],
        fullSentence: 'The concept of $word is important in this context.',
      ),
      PracticeSentence(
        sentenceTemplate: 'She demonstrated great {blank} throughout the process.',
        correctAnswer: word,
        distractors: ['effort', 'skill'],
        fullSentence: 'She demonstrated great $word throughout the process.',
      ),
      PracticeSentence(
        sentenceTemplate: 'His {blank} was evident in everything he did.',
        correctAnswer: word,
        distractors: ['dedication', 'passion'],
        fullSentence: 'His $word was evident in everything he did.',
      ),
    ];
  }

  // Database of predefined sentences for common words
  static final Map<String, List<PracticeSentence>> _sentenceDatabase = {
    'resilience': [
      PracticeSentence(
        sentenceTemplate: 'She showed great {blank} in finishing the race.',
        correctAnswer: 'resilience',
        distractors: ['strength', 'speed'],
        fullSentence: 'She showed great resilience in finishing the race.',
      ),
      PracticeSentence(
        sentenceTemplate: 'The hiker\'s {blank} helped him reach the summit.',
        correctAnswer: 'resilience',
        distractors: ['fear', 'doubt'],
        fullSentence: 'The hiker\'s resilience helped him reach the summit.',
      ),
      PracticeSentence(
        sentenceTemplate: 'Her {blank} inspired everyone around her.',
        correctAnswer: 'resilience',
        distractors: ['weakness', 'hesitation'],
        fullSentence: 'Her resilience inspired everyone around her.',
      ),
    ],
    'persistence': [
      PracticeSentence(
        sentenceTemplate: 'His {blank} paid off when he finally succeeded.',
        correctAnswer: 'persistence',
        distractors: ['laziness', 'doubt'],
        fullSentence: 'His persistence paid off when he finally succeeded.',
      ),
      PracticeSentence(
        sentenceTemplate: 'The scientist\'s {blank} led to a breakthrough.',
        correctAnswer: 'persistence',
        distractors: ['confusion', 'fear'],
        fullSentence: 'The scientist\'s persistence led to a breakthrough.',
      ),
      PracticeSentence(
        sentenceTemplate: 'Through {blank}, she mastered the skill.',
        correctAnswer: 'persistence',
        distractors: ['giving up', 'avoiding'],
        fullSentence: 'Through persistence, she mastered the skill.',
      ),
    ],
    'eloquent': [
      PracticeSentence(
        sentenceTemplate: 'The speaker was very {blank} in her presentation.',
        correctAnswer: 'eloquent',
        distractors: ['confused', 'quiet'],
        fullSentence: 'The speaker was very eloquent in her presentation.',
      ),
      PracticeSentence(
        sentenceTemplate: 'His {blank} words moved the audience.',
        correctAnswer: 'eloquent',
        distractors: ['harsh', 'simple'],
        fullSentence: 'His eloquent words moved the audience.',
      ),
      PracticeSentence(
        sentenceTemplate: 'She gave an {blank} speech at the ceremony.',
        correctAnswer: 'eloquent',
        distractors: ['awkward', 'boring'],
        fullSentence: 'She gave an eloquent speech at the ceremony.',
      ),
    ],
  };
}
