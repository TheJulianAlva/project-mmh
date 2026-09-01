import 'dart:convert';

import 'package:project_mmh/core/database/database_helper.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';

class NotasRepository {
  final DatabaseHelper _dbHelper;

  NotasRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  static const String _tableName = 'notas';

  Map<String, dynamic> _toDbMap(Nota nota) {
    final map = nota.toJson();
    map['items_json'] = jsonEncode(
      nota.items.map((i) => i.toJson()).toList(),
    );
    map['convertido'] = nota.convertido ? 1 : 0;
    return map;
  }

  Future<List<Nota>> getAllNotas() async {
    final db = await _dbHelper.database;
    final result = await db.query(_tableName, orderBy: 'fecha DESC');
    return result.map((e) => Nota.fromJson(e)).toList();
  }

  Future<Nota?> getNotaById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      _tableName,
      where: 'id_nota = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Nota.fromJson(result.first);
  }

  Future<int> insertNota(Nota nota) async {
    return await _dbHelper.insert(_tableName, _toDbMap(nota));
  }

  Future<int> updateNota(Nota nota) async {
    final db = await _dbHelper.database;
    return await db.update(
      _tableName,
      _toDbMap(nota),
      where: 'id_nota = ?',
      whereArgs: [nota.idNota],
    );
  }

  Future<void> deleteNota(int id) async {
    final db = await _dbHelper.database;
    await db.delete(_tableName, where: 'id_nota = ?', whereArgs: [id]);
  }
}
