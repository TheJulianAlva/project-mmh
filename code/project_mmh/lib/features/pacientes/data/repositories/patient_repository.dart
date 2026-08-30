import 'package:project_mmh/core/database/database_helper.dart';
import 'package:project_mmh/core/services/image_service.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';

class PatientRepository {
  final DatabaseHelper _dbHelper;
  final ImageService _imageService;

  PatientRepository({DatabaseHelper? dbHelper, ImageService? imageService})
    : _dbHelper = dbHelper ?? DatabaseHelper(),
      _imageService = imageService ?? ImageService();

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
        // Normaliza rutas legadas (absolutas) a relativas al leer.
        mutableMap['imagenes_paths'] = paths
            .split('|')
            .map(ImageService.toRelativePath)
            .toList();
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
    final List<String> paths =
        patient.imagenesPaths.map(ImageService.toRelativePath).toList();
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

  /// Actualiza transaccionalmente el id de expediente de un paciente y todos
  /// sus registros relacionados, y mueve su carpeta de imágenes en disco.
  Future<void> updatePatientId(String oldId, Patient newPatientData) async {
    final String newId = newPatientData.idExpediente;

    // Sin cambio de id: es una actualización normal.
    if (oldId == newId) {
      await updatePatient(newPatientData);
      return;
    }

    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // La verificación de existencia va dentro de la transacción para evitar
      // TOCTOU con ediciones concurrentes.
      final existing = await txn.query(
        _tableName,
        columns: ['id_expediente'],
        where: 'id_expediente = ?',
        whereArgs: [newId],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        throw Exception('El expediente $newId ya existe.');
      }

      await txn.insert(_tableName, _toDbMap(newPatientData));

      await txn.update(
        'tratamientos',
        {'id_expediente': newId},
        where: 'id_expediente = ?',
        whereArgs: [oldId],
      );
      await txn.update(
        'odontogramas',
        {'id_expediente': newId},
        where: 'id_expediente = ?',
        whereArgs: [oldId],
      );

      await txn.delete(
        _tableName,
        where: 'id_expediente = ?',
        whereArgs: [oldId],
      );
    });

    // Mover imágenes fuera de la transacción de BD.
    await _imageService.movePatientImages(oldId, newId);
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
      // Sin historial que conservar: se eliminan también las imágenes del disco.
      await _imageService.deletePatientImages(idExpediente);
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
