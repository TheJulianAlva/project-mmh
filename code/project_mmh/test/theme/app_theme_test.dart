import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_theme.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

void main() {
  test('AppText usa las familias empaquetadas, no google_fonts en runtime', () {
    expect(AppText.screenTitle.fontFamily, 'Outfit');
    expect(AppText.body.fontFamily, 'IBM Plex Sans');
    expect(AppText.metric.fontFamily, 'Outfit');
    expect(AppText.caption.fontFamily, 'IBM Plex Sans');
  });

  test('metric usa cifras tabulares', () {
    expect(
      AppText.metric.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  test('buildTextTheme rellena los slots M3 principales', () {
    final t = buildTextTheme(Brightness.light);
    expect(t.bodyMedium!.fontFamily, 'IBM Plex Sans');
    expect(t.titleLarge!.fontFamily, 'Outfit');
    expect(t.displayLarge!.fontFamily, 'Outfit');
  });

  group('AppTheme', () {
    for (final entry in {
      'light': AppTheme.light(),
      'dark': AppTheme.dark(),
    }.entries) {
      test('${entry.key}: se construye con los sub-temas clave', () {
        final t = entry.value;
        expect(t.useMaterial3, isTrue);
        expect(t.cupertinoOverrideTheme, isNotNull);
        expect(t.cupertinoOverrideTheme!.primaryColor, t.colorScheme.primary);
        expect(t.bottomSheetTheme.showDragHandle, isTrue);
        expect(t.dialogTheme.shape, isA<RoundedRectangleBorder>());
        expect(t.textSelectionTheme.cursorColor, t.colorScheme.primary);
        expect(
          t.pageTransitionsTheme.builders[TargetPlatform.android],
          isA<CupertinoPageTransitionsBuilder>(),
        );
        expect(
          (t.cardTheme.shape! as RoundedRectangleBorder).borderRadius,
          AppRadii.mdAll,
        );
      });
    }

    test('brandPink sigue siendo el rosa de marca', () {
      expect(AppTheme.brandPink, const Color(0xFFD81B60));
    });
  });
}
