import 'package:flutter/material.dart';

/// Formatea una duración de sesión de forma legible en español.
///
/// Ejemplos: `30 min`, `1 h`, `1 h 30 min`. Nunca produce cadenas raras como
/// `0h 30m` o duraciones negativas (`-1h -30m`).
String formatDuration(Duration duration) {
  final totalMinutes = duration.inMinutes;
  if (totalMinutes <= 0) return '0 min';

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  if (hours == 0) return '$minutes min';
  if (minutes == 0) return '$hours h';
  return '$hours h $minutes min';
}

/// Formatea una hora del día como `HH:mm` (24 h).
String formatTimeOfDay(TimeOfDay time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
