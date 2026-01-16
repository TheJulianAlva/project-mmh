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
    final result = await _dbHelper.queryAll(_tableName);
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

  Future<int> deletePatient(String idExpediente) async {
    final db = await _dbHelper.database;
    return await db.delete(
      _tableName,
      where: 'id_expediente = ?',
      whereArgs: [idExpediente],
    );
  }
}
