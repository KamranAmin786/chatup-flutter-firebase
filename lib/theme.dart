import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0B141A);
  static const surface = Color(0xFF111B21);
  static const surfaceLight = Color(0xFF202C33);
  static const primary = Color(0xFF00A884);
  static const myBubble = Color(0xFF005C4B);
  static const otherBubble = Color(0xFF202C33);
  static const textPrimary = Color(0xFFE9EDEF);
  static const textSecondary = Color(0xFF8696A0);
  static const readTick = Color(0xFF53BDEB);
}

class AppTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.black,
    ),
  );
}
