import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/cms/models.dart';
import 'workshop_detail_screen.dart';
import 'providers/workshop_providers.dart';

class WorkshopsScreen extends ConsumerStatefulWidget {
  const WorkshopsScreen({super.key});

  @override
  ConsumerState<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends ConsumerState<WorkshopsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch filtered workshops (from repository)
    final workshopsAsync = ref.watch(filteredWorkshopsProvider);
    // Watch selected category
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                'Workshops',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // TABS
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // slightly smaller radius than container
                  color: const Color(0xFF3B82F6),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(2), // padding for indicator
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter', // Try to match app font
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Ongoing'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),

            // FILTER CHIP
            if (selectedCategory != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding( // Extra padding bot because of new layout
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3B82F6), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_list_rounded, size: 16, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            selectedCategory.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => ref.read(selectedCategoryProvider.notifier).state = null,
                          child: const Icon(Icons.close, size: 16, color: Color(0xFF3B82F6)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // CONTENT
            Expanded(
              child: workshopsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Failed to load: $e')),
                data: (allWorkshops) {
                  final now = DateTime.now();

                  // Filter logic
                  final upcoming = allWorkshops.where((w) => w.dateTime.isAfter(now)).toList();
                  final ongoing = allWorkshops.where((w) {
                    final end = w.dateTime.add(Duration(minutes: w.durationMinutes));
                    return w.dateTime.isBefore(now) && end.isAfter(now);
                  }).toList();
                  final completed = allWorkshops.where((w) {
                     final end = w.dateTime.add(Duration(minutes: w.durationMinutes));
                     return end.isBefore(now);
                  }).toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(upcoming, 'No upcoming workshops'),
                      _buildList(ongoing, 'No workshops happening now'),
                      _buildList(completed, 'No completed workshops'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<CmsWorkshop> workshops, String emptyMessage) {
    if (workshops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 48, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: workshops.length,
      itemBuilder: (_, i) => _WorkshopCard(item: workshops[i]),
    );
  }
}

class _WorkshopCard extends ConsumerWidget {
  final CmsWorkshop item;

  const _WorkshopCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WorkshopDetailScreen(workshop: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BANNER
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   if (item.imageUrl.isNotEmpty)
                    Positioned.fill(
                      child: item.imageUrl.startsWith('http')
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.broken_image, color: Colors.white54));
                              },
                            )
                          : Image.asset(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.broken_image, color: Colors.white54));
                              },
                            ),
                    )
                  else
                    Icon(Icons.image, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                  
                  // Gradient Overlay for text visibility if we ever add text on image (optional, but good for premium look)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    // TAPPABLE CATEGORY BADGE (NEW!)
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state = item.category;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // INFO
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 14, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 6),
                      Text(item.instructor, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(item.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280), height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Text(
                        '${item.dateTime.month}/${item.dateTime.day} at ${item.dateTime.hour}:${item.dateTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF)),
                      ),
                    ],
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
