import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RankBadge extends StatelessWidget {
  final int rank;
  final double size;

  const RankBadge({super.key, required this.rank, this.size = 36});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color textColor;

    switch (rank) {
      case 1:
        badgeColor = Colors.amber;
        textColor = AppColors.dominantPurple;
        break;
      case 2:
        badgeColor = Colors.grey;
        textColor = Colors.white;
        break;
      case 3:
        badgeColor = Colors.brown.shade500;
        textColor = Colors.white;
        break;
      default:
        badgeColor = AppColors.dominantPurple.withValues(alpha: 0.1);
        textColor = AppColors.dominantPurple;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: rank > 3
            ? Border.all(color: AppColors.dominantPurple, width: 1.5)
            : null,
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
