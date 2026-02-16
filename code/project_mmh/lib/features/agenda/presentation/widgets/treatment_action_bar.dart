import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        child: OutlinedButton.icon(
          onPressed: onDelete,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
            ),
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          icon: const Icon(CupertinoIcons.trash, size: 16),
          label: const Text('Eliminar Historial'),
        ),
      );
    }

    return Column(
      children: [
        // Primary Action: Add Session
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: onAddSession,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            icon: const Icon(CupertinoIcons.add, size: 20),
            label: const Text(
              'Agregar Sesión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary Actions Grid
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                style: _secondaryButtonStyle(context),
                icon: const Icon(CupertinoIcons.pencil, size: 16),
                label: const Text('Editar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onFinalize,
                style: _secondaryButtonStyle(context),
                icon: const Icon(CupertinoIcons.checkmark_seal, size: 16),
                label: const Text('Finalizar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  ButtonStyle _secondaryButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      side: BorderSide(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
      ),
      foregroundColor: Theme.of(context).colorScheme.onSurface,
    );
  }
}
