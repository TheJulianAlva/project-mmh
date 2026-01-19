import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/clinicas_metas/domain/objetivo.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/objetivos_providers.dart';

// RE-USE Global State from clinicas_providers.dart AND preferences
// final activeClinicIdProvider = StateProvider<int?>((ref) => null);

// Stats Provider - Returns objectives for the selected clinic
final dashboardStatsProvider = FutureProvider.autoDispose<List<Objetivo>>((
  ref,
) async {
  final clinicId = ref.watch(activeClinicIdProvider); // Use GLOBAL provider
  if (clinicId == null) return [];

  final objetivos = await ref.watch(
    objetivosByClinicaProvider(clinicId).future,
  );
  return objetivos;
});
