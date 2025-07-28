import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badges'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.dominantPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.dominantPurple.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dominantPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievement Progress',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '12 of 25 badges unlocked',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 12 / 25,
                        backgroundColor: AppColors.borderLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.dominantPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Study Badges
          _buildBadgeSection(context, 'Study Badges', [
            _buildBadgeTile(
              context,
              icon: Icons.school,
              title: 'First Steps',
              description: 'Complete your first practice test',
              isUnlocked: true,
              progress: 1.0,
              totalRequired: 1,
            ),
            _buildBadgeTile(
              context,
              icon: Icons.timer,
              title: 'Time Master',
              description: 'Complete 10 timed practice sessions',
              isUnlocked: false,
              progress: 7,
              totalRequired: 10,
            ),
            _buildBadgeTile(
              context,
              icon: Icons.local_fire_department,
              title: 'Study Streak',
              description: 'Study for 7 consecutive days',
              isUnlocked: true,
              progress: 1.0,
              totalRequired: 7,
            ),
            _buildBadgeTile(
              context,
              icon: Icons.analytics,
              title: 'Analytics Expert',
              description: 'View your progress report 5 times',
              isUnlocked: false,
              progress: 3,
              totalRequired: 5,
            ),
          ]),

          const SizedBox(height: 24),

          // Subject Badges
          _buildBadgeSection(context, 'Subject Badges', [
            _buildBadgeTile(
              context,
              icon: Icons.calculate,
              title: 'Math Wizard',
              description: 'Score 80%+ in Mathematics',
              isUnlocked: true,
              progress: 1.0,
              totalRequired: 1,
            ),
            _buildBadgeTile(
              context,
              icon: Icons.science,
              title: 'Science Explorer',
              description: 'Complete all Physics topics',
              isUnlocked: false,
              progress: 0.6,
              totalRequired: 1,
            ),
            _buildBadgeTile(
              context,
              icon: Icons.language,
              title: 'English Master',
              description: 'Score 90%+ in English',
              isUnlocked: false,
              progress: 0.7,
              totalRequired: 1,
            ),
            _buildBadgeTile(
              context,
              icon: Icons.history_edu,
              title: 'History Buff',
              description: 'Complete all History topics',
              isUnlocked: false,
              progress: 0.3,
              totalRequired: 1,
            ),
          ]),

          const SizedBox(height: 24),

          // Special Badges
          _buildBadgeSection(context, 'Special Badges', [
            _buildBadgeTile(
              context,
              icon: Icons.psychology,
              title: 'AI Tutor',
              description: 'Use AI tutor feature 10 times',
              isUnlocked: false,
              progress: 4,
              totalRequired: 10,
            ),
            _buildBadgeTile(
              context,
              icon: Icons.quiz,
              title: 'Mock Test Champion',
              description: 'Complete 5 full mock tests',
              isUnlocked: false,
              progress: 2,
              totalRequired: 5,
            ),
            _buildBadgeTile(
              context,
              icon: Icons.share,
              title: 'Social Learner',
              description: 'Share your progress 3 times',
              isUnlocked: false,
              progress: 1,
              totalRequired: 3,
            ),
            _buildBadgeTile(
              context,
              icon: Icons.star,
              title: 'Perfect Score',
              description: 'Get 100% on any practice test',
              isUnlocked: false,
              progress: 0,
              totalRequired: 1,
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBadgeSection(
    BuildContext context,
    String title,
    List<Widget> badges,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(children: badges),
        ),
      ],
    );
  }

  Widget _buildBadgeTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isUnlocked,
    required double progress,
    required int totalRequired,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnlocked
                ? AppColors.accentAmber.withValues(alpha: 0.2)
                : AppColors.borderLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isUnlocked ? AppColors.accentAmber : AppColors.textTertiary,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            if (isUnlocked) ...[
              const SizedBox(width: 8),
              Icon(Icons.verified, color: AppColors.accentAmber, size: 16),
            ],
          ],
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${progress.toStringAsFixed(1)} / $totalRequired',
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (progress / totalRequired).clamp(0.0, 1.0),
              backgroundColor: AppColors.borderLight,
              color: isUnlocked
                  ? AppColors.accentAmber
                  : AppColors.dominantPurple,
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }
}
