import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_helper.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: ResponsiveHelper.responsiveSingleChildScrollView(
        context: context,
        child: Padding(
          padding: ResponsiveHelper.getResponsiveEdgeInsets(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 2),
              
              // Illustration
              Container(
                height: ResponsiveHelper.getResponsiveIconSize(context, 180),
                width: ResponsiveHelper.getResponsiveIconSize(context, 180),
                decoration: BoxDecoration(
                  color: AppColors.dominantPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveIconSize(context, 90)),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 100),
                  color: AppColors.dominantPurple,
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 2),
              
              // Title
              Text(
                'UTME PrepMaster',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.dominantPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context) / 2),
              
              // Subtitle
              Text(
                'Your smart study companion for UTME success!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 3),
              
              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.getResponsiveButtonHeight(context),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dominantPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsivePadding(context) / 2),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
              
              // Features
              _buildFeaturesSection(context),
              
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      children: [
        _buildFeatureItem(
          context,
          Icons.psychology,
          'AI-Powered Learning',
          'Get personalized study recommendations and explanations',
          AppColors.dominantPurple,
        ),
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
        _buildFeatureItem(
          context,
          Icons.quiz,
          'Practice Tests',
          'Access thousands of UTME practice questions',
          AppColors.subjectBlue,
        ),
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context)),
        _buildFeatureItem(
          context,
          Icons.trending_up,
          'Track Progress',
          'Monitor your performance and improvement over time',
          AppColors.accentAmber,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context) / 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsivePadding(context) / 2),
          ),
          child: Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getResponsiveIconSize(context, 24),
          ),
        ),
        SizedBox(width: ResponsiveHelper.getResponsivePadding(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
