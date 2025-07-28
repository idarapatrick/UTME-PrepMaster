import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          _buildSection(context, 'Profile', [
            _buildSettingTile(
              context,
              icon: Icons.person_outline,
              title: 'Update your personal information',
              subtitle: '',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
            _buildSettingTile(
              context,
              icon: Icons.phone_outlined,
              title: '+234 801 234 5678',
              subtitle: '',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
          ]),

          const SizedBox(height: 24),

          // Preferences Section
          _buildSection(context, 'Preferences', [
            _buildSettingTile(
              context,
              icon: Icons.notifications_outlined,
              title: 'Manage your notification preferences',
              subtitle: '',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
            SwitchListTile(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                Provider.of<ThemeNotifier>(
                  context,
                  listen: false,
                ).toggleTheme(value);
              },
              secondary: const Icon(
                Icons.dark_mode_outlined,
                color: AppColors.dominantPurple,
              ),
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark themes'),
              activeColor: AppColors.dominantPurple,
            ),
            _buildSettingTile(
              context,
              icon: Icons.language_outlined,
              title: 'English',
              subtitle: '',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
          ]),

          const SizedBox(height: 24),

          // Study Section
          _buildSection(context, 'Study', [
            _buildSettingTile(
              context,
              icon: Icons.timer_outlined,
              title: 'Set daily study reminders',
              subtitle: '',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
            _buildSettingTile(
              context,
              icon: Icons.analytics_outlined,
              title: 'View your study progress',
              subtitle: '',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
          ]),

          const SizedBox(height: 24),

          // Support Section
          _buildSection(context, 'Support', [
            _buildSettingTile(
              context,
              icon: Icons.help_outline,
              title: 'Help & FAQ',
              subtitle: '',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
            _buildSettingTile(
              context,
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: '',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
            _buildSettingTile(
              context,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version 1.0.0',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
          ]),

          const SizedBox(height: 24),

          // Account Section
          _buildSection(context, 'Account', [
            _buildSettingTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () {
                // TODO: Navigate to privacy policy
              },
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
            _buildSettingTile(
              context,
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'Read our terms of service',
              onTap: () {
                // TODO: Navigate to terms of service
              },
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
          ]),
          const SizedBox(height: 24),
          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: AppColors.dominantPurple),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.dominantPurple,
                side: const BorderSide(color: AppColors.dominantPurple),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _showLogoutDialog(context),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.dominantPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = cardColor;
    return Card(
      color: tileColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: TextStyle(color: textColor.withOpacity(0.7)),
              )
            : null,
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
