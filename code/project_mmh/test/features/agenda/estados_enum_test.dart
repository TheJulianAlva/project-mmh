import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento.dart';

void main() {
  test('EstadoTratamiento.enProceso serializa a en_proceso', () {
    expect(EstadoTratamiento.enProceso.dbValue, 'en_proceso');
    expect(estadoTratamientoFromDb('en_proceso'), EstadoTratamiento.enProceso);
  });

  test('estadoTratamientoFromDb cae a pendiente si el valor es inválido', () {
    expect(estadoTratamientoFromDb(null), EstadoTratamiento.pendiente);
    expect(estadoTratamientoFromDb('xxx'), EstadoTratamiento.pendiente);
  });

  test('EstadoAsistencia round-trip por dbValue', () {
    for (final e in EstadoAsistencia.values) {
      expect(estadoAsistenciaFromDb(e.dbValue), e);
    }
    expect(estadoAsistenciaFromDb(null), isNull);
    expect(estadoAsistenciaFromDb(''), isNull);
  });

  test('labels en es_ES', () {
    expect(EstadoAsistencia.asistio.label, 'Asistió');
    expect(EstadoTratamiento.enProceso.label, 'En proceso');
  });

  group('round-trip de modelos', () {
    test('Sesion preserva estado_asistencia', () {
      const s = Sesion(
        idTratamiento: 1,
        fechaInicio: 'x',
        fechaFin: 'y',
        estadoAsistencia: EstadoAsistencia.asistio,
      );
      final json = s.toJson();
      expect(json['estado_asistencia'], 'asistio');
      expect(Sesion.fromJson(json), s);
    });

    test('Tratamiento preserva estado en_proceso', () {
      const t = Tratamiento(
        idClinica: 1,
        idExpediente: 'A',
        nombreTratamiento: 'Endo',
        fechaCreacion: 'x',
        estado: EstadoTratamiento.enProceso,
      );
      final json = t.toJson();
      expect(json['estado'], 'en_proceso');
      expect(Tratamiento.fromJson(json), t);
    });
  });
}
