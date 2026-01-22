import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/core/database/database_helper.dart';
import 'package:project_mmh/features/odontograma/data/odontograma_repository.dart';
import 'package:project_mmh/features/odontograma/domain/models/pieza_dental.dart';

// Providers
final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper(),
);

final odontogramaRepositoryProvider = Provider<OdontogramaRepository>((ref) {
  return OdontogramaRepository(ref.watch(databaseHelperProvider));
});

final odontogramaControllerProvider = StateNotifierProvider.family<
  OdontogramaController,
  AsyncValue<List<PiezaDental>>,
  String
>((ref, pacienteId) {
  return OdontogramaController(
    ref.watch(odontogramaRepositoryProvider),
    pacienteId,
  );
});

final selectedToolProvider = StateProvider<String>((ref) => 'Sano');

// Tools Constants
// Tools Constants matching Design Doc
class OdontogramaTools {
  // Global States (Nivel Diente)
  static const String sano = 'Sano';
  static const String ausente = 'Ausente'; // Blue /
  static const String porExtraer = 'PorExtraer'; // Red /
  static const String protesisFija = 'ProtesisFija'; // Bridge
  static const String erupcion = 'Erupcion'; // Arrow

  // Independent Property
  static const String sellador = 'Sellador'; // Blue S (Toggle)

  // Surface States (Nivel Caras)
  static const String caries = 'Caries'; // Red solid
  static const String obturacion = 'Obturacion'; // Blue solid (Resina)
  static const String fractura = 'Fractura'; // Red Zigzag
  static const String restauracionFiltrada =
      'RestauracionFiltrada'; // Blue fill, Red border
}

class OdontogramaController
    extends StateNotifier<AsyncValue<List<PiezaDental>>> {
  final OdontogramaRepository _repository;
  final String pacienteId;

  OdontogramaController(this._repository, this.pacienteId)
    : super(const AsyncValue.loading()) {
    loadOdontograma();
  }

  Future<void> loadOdontograma() async {
    try {
      final data = await _repository.getOdontograma(pacienteId);
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Toggles 'tieneSellador' property.
  /// Does NOT affect surfaces or global state (unless global is Ausente).
  Future<void> toggleSellador(PiezaDental pieza) async {
    if (pieza.estadoGeneral == OdontogramaTools.ausente)
      return; // Disabled if Absent

    final updatedPieza = pieza.copyWith(tieneSellador: !pieza.tieneSellador);
    await _updateLocalAndDb(updatedPieza);
  }

  /// Sets a Global State (Ausente, PorExtraer, Erupcion).
  /// If logic: Re-applying the same state toggles back to 'Sano'.
  /// 'Ausente' clears all surface states.
  Future<void> setGlobalState(PiezaDental pieza, String newState) async {
    PiezaDental updatedPieza;

    if (pieza.estadoGeneral == newState) {
      // Toggle off -> Sano
      updatedPieza = pieza.copyWith(estadoGeneral: OdontogramaTools.sano);
    } else {
      updatedPieza = pieza.copyWith(estadoGeneral: newState);
      // Logic: If Ausente, clear surfaces?
      // Doc says: "Si un diente está marcado como Ausente, se deshabilitan las interacciones".
      // It doesn't explicitly say clear, but it implies visual reset. Let's clear for consistency.
      if (newState == OdontogramaTools.ausente) {
        updatedPieza = updatedPieza.copyWith(
          estadoMesial: OdontogramaTools.sano,
          estadoDistal: OdontogramaTools.sano,
          estadoVestibular: OdontogramaTools.sano,
          estadoLingual: OdontogramaTools.sano,
          estadoOclusal: OdontogramaTools.sano,
          tieneSellador: false,
        );
      }
    }
    await _updateLocalAndDb(updatedPieza);
  }

  /// Applies a surface condition (Caries, Obturacion, Fractura).
  /// Ignored if Global State is 'Ausente' or 'ProtesisFija'.
  Future<void> updateSurface(
    PiezaDental pieza,
    String surface,
    String condition,
  ) async {
    if (pieza.estadoGeneral == OdontogramaTools.ausente ||
        pieza.estadoGeneral == OdontogramaTools.protesisFija) {
      return;
    }

    PiezaDental updatedPieza = pieza;
    switch (surface.toLowerCase()) {
      case 'mesial':
        updatedPieza = pieza.copyWith(estadoMesial: condition);
        break;
      case 'distal':
        updatedPieza = pieza.copyWith(estadoDistal: condition);
        break;
      case 'vestibular':
        updatedPieza = pieza.copyWith(estadoVestibular: condition);
        break;
      case 'lingual':
        updatedPieza = pieza.copyWith(estadoLingual: condition);
        break;
      case 'oclusal':
        updatedPieza = pieza.copyWith(estadoOclusal: condition);
        break;
    }

    await _updateLocalAndDb(updatedPieza);
  }

  /// Creates a bridge (Prótesis Fija) between start and end teeth.
  /// Validates that they are in the same arch/quadrant logic implies linear sequence.
  Future<void> createBridge(PiezaDental start, PiezaDental end) async {
    // 1. Determine range
    final allTeeth = state.value ?? [];
    // Sort by ISO to be sure
    final sortedTeeth = List<PiezaDental>.from(allTeeth)
      ..sort((a, b) => a.iso.compareTo(b.iso));

    final startIndex = sortedTeeth.indexWhere((p) => p.iso == start.iso);
    final endIndex = sortedTeeth.indexWhere((p) => p.iso == end.iso);

    if (startIndex == -1 || endIndex == -1) return;

    final minIndex = startIndex < endIndex ? startIndex : endIndex;
    final maxIndex = startIndex > endIndex ? startIndex : endIndex;

    // Validate: simple check, ensure they are somewhat close or same range types?
    // User doc: "mismo paladar (arriba / abajo)".
    // ISO Logic:
    // Upper: 11-18, 21-28, 51-55, 61-65.
    // Lower: 31-38, 41-48, 71-75, 81-85.
    // We can check if both are Upper or both Lower.
    // Upper first digit: 1, 2, 5, 6.
    // Lower first digit: 3, 4, 7, 8.

    bool isUpper(int iso) {
      final d = iso ~/ 10;
      return d == 1 || d == 2 || d == 5 || d == 6;
    }

    if (isUpper(start.iso) != isUpper(end.iso)) {
      // Different palates - invalid.
      // In a real app we might throw error or show snackbar, here we just return or log.
      return;
    }

    // Apply to all in range
    final teethToUpdate = <PiezaDental>[];
    for (int i = minIndex; i <= maxIndex; i++) {
      // Need to check if this tooth is also in the same palate?
      // If sorting puts 18 and 28 adjacent, then 18..28 crosses midline.
      // 18..11 then 21..28.
      // ISOs are not strictly linear in physical arch (18,17...11, 21...28).
      // My sorted list is 11,12..18, 21..28.
      // If I bridge 11 to 21 (Central Incisors bridge), they are adjacent in list?
      // 11, 12... wait.
      // 11 is next to 21 in physical.
      // In sorted list: 11, ..., 18, 21.
      // WAIT. 11 and 21 are physically adjacent.
      // If I bridge 11 to 21.
      // Sorted list: 11, 12, ... 18, 21 ...
      // Range 11 to 21 includes 12,13..18. This is WRONG.
      // The list must be sorted by "Arch Order".
      // Physical order: 18 -> 11, 21 -> 28.

      // Let's refine the range logic.
      // We really just want to set ProtesisFija on the two selected and anything "physically between".
      // Implementing proper physical sorting is complex.
      // Simplification: Just update the two selected for now and any that the user *clicks*?
      // User doc says: "todos los dientes entre los seleccionados".

      // Let's rely on the user selecting start and end correctly?
      // NO, automated.

      // I will implement a quick helper to get 'teeth between' based on standard arch.
      // Upper Arch: 18,17,16,15,14,13,12,11,21,22,23,24,25,26,27,28.
      // Lower Arch: 48,47,46,45,44,43,42,41,31,32,33,34,35,36,37,38.
      // (And pediatric similarly).

      // I'll skip complex "between" logic for this turn and just support setting the ones passed?
      // No, I must do it.
      // I will implement a hardcoded list of 'Physical Order'.
    }

    final physicalOrder = [
      // Upper Adult
      18, 17, 16, 15, 14, 13, 12, 11, 21, 22, 23, 24, 25, 26, 27, 28,
      // Lower Adult
      48, 47, 46, 45, 44, 43, 42, 41, 31, 32, 33, 34, 35, 36, 37, 38,
      // Upper Ped
      55, 54, 53, 52, 51, 61, 62, 63, 64, 65,
      // Lower Ped
      85, 84, 83, 82, 81, 71, 72, 73, 74, 75,
    ];

    int pStart = physicalOrder.indexOf(start.iso);
    int pEnd = physicalOrder.indexOf(end.iso);

    if (pStart != -1 && pEnd != -1) {
      int min = pStart < pEnd ? pStart : pEnd;
      int max = pStart > pEnd ? pStart : pEnd;

      // Check continuity? If indices are far apart but valid, assume yes.
      // Check if they cross upper/lower boundary?
      // Upper Adult indices: 0-15. Lower Adult: 16-31.
      // They shouldn't cross 15-16.
      // Note: We check consistency with isUpper() below.

      if (isUpper(start.iso) == isUpper(end.iso)) {
        // Valid range
        for (int i = min; i <= max; i++) {
          int targetIso = physicalOrder[i];
          // Find this tooth in our state
          try {
            final t = sortedTeeth.firstWhere((t) => t.iso == targetIso);
            teethToUpdate.add(
              t.copyWith(
                estadoGeneral: OdontogramaTools.protesisFija,
                // Should we clear surfaces? Yes for bridge anchors/pontics usually.
                estadoMesial: 'Sano',
                estadoDistal: 'Sano',
                estadoVestibular: 'Sano',
                estadoLingual: 'Sano',
                estadoOclusal: 'Sano',
              ),
            );
          } catch (e) {
            // Tooth might not exist (e.g. pediatric in adult mode? actually state has all 52)
          }
        }
      }
    }

    for (var t in teethToUpdate) {
      await _updateLocalAndDb(t);
    }
  }

  Future<void> cleanPediatricTeeth() async {
    // Pediatric ISOs: 51-55, 61-65, 71-75, 81-85
    final pedIsos = [
      51,
      52,
      53,
      54,
      55,
      61,
      62,
      63,
      64,
      65,
      71,
      72,
      73,
      74,
      75,
      81,
      82,
      83,
      84,
      85,
    ];

    final currentList = state.value ?? [];
    for (var p in currentList) {
      if (pedIsos.contains(p.iso)) {
        // Reset
        if (p.estadoGeneral != 'Sano' ||
            p.tieneSellador ||
            p.estadoMesial != 'Sano') {
          final resetP = p.copyWith(
            estadoGeneral: 'Sano',
            tieneSellador: false,
            estadoMesial: 'Sano',
            estadoDistal: 'Sano',
            estadoVestibular: 'Sano',
            estadoLingual: 'Sano',
            estadoOclusal: 'Sano',
          );
          await _updateLocalAndDb(resetP);
        }
      }
    }
  }

  Future<void> _updateLocalAndDb(PiezaDental updated) async {
    // Optimistic Update
    state.whenData((currentList) {
      state = AsyncValue.data([
        for (final p in currentList)
          if (p.id == updated.id) updated else p,
      ]);
    });

    await _repository.updatePieza(updated);
  }
}
