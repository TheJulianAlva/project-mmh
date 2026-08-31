import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_date_time_sheet.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';

class SessionEditSheet extends ConsumerStatefulWidget {
  final int idTratamiento;
  final Sesion? sesion; // If null, create new. If not null, edit.

  const SessionEditSheet({super.key, required this.idTratamiento, this.sesion});

  @override
  ConsumerState<SessionEditSheet> createState() => _SessionEditSheetState();
}

class _SessionEditSheetState extends ConsumerState<SessionEditSheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sesion != null;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          // ── Title ──
          Text(
            isEditing ? 'Editar Sesión' : 'Agregar Sesión',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // ── Section label ──
          Text(
            'Fecha y Hora',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),

          // ── Form ──
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
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderField<DateTime>(
                    name: 'fecha_inicio',
                    initialValue:
                        isEditing
                            ? DateTime.parse(widget.sesion!.fechaInicio)
                            : DateTime.now(),
                    validator: FormBuilderValidators.required(),
                    builder: (field) {
                      return _DateFieldRow(
                        label: 'Inicio',
                        icon: CupertinoIcons.calendar,
                        value: field.value,
                        errorText: field.errorText,
                        onTap: () async {
                          final picked = await AppDateTimeSheet.pick(
                            context,
                            initial: field.value ?? DateTime.now(),
                          );
                          if (picked != null) {
                            field.didChange(picked);
                            _formKey.currentState?.fields['fecha_fin']
                                ?.didChange(
                                  picked.add(const Duration(hours: 2)),
                                );
                          }
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          CupertinoIcons.arrow_down,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Divider(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.06,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FormBuilderField<DateTime>(
                    name: 'fecha_fin',
                    initialValue:
                        isEditing
                            ? DateTime.parse(widget.sesion!.fechaFin)
                            : DateTime.now().add(const Duration(hours: 2)),
                    validator: FormBuilderValidators.required(),
                    builder: (field) {
                      return _DateFieldRow(
                        label: 'Fin',
                        icon: CupertinoIcons.clock,
                        value: field.value,
                        errorText: field.errorText,
                        onTap: () async {
                          final picked = await AppDateTimeSheet.pick(
                            context,
                            initial: field.value ?? DateTime.now(),
                          );
                          if (picked != null) field.didChange(picked);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Save Button ──
          AppButton.primary(
            loading: _isSaving,
            onPressed: () => _save(isEditing),
            label: isEditing ? 'Guardar Cambios' : 'Crear Sesión',
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Future<void> _save(bool isEditing) async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    final values = _formKey.currentState!.value;
    final inicioDt = values['fecha_inicio'] as DateTime;
    final finDt = values['fecha_fin'] as DateTime;
    if (!finDt.isAfter(inicioDt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La sesión debe terminar después de empezar'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final repo = ref.read(agendaRepositoryProvider);

    final inicio = inicioDt.toIso8601String();
    final fin = finDt.toIso8601String();
    final estado =
        isEditing
            ? widget.sesion!.estadoAsistencia
            : EstadoAsistencia.programada;

    try {
      if (isEditing) {
        final updatedSesion = widget.sesion!.copyWith(
          fechaInicio: inicio,
          fechaFin: fin,
          estadoAsistencia: estado,
        );
        await repo.updateSesion(updatedSesion);
      } else {
        final newSesion = Sesion(
          idTratamiento: widget.idTratamiento,
          fechaInicio: inicio,
          fechaFin: fin,
          estadoAsistencia: estado,
        );
        await repo.createSesion(newSesion);
      }

      // Refresh all relevant providers
      ref.invalidate(sesionesByTratamientoProvider(widget.idTratamiento));
      ref.invalidate(allSesionesProvider);
      ref.invalidate(enrichedSesionesProvider);
      ref.invalidate(allTratamientosRichProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Sesión actualizada' : 'Sesión creada'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar la sesión: $message')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

/// Fila tocable que muestra una fecha/hora y abre `AppDateTimeSheet.pick`.
class _DateFieldRow extends StatelessWidget {
  const _DateFieldRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final IconData icon;
  final DateTime? value;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text =
        value == null
            ? 'Seleccionar'
            : DateFormat("EEE, d MMM yyyy  HH:mm", 'es_ES').format(value!);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: Icon(icon, size: 18),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Icon(
              CupertinoIcons.chevron_up_chevron_down,
              size: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
