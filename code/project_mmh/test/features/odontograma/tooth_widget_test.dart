import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/features/odontograma/presentation/widgets/tooth_widget.dart';

void main() {
  testWidgets('dimmed:true no responde al tap y reduce la opacidad', (t) async {
    var tapped = false;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ToothWidget(
              size: 40,
              isoNumber: '11',
              isUpper: true,
              dimmed: true,
              onTapCenter: () => tapped = true,
            ),
          ),
        ),
      ),
    );
    // el centro del diente
    await t.tap(find.byType(ToothWidget), warnIfMissed: false);
    expect(tapped, isFalse);
    expect(find.byType(Opacity), findsWidgets);
    final op = t.widget<Opacity>(find.byType(Opacity).first);
    expect(op.opacity, lessThan(1.0));
  });

  testWidgets('dimmed:false (defecto) responde al tap', (t) async {
    var tapped = false;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ToothWidget(
              size: 40,
              isoNumber: '11',
              isUpper: true,
              onTapCenter: () => tapped = true,
            ),
          ),
        ),
      ),
    );
    // el cuerpo del diente (el ToothWidget es una Column: etiqueta ISO + cuerpo,
    // así que su centro no coincide con el centro de la zona táctil).
    await t.tapAt(t.getCenter(find.byType(CustomPaint).last));
    expect(tapped, isTrue);
  });
}
