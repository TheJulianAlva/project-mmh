import 'package:flutter/material.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Tarjeta de fila de entidad tocable: fondo tintado con `primary`, sin
/// sombra ni barra de acento, título en color de marca y chevron final.
/// Uso: ítems de lista que navegan a un detalle. Para superficies neutras
/// usa `AppCard`; para paneles tintados no tocables usa `AppCard(tint:)`.
/// Depende de: AppCard, AppText, AppSpacing, ColorScheme.
class AppEntityCard extends StatelessWidget {
  const AppEntityCard({
    super.key,
    required this.title,
    required this.child,
    this.onTap,
    this.leading,
    this.trailing,
  });

  final String title;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveTrailing =
        trailing ??
        (onTap != null
            ? Icon(Icons.chevron_right, color: scheme.primary)
            : null);

    return AppCard(
      tint: scheme.primary,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppText.cardTitle.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (effectiveTrailing != null) effectiveTrailing,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
