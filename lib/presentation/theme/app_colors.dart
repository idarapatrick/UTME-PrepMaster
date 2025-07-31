import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color dominantPurple = Color(0xFF7C3AED);
  static const Color secondaryGray = Color(0xFF64748B);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color primary = Color(0xFF7C3AED); // Same as dominantPurple

  // Light mode background colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF8FAFC);
  static const Color backgroundTertiary = Color(0xFFF1F5F9);

  // Dark mode background colors
  static const Color darkBackgroundPrimary = Color(0xFF0F172A);
  static const Color darkBackgroundSecondary = Color(0xFF1E293B);
  static const Color darkBackgroundTertiary = Color(0xFF334155);

  // Light mode text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFCBD5E1);

  // Dark mode text colors
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);
  static const Color darkTextLight = Color(0xFF64748B);

  // Border colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF94A3B8);

  // Dark mode border colors
  static const Color darkBorderLight = Color(0xFF334155);
  static const Color darkBorderMedium = Color(0xFF475569);
  static const Color darkBorderDark = Color(0xFF64748B);

  // Error and status colors
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningOrange = Color(0xFFF97316);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Subject colors (enhanced for dark mode)
  static const Color subjectBlue = Color(0xFF2563EB);
  static const Color subjectGreen = Color(0xFF22C55E);
  static const Color subjectRed = Color(0xFFEF4444);
  static const Color subjectPurple = Color(0xFF8B5CF6);
  static const Color subjectOrange = Color(0xFFF97316);
  static const Color subjectPink = Color(0xFFEC4899);

  // Card colors for dark mode
  static const Color darkCardPrimary = Color(0xFF1E293B);
  static const Color darkCardSecondary = Color(0xFF334155);
  static const Color darkCardTertiary = Color(0xFF475569);

  // Gradient colors for dark mode
  static const Color darkGradientStart = Color(0xFF1E293B);
  static const Color darkGradientEnd = Color(0xFF334155);

  // Helper methods for dynamic colors
  static Color getBackgroundPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackgroundPrimary
        : backgroundPrimary;
  }

  static Color getBackgroundSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackgroundSecondary
        : backgroundSecondary;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textSecondary;
  }

  static Color getTextTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextTertiary
        : textTertiary;
  }

  static Color getBorderLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderLight
        : borderLight;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardPrimary
        : Colors.white;
  }

  static Color getCardSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardSecondary
        : backgroundSecondary;
  }

  // Enhanced subject colors that work well in both light and dark modes
  static Color getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'physics':
        return subjectBlue;
      case 'chemistry':
      case 'biology':
        return subjectGreen;
      case 'english':
      case 'literature':
        return subjectRed;
      case 'government':
      case 'economics':
        return subjectPurple;
      case 'geography':
      case 'commerce':
        return subjectOrange;
      case 'christian religious studies':
      case 'islamic studies':
        return subjectPink;
      default:
        return dominantPurple;
    }
  }

  // Get appropriate text color for subject backgrounds
  static Color getSubjectTextColor(Color backgroundColor) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
