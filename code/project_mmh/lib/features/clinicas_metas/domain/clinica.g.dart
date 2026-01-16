// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinica.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Clinica _$ClinicaFromJson(Map<String, dynamic> json) => _Clinica(
  idClinica: (json['id_clinica'] as num?)?.toInt(),
  idPeriodo: (json['id_periodo'] as num).toInt(),
  nombreClinica: json['nombre_clinica'] as String,
  color: json['color'] as String,
  horarios: json['horarios'] as String?,
);

Map<String, dynamic> _$ClinicaToJson(_Clinica instance) => <String, dynamic>{
  'id_clinica': instance.idClinica,
  'id_periodo': instance.idPeriodo,
  'nombre_clinica': instance.nombreClinica,
  'color': instance.color,
  'horarios': instance.horarios,
};
