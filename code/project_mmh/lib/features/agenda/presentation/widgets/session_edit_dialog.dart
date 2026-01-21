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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sesion != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isEditing ? 'Editar Sesión' : 'Agregar Sesión',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FormBuilder(
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
                  decoration: _getInputDecoration('Inicio'),
                  validator: FormBuilderValidators.required(),
                  onChanged: (val) {
                    if (val != null) {
                      _formKey.currentState?.fields['fecha_fin']?.didChange(
                        val.add(const Duration(hours: 2)),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                CupertinoDatePickerField(
                  name: 'fecha_fin',
                  initialValue:
                      isEditing
                          ? DateTime.parse(widget.sesion!.fechaFin)
                          : DateTime.now().add(const Duration(hours: 2)),
                  pickerType: CupertinoDatePickerType.dateTime,
                  decoration: _getInputDecoration('Fin'),
                  validator: FormBuilderValidators.required(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                final values = _formKey.currentState!.value;
                final repo = ref.read(agendaRepositoryProvider);

                final inicio =
                    (values['fecha_inicio'] as DateTime).toIso8601String();
                final fin = (values['fecha_fin'] as DateTime).toIso8601String();

                // Determine status: preserve existing if editing, else 'programada'
                final estado =
                    isEditing ? widget.sesion!.estadoAsistencia : 'programada';

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
                    Navigator.pop(context); // Close sheet
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
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: Text(isEditing ? 'Guardar Cambios' : 'Crear Sesión'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
