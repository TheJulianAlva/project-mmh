// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pieza_dental.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PiezaDental _$PiezaDentalFromJson(Map<String, dynamic> json) => _PiezaDental(
  id: json['id'] as String?,
  odontogramaId: (json['odontogramaId'] as num).toInt(),
  iso: (json['iso'] as num).toInt(),
  estadoGeneral: json['estadoGeneral'] as String? ?? 'Sano',
  tieneSellador: json['tieneSellador'] as bool? ?? false,
  estadoMesial: json['estadoMesial'] as String? ?? 'Sano',
  estadoDistal: json['estadoDistal'] as String? ?? 'Sano',
  estadoVestibular: json['estadoVestibular'] as String? ?? 'Sano',
  estadoLingual: json['estadoLingual'] as String? ?? 'Sano',
  estadoOclusal: json['estadoOclusal'] as String? ?? 'Sano',
);

Map<String, dynamic> _$PiezaDentalToJson(_PiezaDental instance) =>
    <String, dynamic>{
      'id': instance.id,
      'odontogramaId': instance.odontogramaId,
      'iso': instance.iso,
      'estadoGeneral': instance.estadoGeneral,
      'tieneSellador': instance.tieneSellador,
      'estadoMesial': instance.estadoMesial,
      'estadoDistal': instance.estadoDistal,
      'estadoVestibular': instance.estadoVestibular,
      'estadoLingual': instance.estadoLingual,
      'estadoOclusal': instance.estadoOclusal,
    };
