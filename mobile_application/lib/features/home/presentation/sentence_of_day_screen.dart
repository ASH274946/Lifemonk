import 'package:flutter/material.dart';

/// Sentence of the Day model
/// FUTURE: This will be fetched from CMS/Supabase with daily content
class SentenceOfDay {
  final String id;
  final String sentence;
  final String meaning;
  final String usage;
  final String focusWord;
  final DateTime date;

  const SentenceOfDay({
    required this.id,
    required this.sentence,
    required this.meaning,
    required this.usage,
    required this.focusWord,
    required this.date,
  });

  factory SentenceOfDay.mock() {
    return SentenceOfDay(
      id: 'sotd-1',
      sentence: 'The curious cat found a secret.',
      meaning:
          'To find means to discover something, usually by searching or by chance.',
      usage:
          'When someone "finds" something, they locate or discover it. For example: "I found my keys under the couch."',
      focusWord: 'found',
      date: DateTime.now(),
    );
  }
}

/// Sentence of the Day Detail Screen
///
/// Features:
/// - Main sentence display with focus word highlighting
/// - Meaning and usage explanation sections
/// - Action cards for practice options
/// - CMS-ready structure for future content integration
/// - Smooth animations and premium UI
class SentenceOfDayScreen extends StatefulWidget {
  final SentenceOfDay? sentence;

  const SentenceOfDayScreen({super.key, this.sentence});

  @override
  State<SentenceOfDayScreen> createState() => _SentenceOfDayScreenState();
}

class _SentenceOfDayScreenState extends State<SentenceOfDayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sentence = widget.sentence ?? SentenceOfDay.mock();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const Text(
                          'TODAY\'S FOCUS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3B82F6),
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Sentence of the Day',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Main Sentence Card
                        _buildSentenceCard(sentence),

                        const SizedBox(height: 24),

                        // What It Means Section
                        _buildMeaningSection(sentence),

                        const SizedBox(height: 24),

                        // Action Options Section
                        _buildActionOptions(context),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentenceCard(SentenceOfDay sentence) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Focus word badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDFE9FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Focus: "${sentence.focusWord}"',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Main sentence
          Text(
            sentence.sentence,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningSection(SentenceOfDay sentence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What it means',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDEE5F7)),
          ),
          child: Text(
            sentence.meaning,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Usage Example
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How to use it',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                sentence.usage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s Next?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 12),

        // Practice Sentence Option
        GestureDetector(
          onTap: () => _navigateToPracticeSentence(context),
          child: _buildActionCard(
            icon: Icons.edit_outlined,
            title: 'Practice Sentence',
            subtitle: 'Test your understanding with interactive exercises',
            color: const Color(0xFF3B82F6),
          ),
        ),

        const SizedBox(height: 12),

        // Practice Word Option
        GestureDetector(
          onTap: () => _navigateToPracticeWord(context),
          child: _buildActionCard(
            icon: Icons.book_outlined,
            title: 'Practice Word of the Day',
            subtitle: 'Learn a new word with examples and meanings',
            color: const Color(0xFF8B5CF6),
          ),
        ),

        const SizedBox(height: 12),

        // Did You Know Option
        GestureDetector(
          onTap: () => _navigateToDidYouKnow(context),
          child: _buildActionCard(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Did You Know?',
            subtitle: 'Discover fascinating facts about language and learning',
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
        ],
      ),
    );
  }

  // Navigation handlers with TODO comments for CMS integration
  void _navigateToPracticeSentence(BuildContext context) {
    // TODO: Connect to actual SentencePracticeQuizScreen when fully implemented
    // This will eventually navigate to the sentence_practice_quiz_screen.dart
    // which will fetch questions from CMS admin panel
    _showComingSoonSheet(context, 'Practice Sentence');
  }

  void _navigateToPracticeWord(BuildContext context) {
    // TODO: Navigate to WordOfTheDayDetailScreen or dedicated word practice screen
    // This section will be populated with:
    // - Word definition from CMS
    // - Pronunciation audio
    // - Usage examples
    // - Practice exercises
    _showComingSoonSheet(context, 'Practice Word of the Day');
  }

  void _navigateToDidYouKnow(BuildContext context) {
    // TODO: Connect to LearningShortDetailScreen for language facts
    // Content structure will include:
    // - Main fun fact/insight
    // - Related learning short ID
    // - Image/icon from CMS
    // - Share functionality
    _showComingSoonSheet(context, 'Did You Know?');
  }

  void _showComingSoonSheet(BuildContext context, String featureName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                size: 32,
                color: Color(0xFF3B82F6),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              featureName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'This feature will be updated daily via our admin panel.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
