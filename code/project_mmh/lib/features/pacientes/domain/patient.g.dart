// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Patient _$PatientFromJson(Map<String, dynamic> json) => _Patient(
  idExpediente: json['id_expediente'] as String,
  nombre: json['nombre'] as String,
  primerApellido: json['primer_apellido'] as String,
  segundoApellido: json['segundo_apellido'] as String?,
  edad: (json['edad'] as num).toInt(),
  sexo: json['sexo'] as String,
  telefono: json['telefono'] as String?,
  padecimientoRelevante: json['padecimiento_relevante'] as String?,
  informacionAdicional: json['informacion_adicional'] as String?,
  imagenesPaths:
      (json['imagenes_paths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$PatientToJson(_Patient instance) => <String, dynamic>{
  'id_expediente': instance.idExpediente,
  'nombre': instance.nombre,
  'primer_apellido': instance.primerApellido,
  'segundo_apellido': instance.segundoApellido,
  'edad': instance.edad,
  'sexo': instance.sexo,
  'telefono': instance.telefono,
  'padecimiento_relevante': instance.padecimientoRelevante,
  'informacion_adicional': instance.informacionAdicional,
  'imagenes_paths': instance.imagenesPaths,
};
