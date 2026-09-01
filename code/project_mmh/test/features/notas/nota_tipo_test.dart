import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';

void main() {
  test('NotaTipo.listaMateriales serializa a lista_materiales', () {
    expect(NotaTipo.listaMateriales.dbValue, 'lista_materiales');
  });

  test('NotaOrigen.imagen serializa a imagen', () {
    expect(NotaOrigen.imagen.dbValue, 'imagen');
  });

  test('labels en español', () {
    expect(NotaTipo.prepaciente.label, 'Prepaciente');
    expect(NotaTipo.cotizacion.label, 'Cotización');
  });
}
