import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';

class SessionActionDialog extends ConsumerWidget {
  final Sesion sesion;

  const SessionActionDialog({super.key, required this.sesion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tratamientoAsync = ref.watch(
      tratamientoByIdProvider(sesion.idTratamiento),
    );

    return AlertDialog(
      title: const Text('Detalles de la Cita'),
      content: tratamientoAsync.when(
        data: (tratamiento) {
          if (tratamiento == null)
            return const Text('Tratamiento no encontrado');
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tratamiento: ${tratamiento.nombreTratamiento}'),
              Text('Estado Actual: ${sesion.estadoAsistencia ?? "Programada"}'),
              const SizedBox(height: 10),
              const Text('¿Desea actualizar el estado de esta sesión?'),
            ],
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        if (sesion.estadoAsistencia != 'concluido')
          ElevatedButton(
            onPressed: () => _updateStatus(context, ref, 'concluido'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
            child: const Text('Concluir (Asistió)'),
          ),
        if (sesion.estadoAsistencia != 'cancelo')
          TextButton(
            onPressed: () => _updateStatus(context, ref, 'cancelo'),
            child: Text(
              'Marcar Cancelado',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  void _updateStatus(BuildContext context, WidgetRef ref, String status) async {
    final repo = ref.read(agendaRepositoryProvider);

    // 1. Update Sesion
    await repo.updateSesionStatus(sesion.idSesion!, status);

    // 2. Logic for "Concluded": Only update session status. Objective updates happen on Treatment Finalization.
    // if (status == 'concluido') { ... } REMOVED

    ref.invalidate(allSesionesProvider);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
