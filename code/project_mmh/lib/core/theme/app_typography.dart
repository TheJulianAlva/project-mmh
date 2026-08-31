import 'package:flutter/material.dart';

/// Roles tipográficos nombrados por uso. Outfit para títulos, etiquetas y
/// métricas; IBM Plex Sans para cuerpo y texto largo. Ambas empaquetadas
/// como asset (ver pubspec.yaml) — sin descarga de red.
abstract final class AppText {
  static const String displayFamily = 'Outfit';
  static const String bodyFamily = 'IBM Plex Sans';

  static const TextStyle screenTitle = TextStyle(
    fontFamily: displayFamily,
    fontSize: 27,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: displayFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Se usa con `.toUpperCase()` en el texto (Flutter no tiene text-transform).
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: displayFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.6,
  );

  static const TextStyle metric = TextStyle(
    fontFamily: displayFamily,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
}

/// Construye el `TextTheme` M3 a partir de los roles, para que los widgets
/// Material sin estilo explícito ya salgan con la tipografía correcta.
/// Los colores se aplican después con `.apply(bodyColor:, displayColor:)`.
TextTheme buildTextTheme(Brightness brightness) {
  const display = AppText.displayFamily;
  const bodyF = AppText.bodyFamily;
  return const TextTheme(
    displayLarge: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
    ),
    displayMedium: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
    ),
    displaySmall: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineLarge: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
    ),
    headlineSmall: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    ),
    titleLarge: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    titleMedium: TextStyle(fontFamily: display, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontFamily: display, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontFamily: bodyF, height: 1.45),
    bodyMedium: TextStyle(fontFamily: bodyF, height: 1.45),
    bodySmall: TextStyle(fontFamily: bodyF),
    labelLarge: TextStyle(fontFamily: display, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontFamily: display, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(
      fontFamily: display,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.6,
    ),
  );
}
