// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sesion.freezed.dart';
part 'sesion.g.dart';

@freezed
abstract class Sesion with _$Sesion {
  const factory Sesion({
    @JsonKey(name: 'id_sesion') int? idSesion,
    @JsonKey(name: 'id_tratamiento') required int idTratamiento,
    @JsonKey(name: 'fecha_inicio') required String fechaInicio,
    @JsonKey(name: 'fecha_fin') required String fechaFin,
    @JsonKey(name: 'estado_asistencia')
    String? estadoAsistencia, // 'programada', 'asistio', 'falto'
  }) = _Sesion;

  factory Sesion.fromJson(Map<String, dynamic> json) => _$SesionFromJson(json);
}
