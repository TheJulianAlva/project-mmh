import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/agenda/data/repositories/agenda_repository.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento_rich_model.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/clinicas_metas/domain/objetivo.dart';

// Repository Provider
final agendaRepositoryProvider = Provider<AgendaRepository>((ref) {
  return AgendaRepository();
});

// State for selected date on Calendar
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// FutureProvider to fetch sessions for the selected date (or all and filter in memory for efficiency if small db)
// For now, let's fetch all sessions to show markers on calendar easily, then filter in UI or logic.
// Or better: fetch month range. For simplicity v1: fetch ALL sessions.
final allSesionesProvider = FutureProvider.autoDispose<List<Sesion>>((
  ref,
) async {
  final repo = ref.watch(agendaRepositoryProvider);
  return await repo.getAllSesiones();
});

// Filtered sessions for the selected date
final sessionsOnSelectedDateProvider = Provider.autoDispose<List<Sesion>>((
  ref,
) {
  final allSesionesAsync = ref.watch(allSesionesProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return allSesionesAsync.when(
    data: (sesiones) {
      return sesiones.where((sesion) {
        final sesionDate = DateTime.parse(sesion.fechaInicio);
        return isSameDay(sesionDate, selectedDate);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Helper for same day check
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// Providers for Forms
final clinicasProvider = FutureProvider.autoDispose<List<Clinica>>((ref) async {
  final repo = ref.watch(agendaRepositoryProvider);
  return await repo.getAllClinicas();
});

final objetivosByClinicaProvider = FutureProvider.autoDispose
    .family<List<Objetivo>, int>((ref, idClinica) async {
      final repo = ref.watch(agendaRepositoryProvider);
      return await repo.getObjetivosByClinica(idClinica);
    });

// Provider to get full Tratamiento details for a Sesion
final tratamientoByIdProvider = FutureProvider.family<Tratamiento?, int>((
  ref,
  idTratamiento,
) async {
  final repo = ref.watch(agendaRepositoryProvider);
  return await repo.getTratamientoById(idTratamiento);
});

// --- Treatments Screen Providers ---

final allTratamientosRichProvider =
    FutureProvider.autoDispose<List<TratamientoRichModel>>((ref) async {
      final repo = ref.watch(agendaRepositoryProvider);
      return await repo.getAllTratamientosRich();
    });

final sesionesByTratamientoProvider = FutureProvider.autoDispose
    .family<List<Sesion>, int>((ref, idTratamiento) async {
      final repo = ref.watch(agendaRepositoryProvider);
      return await repo.getSesionesByTratamiento(idTratamiento);
    });
