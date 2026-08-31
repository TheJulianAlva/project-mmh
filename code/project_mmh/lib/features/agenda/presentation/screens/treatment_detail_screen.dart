import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:project_mmh/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/objetivos_providers.dart'
    as objectives_provider;
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';
import 'package:project_mmh/features/agenda/domain/sesion_rich_model.dart';

// Widgets
import 'package:project_mmh/core/constants/app_constants.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/theme/clinic_palette.dart';
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

    return AppScaffold(
      title: 'Tratamiento',
      slivers: [
        // ── Content ──
        tratamientoAsync.when(
          data: (tratamiento) {
            if (tratamiento == null) {
              return const SliverFillRemaining(
                child: Center(child: Text('Tratamiento no encontrado')),
              );
            }

            // Nombre del paciente (no usar 'Cargando...'/'Error' como nombre real)
            String patientName = '';
            if (patientAsync.hasValue && patientAsync.value != null) {
              final p = patientAsync.value!;
              patientName = '${p.nombre} ${p.primerApellido}';
            }

            // Determine Clinic Info
            String? clinicName;
            Color? clinicColor;
            if (clinicAsync.hasValue && clinicAsync.value != null) {
              clinicName = clinicAsync.value!.nombreClinica;
              clinicColor = ClinicPalette.parse(clinicAsync.value!.color);
            }

            final isConcluded =
                tratamiento.estado == EstadoTratamiento.concluido;

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
                      patientName: patientName.isEmpty ? '—' : patientName,
                      clinicName: clinicName,
                      status: tratamiento.estado,
                      clinicColor: clinicColor,
                    ),
                    const SizedBox(height: 24),

                    // 2. Action Bar
                    TreatmentActionBar(
                      isConcluded: isConcluded,
                      onAddSession:
                          () => _addSesion(
                            context,
                            tratamientoId,
                            sesionesAsync.value?.length,
                          ),
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
                                tratamiento.idClinica,
                              )
                              : null,
                    ),

                    const SizedBox(height: 32),

                    // 3. Timeline Title
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        'Historial de Sesiones',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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

                        return TreatmentTimelineList(
                          sessions: richSessions,
                          onRefresh: () {
                            ref.invalidate(
                              sesionesByTratamientoProvider(tratamientoId),
                            );
                            ref.invalidate(
                              tratamientoByIdProvider(tratamientoId),
                            );
                            ref.invalidate(allTratamientosRichProvider);
                          },
                        );
                      },
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (e, _) => AppErrorView(
                            message: 'No se pudieron cargar las sesiones.',
                            compact: true,
                            onRetry:
                                () => ref.invalidate(
                                  sesionesByTratamientoProvider(tratamientoId),
                                ),
                          ),
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
                child: AppErrorView(
                  message: 'No se pudo cargar el tratamiento.',
                  onRetry:
                      () => ref.invalidate(
                        tratamientoByIdProvider(tratamientoId),
                      ),
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const AppEmptyState(
      icon: CupertinoIcons.calendar_badge_plus,
      title: 'No hay sesiones registradas',
    );
  }

  // ─── Actions ───

  void _addSesion(
    BuildContext context,
    int idTratamiento,
    int? currentSessionCount,
  ) {
    if (currentSessionCount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Espera a que carguen las sesiones e inténtalo de nuevo',
          ),
        ),
      );
      return;
    }
    if (currentSessionCount >= kMaxSesionesPorTratamiento) {
      showCupertinoDialog(
        context: context,
        builder:
            (ctx) => CupertinoAlertDialog(
              title: const Text('Límite Alcanzado'),
              content: Text(
                'No se pueden agregar más de $kMaxSesionesPorTratamiento '
                'sesiones a un tratamiento.',
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
      );
      return;
    }

    showAppSheet(
      context,
      builder: (_) => SessionEditSheet(idTratamiento: idTratamiento),
    );
  }

  void _editTreatment(BuildContext context, dynamic tratamiento) {
    showAppSheet(
      context,
      builder: (_) => TreatmentEditSheet(tratamiento: tratamiento),
    );
  }

  void _finalizeTreatment(
    BuildContext context,
    WidgetRef ref,
    int clinicId,
  ) async {
    final confirmed = await showAppConfirm(
      context,
      title: '¿Finalizar Tratamiento?',
      message:
          'Esto marcará el tratamiento como concluido y actualizará el progreso del objetivo asociado.',
      confirmLabel: 'Finalizar',
    );

    if (!confirmed) return;

    try {
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
    } catch (e) {
      if (context.mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo finalizar: $message')),
        );
      }
    }
  }

  void _deleteTreatment(
    BuildContext context,
    WidgetRef ref,
    int id,
    int clinicId,
  ) async {
    final confirmed = await showAppConfirm(
      context,
      title: 'Eliminar Tratamiento',
      message:
          '¿Estás seguro de eliminar este tratamiento? Se eliminarán también todas sus sesiones asociadas.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );

    if (!confirmed) return;

    try {
      final repo = ref.read(agendaRepositoryProvider);
      await repo.deleteTratamiento(id);

      ref.invalidate(allTratamientosRichProvider);
      ref.invalidate(allSesionesProvider);
      ref.invalidate(enrichedSesionesProvider);
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(objectives_provider.objetivosByClinicaProvider(clinicId));

      if (context.mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tratamiento eliminado')));
      }
    } catch (e) {
      if (context.mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar: $message')),
        );
      }
    }
  }
}
