import 'package:flutter/material.dart';

/// Paleta do guia visual do Saborê.
abstract final class AppColors {
  static const background = Color(0xFFF7F4EE);
  static const green = Color(0xFF245B4A);
  static const ink = Color(0xFF1E3D33);
  static const muted = Color(0xFF6B706B);
  static const border = Color(0xFFE2E1DA);
  static const softGreen = Color(0xFFE5ECE5);
  static const imageBackground = Color(0xFFE7E3D6);
  static const skeleton = Color(0xFFE3E5DE);
  static const accent = Color(0xFFC0532B);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.green).copyWith(
    primary: AppColors.green,
    onPrimary: Colors.white,
    surface: AppColors.background,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    surfaceContainerLowest: Colors.white,
    surfaceContainerHighest: AppColors.imageBackground,
    secondaryContainer: AppColors.softGreen,
    onSecondaryContainer: AppColors.ink,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    error: AppColors.accent,
  );

  const radius = BorderRadius.all(Radius.circular(12));
  const buttonText = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

  OutlineInputBorder inputBorder(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: const RoundedRectangleBorder(borderRadius: radius),
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.green,
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: AppColors.green),
        shape: const RoundedRectangleBorder(borderRadius: radius),
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.green,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.muted,
      border: inputBorder(AppColors.border),
      enabledBorder: inputBorder(AppColors.border),
      focusedBorder: inputBorder(AppColors.green, 1.5),
      errorBorder: inputBorder(AppColors.accent),
      focusedErrorBorder: inputBorder(AppColors.accent, 1.5),
      errorStyle: const TextStyle(color: AppColors.accent),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.softGreen,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 13,
          color: states.contains(WidgetState.selected) ? AppColors.ink : AppColors.muted,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppColors.ink : AppColors.muted,
        ),
      ),
    ),
  );
}
