import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';

void main() {
  test('NotaItem round-trip preserva precio_unitario', () {
    const item = NotaItem(
      nombre: 'Guantes',
      cantidad: 2,
      unidad: 'caja',
      precioUnitario: 45.5,
    );
    final json = item.toJson();
    expect(json['precio_unitario'], 45.5);
    expect(NotaItem.fromJson(json), item);
  });

  test('NotaItem sin precio ni unidad', () {
    const item = NotaItem(nombre: 'Resina', cantidad: 1);
    expect(NotaItem.fromJson(item.toJson()), item);
  });
}
