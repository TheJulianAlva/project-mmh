// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tratamiento.freezed.dart';
part 'tratamiento.g.dart';

@freezed
abstract class Tratamiento with _$Tratamiento {
  const factory Tratamiento({
    @JsonKey(name: 'id_tratamiento') int? idTratamiento,
    @JsonKey(name: 'id_clinica') required int idClinica,
    @JsonKey(name: 'id_expediente') required String idExpediente,
    @JsonKey(name: 'id_objetivo') int? idObjetivo,
    @JsonKey(name: 'nombre_tratamiento') required String nombreTratamiento,
    @JsonKey(name: 'fecha_creacion') required String fechaCreacion,
    @JsonKey(name: 'estado')
    required String estado, // 'pendiente', 'en_proceso', 'concluido'
  }) = _Tratamiento;

  factory Tratamiento.fromJson(Map<String, dynamic> json) =>
      _$TratamientoFromJson(json);
}
