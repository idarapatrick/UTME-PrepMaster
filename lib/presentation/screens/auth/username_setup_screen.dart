import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_helper.dart';
import '../../../data/services/username_service.dart';
import '../../../data/services/firestore_service.dart';

class UsernameSetupScreen extends StatefulWidget {
  final User user;

  const UsernameSetupScreen({super.key, required this.user});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _isChecking = false;
  String? _validationMessage;
  bool _isValid = false;
  bool _isAvailable = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _validateUsername(String username) async {
    if (username.isEmpty) {
      setState(() {
        _validationMessage = null;
        _isValid = false;
        _isAvailable = false;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _validationMessage = null;
    });

    try {
      final result = await UsernameService.validateAndCheckUsername(username);

      setState(() {
        _isChecking = false;
        _isValid = result['isValid'];
        _isAvailable = result['isAvailable'];
        _validationMessage = result['error'];
      });
    } catch (e) {
      setState(() {
        _isChecking = false;
        _validationMessage = 'Error checking username';
      });
    }
  }

  Future<void> _saveUsername() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isValid || !_isAvailable) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user profile with username
      await FirestoreService.updateUserProfile(widget.user.uid, {
        'username': _usernameController.text.toLowerCase(),
      });

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving username: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : AppColors.backgroundSecondary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveHelper.getResponsivePadding(context),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Header
                Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: ResponsiveHelper.getResponsiveIconSize(context, 80),
                      color: AppColors.dominantPurple,
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsivePadding(context),
                    ),
                    Text(
                      'Choose Your Username',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          24,
                        ),
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height:
                          ResponsiveHelper.getResponsivePadding(context) / 2,
                    ),
                    Text(
                      'This will be your display name on the leaderboard',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          16,
                        ),
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context) * 2,
                ),

                // Username Input
                TextFormField(
                  controller: _usernameController,
                  onChanged: _validateUsername,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: const Icon(Icons.person),
                    suffixIcon: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _isValid && _isAvailable
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : _validationMessage != null
                        ? const Icon(Icons.error, color: Colors.red)
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    if (!_isValid) {
                      return _validationMessage;
                    }
                    if (!_isAvailable) {
                      return _validationMessage;
                    }
                    return null;
                  },
                ),

                // Validation Message
                if (_validationMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _validationMessage!,
                      style: TextStyle(
                        color: _isValid && _isAvailable
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                // Username Rules
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2D3E)
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorderMedium
                          : AppColors.borderMedium,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username Rules:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRule('At least 5 characters long'),
                      _buildRule('All lowercase letters'),
                      _buildRule('Cannot start with a number'),
                      _buildRule('No spaces allowed'),
                      _buildRule(
                        'No special characters (-, (, ), &, %, #, !, etc.)',
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Continue Button
                ElevatedButton(
                  onPressed: (_isValid && _isAvailable && !_isLoading)
                      ? _saveUsername
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dominantPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRule(String rule) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: isDark ? AppColors.darkTextLight : AppColors.textLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextLight : AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
