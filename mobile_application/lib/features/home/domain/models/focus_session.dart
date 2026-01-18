/// Focus session model (e.g., Breathing exercise)
class FocusSession {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final String iconType;
  final bool isActive;

  const FocusSession({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.iconType,
    this.isActive = true,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 5,
      iconType: json['icon_type'] as String? ?? 'meditation',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration_minutes': durationMinutes,
      'icon_type': iconType,
      'is_active': isActive,
    };
  }

  String get durationText => '$durationMinutes min session';
}
