import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF111315);
  static const surface = Color(0xFF191C1F);
  static const surfaceRaised = Color(0xFF22262A);
  static const divider = Color(0xFF30343A);
  static const text = Color(0xFFF2EFE6);
  static const secondary = Color(0xFFB8B3A8);
  static const yellow = Color(0xFFFFD000);
  static const green = Color(0xFF55C76A);
  static const red = Color(0xFFF05252);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.yellow,
    brightness: Brightness.dark,
    primary: AppColors.yellow,
    surface: AppColors.surface,
    error: AppColors.red,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    dividerColor: AppColors.divider,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: AppColors.text),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: AppColors.text),
      labelLarge: TextStyle(fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.yellow, width: 2),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surfaceRaised,
      contentTextStyle: TextStyle(color: AppColors.text),
    ),
  );
}
