import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:project_mmh/core/database/database_helper.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento_rich_model.dart';
import 'package:project_mmh/features/agenda/domain/sesion_rich_model.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';

class AgendaRepository {
  final DatabaseHelper _dbHelper;

  AgendaRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  /// Todas las fechas de `sesiones` se guardan como ISO-8601 en **hora local**
  /// (sin sufijo `Z`). Para comparar en SQL usamos `now` truncado a segundos,
  /// de forma que tenga la misma longitud/forma que las fechas guardadas por
  /// los date pickers y la comparación lexicográfica sea fiable.
  static String _nowIsoLocalSeconds() {
    final n = DateTime.now();
    return DateTime(
      n.year,
      n.month,
      n.day,
      n.hour,
      n.minute,
      n.second,
    ).toIso8601String();
  }

  // --- Tratamientos ---

  Future<int> createTratamiento(Tratamiento tratamiento) async {
    return await _dbHelper.insert('tratamientos', tratamiento.toJson());
  }

  Future<int> updateTratamiento(Tratamiento tratamiento) async {
    final db = await _dbHelper.database;
    // Objetivo anterior, por si la edición lo reasigna.
    final anterior = await getTratamientoById(tratamiento.idTratamiento!);

    final rows = await db.update(
      'tratamientos',
      tratamiento.toJson(),
      where: 'id_tratamiento = ?',
      whereArgs: [tratamiento.idTratamiento],
    );

    // Recalcular ambos objetivos afectados (si cambió la asignación).
    await recalcObjetivoProgress(anterior?.idObjetivo);
    if (tratamiento.idObjetivo != anterior?.idObjetivo) {
      await recalcObjetivoProgress(tratamiento.idObjetivo);
    }
    return rows;
  }

  Future<void> deleteTratamiento(int idTratamiento) async {
    final db = await _dbHelper.database;

    final tratamiento = await getTratamientoById(idTratamiento);

    // Cascade delete sessions first
    await db.delete(
      'sesiones',
      where: 'id_tratamiento = ?',
      whereArgs: [idTratamiento],
    );
    // Delete treatment
    await db.delete(
      'tratamientos',
      where: 'id_tratamiento = ?',
      whereArgs: [idTratamiento],
    );

    await recalcObjetivoProgress(tratamiento?.idObjetivo);
  }

  Future<void> markTreatmentAsFinalized(int idTratamiento) async {
    final db = await _dbHelper.database;

    // Marcar como concluido solo si aún no lo estaba (idempotente).
    await db.update(
      'tratamientos',
      {'estado': 'concluido'},
      where: 'id_tratamiento = ? AND estado != ?',
      whereArgs: [idTratamiento, 'concluido'],
    );

    final tratamiento = await getTratamientoById(idTratamiento);
    await recalcObjetivoProgress(tratamiento?.idObjetivo);
  }

  Future<List<Tratamiento>> getTratamientosByPaciente(
    String idExpediente,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tratamientos',
      where: 'id_expediente = ?',
      whereArgs: [idExpediente],
    );
    return result.map((e) => Tratamiento.fromJson(e)).toList();
  }

  Future<Tratamiento?> getTratamientoById(int idTratamiento) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tratamientos',
      where: 'id_tratamiento = ?',
      whereArgs: [idTratamiento],
    );
    if (result.isEmpty) return null;
    return Tratamiento.fromJson(result.first);
  }

  Future<List<TratamientoRichModel>> getAllTratamientosRich() async {
    final db = await _dbHelper.database;

    // Fetch all treatments
    final tratamientosMap = await db.query('tratamientos');
    final tratamientos =
        tratamientosMap.map((e) => Tratamiento.fromJson(e)).toList();

    // Fetch dependencies
    // Optimization: Fetch all clinics and patients once
    final clinicasMap = await db.query('clinicas');
    final clinicas = {
      for (var c in clinicasMap.map((e) => Clinica.fromJson(e))) c.idClinica: c,
    };

    final pacientesMap = await db.query('pacientes');
    final pacientes = {
      for (var p in pacientesMap.map((e) => Patient.fromJson(e)))
        p.idExpediente: p,
    };

    // Próxima sesión por tratamiento en una sola consulta (evita N+1).
    final proximasMap = await db.rawQuery(
      '''
      SELECT id_tratamiento, MIN(fecha_inicio) AS proxima
      FROM sesiones
      WHERE fecha_inicio >= ?
        AND (estado_asistencia IS NULL OR estado_asistencia = ''
             OR estado_asistencia = 'programada')
      GROUP BY id_tratamiento
      ''',
      [_nowIsoLocalSeconds()],
    );
    final proximaPorTratamiento = <int, DateTime>{
      for (final row in proximasMap)
        row['id_tratamiento'] as int:
            DateTime.parse(row['proxima'] as String),
    };

    final List<TratamientoRichModel> richList = [];
    var descartados = 0;

    for (var t in tratamientos) {
      final clinica = clinicas[t.idClinica];
      final paciente = pacientes[t.idExpediente];
      if (clinica == null || paciente == null) {
        descartados++;
        continue;
      }

      richList.add(
        TratamientoRichModel(
          tratamiento: t,
          nombreClinica: clinica.nombreClinica,
          colorClinica: clinica.color,
          nombrePaciente: '${paciente.nombre} ${paciente.primerApellido}',
          idExpediente: paciente.idExpediente,
          proximaSesion: proximaPorTratamiento[t.idTratamiento],
        ),
      );
    }

    if (descartados > 0) {
      debugPrint(
        'getAllTratamientosRich: $descartados tratamiento(s) descartado(s) '
        'por integridad referencial rota (clínica o paciente inexistente).',
      );
    }

    // Sort by next session (nearest first), then by creation date desc
    richList.sort((a, b) {
      if (a.proximaSesion != null && b.proximaSesion != null) {
        return a.proximaSesion!.compareTo(b.proximaSesion!);
      }
      if (a.proximaSesion != null) return -1; // a has session, goes first
      if (b.proximaSesion != null) return 1;

      // Both null, sort by id desc (newest created)
      return (b.tratamiento.idTratamiento ?? 0).compareTo(
        a.tratamiento.idTratamiento ?? 0,
      );
    });

    return richList;
  }

  // --- Enriched Sesiones (for Agenda Timeline) ---

  Future<List<SesionRichModel>> getEnrichedSesiones() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT
        s.id_sesion,
        s.id_tratamiento,
        s.fecha_inicio,
        s.fecha_fin,
        s.estado_asistencia,
        t.nombre_tratamiento,
        p.nombre || ' ' || p.primer_apellido AS nombre_paciente,
        c.nombre_clinica,
        c.color AS color_clinica
      FROM sesiones s
      INNER JOIN tratamientos t ON s.id_tratamiento = t.id_tratamiento
      INNER JOIN pacientes p ON t.id_expediente = p.id_expediente
      INNER JOIN clinicas c ON t.id_clinica = c.id_clinica
      ORDER BY s.fecha_inicio ASC
    ''');

    if (kDebugMode) {
      final total = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM sesiones'),
      );
      if (total != null && total != result.length) {
        debugPrint(
          'getEnrichedSesiones: ${total - result.length} sesión(es) '
          'oculta(s) por integridad referencial rota (tratamiento/paciente/'
          'clínica inexistente).',
        );
      }
    }

    return result.map((row) {
      final sesion = Sesion(
        idSesion: row['id_sesion'] as int?,
        idTratamiento: row['id_tratamiento'] as int,
        fechaInicio: row['fecha_inicio'] as String,
        fechaFin: row['fecha_fin'] as String,
        estadoAsistencia: row['estado_asistencia'] as String?,
      );
      return SesionRichModel(
        sesion: sesion,
        nombreTratamiento: row['nombre_tratamiento'] as String,
        nombrePaciente: row['nombre_paciente'] as String,
        nombreClinica: row['nombre_clinica'] as String,
        colorClinica: row['color_clinica'] as String,
      );
    }).toList();
  }

  // --- Sesiones ---

  Future<int> createSesion(Sesion sesion) async {
    return await _dbHelper.insert('sesiones', sesion.toJson());
  }

  // Se asume que fechas se guardan como ISO8601 String.
  // Para obtener sesiones de un día, buscamos rango o startsWith.
  // Simplificación: Traemos todas (o optimizar luego) y filtramos o query exacta si guardamos YYYY-MM-DD
  Future<List<Sesion>> getSesionesByDateRange(
    String startIso,
    String endIso,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'sesiones',
      where: 'fecha_inicio >= ? AND fecha_inicio <= ?',
      whereArgs: [startIso, endIso],
    );
    return result.map((e) => Sesion.fromJson(e)).toList();
  }

  Future<List<Sesion>> getAllSesiones() async {
    final result = await _dbHelper.queryAll('sesiones');
    return result.map((e) => Sesion.fromJson(e)).toList();
  }

  Future<List<Sesion>> getSesionesByTratamiento(int idTratamiento) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'sesiones',
      where: 'id_tratamiento = ?',
      whereArgs: [idTratamiento],
      orderBy: 'fecha_inicio ASC',
    );
    return result.map((e) => Sesion.fromJson(e)).toList();
  }

  Future<int> updateSesionStatus(int idSesion, String nuevoEstado) async {
    final db = await _dbHelper.database;
    return await db.update(
      'sesiones',
      {'estado_asistencia': nuevoEstado},
      where: 'id_sesion = ?',
      whereArgs: [idSesion],
    );
  }

  Future<int> updateSesion(Sesion sesion) async {
    final db = await _dbHelper.database;
    return await db.update(
      'sesiones',
      sesion.toJson(),
      where: 'id_sesion = ?',
      whereArgs: [sesion.idSesion],
    );
  }

  Future<int> deleteSesion(int idSesion) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'sesiones',
      where: 'id_sesion = ?',
      whereArgs: [idSesion],
    );
  }

  // --- Support Methods (Objectives, Clinicas) for Dropdowns ---

  /// Recalcula `cantidad_actual` de un objetivo como el número real de
  /// tratamientos concluidos que lo referencian. Es idempotente y robusto
  /// frente a finalizar/eliminar/reasignar en cualquier orden.
  Future<void> recalcObjetivoProgress(int? idObjetivo) async {
    if (idObjetivo == null) return;
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM tratamientos "
            "WHERE id_objetivo = ? AND estado = 'concluido'",
            [idObjetivo],
          ),
        ) ??
        0;
    await db.update(
      'objetivos',
      {'cantidad_actual': count},
      where: 'id_objetivo = ?',
      whereArgs: [idObjetivo],
    );
  }

  Future<List<Clinica>> getAllClinicas() async {
    final result = await _dbHelper.queryAll('clinicas');
    return result.map((e) => Clinica.fromJson(e)).toList();
  }
}
