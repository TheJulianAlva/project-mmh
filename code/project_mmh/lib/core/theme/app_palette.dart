import 'package:flutter/material.dart';

/// Primitivas de color. Valores crudos, sin significado semántico.
/// NO usar fuera de `lib/core/theme/`.
abstract final class AppPalette {
  // Marca
  static const Color berry = Color(0xFFD81B60);
  static const Color berrySoft = Color(0xFFF8BBD0);
  static const Color berryDeep = Color(0xFF880E4F);
  static const Color berryPastel = Color(0xFFF48FB1);
  static const Color teal = Color(0xFF009688);
  static const Color tealPastel = Color(0xFF80CBC4);

  // Neutros
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color inkLight = Color(0xFF37474F);
  static const Color grey900 = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color inkDark = Color(0xFFECEFF1);

  // "on-" de marca en oscuro
  static const Color onPrimaryDark = Color(0xFF380016);
  static const Color onSecondaryDark = Color(0xFF003731);

  // Error
  static const Color errorLight = Color(0xFFB00020);
  static const Color errorDark = Color(0xFFCF6679);

  // Estado — claro
  static const Color successLight = Color(0xFF2E7D32);
  static const Color onSuccessLight = Colors.white;
  static const Color warningLight = Color(0xFFED6C02);
  static const Color onWarningLight = Colors.white;
  static const Color infoLight = Color(0xFF0288D1);
  static const Color onInfoLight = Colors.white;

  // Estado — oscuro
  static const Color successDark = Color(0xFF81C784);
  static const Color onSuccessDark = Color(0xFF0A2E0C);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color onWarningDark = Color(0xFF3A2400);
  static const Color infoDark = Color(0xFF4FC3F7);
  static const Color onInfoDark = Color(0xFF00263A);
}
