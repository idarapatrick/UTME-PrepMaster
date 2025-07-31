import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_helper.dart';
import '../../data/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('soundEnabled', _soundEnabled);
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
          (route) => false,
        );
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
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 24,
              ),
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
                        Icon(
                          Icons.warning_amber,
                          color: Colors.red,
                          size: 20,
                        ),
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
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/onboarding',
            (route) => false,
          );
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

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      color: cardColor ?? AppColors.getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? AppColors.dominantPurple,
        ),
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
            color: textColor?.withValues(alpha: 0.7) ?? AppColors.getTextSecondary(context),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
              Card(
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
                    value: _isDarkMode,
                    onChanged: (value) async {
                      setState(() {
                        _isDarkMode = value;
                      });
                      await _saveSettings();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Theme changed to ${value ? 'dark' : 'light'} mode. Restart app to see changes.'),
                            backgroundColor: AppColors.dominantPurple,
                          ),
                        );
                      }
                    },
                    activeColor: AppColors.dominantPurple,
                  ),
                ),
              ),
              Card(
                color: AppColors.getCardColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: AppColors.dominantPurple,
                  ),
                  title: Text(
                    'Notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  subtitle: Text(
                    'Enable push notifications',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      await _saveSettings();
                    },
                    activeColor: AppColors.dominantPurple,
                  ),
                ),
              ),
              Card(
                color: AppColors.getCardColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.volume_up,
                    color: AppColors.dominantPurple,
                  ),
                  title: Text(
                    'Sound Effects',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  subtitle: Text(
                    'Enable app sound effects',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                  trailing: Switch(
                    value: _soundEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _soundEnabled = value;
                      });
                      await _saveSettings();
                    },
                    activeColor: AppColors.dominantPurple,
                  ),
                ),
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
                cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
                textColor: AppColors.getTextPrimary(context),
                iconColor: AppColors.dominantPurple,
              ),
              _buildSettingTile(
                context: context,
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and all data',
                onTap: () => _showDeleteAccountDialog(context),
                cardColor: isDark ? const Color(0xFF23243B) : Colors.white,
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
                        style: TextStyle(color: AppColors.getTextSecondary(context)),
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