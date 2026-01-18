class CmsCategory {
  final String id;
  final String title;
  final String iconType;
  final int lessonCount;
  final String iconColor;
  final bool visible;
  final int order;

  CmsCategory({
    required this.id,
    required this.title,
    required this.iconType,
    required this.lessonCount,
    required this.iconColor,
    required this.visible,
    required this.order,
  });
}

class CmsCourse {
  final String id;
  final String title;
  final String description;
  final String coverImageUrl;
  final List<CmsChapter> chapters;
  final List<CmsByte> bytes;
  final bool quizAvailable;
  final double progress; // 0.0 to 1.0

  CmsCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.chapters,
    required this.bytes,
    required this.quizAvailable,
    this.progress = 0.0,
  });
}

class CmsChapter {
  final String id;
  final String title;
  final String summary;
  final int duration; // in minutes
  final String videoUrl;
  final bool watched;
  final int xp;
  final List<String> prerequisites;
  final List<String> outcomes;
  final List<CmsByte> relatedBytes;
  final int orderNumber;

  bool get unlocked => prerequisites.isEmpty; // Simple logic for now, can be expanded
  bool get isCurrentlyWatching => !watched; // logic placeholder

  CmsChapter({
    required this.id,
    required this.title,
    required this.summary,
    this.duration = 0,
    this.videoUrl = '',
    this.watched = false,
    this.xp = 0,
    this.prerequisites = const [],
    this.outcomes = const [],
    this.relatedBytes = const [],
    this.orderNumber = 0,
  });

  // CopyWith for state updates
  CmsChapter copyWith({
    bool? watched,
  }) {
    return CmsChapter(
      id: id,
      title: title,
      summary: summary,
      duration: duration,
      videoUrl: videoUrl,
      watched: watched ?? this.watched,
      xp: xp,
      prerequisites: prerequisites,
      outcomes: outcomes,
      relatedBytes: relatedBytes,
      orderNumber: orderNumber,
    );
  }
}

class CmsByte {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final List<String> tags;
  final int order;
  final bool visible;
  final String duration; // e.g. "5 min"
  final bool watched;

  const CmsByte({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.tags,
    required this.order,
    required this.visible,
    this.duration = '0 min',
    this.watched = false,
  });

  CmsByte copyWith({bool? watched}) {
    return CmsByte(
      id: id,
      title: title,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      tags: tags,
      order: order,
      visible: visible,
      duration: duration,
      watched: watched ?? this.watched,
    );
  }
}

class CmsPlanSubject {
  final String id;
  final String title;
  final double progress; // 0..1
  final String colorHex;

  CmsPlanSubject({
    required this.id,
    required this.title,
    required this.progress,
    required this.colorHex,
  });
}

class CmsWorkshop {
  final String id;
  final String title;
  final String instructor;
  final DateTime dateTime;
  final String description;
  final bool enrolled;
  final int enrollmentPercentage;
  final String imageUrl;
  final String category;
  final int durationMinutes;
  final String type; // 'Offline', 'Zoom Online', 'Youtube Live'
  final String? videoUrl;

  CmsWorkshop({
    required this.id,
    required this.title,
    required this.instructor,
    required this.dateTime,
    required this.description,
    required this.enrolled,
    required this.enrollmentPercentage,
    required this.imageUrl,
    required this.category,
    required this.durationMinutes,
    this.type = 'Zoom Online',
    this.videoUrl,
  });

  CmsWorkshop copyWith({
    String? id,
    String? title,
    String? instructor,
    DateTime? dateTime,
    String? description,
    bool? enrolled,
    int? enrollmentPercentage,
    String? imageUrl,
    String? category,
    int? durationMinutes,
    String? type,
    String? videoUrl,
  }) {
    return CmsWorkshop(
      id: id ?? this.id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      dateTime: dateTime ?? this.dateTime,
      description: description ?? this.description,
      enrolled: enrolled ?? this.enrolled,
      enrollmentPercentage: enrollmentPercentage ?? this.enrollmentPercentage,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      type: type ?? this.type,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
