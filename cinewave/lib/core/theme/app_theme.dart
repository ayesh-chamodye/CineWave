import 'package:flutter/material.dart';
import 'package:cinewave/core/constants/app_constants.dart';

class AppTheme {
  static Color get _primaryColor => Color(int.parse(
        AppConstants.primaryColor.replaceAll('#', '0xFF'),
      ));

  static ThemeData getTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: Color(int.parse(
        AppConstants.backgroundColor.replaceAll('#', '0xFF'),
      )),
      colorScheme: ColorScheme.dark(
        primary: _primaryColor,
        surface: Color(
          int.parse(AppConstants.backgroundColor.replaceAll('#', '0xFF')),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
        bodyMedium: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 14),
        titleLarge: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(
          color: _primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white, size: 28),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: Color(int.parse(
          AppConstants.cardBackgroundColor.replaceAll('#', '0xFF'),
        )),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
