import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import '_harness.dart';

void main() {
  testWidgets('AppCard renderiza el hijo y responde al tap', (t) async {
    var tapped = false;
    await t.pumpWidget(
      wrap(AppCard(onTap: () => tapped = true, child: const Text('contenido'))),
    );
    expect(find.text('contenido'), findsOneWidget);
    await t.tap(find.text('contenido'));
    expect(tapped, isTrue);
  });

  testWidgets('AppCard con accentColor pinta la barra', (t) async {
    await t.pumpWidget(
      wrap(const AppCard(accentColor: Color(0xFF00C7BE), child: Text('x'))),
    );
    final bar = t.widget<Container>(
      find.descendant(
        of: find.byType(AppCard),
        matching: find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 4,
        ),
      ),
    );
    expect(bar.color, const Color(0xFF00C7BE));
  });

  testWidgets('AppSectionHeader pone el label en mayúsculas', (t) async {
    await t.pumpWidget(wrap(const AppSectionHeader('Información médica')));
    expect(find.text('INFORMACIÓN MÉDICA'), findsOneWidget);
  });

  testWidgets('AppEmptyState muestra icono, título y mensaje', (t) async {
    await t.pumpWidget(
      wrap(
        const AppEmptyState(
          icon: Icons.inbox,
          title: 'Sin pacientes',
          message: 'Añade el primero',
        ),
      ),
    );
    expect(find.text('Sin pacientes'), findsOneWidget);
    expect(find.text('Añade el primero'), findsOneWidget);
    expect(find.byIcon(Icons.inbox), findsOneWidget);
  });

  testWidgets('los tres renderizan en oscuro sin excepción', (t) async {
    await t.pumpWidget(
      wrap(
        dark: true,
        ListView(
          children: const [
            AppCard(child: Text('c')),
            AppSectionHeader('s'),
            SizedBox(
              height: 200,
              child: AppEmptyState(icon: Icons.inbox, title: 't'),
            ),
          ],
        ),
      ),
    );
    expect(t.takeException(), isNull);
  });
}
