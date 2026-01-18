/// Workshop model - Maps directly from CMS data
/// Each field corresponds to CMS fields for seamless API integration
class Workshop {
  final String id;
  final String title;
  final String description;
  final String category; // From CMS: "Communication", "Confidence", etc.
  final DateTime startTime; // From CMS: date & time
  final int duration; // Minutes
  final String ageGroup; // From CMS: "8-14 Years", etc.
  final WorkshopStatus status; // From CMS: "upcoming", "starting_soon", "completed"
  final List<String> outcomes; // From CMS: learning outcomes (bullet points)
  final WorkshopMentor? mentor; // From CMS: mentor details (optional)
  final bool isJoinEnabled; // From CMS: enrollment availability
  final int participantCount; // For display only
  final bool isEnrolled; // Whether the user is enrolled
  final String? imageUrl; // Workshop-specific image

  const Workshop({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startTime,
    required this.duration,
    required this.ageGroup,
    required this.status,
    required this.outcomes,
    this.mentor,
    required this.isJoinEnabled,
    this.participantCount = 0,
    this.isEnrolled = false,
    this.imageUrl,
  });

  /// Format duration as "60 Minutes" or "2 Hours"
  String get formattedDuration {
    if (duration < 60) {
      return '$duration Minutes';
    } else {
      final hours = duration ~/ 60;
      final mins = duration % 60;
      if (mins == 0) {
        return '$hours ${hours == 1 ? 'Hour' : 'Hours'}';
      } else {
        return '$hours ${hours == 1 ? 'Hour' : 'Hours'} $mins Minutes';
      }
    }
  }

  /// Format date as "Oct 25, 2026"
  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[startTime.month - 1]} ${startTime.day}, ${startTime.year}';
  }

  /// Format time as "5:00 PM IST"
  String get formattedTime {
    final hour = startTime.hour == 0
        ? 12
        : (startTime.hour > 12 ? startTime.hour - 12 : startTime.hour);
    final minute = startTime.minute.toString().padLeft(2, '0');
    final period = startTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period IST';
  }

  /// Copy with method for state updates
  Workshop copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? startTime,
    int? duration,
    String? ageGroup,
    WorkshopStatus? status,
    List<String>? outcomes,
    WorkshopMentor? mentor,
    bool? isJoinEnabled,
    int? participantCount,
    bool? isEnrolled,
    String? imageUrl,
  }) {
    return Workshop(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      ageGroup: ageGroup ?? this.ageGroup,
      status: status ?? this.status,
      outcomes: outcomes ?? this.outcomes,
      mentor: mentor ?? this.mentor,
      isJoinEnabled: isJoinEnabled ?? this.isJoinEnabled,
      participantCount: participantCount ?? this.participantCount,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Workshop mentor information
class WorkshopMentor {
  final String name;
  final String role;
  final String? avatarUrl;
  final String? bio;

  const WorkshopMentor({
    required this.name,
    required this.role,
    this.avatarUrl,
    this.bio,
  });
}

enum WorkshopStatus {
  upcoming,
  startingSoon,
  completed;

  /// Convert from CMS string value
  static WorkshopStatus fromString(String value) {
    return WorkshopStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => WorkshopStatus.upcoming,
    );
  }

  String get displayText {
    switch (this) {
      case WorkshopStatus.upcoming:
        return 'UPCOMING';
      case WorkshopStatus.startingSoon:
        return 'STARTING SOON';
      case WorkshopStatus.completed:
        return 'COMPLETED';
    }
  }

  /// Get badge color for the status
  (String background, String text) get badgeColors {
    switch (this) {
      case WorkshopStatus.upcoming:
        return ('#E0F2FE', '#0369A1'); // Light blue
      case WorkshopStatus.startingSoon:
        return ('#FEF3C7', '#A16207'); // Light yellow
      case WorkshopStatus.completed:
        return ('#F3F4F6', '#6B7280'); // Gray
    }
  }
}

/// Mock workshop data for development
class MockWorkshops {
  static final List<Workshop> workshops = [
    Workshop(
      id: 'w1',
      title: 'Confidence Building',
      description:
          'Learn practical strategies to overcome self-doubt and shine in any situation.',
      category: 'Confidence',
      startTime: DateTime(2026, 10, 15, 16, 0),
      duration: 60,
      ageGroup: '8-14 Years',
      status: WorkshopStatus.upcoming,
      outcomes: [
        'Build self-confidence through proven techniques',
        'Overcome fear and self-doubt',
        'Present yourself with confidence',
        'Handle challenges with a positive mindset',
      ],
      mentor: const WorkshopMentor(
        name: 'Sarah Johnson',
        role: 'Life Coach & Mentor',
        bio: 'Over 10 years helping teens build confidence',
      ),
      isJoinEnabled: true,
      participantCount: 34,
      imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800',
    ),
  ];

  static Workshop? getById(String id) {
    try {
      return workshops.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Workshop>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return workshops;
  }

  static Future<List<Workshop>> getUpcoming() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return workshops
        .where((w) => w.status != WorkshopStatus.completed)
        .toList();
  }
}
