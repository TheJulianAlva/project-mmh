import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:project_mmh/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/objetivos_providers.dart'
    as objectives_provider;
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/agenda/domain/sesion_rich_model.dart';

// Widgets
import 'package:project_mmh/core/presentation/widgets/custom_bottom_sheet.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/treatment_edit_dialog.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/session_edit_dialog.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/treatment_info_card.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/treatment_action_bar.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/treatment_timeline_list.dart';

class TreatmentDetailScreen extends ConsumerWidget {
  final int tratamientoId;

  const TreatmentDetailScreen({super.key, required this.tratamientoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tratamientoAsync = ref.watch(tratamientoByIdProvider(tratamientoId));
    final sesionesAsync = ref.watch(
      sesionesByTratamientoProvider(tratamientoId),
    );

    // Resolve Patient
    final patientAsync =
        tratamientoAsync.value != null
            ? ref.watch(
              patientByIdProvider(tratamientoAsync.value!.idExpediente),
            )
            : const AsyncValue.data(null);

    // Resolve Clinic
    final clinicAsync =
        tratamientoAsync.value != null
            ? ref.watch(clinicaByIdProvider(tratamientoAsync.value!.idClinica))
            : const AsyncValue.data(null);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Tratamiento'),
            previousPageTitle: 'Atrás',
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.95),
            border: null,
          ),

          // ── Content ──
          tratamientoAsync.when(
            data: (tratamiento) {
              if (tratamiento == null) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Tratamiento no encontrado')),
                );
              }

              // Determine Patient Name
              String patientName = 'Cargando...';
              if (patientAsync.hasValue && patientAsync.value != null) {
                final p = patientAsync.value!;
                patientName = '${p.nombre} ${p.primerApellido}';
              } else if (patientAsync.hasError) {
                patientName = 'Error al cargar paciente';
              }

              // Determine Clinic Info
              String? clinicName;
              Color? clinicColor;
              if (clinicAsync.hasValue && clinicAsync.value != null) {
                clinicName = clinicAsync.value!.nombreClinica;
                clinicColor = _parseColor(clinicAsync.value!.color);
              }

              final isConcluded = tratamiento.estado == 'concluido';

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Info Card
                      TreatmentInfoCard(
                        treatmentName: tratamiento.nombreTratamiento,
                        patientName: patientName,
                        clinicName: clinicName,
                        status: tratamiento.estado,
                        clinicColor: clinicColor,
                      ),
                      const SizedBox(height: 24),

                      // 2. Action Bar
                      TreatmentActionBar(
                        isConcluded: isConcluded,
                        onAddSession: () => _addSesion(context, tratamientoId),
                        onEdit: () => _editTreatment(context, tratamiento),
                        onFinalize:
                            isConcluded
                                ? null
                                : () => _finalizeTreatment(
                                  context,
                                  ref,
                                  tratamiento.idClinica,
                                ),
                        onDelete:
                            isConcluded
                                ? () => _deleteTreatment(
                                  context,
                                  ref,
                                  tratamientoId,
                                )
                                : null,
                      ),

                      const SizedBox(height: 32),

                      // 3. Timeline Title
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 16),
                        child: Text(
                          'Historial de Sesiones',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),

                      // 4. Timeline List
                      sesionesAsync.when(
                        data: (sesiones) {
                          if (sesiones.isEmpty) {
                            return _buildEmptyState(context);
                          }

                          // Convert to Rich Model for Timeline
                          // Note: We create rich models on the fly using available data
                          final richSessions =
                              sesiones
                                  .map(
                                    (s) => SesionRichModel(
                                      sesion: s,
                                      nombrePaciente: patientName,
                                      nombreTratamiento:
                                          tratamiento.nombreTratamiento,
                                      nombreClinica: clinicName ?? 'Clínica',
                                      colorClinica:
                                          clinicAsync.value?.color ?? '#000000',
                                    ),
                                  )
                                  .toList();

                          // Sort by date desc (if not already) or asc depending on preference.
                          // Usually timelines are newest top, but agenda is often oldest top?
                          // Let's assume the provider gives them in correct order.

                          return TreatmentTimelineList(sessions: richSessions);
                        },
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      ),

                      // Extra padding for safe area
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
            loading:
                () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Error: $e')),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.calendar_badge_plus,
              size: 48,
              color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay sesiones registradas',
              style: TextStyle(
                color: Theme.of(context).disabledColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('Color(')) {
        String value = colorStr.split('(')[1].split(')')[0];
        return Color(int.parse(value));
      } else {
        String cleanHex = colorStr
            .replaceAll('#', '')
            .replaceAll('0x', '')
            .replaceAll('0X', '');
        if (cleanHex.length == 6) {
          return Color(int.parse(cleanHex, radix: 16) + 0xFF000000);
        } else if (cleanHex.length == 8) {
          return Color(int.parse(cleanHex, radix: 16));
        } else {
          return Color(int.parse(cleanHex, radix: 16) + 0xFF000000);
        }
      }
    } catch (_) {
      return Colors.blue; // Fallback
    }
  }

  // ─── Actions ───

  void _addSesion(BuildContext context, int idTratamiento) {
    showCustomBottomSheet(
      context: context,
      child: SessionEditSheet(idTratamiento: idTratamiento),
    );
  }

  void _editTreatment(BuildContext context, dynamic tratamiento) {
    showCustomBottomSheet(
      context: context,
      child: TreatmentEditSheet(tratamiento: tratamiento),
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
      ref.invalidate(allTratamientosRichProvider);
      ref.invalidate(objectives_provider.objetivosByClinicaProvider(clinicId));
      ref.invalidate(dashboardStatsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tratamiento finalizado correctamente')),
        );
      }
    }
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

      ref.invalidate(allTratamientosRichProvider);
      ref.invalidate(allSesionesProvider);

      if (context.mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tratamiento eliminado')));
      }
    }
  }
}
