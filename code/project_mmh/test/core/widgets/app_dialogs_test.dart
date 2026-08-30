import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_switch.dart';
import '_harness.dart';

void main() {
  testWidgets('AppSwitch refleja value y emite onChanged', (t) async {
    var v = false;
    await t.pumpWidget(
      wrap(
        StatefulBuilder(
          builder:
              (c, setState) => AppSwitch(
                value: v,
                onChanged: (nv) => setState(() => v = nv),
              ),
        ),
      ),
    );
    await t.tap(find.byType(AppSwitch));
    await t.pumpAndSettle();
    expect(v, isTrue);
  });

  testWidgets('showAppConfirm devuelve true al confirmar', (t) async {
    late bool result;
    await t.pumpWidget(
      wrap(
        Builder(
          builder:
              (c) => ElevatedButton(
                onPressed:
                    () async =>
                        result = await showAppConfirm(
                          c,
                          title: '¿Seguro?',
                          confirmLabel: 'Sí',
                        ),
                child: const Text('go'),
              ),
        ),
      ),
    );
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
    await t.tap(find.text('Sí'));
    await t.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('showAppSheet muestra el contenido y el título', (t) async {
    await t.pumpWidget(
      wrap(
        Builder(
          builder:
              (c) => ElevatedButton(
                onPressed:
                    () => showAppSheet<void>(
                      c,
                      title: 'Opciones',
                      builder: (_) => const Text('cuerpo'),
                    ),
                child: const Text('open'),
              ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('Opciones'), findsOneWidget);
    expect(find.text('cuerpo'), findsOneWidget);
  });
}
