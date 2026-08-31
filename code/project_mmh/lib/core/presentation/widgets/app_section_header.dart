import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Etiqueta de sección en mayúsculas con tracking amplio y separación
/// estándar (xl arriba, sm abajo).
/// Uso: `AppSectionHeader('Información médica')`.
/// Depende de: AppText.sectionLabel, AppSpacing.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader(this.label, {super.key, this.padding});

  final String label;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding:
          padding ??
          const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: AppText.sectionLabel.copyWith(
          color: scheme.onSurface.withValues(alpha: AppOpacity.strong),
        ),
      ),
    );
  }
}
