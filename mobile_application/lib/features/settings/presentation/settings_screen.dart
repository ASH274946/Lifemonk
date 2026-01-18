import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/feedback_overlay.dart';
import '../../../shared/services/local_storage_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = LocalStorageService.getBool('notifications_enabled') ?? true;
  bool _darkMode = LocalStorageService.getBool('dark_mode_enabled') ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('ACCOUNT'),
            _buildSettingItem(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              onTap: () => FeedbackOverlay.info(context, 'Edit profile coming soon'),
            ),
            _buildSettingItem(
              icon: Icons.lock_outline_rounded,
              title: 'Change Password',
              onTap: () => FeedbackOverlay.info(context, 'Reset password email sent', emoji: '📧'),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('PREFERENCES'),
            _buildSettingItem(
              icon: Icons.notifications_none_rounded,
              title: 'Push Notifications',
              trailing: Switch.adaptive(
                value: _notificationsEnabled,
                activeColor: const Color(0xFF4A7FD4),
                onChanged: (value) async {
                  setState(() => _notificationsEnabled = value);
                  await LocalStorageService.setBool('notifications_enabled', value);
                },
              ),
            ),
            _buildSettingItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Switch.adaptive(
                value: _darkMode,
                activeColor: const Color(0xFF4A7FD4),
                onChanged: (value) async {
                  setState(() => _darkMode = value);
                  await LocalStorageService.setBool('dark_mode_enabled', value);
                  if (context.mounted) {
                    FeedbackOverlay.info(context, 'Theme change will apply on restart');
                  }
                },
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('SUPPORT'),
            _buildSettingItem(
              icon: Icons.help_outline_rounded,
              title: 'Help Center',
              onTap: () => FeedbackOverlay.info(context, 'FAQ page coming soon'),
            ),
            _buildSettingItem(
              icon: Icons.bug_report_outlined,
              title: 'Report an Issue',
              onTap: () => FeedbackOverlay.info(context, 'Bug report form coming soon'),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('LEGAL'),
            _buildSettingItem(
              icon: Icons.description_outlined,
              title: 'Privacy Policy',
              onTap: () => FeedbackOverlay.info(context, 'Privacy policy coming soon'),
            ),
            _buildSettingItem(
              icon: Icons.gavel_outlined,
              title: 'Terms of Service',
              onTap: () => FeedbackOverlay.info(context, 'Terms and conditions coming soon'),
            ),

            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () => _showDeleteConfirmation(),
                child: const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Version 1.0.0 (Build 124)',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.backgroundGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Delete Account?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This action is permanent and cannot be undone. All your progress will be lost.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        FeedbackOverlay.error(context, 'Account deletion disabled in demo');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
