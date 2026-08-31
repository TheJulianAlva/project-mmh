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

  // Relee la lista desde el repositorio y actualiza el estado sin pasar por
  // AsyncLoading (evita el parpadeo a spinner de todas las pantallas).
  Future<void> _reloadInPlace() async {
    final patients = await ref.read(patientRepositoryProvider).getAllPatients();
    state = AsyncData(patients);
  }

  Future<void> addPatient(Patient patient) async {
    await ref.read(patientRepositoryProvider).insertPatient(patient);
    await _reloadInPlace();
  }

  Future<void> updatePatient(Patient patient) async {
    await ref.read(patientRepositoryProvider).updatePatient(patient);
    ref.invalidate(patientByIdProvider(patient.idExpediente));
    await _reloadInPlace();
  }

  Future<void> updatePatientId(String oldId, Patient newPatientData) async {
    await ref
        .read(patientRepositoryProvider)
        .updatePatientId(oldId, newPatientData);
    ref.invalidate(patientByIdProvider(oldId));
    ref.invalidate(patientByIdProvider(newPatientData.idExpediente));
    await _reloadInPlace();
  }

  Future<void> deletePatient(String idExpediente) async {
    await ref.read(patientRepositoryProvider).deletePatient(idExpediente);
    ref.invalidate(patientByIdProvider(idExpediente));
    await _reloadInPlace();
  }
}
