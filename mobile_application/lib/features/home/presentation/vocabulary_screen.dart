import 'package:flutter/material.dart';

/// Vocabulary word model
class VocabularyWord {
  final String id;
  final String word;
  final String definition;
  final String status; // NEW, LEARNED, PENDING
  final String category;

  const VocabularyWord({
    required this.id,
    required this.word,
    required this.definition,
    required this.status,
    required this.category,
  });
}

/// My Vocabulary List Screen
class MyVocabularyScreen extends StatefulWidget {
  const MyVocabularyScreen({super.key});

  @override
  State<MyVocabularyScreen> createState() => _MyVocabularyScreenState();
}

class _MyVocabularyScreenState extends State<MyVocabularyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0=All, 1=New, 2=Learned, 3=Pending

  final List<VocabularyWord> mockVocabulary = [
    const VocabularyWord(
      id: '1',
      word: 'Adventure',
      definition: 'A bold and exciting experience',
      status: 'NEW',
      category: 'Learning',
    ),
    const VocabularyWord(
      id: '2',
      word: 'Curiosity',
      definition: 'A strong desire to learn or know',
      status: 'LEARNED',
      category: 'Emotions',
    ),
    const VocabularyWord(
      id: '3',
      word: 'Growth',
      definition: 'The process of developing or increasing',
      status: 'LEARNED',
      category: 'Development',
    ),
    const VocabularyWord(
      id: '4',
      word: 'Resilience',
      definition: 'The ability to recover or bounce back',
      status: 'NEW',
      category: 'Skills',
    ),
    const VocabularyWord(
      id: '5',
      word: 'Empathy',
      definition: 'Understanding others feelings',
      status: 'LEARNED',
      category: 'Emotions',
    ),
    const VocabularyWord(
      id: '6',
      word: 'Reflection',
      definition: 'Careful thought about something',
      status: 'PENDING',
      category: 'Learning',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<VocabularyWord> get filteredVocabulary {
    var filtered = mockVocabulary.where((word) {
      final matchesSearch =
          word.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          word.definition.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 0) return true;
      if (_selectedFilter == 1) return word.status == 'NEW';
      if (_selectedFilter == 2) return word.status == 'LEARNED';
      if (_selectedFilter == 3) return word.status == 'PENDING';

      return true;
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
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
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'My Vocabulary',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search your words...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF6B7280),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 2,
                      ),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFilterChip('All', 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('New', 1),
                    const SizedBox(width: 8),
                    _buildFilterChip('Learned', 2),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pending', 3),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Vocabulary List
              Expanded(
                child: filteredVocabulary.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No words found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredVocabulary.length,
                        itemBuilder: (context, index) {
                          final word = filteredVocabulary[index];
                          return _buildVocabularyCard(word);
                        },
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildVocabularyCard(VocabularyWord word) {
    final statusColor = word.status == 'NEW'
        ? const Color(0xFFF59E0B)
        : word.status == 'LEARNED'
        ? const Color(0xFF10B981)
        : const Color(0xFF8B5CF6);

    final statusBg = word.status == 'NEW'
        ? const Color(0xFFFEF3C7)
        : word.status == 'LEARNED'
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFEDE9FE);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    word.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Definition
            Text(
              word.definition,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // Category tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word.category,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
