import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

class TreatmentEditDialog extends ConsumerStatefulWidget {
  final Tratamiento tratamiento;

  const TreatmentEditDialog({super.key, required this.tratamiento});

  @override
  ConsumerState<TreatmentEditDialog> createState() =>
      _TreatmentEditDialogState();
}

class _TreatmentEditDialogState extends ConsumerState<TreatmentEditDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  late int _selectedClinicaId;

  @override
  void initState() {
    super.initState();
    _selectedClinicaId = widget.tratamiento.idClinica;
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsProvider);
    final clinicasAsync = ref.watch(clinicasProvider);

    return AlertDialog(
      title: const Text('Editar Tratamiento'),
      content: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'id_expediente': widget.tratamiento.idExpediente,
            'id_clinica': widget.tratamiento.idClinica,
            'id_objetivo': widget.tratamiento.idObjetivo,
            'nombre_tratamiento': widget.tratamiento.nombreTratamiento,
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Patient
              patientsAsync.when(
                data:
                    (patients) => FormBuilderDropdown<String>(
                      name: 'id_expediente',
                      decoration: const InputDecoration(
                        labelText: 'Paciente',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.required(),
                      items:
                          patients
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p.idExpediente,
                                  child: Text(
                                    '${p.nombre} ${p.primerApellido}',
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => const Text('Error al cargar pacientes'),
              ),
              const SizedBox(height: 16),

              // 2. Clinic
              clinicasAsync.when(
                data:
                    (clinicas) => FormBuilderDropdown<int>(
                      name: 'id_clinica',
                      decoration: const InputDecoration(
                        labelText: 'Clínica',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.required(),
                      items:
                          clinicas
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.idClinica,
                                  child: Text(c.nombreClinica),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          if (val != null) {
                            _selectedClinicaId = val;
                            // Reset dependent fields
                            _formKey.currentState?.fields['id_objetivo']
                                ?.reset();
                          }
                        });
                      },
                    ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => const Text('Error al cargar clínicas'),
              ),
              const SizedBox(height: 16),

              // 3. Objective (Dependent on Clinic)
              Consumer(
                builder: (context, ref, child) {
                  final objetivosAsync = ref.watch(
                    objetivosByClinicaProvider(_selectedClinicaId),
                  );
                  return objetivosAsync.when(
                    data:
                        (objetivos) => Column(
                          children: [
                            FormBuilderDropdown<int?>(
                              name: 'id_objetivo',
                              decoration: const InputDecoration(
                                labelText: 'Objetivo',
                                border: OutlineInputBorder(),
                                helperText:
                                    'Seleccione "Personalizado" si no aplica',
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text(
                                    '-- Otro / Personalizado --',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                ...objetivos.map(
                                  (o) => DropdownMenuItem<int?>(
                                    value: o.idObjetivo,
                                    child: Text(
                                      '${o.nombreTratamiento} (Meta: ${o.cantidadMeta})',
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  final obj = objetivos.firstWhere(
                                    (o) => o.idObjetivo == val,
                                  );
                                  _formKey
                                      .currentState
                                      ?.fields['nombre_tratamiento']
                                      ?.didChange(obj.nombreTratamiento);
                                } else {
                                  // Keep existing name or clear?
                                  // Let's keep existing if it matches, else clear or let user type
                                  // If they switched to custom, maybe they want to type a new name.
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'nombre_tratamiento',
                              decoration: const InputDecoration(
                                labelText: 'Nombre del Tratamiento',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.required(),
                            ),
                          ],
                        ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => const Text('Error al cargar objetivos'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _saveChanges, child: const Text('Guardar')),
      ],
    );
  }

  void _saveChanges() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final repo = ref.read(agendaRepositoryProvider);

      final updatedTratamiento = widget.tratamiento.copyWith(
        idExpediente: values['id_expediente'] as String,
        idClinica: values['id_clinica'] as int,
        idObjetivo: values['id_objetivo'] as int?,
        nombreTratamiento: values['nombre_tratamiento'] as String,
      );

      await repo.updateTratamiento(updatedTratamiento);

      // Refresh providers
      ref.invalidate(
        tratamientoByIdProvider(widget.tratamiento.idTratamiento!),
      );
      ref.invalidate(allTratamientosRichProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tratamiento actualizado')),
        );
      }
    }
  }
}
