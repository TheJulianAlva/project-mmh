import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/theme/app_theme.dart';

void main() {
  testWidgets('AppScaffold muestra el título y el body', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const AppScaffold(
          title: 'Pacientes',
          showBack: false,
          body: Text('lista'),
        ),
      ),
    );
    expect(find.text('Pacientes'), findsWidgets);
    expect(find.text('lista'), findsOneWidget);
    expect(find.byType(SliverAppBar), findsOneWidget);
  });

  testWidgets('acepta slivers en vez de body', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppScaffold(
          title: 'Agenda',
          showBack: false,
          slivers: [
            SliverList.list(children: const [Text('a'), Text('b')]),
          ],
        ),
      ),
    );
    expect(find.text('a'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
