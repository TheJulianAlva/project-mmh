import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/presentation/widgets/app_search_field.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import '_harness.dart';

void main() {
  testWidgets('AppSearchField emite onChanged con debounce y limpia', (
    t,
  ) async {
    final changes = <String>[];
    await t.pumpWidget(
      wrap(
        AppSearchField(
          onChanged: changes.add,
          debounce: const Duration(milliseconds: 50),
        ),
      ),
    );
    await t.enterText(find.byType(TextField), 'ana');
    await t.pump(const Duration(milliseconds: 60));
    expect(changes, ['ana']);
    expect(find.byIcon(Icons.close), findsOneWidget);
    await t.tap(find.byIcon(Icons.close));
    await t.pump(const Duration(milliseconds: 60));
    expect(changes.last, '');
  });

  testWidgets('AppTextField.singleLine se integra en un FormBuilder', (
    t,
  ) async {
    final key = GlobalKey<FormBuilderState>();
    await t.pumpWidget(
      wrap(
        FormBuilder(
          key: key,
          child: AppTextField.singleLine(name: 'nombre', label: 'Nombre'),
        ),
      ),
    );
    await t.enterText(find.byType(TextField), 'Marta');
    key.currentState!.save();
    expect(key.currentState!.value['nombre'], 'Marta');
  });

  testWidgets('AppTextField.number usa teclado numérico', (t) async {
    await t.pumpWidget(
      wrap(
        FormBuilder(child: AppTextField.number(name: 'edad', label: 'Edad')),
      ),
    );
    final field = t.widget<TextField>(find.byType(TextField));
    expect(field.keyboardType, TextInputType.number);
  });
}
