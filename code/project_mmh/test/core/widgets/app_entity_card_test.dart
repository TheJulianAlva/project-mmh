import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_entity_card.dart';
import '_harness.dart';

void main() {
  testWidgets('muestra el título en color primary y un chevron si es tocable', (
    t,
  ) async {
    await t.pumpWidget(
      wrap(
        AppEntityCard(
          title: 'Clase V',
          onTap: () {},
          child: const Text('detalle'),
        ),
      ),
    );
    final title = t.widget<Text>(find.text('Clase V'));
    expect(title.style?.color, isNotNull);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(find.text('detalle'), findsOneWidget);
  });

  testWidgets('sin onTap no muestra chevron y no es tocable', (t) async {
    await t.pumpWidget(
      wrap(const AppEntityCard(title: 'Panel', child: Text('x'))),
    );
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('responde al tap', (t) async {
    var tapped = false;
    await t.pumpWidget(
      wrap(
        AppEntityCard(
          title: 'T',
          onTap: () => tapped = true,
          child: const Text('x'),
        ),
      ),
    );
    await t.tap(find.text('T'));
    expect(tapped, isTrue);
  });

  testWidgets('renderiza en claro y oscuro sin excepción', (t) async {
    for (final dark in [false, true]) {
      await t.pumpWidget(
        wrap(
          dark: dark,
          AppEntityCard(
            title: 'T',
            leading: const Icon(Icons.person),
            onTap: () {},
            child: const Text('x'),
          ),
        ),
      );
      expect(t.takeException(), isNull);
    }
  });
}
