// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nota_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotaItem _$NotaItemFromJson(Map<String, dynamic> json) => _NotaItem(
  nombre: json['nombre'] as String,
  cantidad: json['cantidad'] as num,
  unidad: json['unidad'] as String?,
  precioUnitario: (json['precio_unitario'] as num?)?.toDouble(),
);

Map<String, dynamic> _$NotaItemToJson(_NotaItem instance) => <String, dynamic>{
  'nombre': instance.nombre,
  'cantidad': instance.cantidad,
  'unidad': instance.unidad,
  'precio_unitario': instance.precioUnitario,
};
