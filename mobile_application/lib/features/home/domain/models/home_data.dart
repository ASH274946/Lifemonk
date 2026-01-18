import 'models.dart';

/// Combined home screen data model
class HomeData {
  final UserProfile? userProfile;
  final FocusSession? focusSession;
  final Workshop? upcomingWorkshop;
  final WordOfDay? wordOfDay;
  final List<LearningCategory> categories;
  final bool isLoading;
  final String? error;

  const HomeData({
    this.userProfile,
    this.focusSession,
    this.upcomingWorkshop,
    this.wordOfDay,
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  HomeData copyWith({
    UserProfile? userProfile,
    FocusSession? focusSession,
    Workshop? upcomingWorkshop,
    WordOfDay? wordOfDay,
    List<LearningCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return HomeData(
      userProfile: userProfile ?? this.userProfile,
      focusSession: focusSession ?? this.focusSession,
      upcomingWorkshop: upcomingWorkshop ?? this.upcomingWorkshop,
      wordOfDay: wordOfDay ?? this.wordOfDay,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Check if all data is loaded
  bool get hasData =>
      userProfile != null &&
      focusSession != null &&
      upcomingWorkshop != null &&
      wordOfDay != null &&
      categories.isNotEmpty;
}
