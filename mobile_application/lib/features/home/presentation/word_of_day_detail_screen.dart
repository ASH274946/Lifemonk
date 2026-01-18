import 'package:flutter/material.dart';
import '../domain/models/word_of_day.dart';

class WordOfDayDetailScreen extends StatefulWidget {
  final WordOfDay word;

  const WordOfDayDetailScreen({
    super.key,
    required this.word,
  });

  @override
  State<WordOfDayDetailScreen> createState() => _WordOfDayDetailScreenState();
}

class _WordOfDayDetailScreenState extends State<WordOfDayDetailScreen>
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

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content
            CustomScrollView(
              slivers: [
                // Simple back button AppBar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  leading: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  actions: [
                    SizedBox(width: 56), // Balance for back button
                  ],
                ),

                // Main Content
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // Icon Badge (blue)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                size: 32,
                                color: Color(0xFF6366F1),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // "TODAY'S WORD" Label
                            const Text(
                              "TODAY'S WORD",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFB0B8C8),
                                letterSpacing: 1.0,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Large Word Title
                            Text(
                              widget.word.word,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF000000),
                                letterSpacing: -1.0,
                                height: 1.0,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Meaning Section (Badge on left with icon)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F1FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFE9D5FF),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Badge with icon
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color:
                                              const Color(0xFF7C3AED)
                                                  .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.lightbulb_rounded,
                                          size: 14,
                                          color: Color(0xFF7C3AED),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'MEANING',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF7C3AED),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  // Meaning text
                                  Text(
                                    widget.word.meaning,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1F2937),
                                      height: 1.6,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // In A Sentence Section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'IN A SENTENCE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB0B8C8),
                                    letterSpacing: 0.8,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Sentence with word highlighted
                                Text.rich(
                                  textAlign: TextAlign.center,
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: '"She showed great ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF6B7280),
                                          height: 1.6,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: widget.word.word,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF000000),
                                          height: 1.6,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' in finishing the race."',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF6B7280),
                                          height: 1.6,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Practice Button
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Practice mode coming soon! 🎓'),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    backgroundColor:
                                        const Color(0xFF7C3AED),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF000000),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF000000)
                                          .withValues(alpha: 0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Practice Sentence',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Quick Tip
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Quick Tip: ${widget.word.word} is the key to mastering any skill.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFB0B8C8),
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Moon icon in bottom right
            Positioned(
              bottom: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.nights_stay_rounded,
                  size: 24,
                  color: Color(0xFFB0B8C8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
