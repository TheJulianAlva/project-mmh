import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/pacientes/data/repositories/patient_repository.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';

// Repository Provider
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository();
});

// Patients Notifier Provider
final patientsProvider = AsyncNotifierProvider<PatientsNotifier, List<Patient>>(
  PatientsNotifier.new,
);

// Single Patient Provider (Fetches by ID, includes soft-deleted)
final patientByIdProvider = FutureProvider.family<Patient?, String>((ref, id) {
  return ref.watch(patientRepositoryProvider).getPatientById(id);
});

class PatientsNotifier extends AsyncNotifier<List<Patient>> {
  @override
  Future<List<Patient>> build() async {
    return ref.watch(patientRepositoryProvider).getAllPatients();
  }

  Future<void> addPatient(Patient patient) async {
    await ref.read(patientRepositoryProvider).insertPatient(patient);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updatePatient(Patient patient) async {
    await ref.read(patientRepositoryProvider).updatePatient(patient);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updatePatientId(String oldId, Patient newPatientData) async {
    await ref
        .read(patientRepositoryProvider)
        .updatePatientId(oldId, newPatientData);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deletePatient(String idExpediente) async {
    await ref.read(patientRepositoryProvider).deletePatient(idExpediente);
    ref.invalidateSelf();
    await future;
  }

  // Future method to reload/refresh if needed manually, though invalidateSelf does it.
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
