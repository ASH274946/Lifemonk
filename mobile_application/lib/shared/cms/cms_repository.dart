import 'package:flutter/foundation.dart';

import 'models.dart';

/// Abstract repository describing the CMS contract.
/// Replace this with a real implementation (Supabase/Firestore/Headless CMS)
/// without changing UI code.
abstract class CmsRepository {
  Future<List<CmsCategory>> getCategories();
  Future<CmsCourse> getCourseById(String courseId);
  Future<List<CmsByte>> getBytesFeed({String? categoryId});
  Future<List<CmsPlanSubject>> getPlan();
  Future<List<CmsWorkshop>> getWorkshops();
  
  // Learning State Mutations (Mock DB)
  Future<void> markChapterComplete(String courseId, String chapterId);
  Future<void> markByteWatched(String byteId);
  Future<void> saveLastViewedChapter(String courseId, String chapterId);
  Future<String?> getLastViewedChapter(String courseId);
  Future<int> getUserXp();
}

/// Simple mock implementation used during development.
class MockCmsRepository implements CmsRepository {
  @override
  Future<List<CmsCategory>> getCategories() async {
    return SynchronousFuture<List<CmsCategory>>([
      CmsCategory(
        id: 'vedic',
        title: 'Vedic Maths',
        iconType: 'mathematics',
        lessonCount: 28,
        iconColor: '#9DB8FF',
        visible: true,
        order: 1,
      ),
      CmsCategory(
        id: 'geo',
        title: 'Geography',
        iconType: 'geography',
        lessonCount: 24,
        iconColor: '#4A90E2',
        visible: true,
        order: 2,
      ),
      CmsCategory(
        id: 'cog',
        title: 'Cognitive Skills',
        iconType: 'cognitive',
        lessonCount: 18,
        iconColor: '#A855F7',
        visible: true,
        order: 3,
      ),
      CmsCategory(
        id: 'math',
        title: 'Applied Maths',
        iconType: 'mathematics',
        lessonCount: 32,
        iconColor: '#F97316',
        visible: true,
        order: 4,
      ),
      CmsCategory(
        id: 'arts',
        title: 'Creative Arts',
        iconType: 'creative',
        lessonCount: 15,
        iconColor: '#10B981',
        visible: true,
        order: 5,
      ),
      CmsCategory(
        id: 'science',
        title: 'Discovery & Science',
        iconType: 'discovery',
        lessonCount: 22,
        iconColor: '#EC4899',
        visible: true,
        order: 6,
      ),
      CmsCategory(
        id: 'lang',
        title: 'Languages',
        iconType: 'languages',
        lessonCount: 20,
        iconColor: '#8B5CF6',
        visible: true,
        order: 7,
      ),
    ]);
  }

  @override
  Future<CmsCourse> getCourseById(String courseId) async {
    // Return different course content based on category ID
    switch (courseId) {
      case 'vedic':
        return SynchronousFuture<CmsCourse>(CmsCourse(
          id: courseId,
          title: 'Vedic Maths Mastery',
          description: 'Ancient calculation techniques for modern problem-solving',
          coverImageUrl: '',
          chapters: [
            CmsChapter(
              id: 'v1', 
              title: 'Chapter 1: Multiplication Tricks', 
              summary: 'Master fast multiplication methods',
              duration: 15,
              videoUrl: 'https://example.com/v1.mp4',
              watched: true,
              xp: 50,
              orderNumber: 0,
              outcomes: ['Speed Math', 'Mental Calculation'],
            ),
            CmsChapter(
              id: 'v2', 
              title: 'Chapter 2: Square Numbers', 
              summary: 'Quick squaring techniques',
              duration: 20,
              videoUrl: 'https://example.com/v2.mp4',
              watched: false,
              xp: 50,
              orderNumber: 1,
              prerequisites: ['v1'],
            ),
            CmsChapter(
              id: 'v3', 
              title: 'Chapter 3: Division Shortcuts', 
              summary: 'Simplified division methods',
              duration: 25,
              videoUrl: 'https://example.com/v3.mp4',
              watched: false,
              xp: 60,
              orderNumber: 2,
            ),
            CmsChapter(
              id: 'v4', 
              title: 'Chapter 4: Mental Calculations', 
              summary: 'Boost your mental math speed',
              duration: 30,
              videoUrl: 'https://example.com/v4.mp4',
              watched: false,
              xp: 70,
              orderNumber: 3,
            ),
          ],
          bytes: [
            CmsByte(
              id: 'vb1',
              title: '9s Multiplication Trick',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/vedic1.mp4',
              tags: const ['vedic', 'multiplication'],
              order: 1,
              visible: true,
              duration: '2 min',
              watched: true,
            ),
            CmsByte(
              id: 'vb2',
              title: 'Squaring Numbers ending in 5',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/vedic2.mp4',
              tags: const ['vedic', 'squares'],
              order: 2,
              visible: true,
              duration: '3 min',
            ),
          ],
          quizAvailable: true,
        ));

      case 'geo':
        return SynchronousFuture<CmsCourse>(CmsCourse(
          id: courseId,
          title: 'World Geography Explorer',
          description: 'Discover continents, countries, and cultures around the world',
          coverImageUrl: '',
          chapters: [
            CmsChapter(id: 'g1', title: 'Chapter 1: Continents & Oceans', summary: 'Learn about the seven continents'),
            CmsChapter(id: 'g2', title: 'Chapter 2: Countries & Capitals', summary: 'Major countries and their capitals'),
            CmsChapter(id: 'g3', title: 'Chapter 3: Landforms', summary: 'Mountains, rivers, and natural wonders'),
            CmsChapter(id: 'g4', title: 'Chapter 4: Climate Zones', summary: 'Understanding weather patterns'),
          ],
          bytes: [
            CmsByte(
              id: 'gb1',
              title: 'Seven Continents Song',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/geo1.mp4',
              tags: const ['geography', 'continents'],
              order: 1,
              visible: true,
            ),
            CmsByte(
              id: 'gb2',
              title: 'World Capitals Quiz',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/geo2.mp4',
              tags: const ['geography', 'capitals'],
              order: 2,
              visible: true,
            ),
          ],
          quizAvailable: true,
        ));

      case 'cog':
        return SynchronousFuture<CmsCourse>(CmsCourse(
          id: courseId,
          title: 'Cognitive Skills Builder',
          description: 'Enhance memory, focus, and problem-solving abilities',
          coverImageUrl: '',
          chapters: [
            CmsChapter(id: 'c1', title: 'Chapter 1: Memory Techniques', summary: 'Boost your memory power'),
            CmsChapter(id: 'c2', title: 'Chapter 2: Pattern Recognition', summary: 'Identify and solve patterns'),
            CmsChapter(id: 'c3', title: 'Chapter 3: Logical Thinking', summary: 'Develop reasoning skills'),
            CmsChapter(id: 'c4', title: 'Chapter 4: Focus & Concentration', summary: 'Improve attention span'),
          ],
          bytes: [
            CmsByte(
              id: 'cb1',
              title: 'Memory Palace Technique',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/cog1.mp4',
              tags: const ['cognitive', 'memory'],
              order: 1,
              visible: true,
            ),
            CmsByte(
              id: 'cb2',
              title: 'Pattern Puzzle Challenge',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/cog2.mp4',
              tags: const ['cognitive', 'patterns'],
              order: 2,
              visible: true,
            ),
          ],
          quizAvailable: true,
        ));

      case 'math':
        return SynchronousFuture<CmsCourse>(CmsCourse(
          id: courseId,
          title: 'Applied Mathematics',
          description: 'Master mathematical concepts used in real-world applications and problems.',
          coverImageUrl: '',
          progress: _completedChapters.intersection({'m1', 'm2', 'm3'}).length / 3, // Dynamic progress
          chapters: [
            CmsChapter(
              id: 'm1',
              title: 'Basics of Algebra',
              summary: 'Learn fundamental algebra concepts',
              duration: 45,
              watched: _completedChapters.contains('m1'),
              xp: 100,
              orderNumber: 0,
              videoUrl: 'https://example.com/math1.mp4',
              outcomes: [
                'Understand variables and constants',
                'Solve linear equations',
                'Graphing linear functions',
              ],
              relatedBytes: [
                 CmsByte(
                  id: 'mb1',
                  title: 'Quick Algebra Tips',
                  thumbnailUrl: '',
                  videoUrl: 'https://example.com/byte1.mp4',
                  tags: ['math', 'algebra'],
                  order: 1,
                  visible: true,
                  duration: '8 min',
                  watched: _watchedBytes.contains('mb1'),
                ),
              ],
            ),
            CmsChapter(
              id: 'm2',
              title: 'Trigonometry Fundamentals',
              summary: 'Master sine, cosine, tangent and their applications',
              duration: 50,
              watched: _completedChapters.contains('m2'),
              xp: 150,
              orderNumber: 1,
              videoUrl: 'https://example.com/math2.mp4',
              prerequisites: ['m1'], // Requires Chapter 1
              outcomes: [
                'Understand sine, cosine, and tangent',
                'Solve right-angle triangles',
                'Apply trig to real-world problems',
              ],
              relatedBytes: [
                 CmsByte(
                  id: 'mb2',
                  title: 'Trigonometry Problem Solving',
                  thumbnailUrl: '',
                  videoUrl: 'https://example.com/byte2.mp4',
                  tags: ['math', 'trig'],
                  order: 1,
                  visible: true,
                  duration: '12 min',
                  watched: _watchedBytes.contains('mb2'),
                ),
              ],
            ),
            CmsChapter(
              id: 'm3',
              title: 'Introduction to Calculus',
              summary: 'Start your calculus journey with limits and derivatives',
              duration: 60,
              watched: _completedChapters.contains('m3'),
              xp: 150,
              orderNumber: 2,
              videoUrl: 'https://example.com/math3.mp4',
              prerequisites: ['m2'], // Requires Chapter 2
              outcomes: [
                'Concept of Limits',
                'Basic Derivatives',
                'Rate of change',
              ],
            ),
            CmsChapter(
              id: 'm4',
              title: 'Shopping Math',
              summary: 'Discounts and unit pricing',
              duration: 30,
              watched: _completedChapters.contains('m4'),
              xp: 50,
              orderNumber: 3,
              prerequisites: ['m3'],
            ),
          ],
          bytes: [
            CmsByte(
              id: 'mb1',
              title: 'Calculate Discounts Fast',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/math1.mp4',
              tags: ['math', 'shopping'],
              order: 1,
              visible: true,
              duration: '5 min',
              watched: _watchedBytes.contains('mb1'),
            ),
            CmsByte(
              id: 'mb2',
              title: 'Time Zone Math',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/math2.mp4',
              tags: ['math', 'time'],
              order: 2,
              visible: true,
              duration: '8 min',
              watched: _watchedBytes.contains('mb2'),
            ),
          ],
          quizAvailable: true,
        ));

      case 'arts':
        return SynchronousFuture<CmsCourse>(CmsCourse(
          id: courseId,
          title: 'Creative Arts Workshop',
          description: 'Express yourself through art, music, and creativity',
          coverImageUrl: '',
          chapters: [
            CmsChapter(id: 'a1', title: 'Chapter 1: Drawing Basics', summary: 'Fundamentals of sketching'),
            CmsChapter(id: 'a2', title: 'Chapter 2: Color Theory', summary: 'Understanding colors'),
            CmsChapter(id: 'a3', title: 'Chapter 3: Crafts & DIY', summary: 'Hands-on creative projects'),
            CmsChapter(id: 'a4', title: 'Chapter 4: Music & Rhythm', summary: 'Introduction to music'),
          ],
          bytes: [
            CmsByte(
              id: 'ab1',
              title: '5-Minute Drawing Tips',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/arts1.mp4',
              tags: const ['arts', 'drawing'],
              order: 1,
              visible: true,
            ),
            CmsByte(
              id: 'ab2',
              title: 'Easy Paper Crafts',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/arts2.mp4',
              tags: const ['arts', 'crafts'],
              order: 2,
              visible: true,
            ),
          ],
          quizAvailable: true,
        ));

      case 'science':
        return SynchronousFuture<CmsCourse>(CmsCourse(
          id: courseId,
          title: 'Discovery & Science Adventures',
          description: 'Explore the wonders of science through experiments',
          coverImageUrl: '',
          chapters: [
            CmsChapter(id: 's1', title: 'Chapter 1: Simple Machines', summary: 'Levers, pulleys, and wheels'),
            CmsChapter(id: 's2', title: 'Chapter 2: States of Matter', summary: 'Solids, liquids, and gases'),
            CmsChapter(id: 's3', title: 'Chapter 3: Plants & Animals', summary: 'Living organisms'),
            CmsChapter(id: 's4', title: 'Chapter 4: Space & Planets', summary: 'Our solar system'),
          ],
          bytes: [
            CmsByte(
              id: 'sb1',
              title: 'Easy Science Experiments',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/science1.mp4',
              tags: const ['science', 'experiments'],
              order: 1,
              visible: true,
            ),
            CmsByte(
              id: 'sb2',
              title: 'Solar System Tour',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/science2.mp4',
              tags: const ['science', 'space'],
              order: 2,
              visible: true,
            ),
          ],
          quizAvailable: true,
        ));

      case 'lang':
        return SynchronousFuture<CmsCourse>(CmsCourse(
          id: courseId,
          title: 'Language Learning Journey',
          description: 'Build vocabulary and communication skills',
          coverImageUrl: '',
          chapters: [
            CmsChapter(id: 'l1', title: 'Chapter 1: Vocabulary Builder', summary: 'Expand your word power'),
            CmsChapter(id: 'l2', title: 'Chapter 2: Grammar Basics', summary: 'Essential grammar rules'),
            CmsChapter(id: 'l3', title: 'Chapter 3: Reading Skills', summary: 'Comprehension strategies'),
            CmsChapter(id: 'l4', title: 'Chapter 4: Creative Writing', summary: 'Express your ideas'),
          ],
          bytes: [
            CmsByte(
              id: 'lb1',
              title: 'Word of the Day',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/lang1.mp4',
              tags: const ['language', 'vocabulary'],
              order: 1,
              visible: true,
            ),
            CmsByte(
              id: 'lb2',
              title: 'Story Writing Tips',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/lang2.mp4',
              tags: const ['language', 'writing'],
              order: 2,
              visible: true,
            ),
          ],
          quizAvailable: true,
        ));

      default:
        // Fallback for unknown categories
        return SynchronousFuture<CmsCourse>(CmsCourse(
          id: courseId,
          title: 'Learning Course',
          description: 'Quick bites, chapters and a quiz to test yourself',
          coverImageUrl: '',
          chapters: [
            CmsChapter(id: 'c1', title: 'Chapter 1: Introduction', summary: 'Getting started'),
            CmsChapter(id: 'c2', title: 'Chapter 2: Core Concepts', summary: 'Building foundations'),
            CmsChapter(id: 'c3', title: 'Chapter 3: Practice', summary: 'Apply your knowledge'),
          ],
          bytes: [
            CmsByte(
              id: 'b1',
              title: 'Quick Lesson',
              thumbnailUrl: '',
              videoUrl: 'https://example.com/video1.mp4',
              tags: const ['learning'],
              order: 1,
              visible: true,
            ),
          ],
          quizAvailable: true,
        ));
    }
  }

  @override
  Future<List<CmsByte>> getBytesFeed({String? categoryId}) async {
    return SynchronousFuture<List<CmsByte>>([
      CmsByte(
        id: 's1',
        title: 'Breathing Exercise',
        thumbnailUrl: '',
        videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4',
        tags: const ['wellness'],
        order: 1,
        visible: true,
      ),
      CmsByte(
        id: 's2',
        title: 'Vedic Maths: 9s trick',
        thumbnailUrl: '',
        videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-waves-in-the-water-1164-large.mp4',
        tags: const ['math'],
        order: 2,
        visible: true,
      ),
    ]);
  }

  @override
  Future<List<CmsPlanSubject>> getPlan() async {
    return SynchronousFuture<List<CmsPlanSubject>>([
      CmsPlanSubject(id: 'vedic', title: 'Vedic Maths', progress: 0.65, colorHex: '#9DB8FF'),
      CmsPlanSubject(id: 'nutrition', title: 'Nutrition', progress: 0.30, colorHex: '#FFB2B2'),
      CmsPlanSubject(id: 'applied', title: 'Applied Maths', progress: 0.60, colorHex: '#FFD58C'),
      CmsPlanSubject(id: 'creative', title: 'Creative Writing', progress: 0.12, colorHex: '#C7E4FF'),
    ]);
  }

  static final Set<String> _enrolledIds = {'w2'}; // Start with one enrolled

  static void toggleEnrollment(String id) {
    if (_enrolledIds.contains(id)) {
      _enrolledIds.remove(id);
    } else {
      _enrolledIds.add(id);
    }
  }

  @override
  Future<List<CmsWorkshop>> getWorkshops() async {
    return SynchronousFuture<List<CmsWorkshop>>([
      // 1. UPCOMING
      CmsWorkshop(
        id: 'w1',
        title: 'Basics of Saregama',
        instructor: 'Santosh Personal',
        dateTime: DateTime.now().add(const Duration(days: 2, hours: 4)),
        description: 'Dive deep into the roots of Indian classical music. Learn the 7 notes in perfect harmony.',
        enrolled: _enrolledIds.contains('w1'),
        enrollmentPercentage: 90,
        imageUrl: 'assets/images/workshop_music.png',
        category: 'Music',
        durationMinutes: 120,
        type: 'Offline',
      ),
      CmsWorkshop(
        id: 'w2',
        title: 'Future of AI: Kids Edition',
        instructor: 'Dr. A. Verma',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        description: 'An interactive session introducing Artificial Intelligence concepts to young minds.',
        enrolled: _enrolledIds.contains('w2'),
        enrollmentPercentage: 65,
        imageUrl: 'assets/images/workshop_ai.png',
        category: 'Technology',
        durationMinutes: 60,
        type: 'Zoom Online',
      ),

      // 2. ONGOING (Starts 10 mins ago, lasts 60 mins)
      CmsWorkshop(
        id: 'w_ongoing',
        title: 'Live: Watercolor Painting',
        instructor: 'Priya Art',
        dateTime: DateTime.now().subtract(const Duration(minutes: 10)),
        description: 'Join us live as we paint a beautiful sunset landscape together.',
        enrolled: true,
        enrollmentPercentage: 88,
        imageUrl: 'assets/images/workshop_art.jpg',
        category: 'Arts',
        durationMinutes: 60, // Ends in 50 mins
        type: 'Youtube Live',
      ),

      // 3. COMPLETED (3 workshops)
      CmsWorkshop(
        id: 'w_comp1',
        title: 'Mindful Breathing',
        instructor: 'Dr. Ananya',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        description: 'A calming session focused on breathwork techniques for anxiety relief.',
        enrolled: _enrolledIds.contains('w_comp1'),
        enrollmentPercentage: 100,
        imageUrl: 'assets/images/workshop_wellness.png',
        category: 'Wellness',
        durationMinutes: 45,
        type: 'Zoom Online',
      ),
      CmsWorkshop(
        id: 'w_comp2',
        title: 'Space Exploration 101',
        instructor: 'Cosmos Club',
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Journey through the solar system and learn about our neighboring planets.',
        enrolled: false,
        enrollmentPercentage: 95,
        imageUrl: 'assets/images/workshop_space.jpg',
        category: 'Science',
        durationMinutes: 90,
        type: 'Offline',
      ),
      CmsWorkshop(
        id: 'w_comp3',
        title: 'Creative Writing Masterclass',
        instructor: 'R. K. Sharma',
        dateTime: DateTime.now().subtract(const Duration(days: 10)),
        description: 'Unlock your creativity and write compelling short stories.',
        enrolled: _enrolledIds.contains('w_comp3'),
        enrollmentPercentage: 75,
        imageUrl: 'assets/images/workshop_art.jpg',
        category: 'Writing',
        durationMinutes: 90,
        type: 'Zoom Online',
      ),
    ]);
  }

  // --- Mock DB State ---
  // In-memory state for the session
  final Set<String> _completedChapters = {'m1'}; // Pre-mark Chapter 1 as complete for demo
  final Set<String> _watchedBytes = {'mb1'};
  final Map<String, String> _lastViewedChapters = {}; // courseId -> chapterId
  int _userXp = 100; // Initial XP

  @override
  Future<void> markChapterComplete(String courseId, String chapterId) async {
    // 1. Mark as complete
    if (!_completedChapters.contains(chapterId)) {
       _completedChapters.add(chapterId);
       // 2. Add XP (simplistic logic: 150 for chapters)
       _userXp += 150;
    }
    return SynchronousFuture(null);
  }

  @override
  Future<void> markByteWatched(String byteId) async {
    _watchedBytes.add(byteId);
    return SynchronousFuture(null);
  }

  @override
  Future<void> saveLastViewedChapter(String courseId, String chapterId) async {
    _lastViewedChapters[courseId] = chapterId;
    return SynchronousFuture(null);
  }

  @override
  Future<String?> getLastViewedChapter(String courseId) async {
    return SynchronousFuture(_lastViewedChapters[courseId]);
  }

  @override
  Future<int> getUserXp() async {
    return SynchronousFuture(_userXp);
  }
}
