import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_semantic_colors.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';

enum _Role { success, warning, danger, info }

/// Píldora de estado: mapea un enum de dominio a color + icono + label.
/// Uso: `AppStatusBadge.asistencia(sesion.estadoAsistencia)`.
/// Depende de: AppSemanticColors, AppRadii, AppText, los enums de agenda.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge._(this.label, this.icon, this._role);

  factory AppStatusBadge.asistencia(EstadoAsistencia? estado) {
    switch (estado) {
      case EstadoAsistencia.asistio:
        return const AppStatusBadge._(
          'Asistió',
          Icons.check_circle_outline,
          _Role.success,
        );
      case EstadoAsistencia.falto:
        return const AppStatusBadge._(
          'Faltó',
          Icons.cancel_outlined,
          _Role.danger,
        );
      case EstadoAsistencia.programada:
      case null:
        return const AppStatusBadge._('Programada', Icons.schedule, _Role.info);
    }
  }

  factory AppStatusBadge.tratamiento(EstadoTratamiento estado) {
    switch (estado) {
      case EstadoTratamiento.pendiente:
        return AppStatusBadge._(estado.label, Icons.schedule, _Role.info);
      case EstadoTratamiento.enProceso:
        return AppStatusBadge._(
          estado.label,
          Icons.play_circle_outline,
          _Role.warning,
        );
      case EstadoTratamiento.concluido:
        return AppStatusBadge._(
          estado.label,
          Icons.check_circle_outline,
          _Role.success,
        );
    }
  }

  final String label;
  final IconData icon;
  final _Role _role;

  @override
  Widget build(BuildContext context) {
    final s = context.semantic;
    final scheme = Theme.of(context).colorScheme;
    final color = switch (_role) {
      _Role.success => s.success,
      _Role.warning => s.warning,
      _Role.danger => scheme.error,
      _Role.info => s.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.subtle),
        borderRadius: AppRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppText.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
