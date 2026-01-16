// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'objetivo.freezed.dart';
part 'objetivo.g.dart';

@freezed
abstract class Objetivo with _$Objetivo {
  const factory Objetivo({
    @JsonKey(name: 'id_objetivo') int? idObjetivo,
    @JsonKey(name: 'id_clinica') required int idClinica,
    @JsonKey(name: 'nombre_tratamiento') required String nombreTratamiento,
    @JsonKey(name: 'cantidad_meta') required int cantidadMeta,
    @JsonKey(name: 'cantidad_actual') @Default(0) int cantidadActual,
  }) = _Objetivo;

  factory Objetivo.fromJson(Map<String, dynamic> json) =>
      _$ObjetivoFromJson(json);
}
