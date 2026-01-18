/// Workshop model for upcoming workshops
class Workshop {
  final String id;
  final String title;
  final DateTime dateTime;
  final String? imageUrl;
  final int participantCount;
  final List<String> participantAvatars;
  final bool isEnrolled;
  final bool isActive;

  const Workshop({
    required this.id,
    required this.title,
    required this.dateTime,
    this.imageUrl,
    this.participantCount = 0,
    this.participantAvatars = const [],
    this.isEnrolled = false,
    this.isActive = true,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['id'] as String,
      title: json['title'] as String,
      dateTime: DateTime.parse(json['date_time'] as String),
      imageUrl: json['image_url'] as String?,
      participantCount: json['participant_count'] as int? ?? 0,
      participantAvatars: (json['participant_avatars'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isEnrolled: json['is_enrolled'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date_time': dateTime.toIso8601String(),
      'image_url': imageUrl,
      'participant_count': participantCount,
      'participant_avatars': participantAvatars,
      'is_enrolled': isEnrolled,
      'is_active': isActive,
    };
  }

  /// Format date for display (e.g., "Oct 24, 4:00 PM")
  String get formattedDateTime {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $hour:$minute $period';
  }
}
