import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
import 'package:project_mmh/core/database/data_seeder.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';

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
                  width: 150, // Fixed width to prevent overflow
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
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
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'seed') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generando datos de prueba...')),
                );
                try {
                  // Lazy import/instantiate to avoid circular deps if possible or just standard import
                  // Assuming DataSeeder is available
                  await DataSeeder().seedAll();
                  // Re-read providers to refresh UI
                  ref.invalidate(periodosProvider);
                  ref.invalidate(dashboardStatsProvider);
                  // Refresh other lists
                  ref.invalidate(patientsProvider); // Fix for missing patients
                  ref.invalidate(allTratamientosRichProvider);
                  ref.invalidate(allSesionesProvider);

                  // Verify if we need to invalidate clinics as well
                  if (selectedPeriodId != null) {
                    ref.invalidate(clinicasByPeriodoProvider(selectedPeriodId));
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Datos generados correctamente'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'seed',
                    child: Row(
                      children: [
                        Icon(Icons.science, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Generar Datos de Prueba'),
                      ],
                    ),
                  ),
                ],
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ActionButton(
                      icon: Icons.person_add,
                      label: 'Nuevo Paciente',
                      onPressed: () {
                        context.push('/pacientes/nuevo');
                      },
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.medical_services,
                      label: 'Agregar Tratamiento',
                      overflow: true,
                      onPressed: () {
                        // Navigate to Treatments -> New
                        context.push('/tratamientos/new');
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
                  width: 140,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? clinicColor
                            : Theme.of(context).cardTheme.color ??
                                Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? clinicColor
                              : Theme.of(context).dividerColor,
                      width: 2,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: clinicColor.withValues(alpha: 0.3),
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
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
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
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, overflow: overflow ? TextOverflow.ellipsis : null),
    );
  }
}
