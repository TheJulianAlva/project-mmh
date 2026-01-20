import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/clinicas_metas/domain/periodo.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/objetivos_providers.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:project_mmh/features/clinicas_metas/presentation/widgets/color_picker_field.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/widgets/weekly_schedule_picker.dart';
import 'package:project_mmh/features/clinicas_metas/domain/objetivo.dart';

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
              final theme = Theme.of(context);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(
                    periodo.nombrePeriodo,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.all(16),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Editar Periodo',
                        onPressed:
                            () => _showEditPeriodoDialog(context, ref, periodo),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        tooltip: 'Eliminar Periodo',
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
                maxLength: 30,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Periodo',
                  counterText: "",
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
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
              initialValue: {'nombre': periodo.nombrePeriodo},
              child: FormBuilderTextField(
                name: 'nombre',
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Periodo',
                  counterText: "",
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
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  // ...
}

// ... Previous Dialog Methods ...

class _ClinicasList extends ConsumerWidget {
  final int idPeriodo;
  const _ClinicasList({required this.idPeriodo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicasAsync = ref.watch(clinicasByPeriodoProvider(idPeriodo));

    return clinicasAsync.when(
      data: (clinicas) {
        if (clinicas.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    'No hay clínicas registradas.',
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
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
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            ...clinicas.map((clinica) {
              final clinicColor = _parseColor(clinica.color);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: clinicColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.local_hospital, color: clinicColor),
                  ),
                  title: Text(
                    clinica.nombreClinica,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (clinica.horarios != null &&
                          clinica.horarios!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: Theme.of(context).disabledColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  clinica.horarios!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showEditClinicaDialog(context, ref, clinica, clinicas);
                      } else if (value == 'delete') {
                        // Delete logic
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
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Eliminar',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text(
                  'Agregar Clínica',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
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
    if (colorString.isEmpty) return Colors.blue;
    try {
      String cleanHex = colorString
          .replaceAll('#', '')
          .replaceAll('0x', '')
          .replaceAll('0X', '');
      if (cleanHex.length == 6) {
        return Color(int.parse(cleanHex, radix: 16) + 0xFF000000);
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
      return Color(int.parse(cleanHex, radix: 16) + 0xFF000000);
    } catch (_) {
      return Colors.blue;
    }
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
                      maxLength: 30,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Clínica',
                        counterText: "",
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Requerido';
                        if (existingClinicas.any(
                          (c) =>
                              c.nombreClinica.toLowerCase() ==
                              val.toLowerCase(),
                        )) {
                          return 'Este nombre ya existe';
                        }
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
                    final vals = formKey.currentState!.value;
                    await ref
                        .read(clinicasByPeriodoProvider(idPeriodo).notifier)
                        .addClinica(
                          nombre: vals['nombre'],
                          color: vals['color'] ?? '#2196F3',
                          horarios: vals['horarios'] ?? '',
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
                      maxLength: 30,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Clínica',
                        counterText: "",
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Requerido';
                        if (existingClinicas.any(
                          (c) =>
                              c.nombreClinica.toLowerCase() ==
                                  val.toLowerCase() &&
                              c.idClinica != clinica.idClinica,
                        )) {
                          return 'Este nombre ya existe';
                        }
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
                    final vals = formKey.currentState!.value;
                    final updated = clinica.copyWith(
                      nombreClinica: vals['nombre'],
                      color: vals['color'] ?? '#2196F3',
                      horarios: vals['horarios'] ?? '',
                    );
                    await ref
                        .read(
                          clinicasByPeriodoProvider(clinica.idPeriodo).notifier,
                        )
                        .updateClinica(updated);
                    if (context.mounted) Navigator.pop(context);
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
        child: objetivosAsync.when(
          data: (objetivos) {
            if (objetivos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No hay metas definidas. ¡Agrega una!',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: objetivos.length,
              itemBuilder: (ctx, i) {
                final obj = objetivos[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    obj.nombreTratamiento,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Meta: ${obj.cantidadMeta}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${obj.cantidadActual} / ${obj.cantidadMeta}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed:
                            () => _showEditObjetivoDialog(
                              context,
                              ref,
                              obj,
                            ), // New Method
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () async {
                          // Confirm delete
                          // Simplified for brevity, usually show confirm diag
                          await ref
                              .read(
                                objetivosByClinicaProvider(idClinica).notifier,
                              )
                              .deleteObjetivo(obj.idObjetivo!);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading:
              () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
          error: (e, s) => Text('Error: $e'),
        ),
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

  // New Edit Method
  void _showEditObjetivoDialog(
    BuildContext context,
    WidgetRef ref,
    Objetivo objetivo,
  ) {
    final formKey = GlobalKey<FormBuilderState>();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Meta'),
            content: SingleChildScrollView(
              child: FormBuilder(
                key: formKey,
                initialValue: {
                  'nombre': objetivo.nombreTratamiento,
                  'meta': objetivo.cantidadMeta.toString(),
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: 'nombre',
                      maxLength: 30,
                      decoration: const InputDecoration(
                        labelText: 'Tratamiento',
                        counterText: "",
                      ),
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'meta',
                      decoration: const InputDecoration(
                        labelText: 'Cantidad Meta',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Requerido';
                        final number = int.tryParse(val);
                        if (number == null || number <= 0) return 'Válido > 0';
                        return null;
                      },
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
                    final vals = formKey.currentState!.value;
                    final updatedObj = objetivo.copyWith(
                      nombreTratamiento: vals['nombre'],
                      cantidadMeta: int.parse(vals['meta']),
                    );
                    await ref
                        .read(objetivosByClinicaProvider(idClinica).notifier)
                        .updateObjetivo(updatedObj);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _showAddObjetivoDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormBuilderState>();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nueva Meta'),
            content: SingleChildScrollView(
              child: FormBuilder(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: 'nombre',
                      maxLength: 30,
                      decoration: const InputDecoration(
                        labelText: 'Tratamiento',
                        counterText: "",
                      ),
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'meta',
                      decoration: const InputDecoration(
                        labelText: 'Cantidad Meta',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Requerido';
                        final number = int.tryParse(val);
                        if (number == null || number <= 0) return 'Válido > 0';
                        return null;
                      },
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
