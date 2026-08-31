import 'package:flutter/cupertino.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';

class TreatmentActionBar extends StatelessWidget {
  final VoidCallback onAddSession;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFinalize;
  final bool isConcluded;

  const TreatmentActionBar({
    super.key,
    required this.onAddSession,
    required this.onEdit,
    this.onDelete,
    this.onFinalize,
    required this.isConcluded,
  });

  @override
  Widget build(BuildContext context) {
    if (isConcluded) {
      return SizedBox(
        width: double.infinity,
        child: AppButton.destructive(
          onPressed: onDelete,
          icon: CupertinoIcons.trash,
          label: 'Eliminar Historial',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Action: Add Session
        AppButton.primary(
          onPressed: onAddSession,
          icon: CupertinoIcons.add,
          label: 'Agregar Sesión',
        ),
        const SizedBox(height: AppSpacing.md),

        // Secondary Actions Grid
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                onPressed: onEdit,
                icon: CupertinoIcons.pencil,
                label: 'Editar',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton.secondary(
                onPressed: onFinalize,
                icon: CupertinoIcons.checkmark_seal,
                label: 'Finalizar',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
