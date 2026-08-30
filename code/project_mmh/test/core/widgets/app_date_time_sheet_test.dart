import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_date_time_sheet.dart';
import '_harness.dart';

void main() {
  testWidgets('devuelve el valor inicial al confirmar sin girar la rueda', (
    t,
  ) async {
    final initial = DateTime(2026, 9, 2, 10, 0);
    DateTime? picked;
    await t.pumpWidget(
      wrap(
        Builder(
          builder:
              (c) => ElevatedButton(
                onPressed:
                    () async =>
                        picked = await AppDateTimeSheet.pick(
                          c,
                          initial: initial,
                        ),
                child: const Text('pick'),
              ),
        ),
      ),
    );
    await t.tap(find.text('pick'));
    await t.pumpAndSettle();
    await t.tap(find.text('Aceptar'));
    await t.pumpAndSettle();
    expect(picked, initial);
  });

  testWidgets('devuelve null al cancelar', (t) async {
    DateTime? picked = DateTime(2000);
    await t.pumpWidget(
      wrap(
        Builder(
          builder:
              (c) => ElevatedButton(
                onPressed: () async => picked = await AppDateTimeSheet.pick(c),
                child: const Text('pick'),
              ),
        ),
      ),
    );
    await t.tap(find.text('pick'));
    await t.pumpAndSettle();
    await t.tap(find.text('Cancelar'));
    await t.pumpAndSettle();
    expect(picked, isNull);
  });
}
