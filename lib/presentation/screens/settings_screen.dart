import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_helper.dart';
import '../../data/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../providers/language_provider.dart';
import '../providers/study_preferences_provider.dart';
import 'language_selection_screen.dart';
import 'study_preferences_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize preferences when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeNotifier>().initializeTheme();
      context.read<LanguageProvider>().initializeLanguage();
      context.read<StudyPreferencesProvider>().initializePreferences();
    });
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: AppColors.dominantPurple, size: 24),
              const SizedBox(width: 8),
              const Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout? You will need to sign in again to access your account.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dominantPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/onboarding', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'This action cannot be undone!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Your account will be permanently deleted\n'
                      '• All your data will be removed\n'
                      '• Progress and achievements will be lost\n'
                      '• You will need to create a new account to use the app again',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performDeleteAccount(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeleteAccount(BuildContext context) async {
    try {
      final authService = AuthService();

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Deleting account...'),
              ],
            ),
          );
        },
      );

      // Perform account deletion
      final result = await authService.deleteAccount();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (result.isSuccess) {
        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Clear SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Navigate to onboarding screen
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/onboarding', (route) => false);
        }
      } else {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? cardColor,
    Color? textColor,
    Color? iconColor,
  }) {
    return Card(
      color: cardColor ?? AppColors.getCardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.dominantPurple),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.getTextPrimary(context),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color:
                textColor?.withValues(alpha: 0.7) ??
                AppColors.getTextSecondary(context),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.getTextSecondary(context),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.getBackgroundPrimary(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings Section
            _buildSection(context, 'App Settings', [
              Consumer<ThemeNotifier>(
                builder: (context, themeNotifier, child) {
                  return Card(
                    color: AppColors.getCardColor(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.dark_mode,
                        color: AppColors.dominantPurple,
                      ),
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      subtitle: Text(
                        'Switch between light and dark themes',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                      trailing: Switch(
                        value: themeNotifier.themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          themeNotifier.toggleTheme(value);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Theme changed to ${value ? 'dark' : 'light'} mode.',
                                ),
                                backgroundColor: AppColors.dominantPurple,
                              ),
                            );
                          }
                        },
                        activeColor: AppColors.dominantPurple,
                      ),
                    ),
                  );
                },
              ),
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return Card(
                    color: AppColors.getCardColor(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.language,
                        color: AppColors.dominantPurple,
                      ),
                      title: Text(
                        'Language',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      subtitle: Text(
                        'Choose your preferred language',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            languageProvider.currentLanguageName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.dominantPurple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageSelectionScreen(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ]),

            // Study Preferences Section
            _buildSection(context, 'Study Preferences', [
              _buildSettingTile(
                context: context,
                icon: Icons.school,
                title: 'Study Settings',
                subtitle: 'Configure study reminders and session duration',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudyPreferencesScreen(),
                    ),
                  );
                },
              ),
            ]),

            // Account Management Section
            _buildSection(context, 'Account Management', [
              _buildSettingTile(
                context: context,
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: _logout,
                cardColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF23243B)
                    : Colors.white,
                textColor: AppColors.getTextPrimary(context),
                iconColor: AppColors.dominantPurple,
              ),
              _buildSettingTile(
                context: context,
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and all data',
                onTap: () => _showDeleteAccountDialog(context),
                cardColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF23243B)
                    : Colors.white,
                textColor: Colors.red,
                iconColor: Colors.red,
              ),
            ]),

            // App Information Section
            _buildSection(context, 'App Information', [
              _buildSettingTile(
                context: context,
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'UTME PrepMaster',
                    applicationVersion: '1.0.0',
                    applicationIcon: Icon(
                      Icons.school,
                      color: AppColors.dominantPurple,
                      size: 48,
                    ),
                    children: [
                      Text(
                        'UTME PrepMaster is your comprehensive study companion for UTME success. '
                        'Access practice tests, AI tutoring, and track your progress.',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  );
                },
              ),
              _buildSettingTile(
                context: context,
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy Policy - Coming Soon'),
                      backgroundColor: AppColors.dominantPurple,
                    ),
                  );
                },
              ),
              _buildSettingTile(
                context: context,
                icon: Icons.description,
                title: 'Terms of Service',
                subtitle: 'Read our terms of service',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terms of Service - Coming Soon'),
                      backgroundColor: AppColors.dominantPurple,
                    ),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
