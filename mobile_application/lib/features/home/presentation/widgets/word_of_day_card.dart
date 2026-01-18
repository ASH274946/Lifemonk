import 'package:flutter/material.dart';

/// Word of the Day Card (Light blue card)
/// Shows the word, meaning, and learn more button with progress
class WordOfDayCard extends StatelessWidget {
  final String word;
  final String meaning;
  final VoidCallback? onTap;
  final VoidCallback? onPracticeTap;
  final int? currentIndex;
  final int? totalWords;

  const WordOfDayCard({
    super.key,
    required this.word,
    required this.meaning,
    this.onTap,
    this.onPracticeTap,
    this.currentIndex,
    this.totalWords,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? onPracticeTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFD6EEFF), // Light blue
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              'WORD OF THE DAY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                letterSpacing: 1.0,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Word
            Text(
              word,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Meaning
            Text(
              meaning,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.7),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 16),
            
            // Learn more button with progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    currentIndex != null && totalWords != null
                        ? 'Learn more $currentIndex/$totalWords'
                        : 'Learn more',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
