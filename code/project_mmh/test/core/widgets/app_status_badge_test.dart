import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_status_badge.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';
import '_harness.dart';

void main() {
  testWidgets('cubre todos los valores de EstadoAsistencia (+ null)', (
    t,
  ) async {
    for (final e in [...EstadoAsistencia.values, null]) {
      await t.pumpWidget(wrap(AppStatusBadge.asistencia(e)));
      expect(find.byType(AppStatusBadge), findsOneWidget);
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('cubre todos los valores de EstadoTratamiento', (t) async {
    for (final e in EstadoTratamiento.values) {
      await t.pumpWidget(wrap(AppStatusBadge.tratamiento(e)));
      expect(find.text(e.label), findsOneWidget);
    }
  });

  testWidgets('asistio muestra el label "Asistió"', (t) async {
    await t.pumpWidget(
      wrap(AppStatusBadge.asistencia(EstadoAsistencia.asistio)),
    );
    expect(find.text('Asistió'), findsOneWidget);
  });
}
