import 'package:flutter/material.dart';

/// Paleta y utilidades de color para las clínicas. Fuente única para:
/// - la lista de colores elegibles (`ClinicPalette.colors`)
/// - convertir el texto guardado en BD ↔ `Color` (`parse` / `toHex`)
///
/// Reemplaza las ~6 copias divergentes de `_parseColor` / `_hexToColor`.
class ClinicPalette {
  ClinicPalette._();

  static const List<Color> colors = [
    Color(0xFFFF3B30), // iOS Red
    Color(0xFFFF9500), // iOS Orange
    Color(0xFFFFCC00), // iOS Yellow
    Color(0xFF34C759), // iOS Green
    Color(0xFF00C7BE), // iOS Mint
    Color(0xFF30B0C7), // iOS Teal
    Color(0xFF32ADE6), // iOS Cyan
    Color(0xFF007AFF), // iOS Blue
    Color(0xFF5856D6), // iOS Indigo
    Color(0xFFAF52DE), // iOS Purple
    Color(0xFFFF2D55), // iOS Pink
    Color(0xFFA2845E), // iOS Brown
  ];

  /// Color usado cuando el valor guardado es inválido o está vacío.
  static const Color fallback = Color(0xFF007AFF);

  /// Formatos aceptados: `#RRGGBB`, `RRGGBB`, `#AARRGGBB`, `0xAARRGGBB`,
  /// y el formato legado `Color(0x...)`.
  static Color parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    var value = raw.trim();

    final legacy = RegExp(r'Color\(0x([0-9a-fA-F]+)\)').firstMatch(value);
    if (legacy != null) {
      final v = int.tryParse(legacy.group(1)!, radix: 16);
      return v == null ? fallback : Color(v);
    }

    value = value
        .replaceAll('#', '')
        .replaceAll('0x', '')
        .replaceAll('0X', '')
        .trim();

    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return fallback;
    if (value.length <= 6) return Color(parsed + 0xFF000000);
    return Color(parsed);
  }

  /// Serializa a `#RRGGBB` (formato que espera la BD y el picker).
  static String toHex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
