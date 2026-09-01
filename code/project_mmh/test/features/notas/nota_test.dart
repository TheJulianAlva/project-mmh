import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';

void main() {
  test('Nota general round-trip', () {
    const nota = Nota(
      tipo: NotaTipo.general,
      contenido: 'Revisar radiografía',
      fecha: '2026-09-01T10:00:00.000',
    );
    final json = nota.toJson();
    expect(json['tipo'], 'general');
    expect(Nota.fromJson(json), nota);
  });

  test('Nota lista_materiales serializa items_json como lista de mapas', () {
    const nota = Nota(
      tipo: NotaTipo.listaMateriales,
      fecha: '2026-09-01T10:00:00.000',
      items: [NotaItem(nombre: 'Resina', cantidad: 3, unidad: 'pza')],
    );
    final json = nota.toJson();
    expect(json['items_json'], isA<List>());
    expect(Nota.fromJson(json).items, nota.items);
  });

  test('Nota.fromJson parsea items_json cuando viene como String (BD)', () {
    final json = {
      'id_nota': 1,
      'tipo': 'lista_materiales',
      'fecha': '2026-09-01T10:00:00.000',
      'items_json': '[{"nombre":"Guantes","cantidad":2,"unidad":"caja"}]',
      'origen': 'manual',
      'convertido': 0,
    };
    final nota = Nota.fromJson(json);
    expect(nota.items, [
      const NotaItem(nombre: 'Guantes', cantidad: 2, unidad: 'caja'),
    ]);
  });

  test('Nota.fromJson trata items_json vacío/null como lista vacía', () {
    final json = {
      'id_nota': 2,
      'tipo': 'general',
      'fecha': '2026-09-01T10:00:00.000',
      'items_json': null,
      'origen': 'manual',
      'convertido': 0,
    };
    expect(Nota.fromJson(json).items, isEmpty);
  });

  test('totalCotizacion suma cantidad * precioUnitario', () {
    const nota = Nota(
      tipo: NotaTipo.cotizacion,
      fecha: '2026-09-01T10:00:00.000',
      items: [
        NotaItem(nombre: 'A', cantidad: 2, precioUnitario: 10),
        NotaItem(nombre: 'B', cantidad: 1, precioUnitario: 5),
      ],
    );
    expect(nota.totalCotizacion, 25);
  });
}
