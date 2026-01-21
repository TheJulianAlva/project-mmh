import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/core/presentation/widgets/custom_bottom_sheet.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/session_edit_dialog.dart';

import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

class SessionActionSheet extends ConsumerWidget {
  final Sesion sesion;

  const SessionActionSheet({super.key, required this.sesion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tratamientoAsync = ref.watch(
      tratamientoByIdProvider(sesion.idTratamiento),
    );
    final patientsAsync = ref.watch(patientsProvider);

    return tratamientoAsync.when(
      data: (tratamiento) {
        if (tratamiento == null) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('Tratamiento no encontrado')),
          );
        }
        final fechaInicio = DateTime.parse(sesion.fechaInicio);
        final fechaFin = DateTime.parse(sesion.fechaFin);

        String patientName = 'Cargando...';
        if (patientsAsync.hasValue && patientsAsync.value != null) {
          try {
            final p = patientsAsync.value!.firstWhere(
              (p) => p.idExpediente == tratamiento.idExpediente,
            );
            patientName = '${p.nombre} ${p.primerApellido} (${p.idExpediente})';
          } catch (e) {
            patientName =
                'Paciente no encontrado (${tratamiento.idExpediente})';
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Detalles de la Cita',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tratamiento.nombreTratamiento,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            patientName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')} - ${fechaFin.hour.toString().padLeft(2, '0')}:${fechaFin.minute.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Estado de Asistencia',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

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
                    const SizedBox(width: 12),
                    _StatusButton(
                      label: 'No Asistió',
                      color: Colors.orange,
                      isSelected: sesion.estadoAsistencia == 'falto',
                      onPressed: () => _updateStatus(context, ref, 'falto'),
                    ),
                    const SizedBox(width: 12),
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

              const SizedBox(height: 32),

              const SizedBox(height: 32),

              // Actions
              OutlinedButton.icon(
                onPressed: () => _reprogramar(context, ref),
                icon: const Icon(Icons.edit_calendar, size: 18),
                label: const Text('Reprogramar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _confirmDelete(context, ref),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Eliminar Sesión'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cerrar',
                  style: TextStyle(color: Theme.of(context).disabledColor),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
      loading:
          () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, _) =>
              SizedBox(height: 100, child: Center(child: Text('Error: $e'))),
    );
  }

  void _updateStatus(BuildContext context, WidgetRef ref, String status) async {
    final repo = ref.read(agendaRepositoryProvider);
    await repo.updateSesionStatus(sesion.idSesion!, status);
    ref.invalidate(allSesionesProvider);
    ref.invalidate(allTratamientosRichProvider);
    if (context.mounted) Navigator.of(context).pop();
  }

  void _reprogramar(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop(); // Close current sheet

    // Show SessionEditSheet
    showCustomBottomSheet(
      context: context,
      child: SessionEditSheet(
        idTratamiento: sesion.idTratamiento,
        sesion: sesion,
      ),
    );
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
                  // Close sheet if mounted
                  await repo.deleteSesion(sesion.idSesion!);
                  ref.invalidate(allSesionesProvider);
                  if (context.mounted) Navigator.of(context).pop();
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
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: ShapeDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          shape: StadiumBorder(
            side: BorderSide(
              color:
                  isSelected
                      ? color
                      : Theme.of(context).dividerColor.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Theme.of(context).disabledColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
