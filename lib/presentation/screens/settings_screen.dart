import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
          ),
        ),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveHelper.responsiveListView(
        context: context,
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

          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 1.5),

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
              secondary: Icon(
                Icons.dark_mode_outlined,
                color: AppColors.dominantPurple,
                size: ResponsiveHelper.getResponsiveIconSize(context, 24),
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
              subtitle: Text(
                'Switch between light and dark themes',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
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

          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 1.5),

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

          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 1.5),

          // Support Section
          _buildSection(context, 'Support', [
            _buildSettingTile(
              context,
              icon: Icons.help_outline,
              title: 'Help & FAQ',
              subtitle: 'Get help and find answers',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
            _buildSettingTile(
              context,
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Help us improve the app',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
            _buildSettingTile(
              context,
              icon: Icons.star_outline,
              title: 'Rate the App',
              subtitle: 'Rate us on the app store',
              onTap: () {},
              cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
              textColor: isDark ? Colors.white : AppColors.textPrimary,
              iconColor: AppColors.dominantPurple,
            ),
          ]),

          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 1.5),

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
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 1.5),
          
          // Sign Out Button
          Padding(
            padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
            child: SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.getResponsiveButtonHeight(context),
              child: OutlinedButton.icon(
                icon: Icon(
                  Icons.logout, 
                  color: AppColors.dominantPurple,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                ),
                label: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dominantPurple,
                  side: const BorderSide(color: AppColors.dominantPurple),
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.getResponsivePadding(context),
                  ),
                ),
                onPressed: () => _showLogoutDialog(context),
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 2),
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
          padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.dominantPurple,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            ),
          ),
        ),
        Container(
          margin: ResponsiveHelper.getResponsiveHorizontalPadding(context),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsivePadding(context) / 2),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsivePadding(context) / 2),
      ),
      elevation: 1,
      child: ListTile(
        leading: Icon(
          icon, 
          color: iconColor, 
          size: ResponsiveHelper.getResponsiveIconSize(context, 28)
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              )
            : null,
        onTap: onTap,
        trailing: Icon(
          Icons.arrow_forward_ios, 
          size: ResponsiveHelper.getResponsiveIconSize(context, 18)
        ),
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
                await _performLogout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();
      
      // Clear all session data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Navigate to onboarding screen
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding',
          (route) => false, // Remove all previous routes from the stack
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      // Even if there's an error, try to navigate to onboarding
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding',
          (route) => false,
        );
      }
    }
  }
}
