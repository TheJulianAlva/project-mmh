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

  // Orden físico de cada arcada (para calcular los dientes "entre" dos piezas).
  static const List<int> _upperAdult = [
    18, 17, 16, 15, 14, 13, 12, 11, 21, 22, 23, 24, 25, 26, 27, 28,
  ];
  static const List<int> _lowerAdult = [
    48, 47, 46, 45, 44, 43, 42, 41, 31, 32, 33, 34, 35, 36, 37, 38,
  ];
  static const List<int> _upperPed = [55, 54, 53, 52, 51, 61, 62, 63, 64, 65];
  static const List<int> _lowerPed = [85, 84, 83, 82, 81, 71, 72, 73, 74, 75];

  static const Set<int> _pedIsos = {
    51, 52, 53, 54, 55, 61, 62, 63, 64, 65, //
    71, 72, 73, 74, 75, 81, 82, 83, 84, 85,
  };

  List<int>? _archFor(int iso) {
    for (final arch in [_upperAdult, _lowerAdult, _upperPed, _lowerPed]) {
      if (arch.contains(iso)) return arch;
    }
    return null;
  }

  bool _isDirty(PiezaDental p) =>
      p.estadoGeneral != 'Sano' ||
      p.tieneSellador ||
      p.estadoMesial != 'Sano' ||
      p.estadoDistal != 'Sano' ||
      p.estadoVestibular != 'Sano' ||
      p.estadoLingual != 'Sano' ||
      p.estadoOclusal != 'Sano';

  /// Indica si hay trabajo registrado en piezas temporales (para pedir
  /// confirmación antes de limpiarlas).
  bool hasPediatricData() {
    final list = state.value ?? [];
    return list.any((p) => _pedIsos.contains(p.iso) && _isDirty(p));
  }

  /// Crea un puente (Prótesis Fija) entre dos piezas de la **misma arcada**,
  /// marcando también las piezas intermedias. Devuelve `false` si las piezas
  /// no pertenecen a la misma arcada o el rango es inválido.
  Future<bool> createBridge(PiezaDental start, PiezaDental end) async {
    if (start.iso == end.iso) return false;

    final arch = _archFor(start.iso);
    if (arch == null || !arch.contains(end.iso)) return false;

    final teeth = state.value ?? [];
    final i1 = arch.indexOf(start.iso);
    final i2 = arch.indexOf(end.iso);
    final lo = i1 < i2 ? i1 : i2;
    final hi = i1 < i2 ? i2 : i1;

    final updates = <PiezaDental>[];
    for (var i = lo; i <= hi; i++) {
      final iso = arch[i];
      PiezaDental? pieza;
      for (final t in teeth) {
        if (t.iso == iso) {
          pieza = t;
          break;
        }
      }
      if (pieza == null) continue;
      // Respetar dientes ausentes: no forman parte del puente.
      if (pieza.estadoGeneral == OdontogramaTools.ausente) continue;
      updates.add(
        pieza.copyWith(
          estadoGeneral: OdontogramaTools.protesisFija,
          estadoMesial: 'Sano',
          estadoDistal: 'Sano',
          estadoVestibular: 'Sano',
          estadoLingual: 'Sano',
          estadoOclusal: 'Sano',
        ),
      );
    }

    for (final t in updates) {
      await _updateLocalAndDb(t);
    }
    return updates.isNotEmpty;
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
