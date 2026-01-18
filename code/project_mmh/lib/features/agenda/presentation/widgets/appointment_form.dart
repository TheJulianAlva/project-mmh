import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/clinicas_metas/domain/objetivo.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

class AppointmentForm extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const AppointmentForm({super.key, required this.initialDate});

  @override
  ConsumerState<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<AppointmentForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  int? _selectedClinicaId;

  // List to track multiple sessions. Initialized with one session.
  // We store temporary data maps for sessions > 1
  final List<Map<String, dynamic>> _additionalSessions = [];

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsProvider);
    final clinicasAsync = ref.watch(clinicasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Cita'),
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
              // 1. Seleccionar Paciente
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
                error: (e, _) => Text('Error al cargar pacientes: $e'),
              ),
              const SizedBox(height: 16),

              // 2. Seleccionar Clínica
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
                          _selectedClinicaId = val;
                          _formKey.currentState?.fields['id_objetivo']?.reset();
                        });
                      },
                    ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error al cargar clínicas: $e'),
              ),
              const SizedBox(height: 16),

              // 3. Seleccionar Objetivo (Tratamiento Meta)
              if (_selectedClinicaId != null)
                Consumer(
                  builder: (context, ref, child) {
                    final objetivosAsync = ref.watch(
                      objetivosByClinicaProvider(_selectedClinicaId!),
                    );
                    return objetivosAsync.when(
                      data:
                          (objetivos) => FormBuilderDropdown<int>(
                            name: 'id_objetivo',
                            decoration: const InputDecoration(
                              labelText: 'Tratamiento / Objetivo',
                              border: OutlineInputBorder(),
                            ),
                            validator: FormBuilderValidators.required(),
                            items: [
                              ...objetivos.map(
                                (o) => DropdownMenuItem(
                                  value: o.idObjetivo,
                                  child: Text(
                                    '${o.nombreTratamiento} (Meta: ${o.cantidadMeta})',
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                          icon: const Icon(Icons.delete, color: Colors.red),
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
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _saveAppointment() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;

      final repo = ref.read(agendaRepositoryProvider);

      // 1. Crear Tratamiento
      final idObjetivo = values['id_objetivo'] as int;
      final selectedObjetivo = await _getObjetivoName(idObjetivo);

      final nuevoTratamiento = Tratamiento(
        idClinica: values['id_clinica'] as int,
        idExpediente: values['id_expediente'] as String,
        idObjetivo: idObjetivo,
        nombreTratamiento:
            selectedObjetivo?.nombreTratamiento ?? 'Tratamiento General',
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

  Future<Objetivo?> _getObjetivoName(int idObjetivo) async {
    final repo = ref.read(agendaRepositoryProvider);
    final objectives = await repo.getObjetivosByClinica(_selectedClinicaId!);
    try {
      return objectives.firstWhere((o) => o.idObjetivo == idObjetivo);
    } catch (e) {
      return null;
    }
  }
}
