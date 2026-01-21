import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart'
    hide objetivosByClinicaProvider;
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

import 'package:project_mmh/features/clinicas_metas/presentation/providers/objetivos_providers.dart';

class TreatmentEditSheet extends ConsumerStatefulWidget {
  final Tratamiento tratamiento;

  const TreatmentEditSheet({super.key, required this.tratamiento});

  @override
  ConsumerState<TreatmentEditSheet> createState() => _TreatmentEditSheetState();
}

class _TreatmentEditSheetState extends ConsumerState<TreatmentEditSheet> {
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
            'Editar Tratamiento',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FormBuilder(
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
                  data: (patients) {
                    return FormBuilderField<String>(
                      name: 'id_expediente',
                      // initialValue is handled by FormBuilder initialValue
                      validator: FormBuilderValidators.required(
                        errorText: 'Seleccione un paciente de la lista',
                      ),
                      builder: (FormFieldState<String> field) {
                        // Calculate initial text if available
                        String initialText = '';
                        if (field.value != null) {
                          final p = patients.firstWhere(
                            (element) => element.idExpediente == field.value,
                            orElse: () => patients.first, // Fallback safe
                          );
                          if (p.idExpediente == field.value) {
                            initialText = '${p.nombre} ${p.primerApellido}';
                          }
                        }

                        return InputDecorator(
                          decoration: _getInputDecoration('Paciente').copyWith(
                            errorText: field.errorText,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          child: Autocomplete<Patient>(
                            initialValue: TextEditingValue(text: initialText),
                            optionsBuilder: (
                              TextEditingValue textEditingValue,
                            ) {
                              if (textEditingValue.text.isEmpty) {
                                return patients;
                              }
                              return patients.where((Patient p) {
                                final name =
                                    '${p.nombre} ${p.primerApellido} ${p.segundoApellido ?? ''}'
                                        .toLowerCase();
                                final id = p.idExpediente.toLowerCase();
                                final query =
                                    textEditingValue.text.toLowerCase();
                                return name.contains(query) ||
                                    id.contains(query);
                              });
                            },
                            displayStringForOption:
                                (Patient p) =>
                                    '${p.nombre} ${p.primerApellido} (${p.idExpediente})',
                            onSelected: (Patient selection) {
                              field.didChange(selection.idExpediente);
                            },
                            fieldViewBuilder: (
                              context,
                              textEditingController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              return TextField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Escriba para buscar...',
                                ),
                                onChanged: (val) {
                                  // Clear selection if user types (enforcing selection)
                                  if (field.value != null) {
                                    // Only clear if logic demands strict matching or if user is modifying selection
                                    // But for better UX let's keep it until they pick another,
                                    // actually for strict ID relationship we should clear if text mismatch.
                                    // But let's follow AppointmentForm logic
                                    field.didChange(null);
                                  }
                                },
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4.0,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: 200,
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                          64, // Adjust for padding
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (
                                        BuildContext context,
                                        int index,
                                      ) {
                                        final Patient option = options
                                            .elementAt(index);
                                        return ListTile(
                                          title: Text(
                                            '${option.nombre} ${option.primerApellido}',
                                          ),
                                          subtitle: Text(option.idExpediente),
                                          onTap: () {
                                            onSelected(option);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => const Text('Error al cargar pacientes'),
                ),
                const SizedBox(height: 12),

                // 2. Clinic
                clinicasAsync.when(
                  data:
                      (clinicas) => Builder(
                        builder: (context) {
                          // Validate if current selectedClinicaId exists
                          if (!clinicas.any(
                            (c) => c.idClinica == _selectedClinicaId,
                          )) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && clinicas.isNotEmpty) {
                                setState(() {
                                  _selectedClinicaId =
                                      clinicas.first.idClinica!;
                                  _formKey.currentState?.fields['id_clinica']
                                      ?.didChange(_selectedClinicaId);
                                });
                              }
                            });
                            return const LinearProgressIndicator();
                          }

                          return FormBuilderDropdown<int>(
                            name: 'id_clinica',
                            initialValue: _selectedClinicaId,
                            decoration: _getInputDecoration('Clínica'),
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
                                  _formKey.currentState?.fields['id_objetivo']
                                      ?.reset();
                                }
                              });
                            },
                          );
                        },
                      ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => const Text('Error al cargar clínicas'),
                ),
                const SizedBox(height: 12),

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
                              Builder(
                                builder: (context) {
                                  final currentObjectiveId =
                                      _formKey
                                              .currentState
                                              ?.fields['id_objetivo']
                                              ?.value
                                          as int?;
                                  if (currentObjectiveId != null &&
                                      !objetivos.any(
                                        (o) =>
                                            o.idObjetivo == currentObjectiveId,
                                      )) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            _formKey
                                                .currentState
                                                ?.fields['id_objetivo']
                                                ?.didChange(null);
                                          }
                                        });
                                  }

                                  return FormBuilderDropdown<int?>(
                                    name: 'id_objetivo',
                                    decoration: _getInputDecoration(
                                      'Objetivo',
                                    ).copyWith(
                                      helperText:
                                          'Seleccione "Personalizado" si no aplica',
                                    ),
                                    items: [
                                      DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text(
                                          '-- Otro / Personalizado --',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
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
                                        _formKey
                                            .currentState
                                            ?.fields['nombre_tratamiento']
                                            ?.didChange('');
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              FormBuilderTextField(
                                name: 'nombre_tratamiento',
                                decoration: _getInputDecoration(
                                  'Nombre del Tratamiento',
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
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text('Guardar'),
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tratamiento actualizado')),
        );
      }
    }
  }
}
