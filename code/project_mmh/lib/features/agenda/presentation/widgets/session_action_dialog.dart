import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/utils/formatters.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/session_edit_dialog.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:intl/intl.dart';

class SessionActionSheet extends ConsumerWidget {
  final Sesion sesion;

  const SessionActionSheet({super.key, required this.sesion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tratamientoAsync = ref.watch(
      tratamientoByIdProvider(sesion.idTratamiento),
    );
    final patientsAsync = ref.watch(patientsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        final duration = fechaFin.difference(fechaInicio);
        final durationStr = formatDuration(duration);

        String patientName = 'Cargando...';
        if (patientsAsync.hasValue && patientsAsync.value != null) {
          final p =
              patientsAsync.value!
                  .where((p) => p.idExpediente == tratamiento.idExpediente)
                  .firstOrNull;
          patientName =
              p != null
                  ? '${p.nombre} ${p.primerApellido}'
                  : 'Expediente ${tratamiento.idExpediente}';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // ── Title ──
              Text(
                'Detalles de la Cita',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // ── Info Card ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? colorScheme.surface
                          : colorScheme.primary.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : colorScheme.primary.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Treatment name — tappable link to detail
                    GestureDetector(
                      onTap:
                          () => _goToTreatment(context, sesion.idTratamiento),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              tratamiento.nombreTratamiento,
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 14,
                            color: colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Patient
                    _buildInfoRow(
                      context,
                      CupertinoIcons.person,
                      patientName,
                      colorScheme,
                    ),
                    const SizedBox(height: 6),
                    // Date
                    _buildInfoRow(
                      context,
                      CupertinoIcons.calendar,
                      DateFormat(
                        "EEEE d 'de' MMMM, yyyy",
                        'es_ES',
                      ).format(fechaInicio),
                      colorScheme,
                    ),
                    const SizedBox(height: 6),
                    // Time
                    _buildInfoRow(
                      context,
                      CupertinoIcons.clock,
                      '${DateFormat('HH:mm').format(fechaInicio)} – ${DateFormat('HH:mm').format(fechaFin)}  ·  $durationStr',
                      colorScheme,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Status Section ──
              Text(
                'Estado de Asistencia',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 10),

              // Status Buttons
              Row(
                children: [
                  Expanded(
                    child: _StatusChip(
                      label: 'Programada',
                      icon: CupertinoIcons.circle,
                      color: colorScheme.primary,
                      isSelected:
                          sesion.estadoAsistencia ==
                              EstadoAsistencia.programada ||
                          sesion.estadoAsistencia == null,
                      onTap:
                          () => _updateStatus(
                            context,
                            ref,
                            EstadoAsistencia.programada,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatusChip(
                      label: 'Asistió',
                      icon: CupertinoIcons.checkmark_alt,
                      color: colorScheme.secondary,
                      isSelected:
                          sesion.estadoAsistencia == EstadoAsistencia.asistio,
                      onTap:
                          () => _updateStatus(
                            context,
                            ref,
                            EstadoAsistencia.asistio,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatusChip(
                      label: 'No Asistió',
                      icon: CupertinoIcons.person_badge_minus,
                      color: colorScheme.error,
                      isSelected:
                          sesion.estadoAsistencia == EstadoAsistencia.falto,
                      onTap:
                          () => _updateStatus(
                            context,
                            ref,
                            EstadoAsistencia.falto,
                          ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Actions ──
              AppButton.secondary(
                onPressed: () => _reprogramar(context, ref),
                icon: CupertinoIcons.calendar_badge_plus,
                label: 'Reprogramar',
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.destructive(
                onPressed: () => _confirmDelete(context, ref),
                icon: CupertinoIcons.trash,
                label: 'Eliminar Sesión',
              ),
              const SizedBox(height: AppSpacing.sm),
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
          (e, _) => const SizedBox(
            height: 120,
            child: AppErrorView(
              message: 'No se pudo cargar la información de la sesión.',
              compact: true,
            ),
          ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String text,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _goToTreatment(BuildContext context, int idTratamiento) {
    Navigator.of(context).pop(); // Close bottom sheet
    context.push('/tratamientos/$idTratamiento');
  }

  void _invalidateSessionProviders(WidgetRef ref) {
    ref.invalidate(allSesionesProvider);
    ref.invalidate(enrichedSesionesProvider);
    ref.invalidate(allTratamientosRichProvider);
    ref.invalidate(sesionesByTratamientoProvider(sesion.idTratamiento));
    ref.invalidate(tratamientoByIdProvider(sesion.idTratamiento));
  }

  void _updateStatus(
    BuildContext context,
    WidgetRef ref,
    EstadoAsistencia status,
  ) async {
    try {
      final repo = ref.read(agendaRepositoryProvider);
      await repo.updateSesionStatus(sesion.idSesion!, status);
      _invalidateSessionProviders(ref);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo actualizar la sesión: $message')),
        );
      }
    }
  }

  void _reprogramar(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    showAppSheet(
      context,
      builder:
          (_) => SessionEditSheet(
            idTratamiento: sesion.idTratamiento,
            sesion: sesion,
          ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirm(
      context,
      title: 'Eliminar Sesión',
      message: '¿Estás seguro de que deseas eliminar esta sesión?',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      final repo = ref.read(agendaRepositoryProvider);
      await repo.deleteSesion(sesion.idSesion!);
      _invalidateSessionProviders(ref);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar la sesión: $message')),
        );
      }
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Status Chip — animated selection with icon
// ──────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? color
                    : Theme.of(context).dividerColor.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
