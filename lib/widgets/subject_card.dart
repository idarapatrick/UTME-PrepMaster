import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SubjectCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final String imageUrl;
  final Color accentColor;
  final VoidCallback? onTap;
  final String? progressText;
  final Widget? trailing;

  const SubjectCard({
    super.key,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.accentColor,
    this.progressText,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final iconColor = isDark ? Colors.white : accentColor;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentColor, size: 16),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: iconColor, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                    if (progressText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        progressText!,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : AppColors.textSecondary,
                          fontSize: 9,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
