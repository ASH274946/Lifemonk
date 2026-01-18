import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/home_screen.dart';
import '../../workshops/presentation/workshops_screen.dart';
import '../../bytes/presentation/bytes_screen.dart';
import '../../plan/presentation/plan_screen.dart';
import '../../more/presentation/more_screen.dart';
import '../../../core/theme/app_theme.dart';
import 'providers/shell_providers.dart';

/// Main Shell - Manages bottom navigation and screen routing
/// This is the container for all main app screens after authentication
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {

  // All main screens
  final List<Widget> _screens = const [
    HomeScreen(),
    WorkshopsScreen(),
    SizedBox.shrink(), // Placeholder - Bytes is pushed as full-screen route
    PlanScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainShellIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(currentIndex),
    );
  }

  Widget _buildBottomNav(int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.groups_outlined,
                label: 'Workshops',
                currentIndex: currentIndex,
              ),
              _buildByteButton(currentIndex),
              _buildNavItem(
                index: 3,
                icon: Icons.checklist_rounded,
                label: 'My Plan',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.menu_rounded,
                label: 'More',
                currentIndex: currentIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required int currentIndex,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => ref.read(mainShellIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF4A7FD4)
                  : const Color(0xFF9E9E9E),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF4A7FD4)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildByteButton(int currentIndex) {
    final isSelected = currentIndex == 2;

    return GestureDetector(
      onTap: () {
        // Navigate to full-screen Bytes player (Reels style)
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ByteScreen()),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    const Color(0xFF3B7DD8),
                    const Color(0xFF5B9AE8),
                  ]
                : [
                    const Color(0xFF4A8FE7),
                    const Color(0xFF6BA3ED),
                  ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A8FE7).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 22,
            ),
            const Text(
              'BYTE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholders removed in favor of real screens
