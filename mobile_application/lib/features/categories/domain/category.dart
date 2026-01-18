/// Category model representing a learning category
class Category {
  final String id;
  final String title;
  final String iconType; // Icon identifier (e.g., 'geography', 'cognitive', 'math')
  final int lessonCount;
  final String iconColor; // Hex color for icon background

  const Category({
    required this.id,
    required this.title,
    required this.iconType,
    required this.lessonCount,
    required this.iconColor,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      title: json['title'] as String,
      iconType: json['icon_type'] as String,
      lessonCount: json['lesson_count'] as int,
      iconColor: json['icon_color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon_type': iconType,
      'lesson_count': lessonCount,
      'icon_color': iconColor,
    };
  }
}
