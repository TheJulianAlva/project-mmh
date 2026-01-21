import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/clinicas_metas/data/repositories/clinicas_repository.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/clinicas_metas/domain/periodo.dart';

// Repository Provider
final clinicasRepositoryProvider = Provider<ClinicasRepository>((ref) {
  return ClinicasRepository();
});

// Global Active Context
final activePeriodIdProvider = StateProvider<int?>((ref) => null);
final activeClinicIdProvider = StateProvider<int?>((ref) => null);

// Signal to notify other features (like Agenda) that clinics have changed
final clinicasUpdateSignalProvider = StateProvider<int>((ref) => 0);

// 1. Periodos Provider
final periodosProvider = AsyncNotifierProvider<PeriodosNotifier, List<Periodo>>(
  PeriodosNotifier.new,
);

class PeriodosNotifier extends AsyncNotifier<List<Periodo>> {
  @override
  Future<List<Periodo>> build() async {
    return ref.watch(clinicasRepositoryProvider).getAllPeriodos();
  }

  Future<void> addPeriodo(String nombre) async {
    final periodo = Periodo(nombrePeriodo: nombre);
    await ref.read(clinicasRepositoryProvider).insertPeriodo(periodo);
    ref.invalidateSelf();
    // Notify other features
    ref.read(clinicasUpdateSignalProvider.notifier).state++;
    await future;
  }

  Future<void> updatePeriodo(int id, String nombre) async {
    final periodo = Periodo(idPeriodo: id, nombrePeriodo: nombre);
    await ref.read(clinicasRepositoryProvider).updatePeriodo(periodo);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deletePeriodo(int idPeriodo) async {
    await ref.read(clinicasRepositoryProvider).deletePeriodo(idPeriodo);
    ref.invalidateSelf();
    // Notify other features
    ref.read(clinicasUpdateSignalProvider.notifier).state++;
    await future;
  }
}

// 2. Clinicas by Periodo Provider
final clinicasByPeriodoProvider =
    AsyncNotifierProvider.family<ClinicasByPeriodoNotifier, List<Clinica>, int>(
      ClinicasByPeriodoNotifier.new,
    );

class ClinicasByPeriodoNotifier
    extends FamilyAsyncNotifier<List<Clinica>, int> {
  late int _periodoId;

  @override
  Future<List<Clinica>> build(int arg) async {
    _periodoId = arg;
    return ref.watch(clinicasRepositoryProvider).getClinicasByPeriodo(arg);
  }

  Future<void> addClinica({
    required String nombre,
    required String color,
    String? horarios,
  }) async {
    final clinica = Clinica(
      idPeriodo: _periodoId,
      nombreClinica: nombre,
      color: color,
      horarios: horarios,
    );
    await ref.read(clinicasRepositoryProvider).insertClinica(clinica);
    ref.invalidateSelf();
    // Notify other features
    ref.read(clinicasUpdateSignalProvider.notifier).state++;
    await future;
  }

  Future<void> updateClinica(Clinica clinica) async {
    await ref.read(clinicasRepositoryProvider).updateClinica(clinica);
    ref.invalidateSelf();
    // Notify other features
    ref.read(clinicasUpdateSignalProvider.notifier).state++;
    await future;
  }

  Future<void> deleteClinica(int idClinica) async {
    await ref.read(clinicasRepositoryProvider).deleteClinica(idClinica);
    ref.invalidateSelf();
    // Notify other features
    ref.read(clinicasUpdateSignalProvider.notifier).state++;
    await future;
  }
}

final clinicaByIdProvider = FutureProvider.autoDispose.family<Clinica?, int>((
  ref,
  idClinica,
) async {
  return await ref.watch(clinicasRepositoryProvider).getClinicaById(idClinica);
});
