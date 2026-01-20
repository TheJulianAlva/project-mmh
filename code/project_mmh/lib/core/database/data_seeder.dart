import 'dart:math';

import 'package:faker/faker.dart';
import 'package:project_mmh/core/database/database_helper.dart';

class DataSeeder {
  final DatabaseHelper _dbHelper;
  final Faker _faker;
  final Random _random;

  DataSeeder({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper(),
      _faker = Faker(),
      _random = Random();

  Future<void> seedAll() async {
    await seedPeriodsAndClinics();
    await seedPatients(25); // Create 25 patients
    await seedTreatments(); // Create treatments for patients
    await seedSessions(); // Create sessions for treatments
  }

  Future<void> seedPeriodsAndClinics() async {
    final db = await _dbHelper.database;

    // 1. Periodo
    final periods = await db.query('periodos');
    int periodId;
    if (periods.isEmpty) {
      periodId = await db.insert('periodos', {'nombre_periodo': '2026-1'});
    } else {
      periodId = periods.first['id_periodo'] as int;
    }

    // 2. Clínicas
    final clinics = await db.query('clinicas');
    if (clinics.isEmpty) {
      final clinicNames = [
        {'name': 'Clínica de Odontopediatría', 'color': '0xFF4CAF50'}, // Green
        {'name': 'Clínica de Endodoncia', 'color': '0xFF2196F3'}, // Blue
        {'name': 'Clínica Integral', 'color': '0xFFFF9800'}, // Orange
      ];

      for (var c in clinicNames) {
        final clinicId = await db.insert('clinicas', {
          'id_periodo': periodId,
          'nombre_clinica': c['name'],
          'color': c['color'],
          'horarios': 'Lunes 8-12',
        });

        // 3. Metas/Objetivos por defecto
        final goals = [
          {'name': 'Limpiezas', 'target': 20},
          {'name': 'Resinas', 'target': 15},
          {'name': 'Extracciones', 'target': 10},
          {'name': 'Coronas', 'target': 5},
        ];

        for (var g in goals) {
          await db.insert('objetivos', {
            'id_clinica': clinicId,
            'nombre_tratamiento': g['name'],
            'cantidad_meta': g['target'],
            'cantidad_actual':
                0, // Will update dynamically later if needed or recalculate
          });
        }
      }
    }
  }

  Future<void> seedPatients(int count) async {
    final db = await _dbHelper.database;
    final sexos = ['M', 'F'];

    for (int i = 0; i < count; i++) {
      final sexo = sexos[_random.nextInt(sexos.length)];
      final firstName = _faker.person.firstName();
      final lastName1 = _faker.person.lastName();
      final lastName2 = _faker.person.lastName();
      final idExp =
          'EXP-${_random.nextInt(10000) + 10000}-${DateTime.now().year}';

      await db.insert('pacientes', {
        'id_expediente': idExp,
        'nombre': firstName,
        'primer_apellido': lastName1,
        'segundo_apellido': lastName2,
        'edad': _random.nextInt(80) + 5,
        'sexo': sexo,
        'telefono': _faker.phoneNumber.us(),
        'padecimiento_relevante':
            _random.nextBool() ? _faker.lorem.sentence() : null,
        'informacion_adicional':
            _random.nextBool() ? _faker.lorem.sentence() : null,
        'imagenes_paths': '',
      });
    }
  }

  Future<void> seedTreatments() async {
    final db = await _dbHelper.database;
    final clinics = await db.query('clinicas');
    final patients = await db.query('pacientes');

    if (clinics.isEmpty || patients.isEmpty) return;

    for (var patient in patients) {
      // 70% chance a patient has treatments
      if (_random.nextDouble() > 0.3) {
        final clinic = clinics[_random.nextInt(clinics.length)];
        final clinicId = clinic['id_clinica'] as int;
        final patientId = patient['id_expediente'] as String;

        // Get goals for this clinic to link treatments
        final goals = await db.query(
          'objetivos',
          where: 'id_clinica = ?',
          whereArgs: [clinicId],
        );

        // Add 1-3 treatments
        int treatmentCount = _random.nextInt(3) + 1;
        for (int t = 0; t < treatmentCount; t++) {
          int? objectiveId;
          String treatmentName = 'Consulta General';

          if (goals.isNotEmpty && _random.nextBool()) {
            final goal = goals[_random.nextInt(goals.length)];
            objectiveId = goal['id_objetivo'] as int;
            treatmentName = goal['nombre_tratamiento'] as String;

            // Increment goal progress
            int current = (goal['cantidad_actual'] as int) + 1;
            await db.update(
              'objetivos',
              {'cantidad_actual': current},
              where: 'id_objetivo = ?',
              whereArgs: [objectiveId],
            );
          } else {
            final treatments = [
              'Profilaxis',
              'Amalgama',
              'Resina',
              'Extracción',
              'Consulta',
            ];
            treatmentName = treatments[_random.nextInt(treatments.length)];
          }

          await db.insert('tratamientos', {
            'id_clinica': clinicId,
            'id_expediente': patientId,
            'id_objetivo': objectiveId,
            'nombre_tratamiento': treatmentName,
            'fecha_creacion':
                DateTime.now()
                    .subtract(Duration(days: _random.nextInt(60)))
                    .toIso8601String(),
            'estado': _random.nextBool() ? 'Activo' : 'Completado',
          });
        }
      }
    }
  }

  Future<void> seedSessions() async {
    // Simplified: Just leaving this empty or basic for now as it requires linking specific treatments
    final db = await _dbHelper.database;
    final treatments = await db.query('tratamientos');

    for (var t in treatments) {
      if (_random.nextDouble() > 0.5) {
        final tId = t['id_tratamiento'] as int;
        // Add 1-5 sessions
        int sessionCount = _random.nextInt(5) + 1;
        for (int s = 0; s < sessionCount; s++) {
          final date = DateTime.now().add(
            Duration(
              days: _random.nextInt(60) - 30,
            ), // Past 30 to Future 30 days
          );
          await db.insert('sesiones', {
            'id_tratamiento': tId,
            'fecha_inicio': date.toIso8601String(),
            'fecha_fin': date.add(const Duration(hours: 1)).toIso8601String(),
            'estado_asistencia': 'Asistió',
          });
        }
      }
    }
  }
}
