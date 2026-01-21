import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:project_mmh/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/objetivos_providers.dart'
    as objectives_provider;

import 'package:project_mmh/core/presentation/widgets/custom_bottom_sheet.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/treatment_edit_dialog.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/session_edit_dialog.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';

class TreatmentDetailScreen extends ConsumerWidget {
  final int tratamientoId;

  const TreatmentDetailScreen({super.key, required this.tratamientoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tratamientoAsync = ref.watch(tratamientoByIdProvider(tratamientoId));
    final sesionesAsync = ref.watch(
      sesionesByTratamientoProvider(tratamientoId),
    );
    final patientsAsync = ref.watch(patientsProvider);

    // Watch clinic if treatment is loaded
    final clinicAsync =
        tratamientoAsync.value != null
            ? ref.watch(clinicaByIdProvider(tratamientoAsync.value!.idClinica))
            : const AsyncValue.data(null);

    final dateFormat = DateFormat('EEE d MMM yyyy, HH:mm', 'es_ES');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Detalle'),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.9),
            trailing:
                tratamientoAsync.value != null &&
                        tratamientoAsync.value?.estado != 'concluido'
                    ? TextButton(
                      onPressed:
                          () =>
                              _editTreatment(context, tratamientoAsync.value!),
                      child: const Text(
                        'Editar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    : null,
          ),
          SliverToBoxAdapter(
            child: tratamientoAsync.when(
              data: (tratamiento) {
                if (tratamiento == null)
                  return const Center(child: Text('Tratamiento no encontrado'));

                // Find patient name
                String patientName = 'Cargando...';
                if (patientsAsync.hasValue && patientsAsync.value != null) {
                  try {
                    final p = patientsAsync.value!.firstWhere(
                      (p) => p.idExpediente == tratamiento.idExpediente,
                    );
                    patientName =
                        '${p.nombre} ${p.primerApellido} (${p.idExpediente})';
                  } catch (e) {
                    patientName =
                        'Paciente no encontrado (${tratamiento.idExpediente})';
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(
                        context,
                        tratamiento.nombreTratamiento,
                        patientName,
                        clinicAsync.value?.nombreClinica,
                      ),
                      const SizedBox(height: 16),
                      _buildStatusCard(context, tratamiento.estado),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle(context, 'Historial de Sesiones'),
                          if (tratamiento.estado != 'concluido')
                            TextButton(
                              onPressed:
                                  () => _addSesion(context, tratamientoId),
                              child: const Text('Añadir Sesión'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      sesionesAsync.when(
                        data: (sesiones) {
                          if (sesiones.isEmpty)
                            return const Text('No hay sesiones registradas.');
                          return ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sesiones.length,
                            separatorBuilder:
                                (_, __) => Divider(
                                  height: 1,
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.1),
                                ),
                            itemBuilder: (context, index) {
                              final s = sesiones[index];
                              final start = DateTime.parse(s.fechaInicio);
                              final end = DateTime.parse(s.fechaFin);
                              final duration = end.difference(start).inMinutes;

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      context,
                                      s.estadoAsistencia,
                                    ).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getStatusIcon(s.estadoAsistencia),
                                    color: _getStatusColor(
                                      context,
                                      s.estadoAsistencia,
                                    ),
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  dateFormat.format(start),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  '${duration} min • ${s.estadoAsistencia ?? "Programada"}',
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                  ),
                                ),
                                trailing:
                                    tratamiento.estado != 'concluido'
                                        ? IconButton(
                                          icon: const Icon(Icons.more_horiz),
                                          onPressed:
                                              () => _showSessionOptions(
                                                context,
                                                ref,
                                                s,
                                                tratamientoId,
                                              ),
                                        )
                                        : null,
                              );
                            },
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('Error al cargar sesiones: $e'),
                      ),
                      const SizedBox(height: 32),
                      if (tratamiento.estado != 'concluido')
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed:
                                () => _finalizeTreatment(
                                  context,
                                  ref,
                                  tratamiento.idClinica,
                                ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const StadiumBorder(),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Text('Finalizar Tratamiento'),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (tratamiento.estado != 'concluido')
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed:
                                () => _deleteTreatment(
                                  context,
                                  ref,
                                  tratamientoId,
                                ),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                            child: const Text('Eliminar Tratamiento'),
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String status) {
    Color color;
    String text;
    IconData icon;

    if (status == 'concluido') {
      color = Colors.green;
      text = 'Completado';
      icon = Icons.check_circle;
    } else {
      color = Colors.orange;
      text = 'En Progreso';
      icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.1),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _finalizeTreatment(
    BuildContext context,
    WidgetRef ref,
    int clinicId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('¿Finalizar Tratamiento?'),
            content: const Text(
              'Esto marcará el tratamiento como concluido y actualizará el progreso del objetivo asociado.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Finalizar'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final repo = ref.read(agendaRepositoryProvider);
      await repo.markTreatmentAsFinalized(tratamientoId);
      ref.invalidate(tratamientoByIdProvider(tratamientoId));
      ref.invalidate(allTratamientosRichProvider); // Update list

      // Invalidate the underlying objectives provider to force a refresh from DB
      ref.invalidate(objectives_provider.objetivosByClinicaProvider(clinicId));

      ref.invalidate(dashboardStatsProvider); // Update Dashboard Goals

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tratamiento finalizado correctamente')),
        );
      }
    }
  }

  Widget _buildHeader(
    BuildContext context,
    String title,
    String subtitle,
    String? clinicName,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (clinicName != null)
                      Text(
                        clinicName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Color _getStatusColor(BuildContext context, String? status) {
    switch (status) {
      case 'concluido':
        return Colors.green;
      case 'cancelo':
        return Colors.red;
      case 'falto':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'concluido':
        return Icons.check;
      case 'cancelo':
        return Icons.close;
      case 'falto':
        return Icons.person_off;
      default:
        return Icons.event;
    }
  }

  void _editTreatment(BuildContext context, dynamic tratamiento) {
    showCustomBottomSheet(
      context: context,
      child: TreatmentEditSheet(tratamiento: tratamiento),
    );
  }

  void _deleteTreatment(BuildContext context, WidgetRef ref, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Eliminar Tratamiento'),
            content: const Text(
              '¿Estás seguro de eliminar este tratamiento? Se eliminarán también todas sus sesiones asociadas.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError,
                ),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final repo = ref.read(agendaRepositoryProvider);
      await repo.deleteTratamiento(id);

      // Update lists
      ref.invalidate(allTratamientosRichProvider);
      ref.invalidate(allSesionesProvider);

      if (context.mounted) {
        Navigator.pop(context); // Go back
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tratamiento eliminado')));
      }
    }
  }

  void _addSesion(BuildContext context, int idTratamiento) {
    showCustomBottomSheet(
      context: context,
      child: SessionEditSheet(idTratamiento: idTratamiento),
    );
  }

  void _editSesion(BuildContext context, int idTratamiento, dynamic sesion) {
    showCustomBottomSheet(
      context: context,
      child: SessionEditSheet(idTratamiento: idTratamiento, sesion: sesion),
    );
  }

  void _deleteSesion(
    BuildContext context,
    WidgetRef ref,
    int idSesion,
    int idTratamiento,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Eliminar Sesión'),
            content: const Text('¿Estás seguro de eliminar esta sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError,
                ),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final repo = ref.read(agendaRepositoryProvider);
      await repo.deleteSesion(idSesion);
      ref.invalidate(sesionesByTratamientoProvider(idTratamiento));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sesión eliminada')));
      }
    }
  }

  void _showSessionOptions(
    BuildContext context,
    WidgetRef ref,
    dynamic sesion,
    int idTratamiento,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (ctx) => CupertinoActionSheet(
            title: const Text('Sesión'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  _editSesion(context, idTratamiento, sesion);
                },
                child: const Text('Editar'),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(ctx);
                  _deleteSesion(context, ref, sesion.idSesion!, idTratamiento);
                },
                child: const Text('Eliminar'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
          ),
    );
  }
}
