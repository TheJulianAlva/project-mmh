import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento_rich_model.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/clinicas_metas/domain/periodo.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart'; // Implemented activeClinicIdProvider
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_entity_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_search_field.dart';
import 'package:project_mmh/core/presentation/widgets/app_selection_sheet.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_semantic_colors.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/core/presentation/widgets/app_filter_chip.dart';

class TreatmentsScreen extends ConsumerStatefulWidget {
  final String? initialPatientId;
  const TreatmentsScreen({super.key, this.initialPatientId});

  @override
  ConsumerState<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends ConsumerState<TreatmentsScreen> {
  // Local state is now managed by providers in agenda_providers.dart
  String searchQuery = '';
  int _selectedSegment = 0; // 0: Pendientes, 1: Concluidos

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPatientId != null) {
      searchQuery = widget.initialPatientId!;
      _searchController.text = searchQuery;
    }

    // Initialize period from persistent state only if not already set
    // This ensures continuity when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentPeriod = ref.read(treatmentsActivePeriodIdProvider);
      if (currentPeriod == null) {
        final lastViewed = ref.read(lastViewedPeriodIdProvider);
        if (lastViewed != null) {
          ref.read(treatmentsActivePeriodIdProvider.notifier).state =
              lastViewed;
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch Local State Providers
    final activePeriodId = ref.watch(treatmentsActivePeriodIdProvider);
    // Note: treatmentsActiveClinicIdProvider is watched inside _buildFilters or where needed
    // But we need it for filtering the list?
    // Wait, allTratamientosRichProvider only takes periodId filter in my previous implementation plan?
    // Let's check agenda_providers.dart.
    // It takes `int? filterPeriodId`.
    // It logic is: if period provided, fetch clinics for period, filter treatments by those clinics.
    // It does NOT filter by specific clinic ID currently.
    // I need to filter by specific clinic ID in the UI (memory) or update the provider.
    // The previous code passed `selectedPeriodId`.

    // Updated Logic: We need to filter by BOTH period and specific clinic.
    // Since `allTratamientosRichProvider` only accepts one arg, let's filter the result in memory here
    // or update the provider. Filtering in memory is fine for now as we have the list.

    final tratamientosAsync = ref.watch(
      allTratamientosRichProvider(activePeriodId),
    );

    // Fetch Periodos for the selector
    final periodosAsync = ref.watch(periodosProvider);

    final activeClinicId = ref.watch(treatmentsActiveClinicIdProvider);

    return AppScaffold(
      title: 'Tratamientos',
      showBack: false,
      actions: [
        AppButton.text(
          label: 'Añadir',
          onPressed: () => _handleAddPressed(context),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AppSearchField(
                    controller: _searchController,
                    hintText: 'Buscar tratamiento, paciente...',
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
                // Filters
                _buildFilters(context, periodosAsync),
                const SizedBox(height: 16),
                // Segmented Control
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    thumbColor: Theme.of(context).colorScheme.primary,
                    groupValue: _selectedSegment,
                    children: {
                      0: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: Text(
                          'Pendientes',
                          style: TextStyle(
                            color:
                                _selectedSegment == 0
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      1: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: Text(
                          'Concluidos',
                          style: TextStyle(
                            color:
                                _selectedSegment == 1
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    },
                    onValueChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSegment = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // Content
        tratamientosAsync.when(
          data: (tratamientos) {
            // Filter logic
            var filtered = tratamientos;
            // Filter by Clinic if specific clinic selected (local override)
            if (activeClinicId != null) {
              filtered =
                  filtered
                      .where((t) => t.tratamiento.idClinica == activeClinicId)
                      .toList();
            }

            if (searchQuery.isNotEmpty) {
              filtered =
                  filtered.where((t) {
                    final query = searchQuery.toLowerCase();
                    final treatmentName =
                        t.tratamiento.nombreTratamiento.toLowerCase();
                    final patientName = t.nombrePaciente.toLowerCase();
                    final fileId = t.tratamiento.idExpediente.toLowerCase();

                    return treatmentName.contains(query) ||
                        patientName.contains(query) ||
                        fileId.contains(query);
                  }).toList();
            }

            final pending =
                filtered
                    .where(
                      (t) =>
                          t.tratamiento.estado != EstadoTratamiento.concluido,
                    )
                    .toList();
            final completed =
                filtered
                    .where(
                      (t) =>
                          t.tratamiento.estado == EstadoTratamiento.concluido,
                    )
                    .toList();

            final displayList = _selectedSegment == 0 ? pending : completed;

            if (displayList.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: CupertinoIcons.doc_text_search,
                  title:
                      _selectedSegment == 0
                          ? 'No hay tratamientos pendientes'
                          : 'No hay tratamientos concluidos',
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: _TreatmentCard(item: displayList[index]),
                );
              }, childCount: displayList.length),
            );
          },
          loading:
              () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
          error:
              (e, st) => SliverFillRemaining(
                child: AppErrorView(
                  message: 'No se pudieron cargar los tratamientos.',
                  onRetry:
                      () => ref.invalidate(
                        allTratamientosRichProvider(activePeriodId),
                      ),
                ),
              ),
        ),
        // Bottom padding for scroll
        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }

  void _handleAddPressed(BuildContext context) {
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
                      onPressed: () => Navigator.pop(context),
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
  }

  Widget _buildFilters(
    BuildContext context,
    AsyncValue<List<Periodo>> periodosAsync,
  ) {
    final activePeriodId = ref.watch(treatmentsActivePeriodIdProvider);
    final activeClinicId = ref.watch(treatmentsActiveClinicIdProvider);

    // Resolve Period Name
    String periodLabel = 'Todos los Periodos';
    if (activePeriodId != null && periodosAsync.hasValue) {
      final p = periodosAsync.value!.firstWhere(
        (element) => element.idPeriodo == activePeriodId,
        orElse: () => const Periodo(nombrePeriodo: 'Periodo Actual'),
      );
      periodLabel = p.nombrePeriodo;
    } else if (activePeriodId != null) {
      periodLabel = 'Periodo Actual';
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Period Filter
          AppFilterChip(
            label: periodLabel,
            icon: CupertinoIcons.calendar,
            isActive: activePeriodId != null,
            onTap: () {
              if (periodosAsync.hasValue) {
                _showPeriodPicker(
                  context,
                  periodosAsync.value!,
                  activePeriodId,
                );
              }
            },
          ),

          // Clinic Filters (Only if period selected and has clinics)
          if (activePeriodId != null) ...[
            // Watch clinics for this period
            Builder(
              builder: (context) {
                final clinicasAsync = ref.watch(
                  clinicasByPeriodoProvider(activePeriodId),
                );
                return clinicasAsync.when(
                  data: (clinicas) {
                    if (clinicas.isEmpty) return const SizedBox.shrink();
                    return Row(
                      children: [
                        const SizedBox(width: 8),
                        ...clinicas.map((clinica) {
                          final isActive = activeClinicId == clinica.idClinica;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: AppFilterChip(
                              label: clinica.nombreClinica,
                              icon: CupertinoIcons.list_bullet,
                              isActive: isActive,
                              onTap: () {
                                final current = ref.read(
                                  treatmentsActiveClinicIdProvider,
                                );
                                if (current == clinica.idClinica) {
                                  ref
                                      .read(
                                        treatmentsActiveClinicIdProvider
                                            .notifier,
                                      )
                                      .state = null;
                                } else {
                                  ref
                                      .read(
                                        treatmentsActiveClinicIdProvider
                                            .notifier,
                                      )
                                      .state = clinica.idClinica;
                                }
                              },
                            ),
                          );
                        }),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showPeriodPicker(
    BuildContext context,
    List<Periodo> periodos,
    int? currentId,
  ) async {
    if (periodos.isEmpty) return;

    final actual = periodos.where((p) => p.idPeriodo == currentId).firstOrNull;
    final p = await showAppSelectionSheet<Periodo>(
      context,
      title: 'Periodo',
      options: periodos,
      labelOf: (p) => p.nombrePeriodo,
      selected: actual,
    );
    if (p != null && p.idPeriodo != currentId) {
      ref.read(treatmentsActivePeriodIdProvider.notifier).state = p.idPeriodo;
      // Reset local clinic filter when period changes
      ref.read(treatmentsActiveClinicIdProvider.notifier).state = null;
    }
  }
}

class _TreatmentCard extends StatelessWidget {
  final TratamientoRichModel item;

  const _TreatmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final nextSession = item.proximaSesion;
    final isCompleted = item.tratamiento.estado == EstadoTratamiento.concluido;
    final dateFormat = DateFormat('d MMM, HH:mm', 'es_ES');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppEntityCard(
      title: item.tratamiento.nombreTratamiento,
      onTap:
          () => context.push('/tratamientos/${item.tratamiento.idTratamiento}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.nombrePaciente} • ${item.nombreClinica}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: AppOpacity.muted),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                CupertinoIcons.clock,
                size: 14,
                color: colorScheme.onSurface.withValues(
                  alpha: AppOpacity.muted,
                ),
              ),
              const SizedBox(width: 6),
              if (isCompleted)
                Text(
                  'Completado',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.semantic.success,
                  ),
                )
              else
                Text(
                  nextSession != null
                      ? 'Próxima: ${dateFormat.format(nextSession)}'
                      : 'Sin sesiones próximas',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        nextSession != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(
                              alpha: AppOpacity.muted,
                            ),
                    fontWeight:
                        nextSession != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
