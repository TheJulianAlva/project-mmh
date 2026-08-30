import 'package:flutter/material.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Fila estándar de ajustes/listado: icono opcional, título, subtítulo y
/// control trailing.
/// Uso: dentro de `AppSettingsGroup(children: [AppListTile(...)])`.
/// Depende de: AppText, AppSpacing, ColorScheme.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: scheme.onSurface),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.body.copyWith(color: scheme.onSurface),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppText.caption.copyWith(
                        color: scheme.onSurface.withValues(
                          alpha: AppOpacity.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Agrupa varios `AppListTile` en una tarjeta con separadores hairline y
/// una cabecera de sección opcional.
/// Depende de: AppListTile, AppSectionHeader, AppRadii.
class AppSettingsGroup extends StatelessWidget {
  const AppSettingsGroup({super.key, this.header, required this.children});

  final String? header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppSectionHeader(header!),
          ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadii.mdAll,
            border: Border.all(
              color: scheme.onSurface.withValues(alpha: AppOpacity.hairline),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
