import 'package:flutter/material.dart';

class AppColors {
  static const verdeProfundo = Color(0xFF0B3C49);
  static const turquesa = Color(0xFF1B998B);
  static const naranja = Color(0xFFF46036);
  static const crema = Color(0xFFFFF8EE);
  static const perdido = Color(0xFFD1495B);
  static const encontrado = Color(0xFF2E8B57);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.turquesa,
    primary: AppColors.verdeProfundo,
    secondary: AppColors.naranja,
    surface: AppColors.crema,
  );

  OutlineInputBorder borde(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.crema,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.verdeProfundo,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: borde(Colors.black26),
      enabledBorder: borde(Colors.black26),
      focusedBorder: borde(AppColors.turquesa),
      errorBorder: borde(AppColors.perdido),
      focusedErrorBorder: borde(AppColors.perdido),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.naranja,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.naranja,
      foregroundColor: Colors.white,
    ),
  );
}
