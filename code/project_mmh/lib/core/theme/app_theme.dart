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
      displayLarge: GoogleFonts.outfit(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.bold,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.outfit(
        textStyle: base.displayMedium,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.8,
      ),
      displaySmall: GoogleFonts.outfit(
        textStyle: base.displaySmall,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.outfit(
        textStyle: base.headlineLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.outfit(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      headlineSmall: GoogleFonts.outfit(
        textStyle: base.headlineSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.outfit(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.outfit(
        textStyle: base.titleMedium,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: GoogleFonts.outfit(
        textStyle: base.titleSmall,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.outfit(
        textStyle: base.bodyLarge,
        letterSpacing: -0.1,
      ),
      bodyMedium: GoogleFonts.outfit(
        textStyle: base.bodyMedium,
        letterSpacing: -0.1,
      ),
      bodySmall: GoogleFonts.outfit(textStyle: base.bodySmall),
      labelLarge: GoogleFonts.outfit(
        textStyle: base.labelLarge,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.outfit(
        textStyle: base.labelMedium,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: GoogleFonts.outfit(
        textStyle: base.labelSmall,
        fontWeight: FontWeight.w500,
      ),
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
      textTheme: _buildTextTheme(base.textTheme).apply(
        bodyColor: _lightText,
        displayColor: _lightText,
        fontFamily: GoogleFonts.outfit().fontFamily,
      ),
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
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _lightText,
          letterSpacing: -0.4,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightText,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
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
      textTheme: _buildTextTheme(base.textTheme).apply(
        bodyColor: _darkText,
        displayColor: _darkText,
        fontFamily: GoogleFonts.outfit().fontFamily,
      ),
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
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _darkText,
          letterSpacing: -0.4,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkSurface,
        contentTextStyle: GoogleFonts.outfit(color: _darkText, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }
}
