import 'package:project_mmh/core/database/database_helper.dart';
import 'package:project_mmh/features/clinicas_metas/domain/objetivo.dart';

class ObjetivosRepository {
  final DatabaseHelper _dbHelper;

  ObjetivosRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<List<Objetivo>> getObjetivosByClinica(int idClinica) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'objetivos',
      where: 'id_clinica = ?',
      whereArgs: [idClinica],
    );
    return result.map((e) => Objetivo.fromJson(e)).toList();
  }

  Future<int> insertObjetivo(Objetivo objetivo) async {
    return await _dbHelper.insert('objetivos', objetivo.toJson());
  }

  Future<int> updateObjetivo(Objetivo objetivo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'objetivos',
      objetivo.toJson(),
      where: 'id_objetivo = ?',
      whereArgs: [objetivo.idObjetivo],
    );
  }

  Future<int> deleteObjetivo(int idObjetivo) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'objetivos',
      where: 'id_objetivo = ?',
      whereArgs: [idObjetivo],
    );
  }
}
