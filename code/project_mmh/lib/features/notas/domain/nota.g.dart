// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nota.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Nota _$NotaFromJson(Map<String, dynamic> json) => _Nota(
  idNota: (json['id_nota'] as num?)?.toInt(),
  tipo: $enumDecode(_$NotaTipoEnumMap, json['tipo']),
  contenido: json['contenido'] as String?,
  fecha: json['fecha'] as String,
  idPaciente: json['id_paciente'] as String?,
  idClinica: (json['id_clinica'] as num?)?.toInt(),
  idNotaRelacionada: (json['id_nota_relacionada'] as num?)?.toInt(),
  items:
      json['items_json'] == null ? const [] : _parseItems(json['items_json']),
  proveedor: json['proveedor'] as String?,
  origen:
      $enumDecodeNullable(_$NotaOrigenEnumMap, json['origen']) ??
      NotaOrigen.manual,
  nombreContacto: json['nombre_contacto'] as String?,
  telefono: json['telefono'] as String?,
  tratamientoProbable: json['tratamiento_probable'] as String?,
  convertido:
      json['convertido'] == null ? false : _boolFromDb(json['convertido']),
  idPacienteConvertido: json['id_paciente_convertido'] as String?,
);

Map<String, dynamic> _$NotaToJson(_Nota instance) => <String, dynamic>{
  'id_nota': instance.idNota,
  'tipo': _$NotaTipoEnumMap[instance.tipo]!,
  'contenido': instance.contenido,
  'fecha': instance.fecha,
  'id_paciente': instance.idPaciente,
  'id_clinica': instance.idClinica,
  'id_nota_relacionada': instance.idNotaRelacionada,
  'items_json': instance.items,
  'proveedor': instance.proveedor,
  'origen': _$NotaOrigenEnumMap[instance.origen]!,
  'nombre_contacto': instance.nombreContacto,
  'telefono': instance.telefono,
  'tratamiento_probable': instance.tratamientoProbable,
  'convertido': instance.convertido,
  'id_paciente_convertido': instance.idPacienteConvertido,
};

const _$NotaTipoEnumMap = {
  NotaTipo.general: 'general',
  NotaTipo.prepaciente: 'prepaciente',
  NotaTipo.listaMateriales: 'lista_materiales',
  NotaTipo.cotizacion: 'cotizacion',
};

const _$NotaOrigenEnumMap = {
  NotaOrigen.manual: 'manual',
  NotaOrigen.imagen: 'imagen',
  NotaOrigen.pdf: 'pdf',
};
