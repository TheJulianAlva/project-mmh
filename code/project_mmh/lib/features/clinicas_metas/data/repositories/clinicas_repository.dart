import 'package:project_mmh/core/database/database_helper.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/clinicas_metas/domain/periodo.dart';

class ClinicasRepository {
  final DatabaseHelper _dbHelper;

  ClinicasRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  // Periodos
  Future<List<Periodo>> getAllPeriodos() async {
    final result = await _dbHelper.queryAll('periodos');
    return result.map((e) => Periodo.fromJson(e)).toList();
  }

  Future<int> insertPeriodo(Periodo periodo) async {
    return await _dbHelper.insert('periodos', periodo.toJson());
  }

  Future<int> updatePeriodo(Periodo periodo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'periodos',
      periodo.toJson(),
      where: 'id_periodo = ?',
      whereArgs: [periodo.idPeriodo],
    );
  }

  // Clinicas
  Future<List<Clinica>> getClinicasByPeriodo(int idPeriodo) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'clinicas',
      where: 'id_periodo = ?',
      whereArgs: [idPeriodo],
    );
    return result.map((e) => Clinica.fromJson(e)).toList();
  }

  Future<int> insertClinica(Clinica clinica) async {
    return await _dbHelper.insert('clinicas', clinica.toJson());
  }

  Future<int> updateClinica(Clinica clinica) async {
    final db = await _dbHelper.database;
    return await db.update(
      'clinicas',
      clinica.toJson(),
      where: 'id_clinica = ?',
      whereArgs: [clinica.idClinica],
    );
  }

  Future<int> deleteClinica(int idClinica) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'clinicas',
      where: 'id_clinica = ?',
      whereArgs: [idClinica],
    );
  }

  Future<int> deletePeriodo(int idPeriodo) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'periodos',
      where: 'id_periodo = ?',
      whereArgs: [idPeriodo],
    );
  }
}
