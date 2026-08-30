import 'package:flutter/material.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';

/// Diálogo de confirmación único (normal o destructivo). Resuelve a `true`
/// si el usuario confirma, `false` en cualquier otro caso.
/// Uso: `if (await showAppConfirm(context, title: ...)) { ... }`.
/// Depende de: AppButton, dialogTheme.
Future<bool> showAppConfirm(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text(title),
          content: message == null ? null : Text(message),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          actions: [
            AppButton.text(
              label: cancelLabel,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            if (destructive)
              AppButton.destructive(
                label: confirmLabel,
                onPressed: () => Navigator.of(ctx).pop(true),
              )
            else
              AppButton.primary(
                label: confirmLabel,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
          ],
        ),
  );
  return result ?? false;
}
