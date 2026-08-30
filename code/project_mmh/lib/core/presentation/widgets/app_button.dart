import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

enum _Variant { primary, secondary, text, destructive }

/// Botón único del sistema. Cuatro variantes semánticas, estado `loading`
/// (spinner + bloqueo) y deshabilitado cuando `onPressed` es null.
/// Uso: `AppButton.primary(label: 'Guardar', onPressed: ...)`.
/// Depende de: AppRadii, AppSpacing, AppText, ColorScheme.
class AppButton extends StatelessWidget {
  const AppButton._(
    this._variant, {
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  factory AppButton.primary({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
    IconData? icon,
  }) => AppButton._(
    _Variant.primary,
    label: label,
    onPressed: onPressed,
    loading: loading,
    icon: icon,
  );

  factory AppButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
    IconData? icon,
  }) => AppButton._(
    _Variant.secondary,
    label: label,
    onPressed: onPressed,
    loading: loading,
    icon: icon,
  );

  factory AppButton.text({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
    IconData? icon,
  }) => AppButton._(
    _Variant.text,
    label: label,
    onPressed: onPressed,
    loading: loading,
    icon: icon,
  );

  factory AppButton.destructive({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
    IconData? icon,
  }) => AppButton._(
    _Variant.destructive,
    label: label,
    onPressed: onPressed,
    loading: loading,
    icon: icon,
  );

  final _Variant _variant;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveOnPressed = loading ? null : onPressed;
    final shape = const RoundedRectangleBorder(borderRadius: AppRadii.pillAll);
    const padding = EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.md,
    );

    Widget content(Color fg) {
      if (loading) {
        return SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: fg),
        );
      }
      final text = Text(
        label,
        style: AppText.cardTitle.copyWith(fontSize: 15, color: fg),
      );
      if (icon == null) return text;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: AppSpacing.sm),
          text,
        ],
      );
    }

    switch (_variant) {
      case _Variant.primary:
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            shape: shape,
            padding: padding,
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
          ),
          child: content(scheme.onPrimary),
        );
      case _Variant.destructive:
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            shape: shape,
            padding: padding,
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          child: content(scheme.onError),
        );
      case _Variant.secondary:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            shape: shape,
            padding: padding,
            foregroundColor: scheme.primary,
            side: BorderSide(color: scheme.primary),
          ),
          child: content(scheme.primary),
        );
      case _Variant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            shape: shape,
            padding: padding,
            foregroundColor: scheme.primary,
          ),
          child: content(scheme.primary),
        );
    }
  }
}
