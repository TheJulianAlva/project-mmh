import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pieza_dental.freezed.dart';
part 'pieza_dental.g.dart';

@freezed
abstract class PiezaDental with _$PiezaDental {
  const PiezaDental._(); // Added private constructor for custom methods

  const factory PiezaDental({
    String? id, // maps to id_pieza
    required int odontogramaId, // maps to id_odontograma
    required int iso, // maps to numero_pieza

    @Default('Sano') String estadoGeneral, // maps to estado_general
    @Default(false) bool tieneSellador, // Stored in JSON
    // Virtual fields (mapped from/to 'superficies' JSON column)
    @Default('Sano') String estadoMesial,
    @Default('Sano') String estadoDistal,
    @Default('Sano') String estadoVestibular,
    @Default('Sano') String estadoLingual,
    @Default('Sano') String estadoOclusal,
  }) = _PiezaDental;

  factory PiezaDental.fromJson(Map<String, dynamic> json) =>
      _$PiezaDentalFromJson(json);

  // Helper to convert DB row to Model
  factory PiezaDental.fromDb(Map<String, dynamic> row) {
    Map<String, dynamic> surfaces = {};
    if (row['superficies'] != null &&
        row['superficies'].toString().isNotEmpty) {
      try {
        surfaces = jsonDecode(row['superficies']);
      } catch (_) {}
    }

    return PiezaDental(
      id: row['id_pieza'],
      odontogramaId: row['id_odontograma'],
      iso: row['numero_pieza'],
      estadoGeneral: row['estado_general'] ?? 'Sano',
      tieneSellador: surfaces['tieneSellador'] ?? false,
      estadoMesial: surfaces['mesial'] ?? 'Sano',
      estadoDistal: surfaces['distal'] ?? 'Sano',
      estadoVestibular: surfaces['vestibular'] ?? 'Sano',
      estadoLingual: surfaces['lingual'] ?? 'Sano',
      estadoOclusal: surfaces['oclusal'] ?? 'Sano',
    );
  }

  // Helper to convert Model to DB row
  Map<String, dynamic> toDb() {
    final surfaces = {
      'mesial': estadoMesial,
      'distal': estadoDistal,
      'vestibular': estadoVestibular,
      'lingual': estadoLingual,
      'oclusal': estadoOclusal,
      'tieneSellador': tieneSellador,
    };

    return {
      'id_pieza': id,
      'id_odontograma': odontogramaId,
      'numero_pieza': iso,
      'estado_general': estadoGeneral,
      'superficies': jsonEncode(surfaces),
    };
  }
}
