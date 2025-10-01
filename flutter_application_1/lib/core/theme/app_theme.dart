import 'package:flutter/material.dart';

/// Application theme configuration (Single Responsibility)
class AppTheme {
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color successGreen = Color(0xFF34C759);
  static const Color warningOrange = Color(0xFFFF9500);
  static const Color dangerRed = Color(0xFFFF3B30);
  static const Color purple = Color(0xFF5856D6);
  static const Color grey = Color(0xFF8E8E93);

  static const Color proteinRed = Color(0xFFFF6B6B);
  static const Color carbsTeal = Color(0xFF4ECDC4);
  static const Color fatYellow = Color(0xFFFFD93D);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: '.SF Pro Text',
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
      ),
    );
  }

  static BoxShadow get cardShadow {
    return BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    );
  }
}
