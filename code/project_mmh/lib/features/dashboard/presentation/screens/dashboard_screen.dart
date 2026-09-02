import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_selection_sheet.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_semantic_colors.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';
import 'package:project_mmh/core/theme/clinic_palette.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/clinicas_metas/domain/periodo.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to data
    final periodosAsync = ref.watch(periodosProvider);
    final selectedPeriodId = ref.watch(
      lastViewedPeriodIdProvider,
    ); // Persistent
    final selectedClinicId = ref.watch(activeClinicIdProvider); // Global
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Inicio',
      showBack: false,
      slivers: [
        periodosAsync.when(
          data: (periodos) {
            if (periodos.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: CupertinoIcons.calendar,
                  title: 'No hay periodos configurados.',
                  action: AppButton.primary(
                    label: 'Configurar Clínicas',
                    onPressed: () => context.go('/settings/clinicas-metas'),
                  ),
                ),
              );
            }

            // Validate if selectedPeriodId exists in the list
            int? validPeriodId = selectedPeriodId;
            if (validPeriodId != null &&
                !periodos.any((p) => p.idPeriodo == validPeriodId)) {
              validPeriodId = null;
            }

            // Auto-select first period if none selected or invalid
            if (validPeriodId == null && periodos.isNotEmpty) {
              Future.microtask(() {
                ref
                    .read(lastViewedPeriodIdProvider.notifier)
                    .setPeriod(periodos.first.idPeriodo);
              });
            }

            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),

                    // Period Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Periodo Actual',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(
                              alpha: AppOpacity.strong,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        _PeriodSelectorTrigger(
                          periodos: periodos,
                          selectedPeriodId: validPeriodId,
                          onTap:
                              () => _showPeriodPicker(
                                context,
                                ref,
                                periodos,
                                validPeriodId,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Clinics Section
                    Text(
                      'Mis Clínicas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ClinicsHorizontalList(periodId: validPeriodId),
                    const SizedBox(height: AppSpacing.xxl),

                    // Stats Content
                    if (selectedClinicId == null)
                      const AppEmptyState(
                        icon: CupertinoIcons.chart_bar_alt_fill,
                        title: 'Selecciona una clínica para ver el progreso.',
                      )
                    else
                      const _DashboardStats(),

                    const SizedBox(height: AppSpacing.xxl),

                    // Quick Actions
                    Text(
                      'Accesos Directos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ActionTile(
                      icon: CupertinoIcons.person_add,
                      label: 'Nuevo Paciente',
                      subtitle: 'Registrar paciente',
                      onPressed: () {
                        context.push('/patient-create');
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ActionTile(
                      icon: CupertinoIcons.heart_fill,
                      label: 'Agregar Tratamiento',
                      subtitle: 'Nuevo tratamiento',
                      onPressed: () {
                        final clinicasState = ref.read(clinicasProvider);

                        clinicasState.when(
                          data: (clinicas) {
                            if (clinicas.isEmpty) {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Sin Clínicas'),
                                      content: const Text(
                                        'No se pueden crear tratamientos sin clínicas registradas. Por favor, registre una clínica primero en Configuración.',
                                      ),
                                      actions: [
                                        AppButton.text(
                                          label: 'OK',
                                          onPressed:
                                              () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                              );
                            } else {
                              context.push('/treatment-create');
                            }
                          },
                          loading: () => context.push('/treatment-create'),
                          error: (_, __) => context.push('/treatment-create'),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ActionTile(
                      icon: Icons.psychology_rounded,
                      label: 'Diagnóstico Pulpar',
                      subtitle: 'Asistente de diagnóstico',
                      onPressed: () {
                        context.push('/diagnosis');
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ActionTile(
                      icon: CupertinoIcons.pencil_outline,
                      label: 'Nota Rápida',
                      subtitle: 'Capturar una nota en segundos',
                      onPressed: () {
                        context.push('/notas/nueva');
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ActionTile(
                      icon: CupertinoIcons.folder,
                      label: 'Notas y Listas',
                      subtitle: 'Prepacientes, materiales y cotizaciones',
                      onPressed: () {
                        context.push('/notas');
                      },
                    ),
                    // Extra padding at the bottom for better scrolling
                    const SizedBox(height: AppSpacing.xxl + AppSpacing.lg),
                  ],
                ),
              ),
            );
          },
          loading:
              () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
          error:
              (e, s) => SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorView(
                  message: 'No se pudieron cargar los periodos.',
                  onRetry: () => ref.invalidate(periodosProvider),
                ),
              ),
        ),
      ],
    );
  }
}

// ─── Clinics Horizontal List ───────────────────────────────────────────────────

class _ClinicsHorizontalList extends ConsumerWidget {
  final int? periodId;
  const _ClinicsHorizontalList({required this.periodId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (periodId == null) {
      return const AppEmptyState(
        icon: CupertinoIcons.calendar,
        title: 'Selecciona un periodo',
      );
    }

    final clinicasAsync = ref.watch(clinicasByPeriodoProvider(periodId!));
    final selectedClinicId = ref.watch(activeClinicIdProvider);
    final scheme = Theme.of(context).colorScheme;

    return clinicasAsync.when(
      data: (clinicas) {
        if (clinicas.isEmpty) {
          return AppEmptyState(
            icon: CupertinoIcons.building_2_fill,
            title: 'No hay clínicas en este periodo',
            action: AppButton.text(
              label: 'Agregar Clínica',
              onPressed: () => context.go('/settings/clinicas-metas'),
            ),
          );
        }

        // Check if selected clinic still exists
        final isSelectedValid =
            selectedClinicId != null &&
            clinicas.any((c) => c.idClinica == selectedClinicId);

        // Auto-select first clinic if available and (none selected OR selected is invalid)
        if (!isSelectedValid && clinicas.isNotEmpty) {
          Future.microtask(() {
            ref.read(activeClinicIdProvider.notifier).state =
                clinicas.first.idClinica;
          });
        }

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: clinicas.length,
            separatorBuilder:
                (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final clinica = clinicas[index];
              final isSelected = clinica.idClinica == selectedClinicId;

              final clinicColor = ClinicPalette.parse(clinica.color);

              return SizedBox(
                width: 180,
                child: AppCard(
                  padding: EdgeInsets.zero,
                  onTap: () {
                    ref.read(activeClinicIdProvider.notifier).state =
                        clinica.idClinica;
                  },
                  child: Container(
                    color: isSelected ? clinicColor : null,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_hospital,
                          color:
                              isSelected
                                  ? scheme.onPrimary
                                  : scheme.onSurface.withValues(
                                    alpha: AppOpacity.strong,
                                  ),
                          size: 28,
                        ),
                        const Spacer(),
                        Text(
                          clinica.nombreClinica,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: isSelected ? scheme.onPrimary : null,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading:
          () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, s) => SizedBox(
            height: 120,
            child: AppErrorView(
              message: 'No se pudieron cargar las clínicas.',
              compact: true,
              onRetry:
                  () => ref.invalidate(clinicasByPeriodoProvider(periodId!)),
            ),
          ),
    );
  }
}

// ─── Dashboard Stats (Progress Bars) ───────────────────────────────────────────

class _DashboardStats extends ConsumerWidget {
  const _DashboardStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return statsAsync.when(
      data: (objetivos) {
        if (objetivos.isEmpty) {
          return const AppEmptyState(
            icon: CupertinoIcons.chart_bar_alt_fill,
            title: 'No hay metas definidas para esta clínica.',
          );
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(
                        alpha: AppOpacity.subtle,
                      ),
                      borderRadius: AppRadii.smAll,
                    ),
                    child: Icon(
                      CupertinoIcons.chart_bar_alt_fill,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Progreso de Metas',
                    style: AppText.cardTitle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ...objetivos.map((obj) {
                final progress =
                    obj.cantidadMeta > 0
                        ? (obj.cantidadActual / obj.cantidadMeta).clamp(
                          0.0,
                          1.0,
                        )
                        : 0.0;
                final progressColor = _getProgressColor(context, progress);
                final isComplete = progress >= 1.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              obj.nombreTratamiento,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          if (isComplete)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.semantic.success.withValues(
                                  alpha: AppOpacity.subtle,
                                ),
                                borderRadius: AppRadii.smAll,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: context.semantic.success,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${obj.cantidadActual}/${obj.cantidadMeta}',
                                    style: AppText.caption.copyWith(
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                      fontWeight: FontWeight.w700,
                                      color: context.semantic.success,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text(
                              '${obj.cantidadActual} / ${obj.cantidadMeta}',
                              style: AppText.caption.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface.withValues(
                                  alpha: AppOpacity.strong,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _GradientProgressBar(
                        progress: progress,
                        color: progressColor,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading:
          () => AppCard(
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(
                        alpha: AppOpacity.hairline,
                      ),
                      borderRadius: AppRadii.smAll,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(
                              alpha: AppOpacity.hairline,
                            ),
                            borderRadius: AppRadii.smAll,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(
                              alpha: AppOpacity.hairline,
                            ),
                            borderRadius: AppRadii.smAll,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(
                              alpha: AppOpacity.hairline,
                            ),
                            borderRadius: AppRadii.smAll,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(
                              alpha: AppOpacity.hairline,
                            ),
                            borderRadius: AppRadii.smAll,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      error:
          (e, s) => AppErrorView(
            message: 'No se pudieron cargar las estadísticas.',
            compact: true,
            onRetry: () => ref.invalidate(dashboardStatsProvider),
          ),
    );
  }

  Color _getProgressColor(BuildContext context, double progress) {
    final s = context.semantic;
    if (progress >= 1.0) return s.success;
    if (progress >= 0.5) return s.warning;
    return s.info;
  }
}

// ─── Gradient Progress Bar ─────────────────────────────────────────────────────

class _GradientProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _GradientProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: scheme.onSurface.withValues(alpha: AppOpacity.hairline),
            borderRadius: AppRadii.smAll,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Container(
                  width: constraints.maxWidth * value,
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.smAll,
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: AppOpacity.strong),
                        color,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ─── Period Picker ──────────────────────────────────────────────────────────────

Future<void> _showPeriodPicker(
  BuildContext context,
  WidgetRef ref,
  List<Periodo> periodos,
  int? currentId,
) async {
  if (periodos.isEmpty) return;

  final actual = periodos.where((p) => p.idPeriodo == currentId).firstOrNull;
  final p = await showAppSelectionSheet<Periodo>(
    context,
    title: 'Periodo Académico',
    options: periodos,
    labelOf: (p) => p.nombrePeriodo,
    selected: actual,
  );
  if (p != null && p.idPeriodo != currentId) {
    ref.read(lastViewedPeriodIdProvider.notifier).setPeriod(p.idPeriodo);
    ref.read(activeClinicIdProvider.notifier).state = null;
  }
}

// ─── Period Selector Trigger ────────────────────────────────────────────────────

class _PeriodSelectorTrigger extends StatelessWidget {
  final List<Periodo> periodos;
  final int? selectedPeriodId;
  final VoidCallback onTap;

  const _PeriodSelectorTrigger({
    required this.periodos,
    this.selectedPeriodId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Periodo? selectedPeriod;

    if (periodos.isNotEmpty) {
      try {
        selectedPeriod = periodos.firstWhere(
          (p) => p.idPeriodo == selectedPeriodId,
        );
      } catch (_) {
        selectedPeriod = periodos.first;
      }
    }

    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.pillAll,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: AppOpacity.hairline),
          borderRadius: AppRadii.pillAll,
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: AppOpacity.subtle),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.calendar, color: colorScheme.primary, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Text(
              selectedPeriod?.nombrePeriodo ?? 'Seleccionar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              CupertinoIcons.chevron_down,
              color: colorScheme.primary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action Tile (premium list-style buttons) ──────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onPressed;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onPressed,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: AppOpacity.subtle),
              borderRadius: AppRadii.smAll,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: AppOpacity.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            color: colorScheme.onSurface.withValues(alpha: AppOpacity.muted),
            size: 16,
          ),
        ],
      ),
    );
  }
}
