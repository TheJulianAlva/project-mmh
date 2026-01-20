import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';

import 'package:project_mmh/features/pacientes/domain/patient.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:project_mmh/features/clinicas_metas/domain/objetivo.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/objetivos_providers.dart'
    as obj_prov;
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';

class AppointmentForm extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final String? initialPatientId;
  final int? initialClinicId;
  // initialPeriodId can be inferred from context or persistence as default

  const AppointmentForm({
    super.key,
    required this.initialDate,
    this.initialPatientId,
    this.initialClinicId,
  });

  @override
  ConsumerState<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<AppointmentForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  int? _selectedClinicaId;
  int? _selectedPeriodId;
  String? _selectedPatientId;

  // List to track multiple sessions. Initialized with one session.
  // We store temporary data maps for sessions > 1
  final List<Map<String, dynamic>> _additionalSessions = [];

  @override
  void initState() {
    super.initState();
    // 1. Initialize Patient
    if (widget.initialPatientId != null) {
      _selectedPatientId = widget.initialPatientId;
    }

    // 2. Initialize Period (Default to Persistent, fallback to none)
    _selectedPeriodId = ref.read(lastViewedPeriodIdProvider);

    // 3. Initialize Clinic (Contextual or null)
    if (widget.initialClinicId != null) {
      _selectedClinicaId = widget.initialClinicId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Tratamiento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAppointment),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Información del Tratamiento'),
              // 1. Seleccionar Paciente (Searchable)
              patientsAsync.when(
                data: (patients) {
                  return FormBuilderField<String>(
                    name: 'id_expediente',
                    initialValue: _selectedPatientId,
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
                        decoration: InputDecoration(
                          labelText: 'Paciente',
                          border: const OutlineInputBorder(),
                          errorText: field.errorText,
                        ),
                        child: Autocomplete<Patient>(
                          initialValue: TextEditingValue(text: initialText),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return patients;
                            }
                            return patients.where((Patient p) {
                              final name =
                                  '${p.nombre} ${p.primerApellido} ${p.segundoApellido ?? ''}'
                                      .toLowerCase();
                              final id = p.idExpediente.toLowerCase();
                              final query = textEditingValue.text.toLowerCase();
                              return name.contains(query) || id.contains(query);
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
                                // Only allow if matches exactly, otherwise null
                                // For basic UX, we clear value on change and expect re-selection
                                // But to avoid clearing on cosmetic changes, we can logic check,
                                // but safest for "Must exist" is to clear ID if text changes.
                                if (field.value != null) {
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
                                        MediaQuery.of(context).size.width - 32,
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final Patient option = options.elementAt(
                                        index,
                                      );
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
                error: (e, _) => Text('Error al cargar pacientes: $e'),
              ),
              const SizedBox(height: 16),

              // 2. Seleccionar Periodo (Required for Clinic)
              Consumer(
                builder: (context, ref, child) {
                  final periodosAsync = ref.watch(periodosProvider);
                  return periodosAsync.when(
                    data:
                        (periodos) => FormBuilderDropdown<int>(
                          name: 'id_periodo',
                          initialValue: _selectedPeriodId,
                          decoration: const InputDecoration(
                            labelText: 'Periodo',
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.required(),
                          items:
                              periodos
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p.idPeriodo,
                                      child: Text(p.nombrePeriodo),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPeriodId = val;
                              _selectedClinicaId = null; // Reset clinic
                              _formKey.currentState?.fields['id_clinica']
                                  ?.didChange(null);
                              _formKey.currentState?.fields['id_objetivo']
                                  ?.didChange(null);
                            });
                          },
                        ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error cargando periodos'),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 3. Seleccionar Clínica (Dependent on Period)
              if (_selectedPeriodId != null) ...[
                Consumer(
                  builder: (context, ref, child) {
                    final clinicasAsync = ref.watch(
                      clinicasByPeriodoProvider(_selectedPeriodId!),
                    );

                    return clinicasAsync.when(
                      data:
                          (clinicas) => FormBuilderDropdown<int>(
                            name: 'id_clinica',
                            initialValue:
                                _selectedClinicaId, // Use contextual initial
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
                                _selectedClinicaId = val;
                                _formKey.currentState?.fields['id_objetivo']
                                    ?.reset();
                              });
                            },
                          ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Error al cargar clínicas: $e'),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),

              // 4. Seleccionar Objetivo / Tratamiento (Searchable)
              if (_selectedClinicaId != null)
                Consumer(
                  builder: (context, ref, child) {
                    final objetivosAsync = ref.watch(
                      obj_prov.objetivosByClinicaProvider(_selectedClinicaId!),
                    );
                    return objetivosAsync.when(
                      data: (objetivos) {
                        return FormBuilderField<int?>(
                          name: 'id_objetivo',
                          builder: (FormFieldState<int?> field) {
                            // Helper constant for Custom Option
                            const customOption = Objetivo(
                              idObjetivo: -1, // Use -1 as sentinel for Custom
                              idClinica: 0,
                              nombreTratamiento: '-- Otro / Personalizado --',
                              cantidadMeta: 0,
                            );

                            return InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Tratamiento / Objetivo',
                                border: const OutlineInputBorder(),
                                helperText:
                                    'Busque o deje vacío para Personalizado',
                                errorText: field.errorText,
                              ),
                              child: Autocomplete<Objetivo>(
                                optionsBuilder: (
                                  TextEditingValue textEditingValue,
                                ) {
                                  final query =
                                      textEditingValue.text.toLowerCase();
                                  final filtered =
                                      objetivos
                                          .where(
                                            (o) => o.nombreTratamiento
                                                .toLowerCase()
                                                .contains(query),
                                          )
                                          .toList();

                                  return [customOption, ...filtered];
                                },
                                displayStringForOption: (Objetivo option) {
                                  if (option.idObjetivo == -1) {
                                    return '-- Otro / Personalizado --';
                                  }
                                  return '${option.nombreTratamiento} (Meta: ${option.cantidadMeta})';
                                },
                                onSelected: (Objetivo selection) {
                                  if (selection.idObjetivo == -1) {
                                    field.didChange(null);
                                    _formKey
                                        .currentState
                                        ?.fields['nombre_tratamiento']
                                        ?.didChange('');
                                  } else {
                                    field.didChange(selection.idObjetivo);
                                    _formKey
                                        .currentState
                                        ?.fields['nombre_tratamiento']
                                        ?.didChange(
                                          selection.nombreTratamiento,
                                        );
                                  }
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
                                      hintText: 'Seleccione...',
                                    ),
                                    onChanged: (val) {
                                      // If typing, assume custom
                                      if (field.value != null &&
                                          val.isNotEmpty) {
                                        field.didChange(null);
                                      }
                                    },
                                  );
                                },
                                optionsViewBuilder: (
                                  context,
                                  onSelected,
                                  options,
                                ) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: 200,
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width -
                                              32,
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder: (
                                            BuildContext context,
                                            int index,
                                          ) {
                                            final Objetivo option = options
                                                .elementAt(index);
                                            return ListTile(
                                              title: Text(
                                                option.idObjetivo == -1
                                                    ? option.nombreTratamiento
                                                    : option.nombreTratamiento,
                                              ),
                                              subtitle:
                                                  option.idObjetivo != -1
                                                      ? Text(
                                                        'Meta: ${option.cantidadMeta} - Actual: ${option.cantidadActual}',
                                                      )
                                                      : null,
                                              onTap: () => onSelected(option),
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
                      error: (e, _) => Text('Error: $e'),
                    );
                  },
                ),
              if (_selectedClinicaId != null) const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'detalles_adicionales',
                decoration: const InputDecoration(
                  labelText: 'Detalles (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Sesiones'),
              const Text(
                'Sesión 1 (Inicial)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Sesión 1 (Campos principales)
              Row(
                children: [
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'fecha_inicio',
                      initialValue: widget.initialDate,
                      inputType: InputType.both,
                      decoration: const InputDecoration(
                        labelText: 'Inicio',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.required(),
                      onChanged: (val) {
                        if (val != null) {
                          // Auto update End Time
                          final endDate = val.add(const Duration(hours: 2));
                          _formKey.currentState?.fields['fecha_fin']?.didChange(
                            endDate,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'fecha_fin',
                      initialValue: widget.initialDate.add(
                        const Duration(hours: 2),
                      ),
                      inputType: InputType.both,
                      decoration: const InputDecoration(
                        labelText: 'Fin',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                ],
              ),

              // Sesiones Adicionales
              ..._additionalSessions.asMap().entries.map((entry) {
                final index = entry.key;
                final sessionIndex =
                    index + 2; // +2 because index 0 is session 2
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sesión $sessionIndex',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () {
                            setState(() {
                              _additionalSessions.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderDateTimePicker(
                            name: 'sesion_${index}_inicio',
                            initialValue: DateTime.now().add(
                              const Duration(days: 7),
                            ), // Default +1 week
                            inputType: InputType.both,
                            decoration: const InputDecoration(
                              labelText: 'Inicio',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                final endDate = val.add(
                                  const Duration(hours: 2),
                                );
                                _formKey
                                    .currentState
                                    ?.fields['sesion_${index}_fin']
                                    ?.didChange(endDate);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FormBuilderDateTimePicker(
                            name: 'sesion_${index}_fin',
                            initialValue: DateTime.now().add(
                              const Duration(days: 7, hours: 2),
                            ),
                            inputType: InputType.both,
                            decoration: const InputDecoration(
                              labelText: 'Fin',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),

              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _additionalSessions.add({});
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar Otra Sesión'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _saveAppointment() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;

      final repo = ref.read(agendaRepositoryProvider);

      // 1. Crear Tratamiento
      final idObjetivo = values['id_objetivo'] as int?; // Can be null
      final nombreTratamiento = values['nombre_tratamiento'] as String;

      final nuevoTratamiento = Tratamiento(
        idClinica: values['id_clinica'] as int,
        idExpediente: values['id_expediente'] as String,
        idObjetivo: idObjetivo,
        nombreTratamiento: nombreTratamiento,
        fechaCreacion: DateTime.now().toIso8601String(),
        estado: 'pendiente',
      );

      final idTratamiento = await repo.createTratamiento(nuevoTratamiento);

      // 2. Crear Sesion 1 (Main)
      final sesion1 = Sesion(
        idTratamiento: idTratamiento,
        fechaInicio: (values['fecha_inicio'] as DateTime).toIso8601String(),
        fechaFin: (values['fecha_fin'] as DateTime).toIso8601String(),
        estadoAsistencia: 'programada',
      );
      await repo.createSesion(sesion1);

      // 3. Crear Sesiones Adicionales
      for (int i = 0; i < _additionalSessions.length; i++) {
        final inicio = values['sesion_${i}_inicio'] as DateTime?;
        final fin = values['sesion_${i}_fin'] as DateTime?;

        if (inicio != null && fin != null) {
          final sesionExtra = Sesion(
            idTratamiento: idTratamiento,
            fechaInicio: inicio.toIso8601String(),
            fechaFin: fin.toIso8601String(),
            estadoAsistencia: 'programada',
          );
          await repo.createSesion(sesionExtra);
        }
      }

      // Refresh providers
      ref.invalidate(allSesionesProvider);
      ref.invalidate(allTratamientosRichProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tratamiento y sesiones agendados correctamente'),
          ),
        );
      }
    }
  }
}
