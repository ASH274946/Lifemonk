import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/custom_dialog.dart';
import '../domain/practice_question.dart';
import '../providers/vocabulary_provider.dart';

/// Practice Session Screen - Fill-in-the-blank exercises
class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({super.key});

  @override
  ConsumerState<PracticeSessionScreen> createState() =>
      _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(practiceQuestionsProvider);
    
    if (_currentQuestionIndex >= questions.length) {
      return _buildCompletionScreen(context);
    }

    final question = questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              _buildHeader(context, question),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Question card
                      _buildQuestionCard(question),

                      const SizedBox(height: 32),

                      // Answer options
                      ...question.options.map((option) => 
                        _buildOptionButton(option, question.correctAnswer)),

                      const SizedBox(height: 32),

                      // Check answer button
                      if (_selectedAnswer != null && !_showFeedback)
                        _buildCheckAnswerButton(),

                      // Feedback message
                      if (_showFeedback)
                        _buildFeedback(),
                    ],
                  ),
                ),
              ),

              // Progress indicator dots
              _buildProgressIndicator(questions.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PracticeQuestion question) {
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
            onTap: () => _showExitDialog(context),
            child: const Icon(
              Icons.close_rounded,
              size: 24,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Practice Session',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${question.questionIndex} of ${question.totalQuestions} words',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showHelpDialog(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                size: 20,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(PracticeQuestion question) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji indicator
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              question.emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Sentence with blank
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: question.beforeBlank),
                    const TextSpan(
                      text: '_____',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF4A90E2),
                        decorationThickness: 2,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    TextSpan(text: question.afterBlank),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String option, String correctAnswer) {
    final isSelected = _selectedAnswer == option;
    final isCorrectOption = option == correctAnswer;
    
    Color backgroundColor = const Color(0xFFF5F5F5);
    Color textColor = const Color(0xFF1A1A1A);
    Color borderColor = Colors.transparent;

    if (_showFeedback && isSelected) {
      if (_isCorrect) {
        backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF10B981);
      } else {
        backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFFEF4444);
      }
    } else if (isSelected) {
      backgroundColor = const Color(0xFF4A90E2).withOpacity(0.1);
      borderColor = const Color(0xFF4A90E2);
      textColor = const Color(0xFF4A90E2);
    }

    return GestureDetector(
      onTap: _showFeedback ? null : () {
        setState(() {
          _selectedAnswer = option;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: borderColor == Colors.transparent ? 0 : 2,
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckAnswerButton() {
    return GestureDetector(
      onTap: _checkAnswer,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90E2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Check Answer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect
            ? const Color(0xFF10B981).withOpacity(0.1)
            : const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: _isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isCorrect ? 'Correct! Well done!' : 'Incorrect. Try again next time!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int totalQuestions) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalQuestions > 10 ? 10 : totalQuestions,
          (index) {
            final isActive = index == _currentQuestionIndex;
            final isCompleted = index < _currentQuestionIndex;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? const Color(0xFF4A90E2)
                    : const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.celebration_rounded,
                  size: 80,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Great Job!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You\'ve completed all practice questions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Back to History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkAnswer() {
    final questions = ref.read(practiceQuestionsProvider);
    final question = questions[_currentQuestionIndex];
    
    setState(() {
      _isCorrect = _selectedAnswer == question.correctAnswer;
      _showFeedback = true;
    });

    // Auto-advance after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedAnswer = null;
      _showFeedback = false;
      _isCorrect = false;
    });

    // Animate transition
    _animationController.reset();
    _animationController.forward();
  }

  void _showExitDialog(BuildContext context) {
    CustomDialog.show(
      context: context,
      title: 'Exit Practice?',
      message: 'Your progress will not be saved.',
      primaryButtonText: 'Exit',
      secondaryButtonText: 'Cancel',
      isDangerous: true,
      onPrimaryPressed: () {
        Navigator.pop(context); // Close practice session
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    CustomDialog.show(
      context: context,
      title: 'How to Practice',
      message: 'Select the correct word to fill in the blank. You\'ll get instant feedback and automatically move to the next question.',
      primaryButtonText: 'Got it',
    );
  }
}
