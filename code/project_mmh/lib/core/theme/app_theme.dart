import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Paleta Claro ---
  static const Color _lightPrimary = Color(0xFFD81B60); // Pink Berry
  static const Color _lightPrimaryVariant = Color(0xFFF8BBD0); // Soft Pink
  static const Color _lightSecondary = Color(0xFF009688); // Teal
  static const Color _lightBackground = Color(0xFFFAFAFA); // Off-White
  static const Color _lightSurface = Color(0xFFFFFFFF); // White
  static const Color _lightText = Color(0xFF37474F); // Blue Grey Dark
  static const Color _lightError = Color(0xFFB00020);

  // --- Paleta Oscuro ---
  static const Color _darkPrimary = Color(0xFFF48FB1); // Pastel Pink
  static const Color _darkPrimaryVariant = Color(0xFF880E4F); // Deep Berry
  static const Color _darkSecondary = Color(0xFF80CBC4); // Pastel Teal
  static const Color _darkBackground = Color(0xFF121212); // Dark Grey
  static const Color _darkSurface = Color(0xFF1E1E1E); // Lighter Dark
  static const Color _darkText = Color(0xFFECEFF1); // Blue Grey Light
  static const Color _darkError = Color(0xFFCF6679);

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.nunito(textStyle: base.displayLarge),
      displayMedium: GoogleFonts.nunito(textStyle: base.displayMedium),
      displaySmall: GoogleFonts.nunito(textStyle: base.displaySmall),
      headlineLarge: GoogleFonts.nunito(textStyle: base.headlineLarge),
      headlineMedium: GoogleFonts.nunito(textStyle: base.headlineMedium),
      headlineSmall: GoogleFonts.nunito(textStyle: base.headlineSmall),
      titleLarge: GoogleFonts.nunito(textStyle: base.titleLarge),
      titleMedium: GoogleFonts.nunito(textStyle: base.titleMedium),
      titleSmall: GoogleFonts.nunito(textStyle: base.titleSmall),
      bodyLarge: GoogleFonts.lato(textStyle: base.bodyLarge),
      bodyMedium: GoogleFonts.lato(textStyle: base.bodyMedium),
      bodySmall: GoogleFonts.lato(textStyle: base.bodySmall),
    );
  }

  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _lightPrimary,
        primaryContainer: _lightPrimaryVariant,
        onPrimary: Colors.white,
        secondary: _lightSecondary,
        onSecondary: Colors.white,
        error: _lightError,
        onError: Colors.white,
        surface: _lightSurface,
        onSurface: _lightText,
      ),
      scaffoldBackgroundColor: _lightBackground,
      textTheme: _buildTextTheme(
        base.textTheme,
      ).apply(bodyColor: _lightText, displayColor: _lightText),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: Colors.black12,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightText.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightText.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        filled: true,
        fillColor: _lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _lightText,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: _darkPrimary,
        primaryContainer: _darkPrimaryVariant,
        onPrimary: Color(0xFF380016), // Dark text on light primary
        secondary: _darkSecondary,
        onSecondary: Color(0xFF003731),
        error: _darkError,
        onError: Colors.black,
        surface: _darkSurface,
        onSurface: _darkText,
      ),
      scaffoldBackgroundColor: _darkBackground,
      textTheme: _buildTextTheme(
        base.textTheme,
      ).apply(bodyColor: _darkText, displayColor: _darkText),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        color: _darkSurface,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkText.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkText.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        filled: true,
        fillColor: _darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimary,
        foregroundColor: Color(0xFF380016),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _darkText,
        ),
      ),
    );
  }
}
