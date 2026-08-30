import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';

/// Superficie base del sistema: radio `md`, borde/sombra según brillo y una
/// barra de acento vertical opcional (color de clínica).
/// Uso: `AppCard(accentColor: c, onTap: ..., child: ...)`.
/// Depende de: AppRadii, AppSpacing, AppOpacity, ColorScheme.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.accentColor,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final Color? accentColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );

    return Material(
      color: scheme.surface,
      borderRadius: AppRadii.mdAll,
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: AppOpacity.subtle),
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadii.mdAll,
            border:
                isDark
                    ? Border.all(
                      color: scheme.onSurface.withValues(
                        alpha: AppOpacity.hairline,
                      ),
                    )
                    : null,
          ),
          child:
              accentColor == null
                  ? content
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 4, color: accentColor),
                      Expanded(child: content),
                    ],
                  ),
        ),
      ),
    );
  }
}
