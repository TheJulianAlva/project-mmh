import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';

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
      appBar: AppBar(
        title: const Text('Panel Principal'),
        actions: [
          periodosAsync.when(
            data: (periodos) {
              if (periodos.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  width: 140, // Fixed width to prevent overflow
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: selectedPeriodId,
                      hint: Text(
                        'Periodo',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (val) {
                        ref
                            .read(lastViewedPeriodIdProvider.notifier)
                            .setPeriod(val);
                        ref.read(activeClinicIdProvider.notifier).state = null;
                      },
                      items:
                          periodos
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p.idPeriodo,
                                  child: Text(
                                    p.nombrePeriodo,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
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
                  const Text('No hay periodos configurados.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/clinicas-metas'),
                    child: const Text('Configurar Clínicas'),
                  ),
                ],
              ),
            );
          }

          // Auto-select first period if none selected
          if (selectedPeriodId == null && periodos.isNotEmpty) {
            Future.microtask(() {
              ref
                  .read(lastViewedPeriodIdProvider.notifier)
                  .setPeriod(periodos.first.idPeriodo);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period dropdown moved to AppBar

                // Clinics Horizontal List
                const Text(
                  'Mis Clínicas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _ClinicsHorizontalList(periodId: selectedPeriodId),
                const SizedBox(height: 24),

                // Content
                if (selectedClinicId == null)
                  const Center(
                    child: Text('Selecciona una clínica para ver el progreso.'),
                  )
                else
                  const _DashboardStats(),

                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'Accesos Directos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.person_add,
                      label: 'Nuevo Paciente',
                      onPressed: () {
                        context.go('/pacientes/nuevo');
                      },
                    ),
                    _ActionButton(
                      icon: Icons.medical_services_outlined,
                      label: 'Agregar Tratamiento',
                      onPressed: () {
                        // Navigate to Treatments -> New
                        context.go('/tratamientos/new');
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
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
                    onPressed: () => context.go('/clinicas-metas'),
                    child: const Text('Agregar Clínica'),
                  ),
                ],
              ),
            ),
          );
        }

        // Auto-select first clinic if available and none selected
        if (selectedClinicId == null && clinicas.isNotEmpty) {
          // Avoid immediate state change during build
          Future.microtask(() {
            ref.read(activeClinicIdProvider.notifier).state =
                clinicas.first.idClinica;
          });
        }

        return SizedBox(
          height: 110, // Fixed height for cards
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: clinicas.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final clinica = clinicas[index];
              final isSelected = clinica.idClinica == selectedClinicId;

              // Parse color string to Color object
              Color clinicColor = Colors.teal; // Default
              if (clinica.color.startsWith('Color(')) {
                String valueString =
                    clinica.color.split('(0x')[1].split(')')[0];
                int value = int.parse(valueString, radix: 16);
                clinicColor = Color(value);
              } else if (clinica.color.startsWith('#')) {
                clinicColor = Color(
                  int.parse(clinica.color.substring(1), radix: 16) + 0xFF000000,
                );
              }

              return GestureDetector(
                onTap: () {
                  ref.read(activeClinicIdProvider.notifier).state =
                      clinica.idClinica;
                },
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: isSelected ? clinicColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? clinicColor : Colors.grey[300]!,
                      width: 2,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: clinicColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : [],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_hospital,
                        color: isSelected ? Colors.white : Colors.grey[600],
                        size: 28,
                      ),
                      const Spacer(),
                      Text(
                        clinica.nombreClinica,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progreso de Metas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                          backgroundColor: Colors.grey[200],
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.blue;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
