import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/clinicas_metas/domain/periodo.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/objetivos_providers.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:project_mmh/features/clinicas_metas/presentation/widgets/color_picker_field.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/widgets/weekly_schedule_picker.dart';

class ClinicasMetasScreen extends ConsumerWidget {
  const ClinicasMetasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodosAsync = ref.watch(periodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Académica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar Periodo',
            onPressed: () => _showAddPeriodoDialog(context, ref),
          ),
        ],
      ),
      body: periodosAsync.when(
        data: (periodos) {
          if (periodos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay periodos registrados'),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () => _showAddPeriodoDialog(context, ref),
                      child: const Text('Agregar Periodo'),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: periodos.length,
            itemBuilder: (context, index) {
              final periodo = periodos[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          periodo.nombrePeriodo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed:
                            () => _showEditPeriodoDialog(context, ref, periodo),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Eliminar Periodo'),
                                  content: const Text(
                                    '¿Estás seguro? Esto eliminará todas las clínicas y metas asociadas.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            await ref
                                .read(periodosProvider.notifier)
                                .deletePeriodo(periodo.idPeriodo!);
                          }
                        },
                      ),
                    ],
                  ),
                  children: [_ClinicasList(idPeriodo: periodo.idPeriodo!)],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showAddPeriodoDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormBuilderState>();
    final periodosAsync = ref.read(periodosProvider);
    final List<Periodo> existingPeriodos = periodosAsync.asData?.value ?? [];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nuevo Periodo'),
            content: FormBuilder(
              key: formKey,
              child: FormBuilderTextField(
                name: 'nombre',
                decoration: const InputDecoration(
                  labelText: 'Nombre del Periodo',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Requerido';
                  if (existingPeriodos.any(
                    (p) => p.nombrePeriodo.toLowerCase() == val.toLowerCase(),
                  )) {
                    return 'Este nombre ya existe';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.saveAndValidate() ?? false) {
                    try {
                      final nombre = formKey.currentState?.value['nombre'];
                      await ref
                          .read(periodosProvider.notifier)
                          .addPeriodo(nombre);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al guardar: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _showEditPeriodoDialog(
    BuildContext context,
    WidgetRef ref,
    Periodo periodo,
  ) {
    final formKey = GlobalKey<FormBuilderState>();
    final periodosAsync = ref.read(periodosProvider);
    final List<Periodo> existingPeriodos = periodosAsync.asData?.value ?? [];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Periodo'),
            content: FormBuilder(
              key: formKey,
              child: FormBuilderTextField(
                name: 'nombre',
                initialValue: periodo.nombrePeriodo,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Periodo',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Requerido';
                  if (existingPeriodos.any(
                    (p) =>
                        p.nombrePeriodo.toLowerCase() == val.toLowerCase() &&
                        p.idPeriodo != periodo.idPeriodo,
                  )) {
                    return 'Este nombre ya existe';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.saveAndValidate() ?? false) {
                    try {
                      final nombre = formKey.currentState?.value['nombre'];
                      await ref
                          .read(periodosProvider.notifier)
                          .updatePeriodo(periodo.idPeriodo!, nombre);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }
}

class _ClinicasList extends ConsumerWidget {
  final int idPeriodo;
  const _ClinicasList({required this.idPeriodo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicasAsync = ref.watch(clinicasByPeriodoProvider(idPeriodo));

    return clinicasAsync.when(
      data: (clinicas) {
        return Column(
          children: [
            ...clinicas.map(
              (clinica) => ListTile(
                title: Text(clinica.nombreClinica),
                subtitle: Text(clinica.horarios ?? 'Sin horarios'),
                leading: CircleAvatar(
                  backgroundColor: _parseColor(clinica.color),
                  radius: 10,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          () => _showEditClinicaDialog(
                            context,
                            ref,
                            clinica,
                            clinicas,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Eliminar Clínica'),
                                content: const Text(
                                  '¿Estás seguro? Esto eliminará todos los objetivos de esta clínica.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          await ref
                              .read(
                                clinicasByPeriodoProvider(idPeriodo).notifier,
                              )
                              .deleteClinica(clinica.idClinica!);
                        }
                      },
                    ),
                  ],
                ),
                onTap:
                    () => _showObjetivosDialog(
                      context,
                      ref,
                      clinica.idClinica!,
                      clinica.nombreClinica,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Agregar Clínica'),
                onPressed:
                    () => _showAddClinicaDialog(
                      context,
                      ref,
                      idPeriodo,
                      clinicas,
                    ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }

  Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    }
    return Colors.blue;
  }

  void _showAddClinicaDialog(
    BuildContext context,
    WidgetRef ref,
    int idPeriodo,
    List<Clinica> existingClinicas,
  ) {
    final formKey = GlobalKey<FormBuilderState>();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nueva Clínica'),
            content: SingleChildScrollView(
              child: FormBuilder(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: 'nombre',
                      decoration: const InputDecoration(
                        labelText: 'Nombre Clínica',
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Requerido';
                        // Cast existingClinicas to List<Clinica> if strictly needed,
                        // but accessing properties dynamically or ensuring type safety is better.
                        // Since I passed 'clinicas' which is List<Clinica>, checking prop is safe.
                        // I will use explicit casting in the comparison for safety.
                        final exists = existingClinicas.any(
                          (c) =>
                              c.nombreClinica.toLowerCase() ==
                              val.toLowerCase(),
                        );
                        if (exists) return 'Este nombre ya existe';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ColorPickerField(
                      name: 'color',
                      initialValue: '#2196F3',
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    const SizedBox(height: 16),
                    WeeklySchedulePicker(
                      name: 'horarios',
                      decoration: const InputDecoration(labelText: 'Horarios'),
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
                  if (formKey.currentState?.saveAndValidate() ?? false) {
                    try {
                      final vals = formKey.currentState!.value;
                      await ref
                          .read(clinicasByPeriodoProvider(idPeriodo).notifier)
                          .addClinica(
                            nombre: vals['nombre'],
                            color: vals['color'],
                            horarios: vals['horarios'] ?? '',
                          );
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al guardar: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _showObjetivosDialog(
    BuildContext context,
    WidgetRef ref,
    int idClinica,
    String nombreClinica,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => _ObjetivosDialog(
            idClinica: idClinica,
            nombreClinica: nombreClinica,
          ),
    );
  }

  void _showEditClinicaDialog(
    BuildContext context,
    WidgetRef ref,
    Clinica clinica,
    List<Clinica> existingClinicas,
  ) {
    final formKey = GlobalKey<FormBuilderState>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Clínica'),
            content: SingleChildScrollView(
              child: FormBuilder(
                key: formKey,
                initialValue: {
                  'nombre': clinica.nombreClinica,
                  'color': clinica.color,
                  'horarios': clinica.horarios,
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: 'nombre',
                      decoration: const InputDecoration(
                        labelText: 'Nombre Clínica',
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Requerido';
                        final exists = existingClinicas.any(
                          (c) =>
                              c.nombreClinica.toLowerCase() ==
                                  val.toLowerCase() &&
                              c.idClinica != clinica.idClinica,
                        );
                        if (exists) return 'Este nombre ya existe';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ColorPickerField(
                      name: 'color',
                      initialValue: clinica.color,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    const SizedBox(height: 16),
                    WeeklySchedulePicker(
                      name: 'horarios',
                      initialValue: clinica.horarios,
                      decoration: const InputDecoration(labelText: 'Horarios'),
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
                  if (formKey.currentState?.saveAndValidate() ?? false) {
                    try {
                      final vals = formKey.currentState!.value;
                      final updatedClinica = clinica.copyWith(
                        nombreClinica: vals['nombre'],
                        color: vals['color'],
                        horarios: vals['horarios'] ?? '',
                      );
                      await ref
                          .read(
                            clinicasByPeriodoProvider(
                              clinica.idPeriodo,
                            ).notifier,
                          )
                          .updateClinica(updatedClinica);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }
}

class _ObjetivosDialog extends ConsumerWidget {
  final int idClinica;
  final String nombreClinica;

  const _ObjetivosDialog({
    required this.idClinica,
    required this.nombreClinica,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objetivosAsync = ref.watch(objetivosByClinicaProvider(idClinica));

    return AlertDialog(
      title: Text('Metas: $nombreClinica'),
      content: SizedBox(
        width: double.maxFinite,
        child: objectivesContent(objetivosAsync, ref),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        ElevatedButton(
          onPressed: () => _showAddObjetivoDialog(context, ref),
          child: const Text('Agregar Meta'),
        ),
      ],
    );
  }

  Widget objectivesContent(AsyncValue<dynamic> objetivosAsync, WidgetRef ref) {
    return objetivosAsync.when(
      data: (objetivos) {
        if (objetivos.isEmpty) return const Text('No hay metas definidas.');
        return ListView.builder(
          shrinkWrap: true,
          itemCount: objetivos.length,
          itemBuilder: (ctx, i) {
            final obj = objetivos[i];
            return ListTile(
              title: Text(obj.nombreTratamiento),
              trailing: Text('${obj.cantidadActual} / ${obj.cantidadMeta}'),
              onLongPress:
                  () => ref
                      .read(objetivosByClinicaProvider(idClinica).notifier)
                      .deleteObjetivo(obj.idObjetivo!),
            );
          },
        );
      },
      loading:
          () => const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          ),
      error: (e, s) => Text('Error: $e'),
    );
  }

  void _showAddObjetivoDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormBuilderState>();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nueva Meta'),
            content: FormBuilder(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'nombre',
                    decoration: const InputDecoration(labelText: 'Tratamiento'),
                    validator:
                        (val) =>
                            val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  FormBuilderTextField(
                    name: 'meta',
                    decoration: const InputDecoration(
                      labelText: 'Cantidad Meta',
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (val) =>
                            val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.saveAndValidate() ?? false) {
                    final vals = formKey.currentState!.value;
                    await ref
                        .read(objetivosByClinicaProvider(idClinica).notifier)
                        .addObjetivo(
                          nombreTratamiento: vals['nombre'],
                          cantidadMeta: int.parse(vals['meta']),
                        );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }
}
