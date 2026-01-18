import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/vocabulary_word.dart';
import '../domain/practice_question.dart';
import '../domain/practice_history_item.dart';

/// State for vocabulary learning flow
class VocabularyState {
  final List<VocabularyWord> words;
  final int currentWordIndex;
  final List<PracticeHistoryItem> practiceHistory;
  final int totalPracticedThisMonth;
  final bool isLoading;
  final String? error;

  const VocabularyState({
    this.words = const [],
    this.currentWordIndex = 0,
    this.practiceHistory = const [],
    this.totalPracticedThisMonth = 0,
    this.isLoading = false,
    this.error,
  });

  VocabularyWord? get currentWord =>
      words.isNotEmpty && currentWordIndex < words.length
          ? words[currentWordIndex]
          : null;

  bool get hasNextWord => currentWordIndex < words.length - 1;
  bool get hasPreviousWord => currentWordIndex > 0;

  VocabularyState copyWith({
    List<VocabularyWord>? words,
    int? currentWordIndex,
    List<PracticeHistoryItem>? practiceHistory,
    int? totalPracticedThisMonth,
    bool? isLoading,
    String? error,
  }) {
    return VocabularyState(
      words: words ?? this.words,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      practiceHistory: practiceHistory ?? this.practiceHistory,
      totalPracticedThisMonth:
          totalPracticedThisMonth ?? this.totalPracticedThisMonth,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Vocabulary state notifier
class VocabularyNotifier extends StateNotifier<VocabularyState> {
  VocabularyNotifier() : super(const VocabularyState()) {
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load mock data for now
    final mockWords = _generateMockWords();
    final mockHistory = _generateMockHistory();

    state = state.copyWith(
      words: mockWords,
      practiceHistory: mockHistory,
      totalPracticedThisMonth: 200,
    );
  }

  List<VocabularyWord> _generateMockWords() {
    final words = [
      'Resilience',
      'Empathy',
      'Mindful',
      'Persevere',
      'Routine',
      'Gratitude',
      'Compassion',
      'Patience',
      'Courage',
      'Wisdom',
      'Harmony',
      'Balance',
      'Focus',
      'Clarity',
      'Strength',
      'Growth',
      'Peace',
      'Joy',
      'Hope',
      'Trust',
      'Faith',
      'Love',
      'Kindness',
      'Grace',
      'Serenity',
    ];

    return List.generate(
      words.length,
      (index) => VocabularyWord(
        id: 'word_$index',
        word: words[index],
        meaning: _getMeaningForWord(words[index]),
        pronunciation: _getPronunciationForWord(words[index]),
        contextExamples: _getContextExamples(words[index]),
        exampleSentences: _getExampleSentences(words[index]),
        wordIndex: index + 1,
        totalWords: words.length,
        isPracticed: index < 5,
        lastPracticedAt: index < 5 ? DateTime.now().subtract(Duration(days: index)) : null,
      ),
    );
  }

  String _getMeaningForWord(String word) {
    final meanings = {
      'Resilience': 'The ability to be happy, successful, etc. again after something difficult or bad has happened.',
      'Empathy': 'The ability to understand and share the feelings of another person.',
      'Mindful': 'Being conscious or aware of something; paying careful attention.',
      'Persevere': 'To continue trying to do something despite difficulties.',
      'Routine': 'A regular way of doing things in a particular order.',
    };
    return meanings[word] ?? 'A meaningful word for personal growth and well-being.';
  }

  String _getPronunciationForWord(String word) {
    final pronunciations = {
      'Resilience': 'rih-ZIL-yuhns',
      'Empathy': 'EM-puh-thee',
      'Mindful': 'MAHYND-fuhl',
      'Persevere': 'pur-suh-VEER',
      'Routine': 'roo-TEEN',
    };
    return pronunciations[word] ?? word.toLowerCase();
  }

  List<String> _getContextExamples(String word) {
    final examples = {
      'Resilience': [
        '"Resilience helps us handle problems better"',
        '"She showed resilience after failing the test."',
      ],
      'Empathy': [
        '"Empathy allows us to connect with others"',
        '"He showed empathy by listening to her concerns."',
      ],
    };
    return examples[word] ?? [
      '"$word is important for personal growth"',
      '"Practice $word in your daily life."',
    ];
  }

  List<String> _getExampleSentences(String word) {
    return _getContextExamples(word);
  }

  List<PracticeHistoryItem> _generateMockHistory() {
    final words = ['Routine', 'Empathy', 'Mindful', 'Persevere'];
    return List.generate(
      words.length * 3,
      (index) => PracticeHistoryItem(
        id: 'history_$index',
        word: words[index % words.length],
        practicedAt: DateTime.now().subtract(Duration(days: index)),
        correctCount: 3,
        totalAttempts: 4,
        successRate: 0.75,
      ),
    );
  }

  void nextWord() {
    if (state.hasNextWord) {
      state = state.copyWith(currentWordIndex: state.currentWordIndex + 1);
    }
  }

  void previousWord() {
    if (state.hasPreviousWord) {
      state = state.copyWith(currentWordIndex: state.currentWordIndex - 1);
    }
  }

  void setWordIndex(int index) {
    if (index >= 0 && index < state.words.length) {
      state = state.copyWith(currentWordIndex: index);
    }
  }
  
  void markWordAsLearned(String wordId) {
    // Same as markWordAsPracticed - marks word as learned/practiced
    markWordAsPracticed(wordId);
  }

  void markWordAsPracticed(String wordId) {
    final updatedWords = state.words.map((word) {
      if (word.id == wordId) {
        return word.copyWith(
          isPracticed: true,
          lastPracticedAt: DateTime.now(),
        );
      }
      return word;
    }).toList();

    state = state.copyWith(words: updatedWords);
  }
}

/// Provider for vocabulary state
final vocabularyProvider =
    StateNotifierProvider<VocabularyNotifier, VocabularyState>((ref) {
  return VocabularyNotifier();
});

/// Provider for practice questions
final practiceQuestionsProvider = Provider<List<PracticeQuestion>>((ref) {
  // Generate mock practice questions
  return _generateMockQuestions();
});

List<PracticeQuestion> _generateMockQuestions() {
  final questions = [
    {
      'sentence': 'She showed great resilience in finishing the race.',
      'answer': 'resilience',
      'blank': 3,
      'options': ['speed', 'strength', 'resilience'],
    },
    {
      'sentence': 'His empathy made everyone feel understood.',
      'answer': 'empathy',
      'blank': 1,
      'options': ['anger', 'empathy', 'confusion'],
    },
    {
      'sentence': 'Being mindful helps reduce daily stress.',
      'answer': 'mindful',
      'blank': 1,
      'options': ['careless', 'mindful', 'rushed'],
    },
    {
      'sentence': 'You must persevere through difficult times.',
      'answer': 'persevere',
      'blank': 2,
      'options': ['quit', 'persevere', 'avoid'],
    },
    {
      'sentence': 'A morning routine sets a positive tone.',
      'answer': 'routine',
      'blank': 2,
      'options': ['chaos', 'routine', 'surprise'],
    },
  ];

  return List.generate(
    20,
    (index) {
      final q = questions[index % questions.length];
      return PracticeQuestion(
        id: 'question_$index',
        sentence: q['sentence'] as String,
        correctAnswer: q['answer'] as String,
        options: q['options'] as List<String>,
        blankPosition: q['blank'] as int,
        emoji: ['😊', '🌟', '💪', '🎯', '✨'][index % 5],
        questionIndex: index + 1,
        totalQuestions: 20,
      );
    },
  );
}
