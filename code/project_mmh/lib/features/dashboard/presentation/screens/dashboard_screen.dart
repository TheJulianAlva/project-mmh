import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Inicio'),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.9),
          ),
          periodosAsync.when(
            data: (periodos) {
              if (periodos.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No hay periodos configurados.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => context.go('/settings/clinicas-metas'),
                          child: const Text('Configurar Clínicas'),
                        ),
                      ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Period Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Periodo Actual',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                      const SizedBox(height: 28),

                      // Clinics Section
                      Text(
                        'Mis Clínicas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      _ClinicsHorizontalList(periodId: validPeriodId),
                      const SizedBox(height: 32),

                      // Stats Content
                      if (selectedClinicId == null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Selecciona una clínica para ver el progreso.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                        )
                      else
                        const _DashboardStats(),

                      const SizedBox(height: 32),

                      // Quick Actions
                      Text(
                        'Accesos Directos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      _ActionTile(
                        icon: CupertinoIcons.person_add,
                        label: 'Nuevo Paciente',
                        subtitle: 'Registrar paciente',
                        onPressed: () {
                          context.push('/patient-create');
                        },
                      ),
                      const SizedBox(height: 10),
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
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('OK'),
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
                      const SizedBox(height: 10),
                      _ActionTile(
                        icon: Icons.psychology_rounded,
                        label: 'Diagnóstico Pulpar',
                        subtitle: 'Asistente de diagnóstico',
                        onPressed: () {
                          context.push('/diagnosis');
                        },
                      ),
                      // Extra padding at the bottom for better scrolling
                      const SizedBox(height: 48),
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
                  child: Center(child: Text('Error: $e')),
                ),
          ),
        ],
      ),
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
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Selecciona un periodo')),
      );
    }

    final clinicasAsync = ref.watch(clinicasByPeriodoProvider(periodId!));
    final selectedClinicId = ref.watch(activeClinicIdProvider);

    return clinicasAsync.when(
      data: (clinicas) {
        if (clinicas.isEmpty) {
          return SizedBox(
            height: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay clínicas en este periodo'),
                  TextButton(
                    onPressed: () => context.go('/settings/clinicas-metas'),
                    child: const Text('Agregar Clínica'),
                  ),
                ],
              ),
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
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final clinica = clinicas[index];
              final isSelected = clinica.idClinica == selectedClinicId;

              Color clinicColor = Colors.teal;
              try {
                String colorStr = clinica.color;
                if (colorStr.startsWith('Color(')) {
                  String value = colorStr.split('(')[1].split(')')[0];
                  clinicColor = Color(int.parse(value));
                } else {
                  String cleanHex = colorStr
                      .replaceAll('#', '')
                      .replaceAll('0x', '')
                      .replaceAll('0X', '');
                  if (cleanHex.length == 6) {
                    clinicColor = Color(
                      int.parse(cleanHex, radix: 16) + 0xFF000000,
                    );
                  } else if (cleanHex.length == 8) {
                    clinicColor = Color(int.parse(cleanHex, radix: 16));
                  } else {
                    clinicColor = Color(
                      int.parse(cleanHex, radix: 16) + 0xFF000000,
                    );
                  }
                }
              } catch (_) {
                clinicColor = Colors.teal;
              }

              return GestureDetector(
                onTap: () {
                  ref.read(activeClinicIdProvider.notifier).state =
                      clinica.idClinica;
                },
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? clinicColor
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected
                              ? clinicColor
                              : Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_hospital,
                        color:
                            isSelected
                                ? Colors.white
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 28,
                      ),
                      const Spacer(),
                      Text(
                        clinica.nombreClinica,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isSelected ? Colors.white : null,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
          (e, s) => const SizedBox(
            height: 100,
            child: Center(child: Text('Error al cargar clínicas')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return statsAsync.when(
      data: (objetivos) {
        if (objetivos.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
              ),
            ),
            child: Center(
              child: Text(
                'No hay metas definidas para esta clínica.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      CupertinoIcons.chart_bar_alt_fill,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Progreso de Metas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...objetivos.map((obj) {
                final progress =
                    obj.cantidadMeta > 0
                        ? (obj.cantidadActual / obj.cantidadMeta).clamp(
                          0.0,
                          1.0,
                        )
                        : 0.0;
                final progressColor = _getProgressColor(progress);
                final isComplete = progress >= 1.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
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
                          const SizedBox(width: 8),
                          if (isComplete)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Colors.green,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${obj.cantidadActual}/${obj.cantidadMeta}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text(
                              '${obj.cantidadActual} / ${obj.cantidadMeta}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
          () => Card(
            elevation: 0,
            color: Theme.of(context).cardTheme.color,
            child: Container(
              height: 250,
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      error: (e, s) => Text('Error: $e'),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.blue;
  }
}

// ─── Gradient Progress Bar ─────────────────────────────────────────────────────

class _GradientProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _GradientProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(6),
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
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.7), color],
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

void _showPeriodPicker(
  BuildContext context,
  WidgetRef ref,
  List<Periodo> periodos,
  int? currentId,
) {
  int initialIndex = periodos.indexWhere((p) => p.idPeriodo == currentId);
  if (initialIndex == -1) initialIndex = 0;

  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder:
        (context) => Container(
          height: 320,
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Text(
                      'Periodo Académico',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Listo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  itemExtent: 44,
                  magnification: 1.1,
                  useMagnifier: true,
                  onSelectedItemChanged: (index) {
                    ref
                        .read(lastViewedPeriodIdProvider.notifier)
                        .setPeriod(periodos[index].idPeriodo);
                    ref.read(activeClinicIdProvider.notifier).state = null;
                  },
                  children:
                      periodos
                          .map(
                            (p) => Center(
                              child: Text(
                                p.nombrePeriodo,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
  );
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
    //final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.calendar, color: colorScheme.primary, size: 16),
            const SizedBox(width: 8),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
