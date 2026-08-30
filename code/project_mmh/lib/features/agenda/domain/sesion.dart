// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';

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
    EstadoAsistencia? estadoAsistencia,
  }) = _Sesion;

  factory Sesion.fromJson(Map<String, dynamic> json) => _$SesionFromJson(json);
}
