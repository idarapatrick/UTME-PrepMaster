import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../services/firestore_service.dart';

class StudyPartnerScreen extends StatelessWidget {
  const StudyPartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Partner'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : AppColors.backgroundPrimary,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Study Partner Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t been matched with a study partner yet. Study partners are automatically matched based on your subjects and study schedule.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // Feature cards
            Card(
              color: isDark ? const Color(0xFF23243B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppColors.dominantPurple,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Smart Matching',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We match you with study partners who share similar subjects and study goals.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: isDark ? const Color(0xFF23243B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppColors.dominantPurple,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Study Together',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Schedule study sessions, share notes, and motivate each other to achieve your goals.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement study partner matching logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Study partner matching coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Find Study Partner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dominantPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
