import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/clinicas_metas/data/repositories/objetivos_repository.dart';
import 'package:project_mmh/features/clinicas_metas/domain/objetivo.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';

final objetivosRepositoryProvider = Provider<ObjetivosRepository>((ref) {
  return ObjetivosRepository();
});

final objetivosByClinicaProvider =
    AsyncNotifierProvider.family<ObjetivosNotifier, List<Objetivo>, int>(
      ObjetivosNotifier.new,
    );

class ObjetivosNotifier extends FamilyAsyncNotifier<List<Objetivo>, int> {
  late int _clinicaId;

  @override
  Future<List<Objetivo>> build(int arg) async {
    _clinicaId = arg;
    return ref.watch(objetivosRepositoryProvider).getObjetivosByClinica(arg);
  }

  // Notifica a las features dependientes (agenda, dashboard) que las metas
  // de esta clínica cambiaron.
  void _notifyDependents() {
    ref.read(clinicasUpdateSignalProvider.notifier).state++;
  }

  Future<void> addObjetivo({
    required String nombreTratamiento,
    required int cantidadMeta,
  }) async {
    final objetivo = Objetivo(
      idClinica: _clinicaId,
      nombreTratamiento: nombreTratamiento,
      cantidadMeta: cantidadMeta,
    );
    await ref.read(objetivosRepositoryProvider).insertObjetivo(objetivo);
    ref.invalidateSelf();
    await future;
    _notifyDependents();
  }

  Future<void> deleteObjetivo(int idObjetivo) async {
    await ref.read(objetivosRepositoryProvider).deleteObjetivo(idObjetivo);
    ref.invalidateSelf();
    await future;
    _notifyDependents();
  }

  Future<void> updateObjetivo(Objetivo objetivo) async {
    await ref.read(objetivosRepositoryProvider).updateObjetivo(objetivo);
    ref.invalidateSelf();
    await future;
    _notifyDependents();
  }
}
