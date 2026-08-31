// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sesion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Sesion _$SesionFromJson(Map<String, dynamic> json) => _Sesion(
  idSesion: (json['id_sesion'] as num?)?.toInt(),
  idTratamiento: (json['id_tratamiento'] as num).toInt(),
  fechaInicio: json['fecha_inicio'] as String,
  fechaFin: json['fecha_fin'] as String,
  estadoAsistencia: $enumDecodeNullable(
    _$EstadoAsistenciaEnumMap,
    json['estado_asistencia'],
  ),
);

Map<String, dynamic> _$SesionToJson(_Sesion instance) => <String, dynamic>{
  'id_sesion': instance.idSesion,
  'id_tratamiento': instance.idTratamiento,
  'fecha_inicio': instance.fechaInicio,
  'fecha_fin': instance.fechaFin,
  'estado_asistencia': _$EstadoAsistenciaEnumMap[instance.estadoAsistencia],
};

const _$EstadoAsistenciaEnumMap = {
  EstadoAsistencia.programada: 'programada',
  EstadoAsistencia.asistio: 'asistio',
  EstadoAsistencia.falto: 'falto',
};
