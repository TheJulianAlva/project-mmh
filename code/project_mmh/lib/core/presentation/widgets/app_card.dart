import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';

/// Superficie base del sistema: radio `md`, borde/sombra según brillo y una
/// barra de acento vertical opcional (color de clínica).
/// Uso: `AppCard(accentColor: c, onTap: ..., child: ...)`.
/// Con `tint`: fondo tintado suave sin sombra (paneles); excluye `accentColor`.
/// Depende de: AppRadii, AppSpacing, AppOpacity, ColorScheme.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.accentColor,
    this.tint,
    this.onTap,
    this.padding,
  }) : assert(
         accentColor == null || tint == null,
         'AppCard: accentColor y tint son mutuamente excluyentes',
       );

  final Widget child;
  final Color? accentColor;
  final Color? tint;
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

    final tinted = tint != null;
    final bgColor =
        tinted
            ? tint!.withValues(
              alpha: isDark ? AppOpacity.subtle : AppOpacity.hairline,
            )
            : scheme.surface;
    final radius = tinted ? AppRadii.lgAll : AppRadii.mdAll;

    return Material(
      color: bgColor,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      elevation: tinted ? 0 : (isDark ? 0 : 1),
      shadowColor: Colors.black.withValues(alpha: AppOpacity.subtle),
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border:
                isDark && !tinted
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
                  : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(width: 4, color: accentColor),
                        Expanded(child: content),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
