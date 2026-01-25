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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Periodo Actual',
                            style: Theme.of(context).textTheme.titleMedium,
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
                      const SizedBox(height: 24),

                      // Clinics Horizontal List
                      Text(
                        'Mis Clínicas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _ClinicsHorizontalList(periodId: validPeriodId),
                      const SizedBox(height: 24),

                      // Content
                      if (selectedClinicId == null)
                        const Center(
                          child: Text(
                            'Selecciona una clínica para ver el progreso.',
                          ),
                        )
                      else
                        const _DashboardStats(),

                      const SizedBox(height: 24),

                      // Quick Actions
                      Text(
                        'Accesos Directos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ActionButton(
                            icon: Icons.person_add,
                            label: 'Nuevo Paciente',
                            onPressed: () {
                              context.push('/patient-create');
                            },
                          ),
                          const SizedBox(height: 6),
                          _ActionButton(
                            icon: Icons.medical_services,
                            label: 'Agregar Tratamiento',
                            overflow: true,
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
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                    );
                                  } else {
                                    context.push('/treatment-create');
                                  }
                                },
                                loading:
                                    () => context.push('/treatment-create'),
                                error:
                                    (_, __) =>
                                        context.push('/treatment-create'),
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          _ActionButton(
                            icon:
                                Icons
                                    .psychology_rounded, // or any other suitable icon like settings_suggest or healing
                            label: 'Diagnóstico Pulpar',
                            onPressed: () {
                              context.push('/diagnosis');
                            },
                          ),
                        ],
                      ),
                      // Add extra padding at the bottom for better scrolling
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
          // Avoid immediate state change during build
          Future.microtask(() {
            ref.read(activeClinicIdProvider.notifier).state =
                clinicas.first.idClinica;
          });
        }

        return SizedBox(
          height: 160, // Fixed height for cards
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: clinicas.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final clinica = clinicas[index];
              final isSelected = clinica.idClinica == selectedClinicId;

              Color clinicColor = Colors.teal; // Default
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

class _DashboardStats extends ConsumerWidget {
  const _DashboardStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    //final statsAsync = const AsyncValue.loading(); // Forced loading for testing

    return statsAsync.when(
      data: (objetivos) {
        if (objetivos.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('No hay metas definidas para esta clínica.'),
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progreso de Metas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ...objetivos.map((obj) {
                  final progress =
                      obj.cantidadMeta > 0
                          ? (obj.cantidadActual / obj.cantidadMeta).clamp(
                            0.0,
                            1.0,
                          )
                          : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(obj.nombreTratamiento),
                            Text(
                              '${obj.cantidadActual} / ${obj.cantidadMeta}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.12),
                          color: _getProgressColor(progress),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading:
          () => Card(
            elevation: 0,
            color: Theme.of(context).cardTheme.color,
            child: Container(
              height: 250, // Approximate height of the content
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.05),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 8,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.05),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.05),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 8,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.05),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedPeriod?.nombrePeriodo ?? 'Seleccionar',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool overflow;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.overflow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, overflow: overflow ? TextOverflow.ellipsis : null),
    );
  }
}
