import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/custom_bottom_sheet.dart';
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
        final durationStr = '${duration.inHours}h ${duration.inMinutes % 60}m';

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
                          sesion.estadoAsistencia == 'programada' ||
                          sesion.estadoAsistencia == null,
                      onTap: () => _updateStatus(context, ref, 'programada'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatusChip(
                      label: 'Asistió',
                      icon: CupertinoIcons.checkmark_alt,
                      color: colorScheme.secondary,
                      isSelected: sesion.estadoAsistencia == 'asistio',
                      onTap: () => _updateStatus(context, ref, 'asistio'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatusChip(
                      label: 'No Asistió',
                      icon: CupertinoIcons.person_badge_minus,
                      color: Colors.orange,
                      isSelected: sesion.estadoAsistencia == 'falto',
                      onTap: () => _updateStatus(context, ref, 'falto'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Actions ──
              OutlinedButton.icon(
                onPressed: () => _reprogramar(context, ref),
                icon: const Icon(CupertinoIcons.calendar_badge_plus, size: 18),
                label: const Text('Reprogramar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => _confirmDelete(context, ref),
                icon: const Icon(CupertinoIcons.trash, size: 16),
                label: const Text('Eliminar Sesión'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
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

  void _updateStatus(BuildContext context, WidgetRef ref, String status) async {
    final repo = ref.read(agendaRepositoryProvider);
    await repo.updateSesionStatus(sesion.idSesion!, status);

    // Invalidate ALL relevant providers so timeline + lists refresh
    ref.invalidate(allSesionesProvider);
    ref.invalidate(enrichedSesionesProvider);
    ref.invalidate(allTratamientosRichProvider);

    if (context.mounted) Navigator.of(context).pop();
  }

  void _reprogramar(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    showCustomBottomSheet(
      context: context,
      child: SessionEditSheet(
        idTratamiento: sesion.idTratamiento,
        sesion: sesion,
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder:
          (ctx) => CupertinoAlertDialog(
            title: const Text('Eliminar Sesión'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar esta sesión?',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final repo = ref.read(agendaRepositoryProvider);
                  await repo.deleteSesion(sesion.idSesion!);
                  ref.invalidate(allSesionesProvider);
                  ref.invalidate(enrichedSesionesProvider);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
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
