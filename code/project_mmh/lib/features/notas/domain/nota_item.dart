import 'package:freezed_annotation/freezed_annotation.dart';

part 'nota_item.freezed.dart';
part 'nota_item.g.dart';

@freezed
abstract class NotaItem with _$NotaItem {
  const factory NotaItem({
    required String nombre,
    required num cantidad,
    String? unidad,
    @JsonKey(name: 'precio_unitario') double? precioUnitario,
  }) = _NotaItem;

  factory NotaItem.fromJson(Map<String, dynamic> json) =>
      _$NotaItemFromJson(json);
}
