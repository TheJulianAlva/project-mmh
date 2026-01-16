// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'periodo.freezed.dart';
part 'periodo.g.dart';

@freezed
abstract class Periodo with _$Periodo {
  const factory Periodo({
    @JsonKey(name: 'id_periodo') int? idPeriodo,
    @JsonKey(name: 'nombre_periodo') required String nombrePeriodo,
  }) = _Periodo;

  factory Periodo.fromJson(Map<String, dynamic> json) =>
      _$PeriodoFromJson(json);
}
