import 'package:flutter/material.dart';
import 'package:cinewave/core/constants/app_constants.dart';

class AppTheme {
  static ThemeData getTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(int.parse(AppConstants.primaryColor.replaceAll('#', '0xFF'))),
      scaffoldBackgroundColor: Color(int.parse(AppConstants.backgroundColor.replaceAll('#', '0xFF'))),
      colorScheme: ColorScheme.dark(
        primary: Color(int.parse(AppConstants.primaryColor.replaceAll('#', '0xFF'))),
        surface: Color(int.parse(AppConstants.backgroundColor.replaceAll('#', '0xFF'))),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
        bodyMedium: TextStyle(color: Color(0xFFB3B3B3), fontSize: 14),
        titleLarge: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        labelLarge: TextStyle(color: Color(0xFFE50914), fontSize: 14, fontWeight: FontWeight.w600),
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
        color: Color(int.parse(AppConstants.cardBackgroundColor.replaceAll('#', '0xFF'))),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}