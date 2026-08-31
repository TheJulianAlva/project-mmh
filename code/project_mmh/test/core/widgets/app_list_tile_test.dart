import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_list_tile.dart';
import '_harness.dart';

void main() {
  testWidgets('AppListTile muestra título, subtítulo y responde al tap', (
    t,
  ) async {
    var tapped = false;
    await t.pumpWidget(
      wrap(
        AppListTile(
          icon: Icons.notifications,
          title: 'Recordatorios',
          subtitle: 'Diario a las 9:00',
          onTap: () => tapped = true,
        ),
      ),
    );
    expect(find.text('Recordatorios'), findsOneWidget);
    expect(find.text('Diario a las 9:00'), findsOneWidget);
    await t.tap(find.text('Recordatorios'));
    expect(tapped, isTrue);
  });

  testWidgets('AppSettingsGroup pinta cabecera y agrupa hijos', (t) async {
    await t.pumpWidget(
      wrap(
        const AppSettingsGroup(
          header: 'General',
          children: [AppListTile(title: 'A'), AppListTile(title: 'B')],
        ),
      ),
    );
    expect(find.text('GENERAL'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });
}
