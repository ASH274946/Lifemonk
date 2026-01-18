import 'package:flutter/material.dart';
import '../domain/practice_sentence_model.dart';
import '../domain/sentence_generator.dart';

/// Sentence Practice Screen
/// Interactive fill-in-the-blank practice for vocabulary words
class SentencePracticeScreen extends StatefulWidget {
  final String word;
  final String definition;

  const SentencePracticeScreen({
    super.key,
    required this.word,
    required this.definition,
  });

  @override
  State<SentencePracticeScreen> createState() => _SentencePracticeScreenState();
}

class _SentencePracticeScreenState extends State<SentencePracticeScreen> {
  late List<PracticeSentence> sentences;
  late PageController _pageController;
  int currentPage = 0;
  List<String?> selectedAnswers = [];
  List<bool> isCorrectList = [];

  @override
  void initState() {
    super.initState();
    sentences = SentenceGenerator.generateSentences(widget.word, widget.definition);
    selectedAnswers = List.filled(sentences.length, null);
    isCorrectList = List.filled(sentences.length, false);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectAnswer(int pageIndex, String answer) {
    setState(() {
      selectedAnswers[pageIndex] = answer;
      isCorrectList[pageIndex] = answer == sentences[pageIndex].correctAnswer;
    });
  }

  void _nextChallenge() {
    if (currentPage < sentences.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Show completion screen
      _showCompletionScreen();
    }
  }

  void _showCompletionScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _CompletionScreen(word: widget.word),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          currentPage == sentences.length - 1 ? 'Sentence Practice' : 'Step ${currentPage + 1} of ${sentences.length}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (currentPage < sentences.length - 1)
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.black),
              onPressed: () {
                // Show help dialog
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          _buildProgressBar(),
          
          // PageView for sentences
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe, use button
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: sentences.length,
              itemBuilder: (context, index) {
                return _buildSentencePage(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          if (currentPage < sentences.length - 1)
            const Text(
              'Practice Session',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          if (currentPage < sentences.length - 1) const Spacer(),
          if (currentPage < sentences.length - 1)
            Text(
              'Step ${currentPage + 1} of ${sentences.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSentencePage(int index) {
    final sentence = sentences[index];
    final selectedAnswer = selectedAnswers[index];
    final isAnswered = selectedAnswer != null;
    final isCorrect = isCorrectList[index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          
          // Sentence with blank
          _buildSentenceDisplay(sentence, selectedAnswer),
          
          const SizedBox(height: 60),
          
          // Answer options
          ...sentence.allOptions.map((option) {
            final isSelected = selectedAnswer == option;
            final isCorrectOption = option == sentence.correctAnswer;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionButton(
                option: option,
                isSelected: isSelected,
                isCorrect: isCorrectOption,
                isAnswered: isAnswered,
                onTap: isAnswered ? null : () => _selectAnswer(index, option),
              ),
            );
          }),
          
          const SizedBox(height: 40),
          
          // Next Challenge button
          if (isAnswered)
            _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildSentenceDisplay(PracticeSentence sentence, String? selectedAnswer) {
    final parts = sentence.sentenceTemplate.split('{blank}');
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji character
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Color(0xFFFEF3C7),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('😊', style: TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(width: 16),
        
        // Sentence text
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                height: 1.3,
              ),
              children: [
                TextSpan(text: parts[0]),
                TextSpan(
                  text: selectedAnswer ?? '____',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: selectedAnswer != null 
                        ? (selectedAnswers[currentPage] == sentence.correctAnswer 
                            ? const Color(0xFF10B981) 
                            : const Color(0xFF111827))
                        : const Color(0xFF3B82F6),
                    decorationThickness: 3,
                    color: selectedAnswer != null 
                        ? (selectedAnswers[currentPage] == sentence.correctAnswer 
                            ? const Color(0xFF10B981) 
                            : const Color(0xFF111827))
                        : const Color(0xFF111827),
                  ),
                ),
                if (parts.length > 1) TextSpan(text: parts[1]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required String option,
    required bool isSelected,
    required bool isCorrect,
    required bool isAnswered,
    VoidCallback? onTap,
  }) {
    Color backgroundColor = const Color(0xFFF3F4F6);
    Color borderColor = const Color(0xFFF3F4F6);
    Color textColor = const Color(0xFF111827);
    Widget? trailing;

    if (isAnswered) {
      if (isSelected && isCorrect) {
        backgroundColor = const Color(0xFFD1FAE5);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF065F46);
        trailing = const Icon(Icons.check, color: Color(0xFF10B981), size: 24);
      } else if (isSelected && !isCorrect) {
        backgroundColor = const Color(0xFFFEE2E2);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFF991B1B);
      } else if (!isSelected && isCorrect) {
        backgroundColor = const Color(0xFFD1FAE5);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF065F46);
        trailing = const Icon(Icons.check, color: Color(0xFF10B981), size: 24);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: _nextChallenge,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentPage < sentences.length - 1 ? 'Next Challenge' : 'Complete',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}

/// Completion Screen
/// Shown after completing all practice sentences
class _CompletionScreen extends StatelessWidget {
  final String word;

  const _CompletionScreen({required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('📚', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Great job!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              
              const SizedBox(height: 12),
              
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'You mastered '),
                    TextSpan(
                      text: word,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const TextSpan(text: ' today.'),
                  ],
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Next Word button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next Word',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Back to Word button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                  ),
                  child: const Text(
                    'Back to Word',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
