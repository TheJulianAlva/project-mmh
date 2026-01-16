// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinica.freezed.dart';
part 'clinica.g.dart';

@freezed
abstract class Clinica with _$Clinica {
  const factory Clinica({
    @JsonKey(name: 'id_clinica') int? idClinica,
    @JsonKey(name: 'id_periodo') required int idPeriodo,
    @JsonKey(name: 'nombre_clinica') required String nombreClinica,
    required String color,
    String? horarios,
  }) = _Clinica;

  factory Clinica.fromJson(Map<String, dynamic> json) =>
      _$ClinicaFromJson(json);
}
