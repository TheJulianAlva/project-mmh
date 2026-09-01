import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_selection_sheet.dart';
import '_harness.dart';

void main() {
  testWidgets('con una sola opción, tocarla la devuelve', (t) async {
    String? picked;
    await t.pumpWidget(
      wrap(
        Builder(
          builder:
              (c) => ElevatedButton(
                onPressed:
                    () async =>
                        picked = await showAppSelectionSheet<String>(
                          c,
                          title: 'Clínica',
                          options: const ['Central'],
                          labelOf: (s) => s,
                        ),
                child: const Text('open'),
              ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.tap(find.text('Central'));
    await t.pumpAndSettle();
    expect(picked, 'Central');
  });

  testWidgets('marca la opción seleccionada', (t) async {
    await t.pumpWidget(
      wrap(
        Builder(
          builder:
              (c) => ElevatedButton(
                onPressed:
                    () => showAppSelectionSheet<String>(
                      c,
                      title: 'X',
                      options: const ['A', 'B'],
                      labelOf: (s) => s,
                      selected: 'B',
                    ),
                child: const Text('open'),
              ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('searchable filtra por label', (t) async {
    String? picked;
    await t.pumpWidget(
      wrap(
        Builder(
          builder:
              (c) => ElevatedButton(
                onPressed:
                    () async =>
                        picked = await showAppSelectionSheet<String>(
                          c,
                          title: 'X',
                          options: const ['Ana', 'Beto', 'Carla'],
                          labelOf: (s) => s,
                          searchable: true,
                        ),
                child: const Text('open'),
              ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'car');
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Ana'), findsNothing);
    await t.tap(find.text('Carla'));
    await t.pumpAndSettle();
    expect(picked, 'Carla');
  });
}
