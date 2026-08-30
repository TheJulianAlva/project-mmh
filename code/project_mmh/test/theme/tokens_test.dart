import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_palette.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_semantic_colors.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';

void main() {
  test('AppSpacing sigue la escala de 4pt', () {
    expect(
      [
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
      ],
      [4.0, 8.0, 12.0, 16.0, 24.0, 32.0],
    );
  });

  test('AppRadii expone 4 radios y sus BorderRadius', () {
    expect([AppRadii.sm, AppRadii.md, AppRadii.lg], [8.0, 12.0, 20.0]);
    expect(AppRadii.pill, greaterThanOrEqualTo(999.0));
    expect(AppRadii.mdAll, BorderRadius.circular(12));
    expect(AppRadii.pillAll, BorderRadius.circular(AppRadii.pill));
  });

  test('AppOpacity nombra las opacidades en [0,1] y ordenadas', () {
    final vals = [
      AppOpacity.hairline,
      AppOpacity.subtle,
      AppOpacity.muted,
      AppOpacity.strong,
    ];
    expect(vals, [0.08, 0.12, 0.40, 0.70]);
    for (var i = 1; i < vals.length; i++) {
      expect(vals[i], greaterThan(vals[i - 1]));
    }
  });

  group('AppPalette + AppSemanticColors', () {
    test('los valores de marca no cambian', () {
      expect(AppPalette.berry, const Color(0xFFD81B60));
      expect(AppPalette.teal, const Color(0xFF009688));
    });

    test('AppSemanticColors.light se deriva de la paleta', () {
      expect(AppSemanticColors.light.success, AppPalette.successLight);
      expect(AppSemanticColors.dark.warning, AppPalette.warningDark);
    });
  });
}
