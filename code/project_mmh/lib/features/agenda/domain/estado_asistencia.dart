import 'package:freezed_annotation/freezed_annotation.dart';

/// Estado de asistencia de una sesión. El `@JsonValue` fija el string que
/// viaja a/desde la columna `estado_asistencia` de la BD.
enum EstadoAsistencia {
  @JsonValue('programada')
  programada,
  @JsonValue('asistio')
  asistio,
  @JsonValue('falto')
  falto;

  String get dbValue => switch (this) {
    EstadoAsistencia.programada => 'programada',
    EstadoAsistencia.asistio => 'asistio',
    EstadoAsistencia.falto => 'falto',
  };

  String get label => switch (this) {
    EstadoAsistencia.programada => 'Programada',
    EstadoAsistencia.asistio => 'Asistió',
    EstadoAsistencia.falto => 'Faltó',
  };
}

/// Parseo tolerante para valores crudos de BD (incluye null / vacío).
EstadoAsistencia? estadoAsistenciaFromDb(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  for (final e in EstadoAsistencia.values) {
    if (e.dbValue == raw) return e;
  }
  return null;
}
