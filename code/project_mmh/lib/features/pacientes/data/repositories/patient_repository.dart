import 'package:project_mmh/core/database/database_helper.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';

class PatientRepository {
  final DatabaseHelper _dbHelper;

  PatientRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  static const String _tableName = 'pacientes';

  // Helper to convert DB Map to Patient Model
  Patient _fromDbMap(Map<String, dynamic> map) {
    final Map<String, dynamic> mutableMap = Map<String, dynamic>.from(map);

    // Handle imagenes_paths conversion (String -> List<String>)
    if (mutableMap['imagenes_paths'] is String) {
      final String paths = mutableMap['imagenes_paths'] as String;
      if (paths.isEmpty) {
        mutableMap['imagenes_paths'] = <String>[];
      } else {
        mutableMap['imagenes_paths'] = paths.split('|');
      }
    } else {
      mutableMap['imagenes_paths'] = <String>[];
    }

    return Patient.fromJson(mutableMap);
  }

  // Helper to convert Patient Model to DB Map
  Map<String, dynamic> _toDbMap(Patient patient) {
    final map = patient.toJson();

    // Handle imagenes_paths conversion (List<String> -> String)
    final List<String> paths = patient.imagenesPaths;
    map['imagenes_paths'] = paths.join('|');

    return map;
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await _dbHelper.database;
    // V2: Filter out soft-deleted patients
    final result = await db.query(_tableName, where: 'deleted_at IS NULL');
    return result.map((e) => _fromDbMap(e)).toList();
  }

  Future<Patient?> getPatientById(String idExpediente) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      _tableName,
      where: 'id_expediente = ?',
      whereArgs: [idExpediente],
    );

    if (result.isNotEmpty) {
      return _fromDbMap(result.first);
    }
    return null;
  }

  Future<int> insertPatient(Patient patient) async {
    return await _dbHelper.insert(_tableName, _toDbMap(patient));
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await _dbHelper.database;
    return await db.update(
      _tableName,
      _toDbMap(patient),
      where: 'id_expediente = ?',
      whereArgs: [patient.idExpediente],
    );
  }

  /// Transactionally updates a Patient's ID and all related records.
  Future<void> updatePatientId(String oldId, Patient newPatientData) async {
    final db = await _dbHelper.database;

    // Validation: Check if new ID already exists (and is not the same as old ID)
    if (oldId != newPatientData.idExpediente) {
      final existing = await db.query(
        _tableName,
        where: 'id_expediente = ?',
        whereArgs: [newPatientData.idExpediente],
      );
      if (existing.isNotEmpty) {
        throw Exception(
          'El expediente ${newPatientData.idExpediente} ya existe.',
        );
      }
    }

    await db.transaction((txn) async {
      // 1. Insert new patient record with new ID
      // We use the new data provided (which should have the new ID)
      await txn.insert(_tableName, _toDbMap(newPatientData));

      // 2. Re-link dependent tables to new ID
      // Update Tratamientos
      await txn.update(
        'tratamientos',
        {'id_expediente': newPatientData.idExpediente},
        where: 'id_expediente = ?',
        whereArgs: [oldId],
      );

      // Update Odontogramas
      await txn.update(
        'odontogramas',
        {'id_expediente': newPatientData.idExpediente},
        where: 'id_expediente = ?',
        whereArgs: [oldId],
      );

      // 3. Delete the old patient record
      // (Cascades shouldn't trigger effectively because we moved the children,
      // but to be safe and clean, we delete the old parent)
      await txn.delete(
        _tableName,
        where: 'id_expediente = ?',
        whereArgs: [oldId],
      );
    });
  }

  Future<void> deletePatient(String idExpediente) async {
    final db = await _dbHelper.database;

    // 1. Check for existing treatments (History)
    final tratamientos = await db.query(
      'tratamientos',
      where: 'id_expediente = ?',
      whereArgs: [idExpediente],
    );

    if (tratamientos.isEmpty) {
      // CASE 1: No history -> Hard Delete (Clean up error)
      await db.delete(
        _tableName,
        where: 'id_expediente = ?',
        whereArgs: [idExpediente],
      );
    } else {
      // CASE 2: History exists -> Soft Delete (Preserve records)
      await db.transaction((txn) async {
        // Mark as deleted
        await txn.update(
          _tableName,
          {'deleted_at': DateTime.now().toIso8601String()},
          where: 'id_expediente = ?',
          whereArgs: [idExpediente],
        );

        // Hard delete Odontogram (Reset visual state, save space)
        await txn.delete(
          'odontogramas',
          where: 'id_expediente = ?',
          whereArgs: [idExpediente],
        );
      });
    }
  }
}
