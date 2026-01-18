/// Student profile model
/// Represents the student's onboarding data stored in Supabase
class StudentProfile {
  final String id;
  final String userId;
  final String studentName;
  final String schoolName;
  final String grade;
  final String city;
  final String state;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudentProfile({
    required this.id,
    required this.userId,
    required this.studentName,
    required this.schoolName,
    required this.grade,
    required this.city,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Supabase JSON response
  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      studentName: json['student_name'] as String,
      schoolName: json['school_name'] as String,
      grade: json['grade'] as String,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'student_name': studentName,
      'school_name': schoolName,
      'grade': grade,
      'city': city,
      'state': state,
    };
  }

  /// Copy with updated fields
  StudentProfile copyWith({
    String? id,
    String? userId,
    String? studentName,
    String? schoolName,
    String? grade,
    String? city,
    String? state,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studentName: studentName ?? this.studentName,
      schoolName: schoolName ?? this.schoolName,
      grade: grade ?? this.grade,
      city: city ?? this.city,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
