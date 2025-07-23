import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AchievementBadge extends StatelessWidget {
  final String achievement;
  final double size;
  
  const AchievementBadge({
    super.key,
    required this.achievement,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getAchievementData(achievement);
    
    return Tooltip(
      message: achievement.replaceAll('-', ' ').toTitleCase(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Icon(
            icon,
            size: size * 0.6,
            color: color,
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getAchievementData(String achievement) {
    switch (achievement.toLowerCase()) {
      case 'top-1':
        return (Icons.emoji_events, Colors.amber);
      case 'streak-7':
        return (Icons.local_fire_department, Colors.orange);
      case 'perfect-score':
        return (Icons.star, Colors.yellow);
      case 'fast-learner':
        return (Icons.bolt, Colors.blue);
      case 'bookworm':
        return (Icons.menu_book, Colors.green);
      default:
        return (Icons.verified, AppColors.dominantPurple);
    }
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}