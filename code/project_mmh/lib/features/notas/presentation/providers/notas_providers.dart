import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/notas/data/repositories/notas_repository.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';

final notasRepositoryProvider = Provider<NotasRepository>((ref) {
  return NotasRepository();
});

final notasProvider = AsyncNotifierProvider<NotasNotifier, List<Nota>>(
  NotasNotifier.new,
);

class NotasNotifier extends AsyncNotifier<List<Nota>> {
  @override
  Future<List<Nota>> build() async {
    return ref.watch(notasRepositoryProvider).getAllNotas();
  }

  Future<void> _reloadInPlace() async {
    final notas = await ref.read(notasRepositoryProvider).getAllNotas();
    state = AsyncData(notas);
  }

  Future<int> addNota(Nota nota) async {
    final id = await ref.read(notasRepositoryProvider).insertNota(nota);
    await _reloadInPlace();
    return id;
  }

  Future<void> updateNota(Nota nota) async {
    await ref.read(notasRepositoryProvider).updateNota(nota);
    ref.invalidate(notaByIdProvider(nota.idNota!));
    await _reloadInPlace();
  }

  Future<void> deleteNota(int id) async {
    await ref.read(notasRepositoryProvider).deleteNota(id);
    ref.invalidate(notaByIdProvider(id));
    await _reloadInPlace();
  }
}

final notaByIdProvider = FutureProvider.family<Nota?, int>((ref, id) {
  return ref.watch(notasRepositoryProvider).getNotaById(id);
});

final notasPorTipoProvider = Provider.family<List<Nota>, NotaTipo>((
  ref,
  tipo,
) {
  final notas = ref.watch(notasProvider).asData?.value ?? [];
  return notas.where((n) => n.tipo == tipo).toList();
});

final cotizacionesDeListaProvider = Provider.family<List<Nota>, int>((
  ref,
  idLista,
) {
  final notas = ref.watch(notasProvider).asData?.value ?? [];
  return notas
      .where(
        (n) => n.tipo == NotaTipo.cotizacion && n.idNotaRelacionada == idLista,
      )
      .toList();
});
