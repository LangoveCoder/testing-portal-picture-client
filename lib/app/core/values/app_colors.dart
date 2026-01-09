import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (same for both themes)
  static const Color primary = Color(0xFF667eea);
  static const Color primaryDark = Color(0xFF5568d3);
  static const Color accent = Color(0xFF48bb78);

  // Status Colors (same for both themes)
  static const Color success = Color(0xFF48bb78);
  static const Color error = Color(0xFFf56565);
  static const Color warning = Color(0xFF8B5A2B); // Changed from bright orange to dark brown
  static const Color info = Color(0xFF4299e1);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightInputBackground = Color(0xFFF8FAFC);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCardBackground = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF94A3B8);
  static const Color darkInputBackground = Color(0xFF334155);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF667eea);
  static const Color gradientEnd = Color(0xFF764ba2);

  // Context-aware colors
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBackground 
        : lightBackground;
  }

  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkCardBackground 
        : lightCardBackground;
  }

  static Color getBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBorder 
        : lightBorder;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextPrimary 
        : lightTextPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextSecondary 
        : lightTextSecondary;
  }

  static Color getTextMuted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextMuted 
        : lightTextMuted;
  }

  static Color getInputBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkInputBackground 
        : lightInputBackground;
  }

  static Color getShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.08);
  }

  // Legacy colors for backward compatibility
  static const Color background = lightBackground;
  static const Color cardBackground = lightCardBackground;
  static const Color border = lightBorder;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = lightTextMuted;
  static Color shadow = Colors.black.withOpacity(0.08);
}
