import 'package:flutter/material.dart';

/// App color palette based on design
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF8ECAE6); // Light blue for onboarding button
  static const Color primaryDark = Color(0xFF1565C0);

  // Background colors
  static const Color backgroundLight = Color(0xFFFAFAFA); // Splash background
  static const Color backgroundCream = Color(0xFFFAF8F5); // Login/OTP background (warm cream)
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF5F7FA); // Onboarding background

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Black text
  static const Color textSecondary = Color(0xFF6B7280); // Gray text
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFFB0B0B0); // Placeholder text

  // Button colors
  static const Color buttonBlack = Color(0xFF1A1A1A);
  static const Color buttonWhite = Color(0xFFFFFDF7);
  static const Color buttonLightBlue = Color(0xFF8ECAE6); // Onboarding continue button

  // Input field colors
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE8E8E8);
  static const Color inputBorderFocused = Color(0xFF1A1A1A);

  // Onboarding colors
  static const Color dropdownIcon = Color(0xFF6B7280);
}

/// App theme configuration
class AppTheme {
  AppTheme._();

  /// Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.backgroundLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }

  /// Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
    );
  }
}
