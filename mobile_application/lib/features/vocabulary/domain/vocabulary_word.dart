/// Extended vocabulary word model for the Word of the Day learning flow
class VocabularyWord {
  final String id;
  final String word;
  final String meaning;
  final String? pronunciation;
  final List<String> contextExamples;
  final List<String> exampleSentences;
  final int wordIndex;
  final int totalWords;
  final bool isPracticed;
  final DateTime? lastPracticedAt;

  const VocabularyWord({
    required this.id,
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.contextExamples = const [],
    this.exampleSentences = const [],
    required this.wordIndex,
    required this.totalWords,
    this.isPracticed = false,
    this.lastPracticedAt,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] as String,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      pronunciation: json['pronunciation'] as String?,
      contextExamples: (json['context_examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      exampleSentences: (json['example_sentences'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      wordIndex: json['word_index'] as int? ?? 1,
      totalWords: json['total_words'] as int? ?? 25,
      isPracticed: json['is_practiced'] as bool? ?? false,
      lastPracticedAt: json['last_practiced_at'] != null
          ? DateTime.parse(json['last_practiced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'pronunciation': pronunciation,
      'context_examples': contextExamples,
      'example_sentences': exampleSentences,
      'word_index': wordIndex,
      'total_words': totalWords,
      'is_practiced': isPracticed,
      'last_practiced_at': lastPracticedAt?.toIso8601String(),
    };
  }

  VocabularyWord copyWith({
    String? id,
    String? word,
    String? meaning,
    String? pronunciation,
    List<String>? contextExamples,
    List<String>? exampleSentences,
    int? wordIndex,
    int? totalWords,
    bool? isPracticed,
    DateTime? lastPracticedAt,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      pronunciation: pronunciation ?? this.pronunciation,
      contextExamples: contextExamples ?? this.contextExamples,
      exampleSentences: exampleSentences ?? this.exampleSentences,
      wordIndex: wordIndex ?? this.wordIndex,
      totalWords: totalWords ?? this.totalWords,
      isPracticed: isPracticed ?? this.isPracticed,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
    );
  }
}
