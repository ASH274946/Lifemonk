import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/custom_toast.dart';
import '../providers/vocabulary_provider.dart';
import 'practice_session_screen.dart';

/// Practice History Screen - Shows practiced words and summary
class PracticeHistoryScreen extends ConsumerStatefulWidget {
  const PracticeHistoryScreen({super.key});

  @override
  ConsumerState<PracticeHistoryScreen> createState() =>
      _PracticeHistoryScreenState();
}

class _PracticeHistoryScreenState extends ConsumerState<PracticeHistoryScreen> {
  int _displayCount = 10;
  bool _showDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final vocabularyState = ref.watch(vocabularyProvider);
    final practiceHistory = vocabularyState.practiceHistory;
    final displayedHistory = practiceHistory.take(_displayCount).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                _buildHeader(context),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary card
                        _buildSummaryCard(vocabularyState.totalPracticedThisMonth),

                        const SizedBox(height: 24),

                        // Word list
                        ...displayedHistory.map((item) => _buildWordItem(item)),

                        // Show more button
                        if (practiceHistory.length > _displayCount)
                          _buildShowMoreButton(practiceHistory.length),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Dark mode toggle (bottom-right)
            Positioned(
              bottom: 24,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showDarkMode = !_showDarkMode;
                  });
                  CustomToast.info(
                    context,
                    _showDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _showDarkMode ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                    size: 20,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE8E8E8), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 20,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Practice History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int totalWords) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD6EEFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalWords Words',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'In this month',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _navigateToPracticeSession(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Practice Now',
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
    );
  }

  Widget _buildWordItem(item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.word,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A90E2),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _playPronunciation(item.word),
            child: const Icon(
              Icons.volume_up_rounded,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowMoreButton(int totalCount) {
    final remaining = totalCount - _displayCount;
    return GestureDetector(
      onTap: () {
        setState(() {
          _displayCount += 10;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Show more ${remaining > 10 ? 10 : remaining}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  void _playPronunciation(String word) {
    CustomToast.info(context, 'Playing: $word');
  }

  void _navigateToPracticeSession(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PracticeSessionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
