import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:project_mmh/core/presentation/widgets/cupertino_date_picker_field.dart';
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
                  CupertinoDatePickerField(
                    name: 'fecha_inicio',
                    initialValue:
                        isEditing
                            ? DateTime.parse(widget.sesion!.fechaInicio)
                            : DateTime.now(),
                    pickerType: CupertinoDatePickerType.dateTime,
                    decoration: _getInputDecoration(
                      'Inicio',
                      CupertinoIcons.calendar,
                      colorScheme,
                      isDark,
                    ),
                    validator: FormBuilderValidators.required(),
                    onChanged: (val) {
                      if (val != null) {
                        _formKey.currentState?.fields['fecha_fin']?.didChange(
                          val.add(const Duration(hours: 2)),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                  CupertinoDatePickerField(
                    name: 'fecha_fin',
                    initialValue:
                        isEditing
                            ? DateTime.parse(widget.sesion!.fechaFin)
                            : DateTime.now().add(const Duration(hours: 2)),
                    pickerType: CupertinoDatePickerType.dateTime,
                    decoration: _getInputDecoration(
                      'Fin',
                      CupertinoIcons.clock,
                      colorScheme,
                      isDark,
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Save Button ──
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : () => _save(isEditing),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: const StadiumBorder(),
                elevation: 0,
                disabledBackgroundColor: colorScheme.primary.withValues(
                  alpha: 0.5,
                ),
              ),
              child:
                  _isSaving
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                      : Text(
                        isEditing ? 'Guardar Cambios' : 'Crear Sesión',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _save(bool isEditing) async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isSaving = true);

    final values = _formKey.currentState!.value;
    final repo = ref.read(agendaRepositoryProvider);

    final inicio = (values['fecha_inicio'] as DateTime).toIso8601String();
    final fin = (values['fecha_fin'] as DateTime).toIso8601String();
    final estado = isEditing ? widget.sesion!.estadoAsistencia : 'programada';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _getInputDecoration(
    String label,
    IconData icon,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        size: 18,
        color: colorScheme.primary.withValues(alpha: 0.6),
      ),
      filled: true,
      fillColor: isDark ? colorScheme.surface : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      labelStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
