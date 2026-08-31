import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/constants/app_constants.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';
import 'package:project_mmh/core/theme/clinic_palette.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/clinicas_metas/domain/objetivo.dart';
import 'package:project_mmh/features/clinicas_metas/domain/periodo.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/objetivos_providers.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/widgets/color_picker_field.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/widgets/weekly_schedule_picker.dart';

class ClinicasMetasScreen extends ConsumerWidget {
  const ClinicasMetasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodosAsync = ref.watch(periodosProvider);

    return AppScaffold(
      title: 'Gestión Académica',
      actions: [
        AppButton.text(
          label: 'Añadir',
          onPressed: () => _showAddPeriodoDialog(context, ref),
        ),
      ],
      slivers: [
        periodosAsync.when(
          data: (periodos) {
            if (periodos.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.calendar_today,
                  title: 'No hay periodos registrados',
                  action: AppButton.primary(
                    label: 'Agregar Periodo',
                    onPressed: () => _showAddPeriodoDialog(context, ref),
                  ),
                ),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final periodo = periodos[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: _buildPeriodoTile(context, ref, periodo),
                  ),
                );
              }, childCount: periodos.length),
            );
          },
          loading:
              () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
          error:
              (err, stack) => SliverFillRemaining(
                child: AppErrorView(
                  message: 'No se pudieron cargar los periodos.',
                  onRetry: () => ref.invalidate(periodosProvider),
                ),
              ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildPeriodoTile(
    BuildContext context,
    WidgetRef ref,
    Periodo periodo,
  ) {
    final theme = Theme.of(context);
    return ExpansionTile(
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
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: AppRadii.smAll,
        ),
        child: Icon(
          Icons.calendar_today,
          color: theme.colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
      childrenPadding: const EdgeInsets.all(AppSpacing.lg),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            tooltip: 'Editar Periodo',
            onPressed: () => _showEditPeriodoDialog(context, ref, periodo),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            tooltip: 'Eliminar Periodo',
            onPressed: () async {
              final confirm = await showAppConfirm(
                context,
                title: 'Eliminar Periodo',
                message:
                    '¿Estás seguro? Esto eliminará todas las clínicas y metas asociadas.',
                confirmLabel: 'Eliminar',
                destructive: true,
              );
              if (confirm) {
                await ref
                    .read(periodosProvider.notifier)
                    .deletePeriodo(periodo.idPeriodo!);
              }
            },
          ),
        ],
      ),
      children: [_ClinicasList(idPeriodo: periodo.idPeriodo!)],
    );
  }

  void _showAddPeriodoDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormBuilderState>();
    final periodosAsync = ref.read(periodosProvider);
    final List<Periodo> existingPeriodos = periodosAsync.asData?.value ?? [];

    showAppSheet<void>(
      context,
      title: 'Nuevo Periodo',
      builder:
          (sheetContext) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilder(
                  key: formKey,
                  child: AppTextField.singleLine(
                    name: 'nombre',
                    label: 'Nombre del Periodo',
                    maxLength: kMaxNombrePeriodo,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Requerido';
                      if (existingPeriodos.any(
                        (p) =>
                            p.nombrePeriodo.toLowerCase() == val.toLowerCase(),
                      )) {
                        return 'Este nombre ya existe';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton.text(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton.primary(
                      label: 'Guardar',
                      onPressed: () async {
                        if (formKey.currentState?.saveAndValidate() ?? false) {
                          try {
                            final nombre =
                                formKey.currentState?.value['nombre'];
                            await ref
                                .read(periodosProvider.notifier)
                                .addPeriodo(nombre);
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          } catch (e) {
                            if (sheetContext.mounted) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
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

    showAppSheet<void>(
      context,
      title: 'Editar Periodo',
      builder:
          (sheetContext) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilder(
                  key: formKey,
                  initialValue: {'nombre': periodo.nombrePeriodo},
                  child: AppTextField.singleLine(
                    name: 'nombre',
                    label: 'Nombre del Periodo',
                    maxLength: kMaxNombrePeriodo,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Requerido';
                      if (existingPeriodos.any(
                        (p) =>
                            p.nombrePeriodo.toLowerCase() ==
                                val.toLowerCase() &&
                            p.idPeriodo != periodo.idPeriodo,
                      )) {
                        return 'Este nombre ya existe';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton.text(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton.primary(
                      label: 'Guardar',
                      onPressed: () async {
                        if (formKey.currentState?.saveAndValidate() ?? false) {
                          try {
                            final nombre =
                                formKey.currentState?.value['nombre'];
                            await ref
                                .read(periodosProvider.notifier)
                                .updatePeriodo(periodo.idPeriodo!, nombre);
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          } catch (e) {
                            if (sheetContext.mounted) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
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
    final theme = Theme.of(context);

    return clinicasAsync.when(
      data: (clinicas) {
        if (clinicas.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              children: [
                Text(
                  'No hay clínicas registradas.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: AppOpacity.muted,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton.secondary(
                  icon: Icons.add,
                  label: 'Agregar Clínica',
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
          );
        }

        return Column(
          children: [
            ...clinicas.map((clinica) {
              final clinicColor = ClinicPalette.parse(clinica.color);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  padding: EdgeInsets.zero,
                  accentColor: clinicColor,
                  onTap:
                      () => _showObjetivosDialog(
                        context,
                        ref,
                        clinica.idClinica!,
                        clinica.nombreClinica,
                      ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: clinicColor.withValues(alpha: AppOpacity.subtle),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.local_hospital, color: clinicColor),
                    ),
                    title: Text(
                      clinica.nombreClinica,
                      style: AppText.cardTitle.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle:
                        (clinica.horarios != null &&
                                clinica.horarios!.isNotEmpty)
                            ? Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: AppOpacity.muted),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      clinica.horarios!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(
                                                  alpha: AppOpacity.muted,
                                                ),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : null,
                    trailing: IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: AppOpacity.muted,
                        ),
                      ),
                      onPressed:
                          () => _showClinicOptions(
                            context,
                            ref,
                            clinica,
                            clinicas,
                            idPeriodo,
                          ),
                    ),
                  ),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: AppButton.secondary(
                icon: Icons.add,
                label: 'Agregar Clínica',
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
      error:
          (e, s) => const AppErrorView(
            message: 'No se pudieron cargar las clínicas.',
            compact: true,
          ),
    );
  }

  void _showClinicOptions(
    BuildContext context,
    WidgetRef ref,
    Clinica clinica,
    List<Clinica> clinicas,
    int idPeriodo,
  ) {
    showAppSheet<void>(
      context,
      title: clinica.nombreClinica,
      builder:
          (sheetContext) => Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Selecciona una opción'),
                const SizedBox(height: AppSpacing.md),
                AppButton.secondary(
                  icon: Icons.edit,
                  label: 'Editar',
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showEditClinicaDialog(context, ref, clinica, clinicas);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton.destructive(
                  icon: Icons.delete,
                  label: 'Eliminar',
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    final confirm = await showAppConfirm(
                      context,
                      title: 'Eliminar Clínica',
                      message:
                          '¿Estás seguro? Esto eliminará todos los objetivos de esta clínica.',
                      confirmLabel: 'Eliminar',
                      destructive: true,
                    );
                    if (confirm) {
                      await ref
                          .read(clinicasByPeriodoProvider(idPeriodo).notifier)
                          .deleteClinica(clinica.idClinica!);
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showAddClinicaDialog(
    BuildContext context,
    WidgetRef ref,
    int idPeriodo,
    List<Clinica> existingClinicas,
  ) {
    final formKey = GlobalKey<FormBuilderState>();
    showAppSheet<void>(
      context,
      title: 'Nueva Clínica',
      builder:
          (sheetContext) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilder(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField.singleLine(
                        name: 'nombre',
                        label: 'Nombre Clínica',
                        maxLength: 30,
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
                      const SizedBox(height: AppSpacing.lg),
                      const ColorPickerField(
                        name: 'color',
                        initialValue: '#007AFF',
                        label: 'Color',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const WeeklySchedulePicker(
                        name: 'horarios',
                        label: 'Horarios',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton.text(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton.primary(
                      label: 'Guardar',
                      onPressed: () async {
                        if (formKey.currentState?.saveAndValidate() ?? false) {
                          final vals = formKey.currentState!.value;
                          await ref
                              .read(
                                clinicasByPeriodoProvider(idPeriodo).notifier,
                              )
                              .addClinica(
                                nombre: vals['nombre'],
                                color: vals['color'] ?? '#007AFF',
                                horarios: vals['horarios'] ?? '',
                              );
                          if (sheetContext.mounted) Navigator.pop(sheetContext);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
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
    showAppSheet<void>(
      context,
      title: 'Editar Clínica',
      builder:
          (sheetContext) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilder(
                  key: formKey,
                  initialValue: {
                    'nombre': clinica.nombreClinica,
                    'color': clinica.color,
                    'horarios': clinica.horarios,
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField.singleLine(
                        name: 'nombre',
                        label: 'Nombre Clínica',
                        maxLength: 30,
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
                      const SizedBox(height: AppSpacing.lg),
                      ColorPickerField(
                        name: 'color',
                        initialValue: clinica.color,
                        label: 'Color',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      WeeklySchedulePicker(
                        name: 'horarios',
                        initialValue: clinica.horarios,
                        label: 'Horarios',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton.text(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton.primary(
                      label: 'Guardar',
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
                                clinicasByPeriodoProvider(
                                  clinica.idPeriodo,
                                ).notifier,
                              )
                              .updateClinica(updated);
                          if (sheetContext.mounted) Navigator.pop(sheetContext);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _showObjetivosDialog(
    BuildContext context,
    WidgetRef ref,
    int idClinica,
    String nombreClinica,
  ) {
    showAppSheet<void>(
      context,
      title: 'Metas: $nombreClinica',
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 300,
            child: objetivosAsync.when(
              data: (objetivos) {
                if (objetivos.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        'No hay metas definidas. ¡Agrega una!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: objetivos.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final obj = objetivos[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        obj.nombreTratamiento,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text('Meta: ${obj.cantidadMeta}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${obj.cantidadActual} / ${obj.cantidadMeta}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed:
                                () =>
                                    _showEditObjetivoDialog(context, ref, obj),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                            onPressed:
                                () => _confirmDeleteObjetivo(
                                  context,
                                  ref,
                                  idClinica,
                                  obj,
                                ),
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
              error:
                  (e, s) => const SizedBox(
                    height: 100,
                    child: AppErrorView(
                      message: 'No se pudieron cargar los objetivos.',
                      compact: true,
                    ),
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton.text(
                label: 'Cerrar',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton.primary(
                label: 'Agregar Meta',
                onPressed: () => _showAddObjetivoDialog(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteObjetivo(
    BuildContext context,
    WidgetRef ref,
    int idClinica,
    Objetivo obj,
  ) async {
    final confirmed = await showAppConfirm(
      context,
      title: '¿Eliminar objetivo?',
      message:
          'Se eliminará "${obj.nombreTratamiento}". Los tratamientos ya '
          'registrados para este objetivo se conservarán, pero perderán el '
          'vínculo y su aporte al progreso.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await ref
          .read(objetivosByClinicaProvider(idClinica).notifier)
          .deleteObjetivo(obj.idObjetivo!);
    } catch (e) {
      if (context.mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar el objetivo: $message')),
        );
      }
    }
  }

  void _showEditObjetivoDialog(
    BuildContext context,
    WidgetRef ref,
    Objetivo objetivo,
  ) {
    final formKey = GlobalKey<FormBuilderState>();
    showAppSheet<void>(
      context,
      title: 'Editar Meta',
      builder:
          (sheetContext) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: FormBuilder(
              key: formKey,
              initialValue: {
                'nombre': objetivo.nombreTratamiento,
                'meta': objetivo.cantidadMeta.toString(),
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField.singleLine(
                    name: 'nombre',
                    label: 'Tratamiento',
                    maxLength: 30,
                    validator:
                        (val) =>
                            val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField.number(
                    name: 'meta',
                    label: 'Cantidad Meta',
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Requerido';
                      final number = int.tryParse(val);
                      if (number == null || number <= 0) return 'Válido > 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton.text(
                        label: 'Cancelar',
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppButton.primary(
                        label: 'Guardar',
                        onPressed: () async {
                          if (formKey.currentState?.saveAndValidate() ??
                              false) {
                            final vals = formKey.currentState!.value;
                            final updatedObj = objetivo.copyWith(
                              nombreTratamiento: vals['nombre'],
                              cantidadMeta: int.parse(vals['meta']),
                            );
                            await ref
                                .read(
                                  objetivosByClinicaProvider(
                                    idClinica,
                                  ).notifier,
                                )
                                .updateObjetivo(updatedObj);
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showAddObjetivoDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormBuilderState>();
    showAppSheet<void>(
      context,
      title: 'Nueva Meta',
      builder:
          (sheetContext) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: FormBuilder(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField.singleLine(
                    name: 'nombre',
                    label: 'Tratamiento',
                    maxLength: 30,
                    validator:
                        (val) =>
                            val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField.number(
                    name: 'meta',
                    label: 'Cantidad Meta',
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Requerido';
                      final number = int.tryParse(val);
                      if (number == null || number <= 0) return 'Válido > 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton.text(
                        label: 'Cancelar',
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppButton.primary(
                        label: 'Guardar',
                        onPressed: () async {
                          if (formKey.currentState?.saveAndValidate() ??
                              false) {
                            final vals = formKey.currentState!.value;
                            await ref
                                .read(
                                  objetivosByClinicaProvider(
                                    idClinica,
                                  ).notifier,
                                )
                                .addObjetivo(
                                  nombreTratamiento: vals['nombre'],
                                  cantidadMeta: int.parse(vals['meta']),
                                );
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
