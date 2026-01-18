import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/user_providers.dart';

/// ============================================
/// EXAMPLE 1: Display User Profile
/// ============================================
/// Shows how to read and display user data
class UserProfileExample extends ConsumerWidget {
  const UserProfileExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch currentUserDataProvider for reactive UI
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: userDataAsync.when(
        // Loading state - show spinner
        loading: () => const Center(child: CircularProgressIndicator()),

        // Error state - show error message
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Refresh data
                  ref.invalidate(currentUserDataProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),

        // Data state - display user info
        data: (userData) {
          if (userData == null) {
            return const Center(child: Text('No user data found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Info
                _buildSection('Profile Information', [
                  _buildInfoRow('Name', userData.profile.name),
                  _buildInfoRow('Phone', userData.profile.phone),
                  _buildInfoRow('Email', userData.profile.email ?? 'Not set'),
                  _buildInfoRow('School', userData.profile.school ?? 'Not set'),
                  _buildInfoRow('Grade', userData.profile.grade ?? 'Not set'),
                  _buildInfoRow('City', userData.profile.city ?? 'Not set'),
                  _buildInfoRow('State', userData.profile.state ?? 'Not set'),
                ]),

                const SizedBox(height: 24),

                // App Stats
                _buildSection('Your Progress', [
                  _buildStatCard(
                    'Level',
                    '${userData.appState.currentLevel}',
                    Icons.star,
                  ),
                  _buildStatCard('XP', '${userData.appState.xp}', Icons.bolt),
                  _buildStatCard(
                    'Streak',
                    '${userData.appState.streakDays} days',
                    Icons.local_fire_department,
                  ),
                  _buildStatCard(
                    'Sessions',
                    '${userData.appState.totalSessions}',
                    Icons.history,
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ============================================
/// EXAMPLE 2: Edit User Profile
/// ============================================
/// Shows how to update user data
class EditProfileExample extends ConsumerStatefulWidget {
  const EditProfileExample({super.key});

  @override
  ConsumerState<EditProfileExample> createState() => _EditProfileExampleState();
}

class _EditProfileExampleState extends ConsumerState<EditProfileExample> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _schoolController;
  late TextEditingController _cityController;
  String? _selectedGrade;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _schoolController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Get current user profile
      final currentProfile = await ref.read(currentUserProfileProvider.future);
      if (currentProfile == null) throw Exception('No profile found');

      // Create updated profile
      final updatedProfile = currentProfile.copyWith(
        name: _nameController.text.trim(),
        school: _schoolController.text.trim(),
        grade: _selectedGrade,
        city: _cityController.text.trim(),
      );

      // Save using userActionsProvider
      final userActions = ref.read(userActionsProvider.notifier);
      await userActions.updateProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveProfile,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }

          // Initialize controllers with current data
          if (_nameController.text.isEmpty) {
            _nameController.text = profile.name;
            _schoolController.text = profile.school ?? '';
            _cityController.text = profile.city ?? '';
            _selectedGrade = profile.grade;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _schoolController,
                  decoration: const InputDecoration(
                    labelText: 'School',
                    prefixIcon: Icon(Icons.school),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'Grade',
                    prefixIcon: Icon(Icons.grade),
                  ),
                  items: ['6th', '7th', '8th', '9th', '10th', '11th', '12th']
                      .map(
                        (grade) =>
                            DropdownMenuItem(value: grade, child: Text(grade)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedGrade = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ============================================
/// EXAMPLE 3: Award XP After Activity
/// ============================================
/// Shows how to add XP after completing an activity
class BreathingSessionCompleteExample extends ConsumerWidget {
  const BreathingSessionCompleteExample({super.key});

  Future<void> _completeSession(WidgetRef ref, BuildContext context) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    try {
      final userActions = ref.read(userActionsProvider.notifier);

      // Award 10 XP for completing breathing session
      await userActions.addXp(userId, 10);

      // Update streak
      await userActions.updateStreak(userId);

      // Update last active
      await userActions.updateLastActive(userId);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session complete! Earned 10 XP 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to award XP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breathing Session')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Breathing exercise completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _completeSession(ref, context),
              child: const Text('Claim 10 XP'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// EXAMPLE 4: Convenience Providers
/// ============================================
/// Shows how to use shorthand providers
class UserStatsWidgetExample extends ConsumerWidget {
  const UserStatsWidgetExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use convenience providers for specific data
    final level = ref.watch(userLevelProvider);
    final xp = ref.watch(userXpProvider);
    final streak = ref.watch(userStreakProvider);
    final onboarded = ref.watch(userOnboardingStatusProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Level $level'),
            Text('$xp XP'),
            Text('🔥 $streak day streak'),
            if (!onboarded)
              const Text(
                'Complete onboarding!',
                style: TextStyle(color: Colors.orange),
              ),
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// EXAMPLE 5: Home Screen Integration
/// ============================================
/// Complete example of home screen with user data
class HomeScreenExample extends ConsumerWidget {
  const HomeScreenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to profile
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfileExample(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: userDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (userData) {
          if (userData == null) {
            return const Center(child: Text('Please log in'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade700],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatChip('Level ${userData.level}', Icons.star),
                          const SizedBox(width: 12),
                          _buildStatChip('${userData.xp} XP', Icons.bolt),
                          const SizedBox(width: 12),
                          _buildStatChip(
                            '${userData.streakDays} 🔥',
                            Icons.local_fire_department,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Activities
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Activities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActivityCard(
                        'Breathing Exercise',
                        'Calm your mind',
                        Icons.spa,
                        Colors.green,
                      ),
                      _buildActivityCard(
                        'Workshops',
                        'Learn new skills',
                        Icons.school,
                        Colors.purple,
                      ),
                      _buildActivityCard(
                        'Vocabulary',
                        'Expand your knowledge',
                        Icons.book,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: color),
        ],
      ),
    );
  }
}
