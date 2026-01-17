import 'dart:convert';
import 'package:project_mmh/core/database/database_helper.dart';
import 'package:project_mmh/features/odontograma/domain/models/pieza_dental.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class OdontogramaRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  OdontogramaRepository(this._dbHelper);

  Future<List<PiezaDental>> getOdontograma(String pacienteId) async {
    final db = await _dbHelper.database;

    // 1. Get or Create Odontograma ID
    final odontogramaId = await _ensureOdontogramaExists(db, pacienteId);

    // 2. Query Piezas
    final List<Map<String, dynamic>> maps = await db.query(
      'piezas_dentales',
      where: 'id_odontograma = ?',
      whereArgs: [odontogramaId],
      orderBy: 'numero_pieza ASC',
    );

    if (maps.isEmpty) {
      await seedOdontograma(odontogramaId);
      return getOdontograma(pacienteId);
    }

    return maps.map((row) => PiezaDental.fromDb(row)).toList();
  }

  Future<int> _ensureOdontogramaExists(Database db, String pacienteId) async {
    final List<Map<String, dynamic>> result = await db.query(
      'odontogramas',
      columns: ['id_odontograma'],
      where: 'id_expediente = ?',
      whereArgs: [pacienteId],
    );

    if (result.isNotEmpty) {
      return result.first['id_odontograma'] as int;
    } else {
      return await db.insert('odontogramas', {'id_expediente': pacienteId});
    }
  }

  Future<void> updatePieza(PiezaDental pieza) async {
    final db = await _dbHelper.database;
    await db.update(
      'piezas_dentales',
      pieza.toDb(),
      where: 'id_pieza = ?',
      whereArgs: [pieza.id],
    );
  }

  Future<void> seedOdontograma(int odontogramaId) async {
    final db = await _dbHelper.database;

    // ISO 3950 Numbers
    List<int> isos = [];
    isos.addAll(List.generate(8, (i) => 11 + i)); // Q1
    isos.addAll(List.generate(8, (i) => 21 + i)); // Q2
    isos.addAll(List.generate(8, (i) => 31 + i)); // Q3
    isos.addAll(List.generate(8, (i) => 41 + i)); // Q4
    isos.addAll(List.generate(5, (i) => 51 + i)); // Q5
    isos.addAll(List.generate(5, (i) => 61 + i)); // Q6
    isos.addAll(List.generate(5, (i) => 71 + i)); // Q7
    isos.addAll(List.generate(5, (i) => 81 + i)); // Q8

    final batch = db.batch();
    for (var iso in isos) {
      final surfaces = {
        'mesial': 'Sano',
        'distal': 'Sano',
        'vestibular': 'Sano',
        'lingual': 'Sano',
        'oclusal': 'Sano',
      };

      batch.insert('piezas_dentales', {
        'id_pieza': _uuid.v4(),
        'id_odontograma': odontogramaId,
        'numero_pieza': iso,
        'estado_general': 'Sano',
        'superficies': jsonEncode(surfaces),
      });
    }
    await batch.commit(noResult: true);
  }
}
