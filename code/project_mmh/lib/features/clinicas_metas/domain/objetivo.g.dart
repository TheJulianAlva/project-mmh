// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'objetivo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Objetivo _$ObjetivoFromJson(Map<String, dynamic> json) => _Objetivo(
  idObjetivo: (json['id_objetivo'] as num?)?.toInt(),
  idClinica: (json['id_clinica'] as num).toInt(),
  nombreTratamiento: json['nombre_tratamiento'] as String,
  cantidadMeta: (json['cantidad_meta'] as num).toInt(),
  cantidadActual: (json['cantidad_actual'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ObjetivoToJson(_Objetivo instance) => <String, dynamic>{
  'id_objetivo': instance.idObjetivo,
  'id_clinica': instance.idClinica,
  'nombre_tratamiento': instance.nombreTratamiento,
  'cantidad_meta': instance.cantidadMeta,
  'cantidad_actual': instance.cantidadActual,
};
