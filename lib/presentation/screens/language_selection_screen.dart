import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_helper.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize language when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LanguageProvider>().initializeLanguage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.getBackgroundPrimary(context),
      body: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildLanguageOptions(context, languageProvider),
                const SizedBox(height: 32),
                _buildInfoCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Language',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your preferred language for the app interface. This will affect all text and labels throughout the application.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.getTextSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOptions(BuildContext context, LanguageProvider languageProvider) {
    return Column(
      children: languageProvider.allLanguages.entries.map((entry) {
        final languageCode = entry.key;
        final languageName = entry.value;
        final isSelected = languageProvider.currentLanguage == languageCode;

        return Card(
          color: isSelected 
            ? AppColors.dominantPurple.withValues(alpha: 0.1)
            : AppColors.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected 
              ? BorderSide(color: AppColors.dominantPurple, width: 2)
              : BorderSide.none,
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                  ? AppColors.dominantPurple 
                  : AppColors.getTextSecondary(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _getLanguageFlag(languageCode),
                  style: TextStyle(
                    fontSize: 20,
                    color: isSelected ? Colors.white : AppColors.getTextSecondary(context),
                  ),
                ),
              ),
            ),
            title: Text(
              languageName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected 
                  ? AppColors.dominantPurple 
                  : AppColors.getTextPrimary(context),
              ),
            ),
            subtitle: Text(
              _getLanguageDescription(languageCode),
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
              ),
            ),
            trailing: isSelected 
              ? Icon(
                  Icons.check_circle,
                  color: AppColors.dominantPurple,
                  size: 24,
                )
              : Icon(
                  Icons.radio_button_unchecked,
                  color: AppColors.getTextSecondary(context),
                  size: 24,
                ),
            onTap: () => _selectLanguage(context, languageProvider, languageCode),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      color: AppColors.getCardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.dominantPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Note',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Language changes will take effect immediately. Some content may still appear in English if translations are not yet available.',
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌐';
    }
  }

  String _getLanguageDescription(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English - Default language';
      case 'fr':
        return 'Français - Langue française';
      default:
        return 'Language description';
    }
  }

  void _selectLanguage(BuildContext context, LanguageProvider languageProvider, String languageCode) async {
    await languageProvider.changeLanguage(languageCode);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Language changed to ${languageProvider.allLanguages[languageCode]}',
          ),
          backgroundColor: AppColors.dominantPurple,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
} 