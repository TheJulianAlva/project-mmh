import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/session_edit_dialog.dart';

class SessionActionDialog extends ConsumerWidget {
  // ... existing class definition ...
  // ... existing build method ...
  // ... existing _updateStatus method ...

  void _reprogramar(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop(); // Close current dialog

    await showDialog(
      context: context,
      builder:
          (_) => SessionEditDialog(
            idTratamiento: sesion.idTratamiento,
            sesion: sesion,
          ),
    );
  }
  // ... existing _confirmDelete and _StatusButton ...

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
          if (tratamiento == null) {
            return const Text('Tratamiento no encontrado');
          }
          final fechaInicio = DateTime.parse(sesion.fechaInicio);
          final fechaFin = DateTime.parse(sesion.fechaFin);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tratamiento.nombreTratamiento,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Fecha: ${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}',
              ),
              Text(
                'Hora: ${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')} - ${fechaFin.hour.toString().padLeft(2, '0')}:${fechaFin.minute.toString().padLeft(2, '0')}',
              ),
              const SizedBox(height: 16),
              const Text(
                'Estado de Asistencia:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Status Buttons Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _StatusButton(
                      label: 'Asistió',
                      color: Colors.green,
                      isSelected: sesion.estadoAsistencia == 'asistio',
                      onPressed: () => _updateStatus(context, ref, 'asistio'),
                    ),
                    const SizedBox(width: 8),
                    _StatusButton(
                      label: 'No Asistió',
                      color: Colors.orange,
                      isSelected: sesion.estadoAsistencia == 'falto',
                      onPressed: () => _updateStatus(context, ref, 'falto'),
                    ),
                    const SizedBox(width: 8),
                    _StatusButton(
                      label: 'Programada',
                      color: Colors.grey,
                      isSelected:
                          sesion.estadoAsistencia == 'programada' ||
                          sesion.estadoAsistencia == null,
                      onPressed:
                          () => _updateStatus(context, ref, 'programada'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        TextButton(
          onPressed: () => _reprogramar(context, ref),
          child: const Text('Reprogramar'),
        ),
        TextButton(
          onPressed: () => _confirmDelete(context, ref),
          child: Text(
            'Eliminar',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }

  void _updateStatus(BuildContext context, WidgetRef ref, String status) async {
    final repo = ref.read(agendaRepositoryProvider);
    await repo.updateSesionStatus(sesion.idSesion!, status);
    ref.invalidate(allSesionesProvider);
    ref.invalidate(allTratamientosRichProvider);
    // If we want to keep dialog open to show change, we can.
    // But usually update refreshes UI.
    // Let's close it or force rebuild?
    // Since this is a Dialog, updating provider won't rebuild this widget unless we watch sesion specific provider.
    // For now, let's close it as it's "Action -> Done".
    if (context.mounted) Navigator.of(context).pop();
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Eliminar Sesión'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar esta sesión?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop(); // Close confirm
                  final repo = ref.read(agendaRepositoryProvider);
                  await repo.deleteSesion(sesion.idSesion!);
                  ref.invalidate(allSesionesProvider);
                  if (context.mounted)
                    Navigator.of(context).pop(); // Close detail
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onPressed;

  const _StatusButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Theme.of(context).cardColor,
        foregroundColor: isSelected ? Colors.white : color,
        side: isSelected ? null : BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: isSelected ? 2 : 0,
      ),
      child: Text(label),
    );
  }
}
