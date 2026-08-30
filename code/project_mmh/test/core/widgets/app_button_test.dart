import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import '_harness.dart';

void main() {
  testWidgets('primary dispara onPressed', (t) async {
    var n = 0;
    await t.pumpWidget(
      wrap(AppButton.primary(label: 'Guardar', onPressed: () => n++)),
    );
    await t.tap(find.text('Guardar'));
    expect(n, 1);
  });

  testWidgets('loading muestra spinner y bloquea el tap', (t) async {
    var n = 0;
    await t.pumpWidget(
      wrap(
        AppButton.primary(
          label: 'Guardar',
          loading: true,
          onPressed: () => n++,
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await t.tap(find.byType(AppButton));
    expect(n, 0);
  });

  testWidgets('onPressed null => deshabilitado', (t) async {
    await t.pumpWidget(wrap(AppButton.secondary(label: 'x', onPressed: null)));
    final btn = t.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(btn.enabled, isFalse);
  });

  testWidgets('las 4 variantes renderizan en claro y oscuro', (t) async {
    for (final dark in [false, true]) {
      await t.pumpWidget(
        wrap(
          dark: dark,
          Column(
            children: [
              AppButton.primary(label: 'a', onPressed: () {}),
              AppButton.secondary(label: 'b', onPressed: () {}),
              AppButton.text(label: 'c', onPressed: () {}),
              AppButton.destructive(label: 'd', onPressed: () {}),
            ],
          ),
        ),
      );
      expect(t.takeException(), isNull);
    }
  });
}
