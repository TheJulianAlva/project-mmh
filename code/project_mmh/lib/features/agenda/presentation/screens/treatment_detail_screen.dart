import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

import 'package:project_mmh/features/agenda/presentation/widgets/treatment_edit_dialog.dart';

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

    final dateFormat = DateFormat('EEE d MMM yyyy, HH:mm', 'es_ES');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Tratamiento'),
        actions: [
          if (tratamientoAsync.value?.estado != 'concluido') ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editTreatment(context, tratamientoAsync.value!),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteTreatment(context, ref, tratamientoId),
            ),
          ],
        ],
      ),
      body: tratamientoAsync.when(
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(
                  context,
                  tratamiento.nombreTratamiento,
                  patientName,
                ),
                const SizedBox(height: 16),
                _buildStatusCard(context, tratamiento.estado),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Historial de Sesiones'),
                const SizedBox(height: 8),
                sesionesAsync.when(
                  data: (sesiones) {
                    if (sesiones.isEmpty)
                      return const Text('No hay sesiones registradas.');
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sesiones.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final s = sesiones[index];
                        final start = DateTime.parse(s.fechaInicio);
                        final end = DateTime.parse(s.fechaFin);
                        final duration = end.difference(start).inMinutes;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(
                              s.estadoAsistencia,
                            ).withValues(alpha: 0.2),
                            child: Icon(
                              _getStatusIcon(s.estadoAsistencia),
                              color: _getStatusColor(s.estadoAsistencia),
                              size: 20,
                            ),
                          ),
                          title: Text(dateFormat.format(start)),
                          subtitle: Text(
                            '${duration} min • ${s.estadoAsistencia ?? "Programada"}',
                          ),
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
                    child: ElevatedButton.icon(
                      onPressed: () => _finalizeTreatment(context, ref),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Finalizar Tratamiento'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _finalizeTreatment(BuildContext context, WidgetRef ref) async {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tratamiento finalizado correctamente')),
        );
      }
    }
  }

  Widget _buildHeader(BuildContext context, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 18),
              const SizedBox(width: 8),
              Text(subtitle, style: const TextStyle(fontSize: 16)),
            ],
          ),
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'concluido':
        return Colors.green;
      case 'cancelo':
        return Colors.red;
      case 'falto':
        return Colors.orange;
      default:
        return Colors.blue;
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
    showDialog(
      context: context,
      builder: (context) => TreatmentEditDialog(tratamiento: tratamiento),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
}
