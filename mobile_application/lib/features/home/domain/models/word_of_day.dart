/// Word of the Day model
class WordOfDay {
  final String id;
  final String word;
  final String meaning;
  final String? pronunciation;
  final String? example;
  final DateTime date;
  final bool isActive;

  const WordOfDay({
    required this.id,
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.example,
    required this.date,
    this.isActive = true,
  });

  factory WordOfDay.fromJson(Map<String, dynamic> json) {
    return WordOfDay(
      id: json['id'] as String,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      pronunciation: json['pronunciation'] as String?,
      example: json['example'] as String?,
      date: DateTime.parse(json['date'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'pronunciation': pronunciation,
      'example': example,
      'date': date.toIso8601String(),
      'is_active': isActive,
    };
  }
}
