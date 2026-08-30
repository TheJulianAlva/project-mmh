import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/theme/app_theme.dart';
import 'package:project_mmh/features/dev/presentation/style_guide_screen.dart';

void main() {
  testWidgets('la style guide renderiza en claro y oscuro sin excepción', (
    t,
  ) async {
    for (final dark in [false, true]) {
      await t.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark() : AppTheme.light(),
          home: const StyleGuideScreen(),
        ),
      );
      await t.pumpAndSettle();
      expect(find.byType(StyleGuideScreen), findsOneWidget);
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('lista secciones de token y de componente', (t) async {
    await t.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const StyleGuideScreen()),
    );
    await t.pumpAndSettle();
    expect(find.text('COLOR'), findsOneWidget);
    expect(find.text('TIPOGRAFÍA'), findsOneWidget);
    // Sección más abajo: hay que desplazarse hasta ella.
    await t.scrollUntilVisible(find.text('BOTONES'), 400);
    expect(find.text('BOTONES'), findsOneWidget);
  });
}
