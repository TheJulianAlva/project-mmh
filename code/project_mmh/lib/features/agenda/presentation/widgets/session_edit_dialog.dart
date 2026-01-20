import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';

class SessionEditDialog extends ConsumerStatefulWidget {
  final int idTratamiento;
  final Sesion? sesion; // If null, create new. If not null, edit.

  const SessionEditDialog({
    super.key,
    required this.idTratamiento,
    this.sesion,
  });

  @override
  ConsumerState<SessionEditDialog> createState() => _SessionEditDialogState();
}

class _SessionEditDialogState extends ConsumerState<SessionEditDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sesion != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Sesión' : 'Agregar Sesión'),
      content: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderDateTimePicker(
                name: 'fecha_inicio',
                initialValue:
                    isEditing
                        ? DateTime.parse(widget.sesion!.fechaInicio)
                        : DateTime.now(),
                inputType: InputType.both,
                decoration: const InputDecoration(
                  labelText: 'Inicio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: FormBuilderValidators.required(),
                onChanged: (val) {
                  // Only auto-update end time if creating new and field untouched
                  if (!isEditing && val != null) {
                    final currentEnd =
                        _formKey.currentState?.fields['fecha_fin']?.value;
                    if (currentEnd == null) {
                      _formKey.currentState?.fields['fecha_fin']?.didChange(
                        val.add(const Duration(hours: 2)),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'fecha_fin',
                initialValue:
                    isEditing
                        ? DateTime.parse(widget.sesion!.fechaFin)
                        : DateTime.now().add(const Duration(hours: 2)),
                inputType: InputType.both,
                decoration: const InputDecoration(
                  labelText: 'Fin',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event_busy),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<String>(
                name: 'estado_asistencia',
                initialValue: widget.sesion?.estadoAsistencia ?? 'programada',
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'programada',
                    child: Text('Programada'),
                  ),
                  DropdownMenuItem(
                    value: 'asistio',
                    child: Text('Asistió (Confirmada)'),
                  ),
                  DropdownMenuItem(value: 'cancelo', child: Text('Canceló')),
                  DropdownMenuItem(
                    value: 'falto',
                    child: Text('Faltó (No Show)'),
                  ),
                  DropdownMenuItem(
                    value: 'reprogramada',
                    child: Text('Reprogramada'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final values = _formKey.currentState!.value;
              final repo = ref.read(agendaRepositoryProvider);

              final inicio =
                  (values['fecha_inicio'] as DateTime).toIso8601String();
              final fin = (values['fecha_fin'] as DateTime).toIso8601String();
              final estado = values['estado_asistencia'] as String;

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

                // Refresh Providers
                ref.invalidate(
                  sesionesByTratamientoProvider(widget.idTratamiento),
                );
                ref.invalidate(allSesionesProvider);
                ref.invalidate(allTratamientosRichProvider);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing ? 'Sesión actualizada' : 'Sesión creada',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            }
          },
          child: Text(isEditing ? 'Guardar Cambios' : 'Crear Sesión'),
        ),
      ],
    );
  }
}
