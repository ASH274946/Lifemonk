import 'package:flutter/material.dart';

/// Learning category model for "Your Plan" section
class LearningCategory {
  final String id;
  final String title;
  final String iconType;
  final int lessonCount;
  final Color? iconColor;
  final Color? iconBgColor;
  final int sortOrder;
  final bool isActive;

  const LearningCategory({
    required this.id,
    required this.title,
    required this.iconType,
    required this.lessonCount,
    this.iconColor,
    this.iconBgColor,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory LearningCategory.fromJson(Map<String, dynamic> json) {
    return LearningCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      iconType: json['icon_type'] as String? ?? 'book',
      lessonCount: json['lesson_count'] as int? ?? 0,
      iconColor: json['icon_color'] != null
          ? Color(int.parse(json['icon_color'] as String, radix: 16))
          : null,
      iconBgColor: json['icon_bg_color'] != null
          ? Color(int.parse(json['icon_bg_color'] as String, radix: 16))
          : null,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon_type': iconType,
      'lesson_count': lessonCount,
      'icon_color': iconColor?.toARGB32().toRadixString(16),
      'icon_bg_color': iconBgColor?.toARGB32().toRadixString(16),
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  String get lessonCountText => '$lessonCount LESSONS';
}
