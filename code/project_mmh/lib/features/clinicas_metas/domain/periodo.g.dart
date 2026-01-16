// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'periodo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Periodo _$PeriodoFromJson(Map<String, dynamic> json) => _Periodo(
  idPeriodo: (json['id_periodo'] as num?)?.toInt(),
  nombrePeriodo: json['nombre_periodo'] as String,
);

Map<String, dynamic> _$PeriodoToJson(_Periodo instance) => <String, dynamic>{
  'id_periodo': instance.idPeriodo,
  'nombre_periodo': instance.nombrePeriodo,
};
