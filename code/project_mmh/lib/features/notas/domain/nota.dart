// ignore_for_file: invalid_annotation_target
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';

part 'nota.freezed.dart';
part 'nota.g.dart';

@freezed
abstract class Nota with _$Nota {
  const Nota._();

  const factory Nota({
    @JsonKey(name: 'id_nota') int? idNota,
    @JsonKey(name: 'tipo') required NotaTipo tipo,
    @JsonKey(name: 'contenido') String? contenido,
    @JsonKey(name: 'fecha') required String fecha,
    @JsonKey(name: 'id_paciente') String? idPaciente,
    @JsonKey(name: 'id_clinica') int? idClinica,
    @JsonKey(name: 'id_nota_relacionada') int? idNotaRelacionada,
    @JsonKey(name: 'items_json', fromJson: _parseItems)
    @Default([])
    List<NotaItem> items,
    @JsonKey(name: 'proveedor') String? proveedor,
    @JsonKey(name: 'origen') @Default(NotaOrigen.manual) NotaOrigen origen,
    @JsonKey(name: 'nombre_contacto') String? nombreContacto,
    @JsonKey(name: 'telefono') String? telefono,
    @JsonKey(name: 'tratamiento_probable') String? tratamientoProbable,
    @JsonKey(name: 'convertido', fromJson: _boolFromDb)
    @Default(false)
    bool convertido,
    @JsonKey(name: 'id_paciente_convertido') String? idPacienteConvertido,
  }) = _Nota;

  factory Nota.fromJson(Map<String, dynamic> json) => _$NotaFromJson(json);

  /// Suma `cantidad * precioUnitario` de los ítems (usado en notas `cotizacion`).
  double get totalCotizacion =>
      items.fold(0.0, (sum, i) => sum + (i.cantidad * (i.precioUnitario ?? 0)));
}

List<NotaItem> _parseItems(Object? value) {
  if (value == null) return [];
  if (value is String) {
    if (value.trim().isEmpty) return [];
    final decoded = jsonDecode(value) as List;
    return decoded
        .map((e) => NotaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  if (value is List) {
    return value
        .map(
          (e) =>
              e is NotaItem ? e : NotaItem.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
  return [];
}

bool _boolFromDb(Object? value) => value == true || value == 1;
