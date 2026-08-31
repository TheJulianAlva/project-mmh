import 'package:freezed_annotation/freezed_annotation.dart';

/// Estado de un tratamiento. Ojo: `enProceso` ↔ `'en_proceso'` en BD.
enum EstadoTratamiento {
  @JsonValue('pendiente')
  pendiente,
  @JsonValue('en_proceso')
  enProceso,
  @JsonValue('concluido')
  concluido;

  String get dbValue => switch (this) {
    EstadoTratamiento.pendiente => 'pendiente',
    EstadoTratamiento.enProceso => 'en_proceso',
    EstadoTratamiento.concluido => 'concluido',
  };

  String get label => switch (this) {
    EstadoTratamiento.pendiente => 'Pendiente',
    EstadoTratamiento.enProceso => 'En proceso',
    EstadoTratamiento.concluido => 'Concluido',
  };
}

/// Fallback a `pendiente` para valores desconocidos (dato histórico).
EstadoTratamiento estadoTratamientoFromDb(String? raw) {
  for (final e in EstadoTratamiento.values) {
    if (e.dbValue == raw) return e;
  }
  return EstadoTratamiento.pendiente;
}
