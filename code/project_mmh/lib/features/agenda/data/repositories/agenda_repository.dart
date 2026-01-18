import 'package:project_mmh/core/database/database_helper.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento.dart';
import 'package:project_mmh/features/clinicas_metas/domain/objetivo.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento_rich_model.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';

class AgendaRepository {
  final DatabaseHelper _dbHelper;

  AgendaRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  // --- Tratamientos ---

  Future<int> createTratamiento(Tratamiento tratamiento) async {
    return await _dbHelper.insert('tratamientos', tratamiento.toJson());
  }

  Future<int> updateTratamiento(Tratamiento tratamiento) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tratamientos',
      tratamiento.toJson(),
      where: 'id_tratamiento = ?',
      whereArgs: [tratamiento.idTratamiento],
    );
  }

  Future<void> deleteTratamiento(int idTratamiento) async {
    final db = await _dbHelper.database;
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
  }

  Future<void> markTreatmentAsFinalized(int idTratamiento) async {
    final db = await _dbHelper.database;

    // 1. Update Treatment State
    await db.update(
      'tratamientos',
      {'estado': 'concluido'},
      where: 'id_tratamiento = ?',
      whereArgs: [idTratamiento],
    );

    // 2. Update Objective Progress
    final tratamiento = await getTratamientoById(idTratamiento);
    if (tratamiento?.idObjetivo != null) {
      await incrementObjetivoProgress(tratamiento!.idObjetivo!);
    }
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

    final List<TratamientoRichModel> richList = [];
    final now = DateTime.now();

    for (var t in tratamientos) {
      final clinica = clinicas[t.idClinica];
      final paciente = pacientes[t.idExpediente];
      if (clinica == null || paciente == null)
        continue; // Should not happen with heavy constraints

      // Find next session
      final sesionesMap = await db.query(
        'sesiones',
        where: 'id_tratamiento = ? AND fecha_inicio >= ?',
        whereArgs: [t.idTratamiento, now.toIso8601String()],
        orderBy: 'fecha_inicio ASC',
        limit: 1,
      );

      DateTime? proximaSesion;
      if (sesionesMap.isNotEmpty) {
        proximaSesion = DateTime.parse(
          sesionesMap.first['fecha_inicio'] as String,
        );
      }

      richList.add(
        TratamientoRichModel(
          tratamiento: t,
          nombreClinica: clinica.nombreClinica,
          colorClinica: clinica.color,
          nombrePaciente: '${paciente.nombre} ${paciente.primerApellido}',
          idExpediente: paciente.idExpediente,
          proximaSesion: proximaSesion,
        ),
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

  // --- Support Methods (Objectives, Clinicas) for Dropdowns ---

  Future<List<Objetivo>> getObjetivosByClinica(int idClinica) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'objetivos',
      where: 'id_clinica = ?',
      whereArgs: [idClinica],
    );
    return result.map((e) => Objetivo.fromJson(e)).toList();
  }

  Future<int> incrementObjetivoProgress(int idObjetivo) async {
    final db = await _dbHelper.database;
    // Primero obtenemos el objetivo actual
    final result = await db.query(
      'objetivos',
      where: 'id_objetivo = ?',
      whereArgs: [idObjetivo],
    );
    if (result.isEmpty) return 0;

    final objetivo = Objetivo.fromJson(result.first);
    final nuevaCantidad = objetivo.cantidadActual + 1;

    return await db.update(
      'objetivos',
      {'cantidad_actual': nuevaCantidad},
      where: 'id_objetivo = ?',
      whereArgs: [idObjetivo],
    );
  }

  Future<List<Clinica>> getAllClinicas() async {
    final result = await _dbHelper.queryAll('clinicas');
    return result.map((e) => Clinica.fromJson(e)).toList();
  }
}
