import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../shared/widgets/custom_dialog.dart';
import '../../../shared/widgets/custom_toast.dart';
import '../domain/vocabulary_word.dart';
import '../providers/vocabulary_provider.dart';
import 'practice_history_screen.dart';

/// Vocabulary Detail Screen - Shows word details with tabs
class VocabularyDetailScreen extends ConsumerStatefulWidget {
  final VocabularyWord? initialWord;
  final int? initialIndex;

  const VocabularyDetailScreen({
    super.key,
    this.initialWord,
    this.initialIndex,
  });

  @override
  ConsumerState<VocabularyDetailScreen> createState() =>
      _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState
    extends ConsumerState<VocabularyDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize TTS
    _initializeTts();

    // Set initial word index if provided
    if (widget.initialIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(vocabularyProvider.notifier).setWordIndex(widget.initialIndex!);
      });
    }

    // Entrance animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }
  
  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      // TTS initialization failed, will handle in playPronunciation
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    // Don't call stop() on TTS, just dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyState = ref.watch(vocabularyProvider);
    final word = vocabularyState.currentWord ?? widget.initialWord;

    if (word == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: Text('No word available')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Header with tabs and Practice button
                _buildHeader(context),

                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildWordOfDayTab(word),
                      _buildHistoryTab(),
                    ],
                  ),
                ),

                // Bottom navigation
                _buildBottomNavigation(word, vocabularyState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE8E8E8), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 20,
              color: Color(0xFF1A1A1A),
            ),
          ),

          const SizedBox(width: 12),

          // Tabs
          Expanded(
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorColor: const Color(0xFF4A90E2),
              indicatorWeight: 3,
              labelColor: const Color(0xFF1A1A1A),
              unselectedLabelColor: const Color(0xFF9CA3AF),
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Vocabulary'),
                Tab(text: 'History'),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Practice button - enabled only after 20 words
          GestureDetector(
            onTap: () {
              final vocabularyState = ref.read(vocabularyProvider);
              final learnedCount = vocabularyState.currentWordIndex + 1; // Words learned so far
              
              if (learnedCount >= 20) {
                _navigateToPracticeHistory(context);
              } else {
                // Show message that user needs to learn more words
                CustomDialog.show(
                  context: context,
                  title: 'Practice Locked 🔒',
                  message: 'Learn ${20 - learnedCount} more words to unlock practice!\n\nCurrent progress: $learnedCount/20 words',
                  primaryButtonText: 'Got it',
                );
              }
            },
            child: Consumer(
              builder: (context, ref, child) {
                final vocabularyState = ref.watch(vocabularyProvider);
                final learnedCount = vocabularyState.currentWordIndex + 1;
                final isEnabled = learnedCount >= 20;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isEnabled 
                        ? const Color(0xFF4A90E2) 
                        : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(20),
                    border: isEnabled 
                        ? null 
                        : Border.all(color: const Color(0xFFD1D5DB), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Practice',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
                        ),
                      ),
                      if (!isEnabled) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordOfDayTab(VocabularyWord word) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Word card with speaker icon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFD6EEFF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WORD OF THE DAY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.word,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A90E2),
                          height: 1.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _playPronunciation(word.word),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          size: 24,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Meaning section
          const Text(
            'Meaning',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            word.meaning,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),

          const SizedBox(height: 32),

          // Context of Use section
          const Text(
            'Context of Use',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          ...word.contextExamples.map((example) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        example,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF374151),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: Text(
        'History tab - Coming soon',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(VocabularyWord word, VocabularyState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE8E8E8), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (state.hasPreviousWord)
            GestureDetector(
              onTap: () {
                ref.read(vocabularyProvider.notifier).previousWord();
                _animateTransition();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios_rounded, size: 16, color: Color(0xFF6B7280)),
                    SizedBox(width: 4),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(width: 50),

          // Progress indicator
          Text(
            '${word.wordIndex}/${word.totalWords}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),

          // Next button
          if (state.hasNextWord)
            GestureDetector(
              onTap: () {
                // Mark current word as learned before moving to next
                ref.read(vocabularyProvider.notifier).markWordAsLearned(word.id);
                ref.read(vocabularyProvider.notifier).nextWord();
                _animateTransition();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
                  ],
                ),
              ),
            )
          else
            const SizedBox(width: 50),
        ],
      ),
    );
  }

  void _animateTransition() {
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _playPronunciation(String word) async {
    try {
      // Speak the word (TTS already initialized in initState)
      await _flutterTts.speak(word);
      
      if (mounted) {
        CustomToast.success(context, '🔊 $word');
      }
    } catch (e) {
      if (mounted) {
        CustomToast.error(context, 'Could not play pronunciation');
      }
    }
  }

  void _navigateToPracticeHistory(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PracticeHistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
