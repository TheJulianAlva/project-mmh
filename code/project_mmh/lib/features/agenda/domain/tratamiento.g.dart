// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tratamiento.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tratamiento _$TratamientoFromJson(Map<String, dynamic> json) => _Tratamiento(
  idTratamiento: (json['id_tratamiento'] as num?)?.toInt(),
  idClinica: (json['id_clinica'] as num).toInt(),
  idExpediente: json['id_expediente'] as String,
  idObjetivo: (json['id_objetivo'] as num?)?.toInt(),
  nombreTratamiento: json['nombre_tratamiento'] as String,
  fechaCreacion: json['fecha_creacion'] as String,
  estado: json['estado'] as String,
);

Map<String, dynamic> _$TratamientoToJson(_Tratamiento instance) =>
    <String, dynamic>{
      'id_tratamiento': instance.idTratamiento,
      'id_clinica': instance.idClinica,
      'id_expediente': instance.idExpediente,
      'id_objetivo': instance.idObjetivo,
      'nombre_tratamiento': instance.nombreTratamiento,
      'fecha_creacion': instance.fechaCreacion,
      'estado': instance.estado,
    };
