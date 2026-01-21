import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento_rich_model.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';

class TreatmentsScreen extends ConsumerStatefulWidget {
  final String? initialPatientId;
  const TreatmentsScreen({super.key, this.initialPatientId});

  @override
  ConsumerState<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends ConsumerState<TreatmentsScreen> {
  int? selectedClinicaId;
  int? selectedPeriodId; // Local filter, defaults to persistent
  String searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPatientId != null) {
      searchQuery = widget.initialPatientId!;
      _searchController.text = searchQuery;
    }
    // Initialize period from persistent state
    selectedPeriodId = ref.read(lastViewedPeriodIdProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pass selectedPeriodId to provider
    final tratamientosAsync = ref.watch(
      allTratamientosRichProvider(selectedPeriodId),
    );
    final clinicasAsync = ref.watch(clinicasProvider);
    final patientsAsync = ref.watch(patientsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              CupertinoSliverNavigationBar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
                largeTitle: const Text('Tratamientos'),
                trailing: TextButton(
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
                      loading: () {
                        context.push('/treatment-create');
                      },
                      error: (_, __) {
                        context.push('/treatment-create');
                      },
                    );
                  },
                  child: const Text(
                    'Añadir',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por tratamiento, paciente o ID...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    searchQuery = '';
                                  });
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                              )
                              : null,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildFilters(context, clinicasAsync, patientsAsync),
              ),
              SliverToBoxAdapter(
                child: TabBar(
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).disabledColor,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Pendientes'),
                    Tab(text: 'Concluidos'),
                  ],
                ),
              ),
            ];
          },
          body: tratamientosAsync.when(
            data: (tratamientos) {
              // Filter by clinic
              var filtered = tratamientos;
              if (selectedClinicaId != null) {
                filtered =
                    filtered
                        .where(
                          (t) => t.tratamiento.idClinica == selectedClinicaId,
                        )
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
                      .where((t) => t.tratamiento.estado != 'concluido')
                      .toList();
              final completed =
                  filtered
                      .where((t) => t.tratamiento.estado == 'concluido')
                      .toList();

              return TabBarView(
                children: [
                  _TreatmentsList(tratamientos: pending),
                  _TreatmentsList(tratamientos: completed),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    AsyncValue<List<Clinica>> clinicasAsync,
    AsyncValue<List<Patient>> patientsAsync,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'Filtrar por: ',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            // Period Filter
            FilterChip(
              label: Text(
                selectedPeriodId == null
                    ? 'Todos los Periodos'
                    : 'Periodo Actual',
              ),
              selected: selectedPeriodId != null,
              onSelected: (selected) {
                setState(() {
                  selectedPeriodId =
                      selected ? ref.read(lastViewedPeriodIdProvider) : null;
                });
              },
            ),
            const SizedBox(width: 8),
            // Clinic Filter
            clinicasAsync.when(
              data:
                  (clinicas) => FilterChip(
                    label: Text(
                      selectedClinicaId == null
                          ? 'Clínica'
                          : clinicas
                              .firstWhere(
                                (c) => c.idClinica == selectedClinicaId,
                                orElse:
                                    () => const Clinica(
                                      idClinica: -1,
                                      idPeriodo: -1,
                                      nombreClinica: 'Unknown',
                                      color: '',
                                      horarios: '',
                                    ),
                              )
                              .nombreClinica,
                    ),
                    selected: selectedClinicaId != null,
                    onSelected: (selected) {
                      if (selected) {
                        _showClinicCupertinoPicker(context, clinicas);
                      } else {
                        setState(() => selectedClinicaId = null);
                      }
                    },
                  ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  void _showClinicCupertinoPicker(
    BuildContext context,
    List<Clinica> clinicas,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              // Header with Done button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() => selectedClinicaId = null);
                        Navigator.pop(context);
                      },
                      child: const Text('Limpiar'),
                    ),
                    Text(
                      'Seleccionar Clínica',
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
              const Divider(height: 1),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 44,
                  magnification: 1.1,
                  useMagnifier: true,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedClinicaId = clinicas[index].idClinica;
                    });
                  },
                  children:
                      clinicas
                          .map(
                            (e) => Center(
                              child: Text(
                                e.nombreClinica,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TreatmentsList extends StatelessWidget {
  final List<TratamientoRichModel> tratamientos;

  const _TreatmentsList({required this.tratamientos});

  @override
  Widget build(BuildContext context) {
    if (tratamientos.isEmpty) {
      return const Center(
        child: Text('No hay tratamientos en esta categoría.'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tratamientos.length,
      itemBuilder: (context, index) {
        final item = tratamientos[index];
        return _TreatmentCard(item: item);
      },
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  final TratamientoRichModel item;

  const _TreatmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // Parse color
    Color clinicaColor;
    try {
      clinicaColor = Color(
        int.parse(item.colorClinica.replaceAll('#', '0xFF')),
      );
    } catch (_) {
      clinicaColor = Theme.of(context).colorScheme.primary;
    }

    final nextSession = item.proximaSesion;
    final dateFormat = DateFormat('EEE d MMM, HH:mm', 'es_ES');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/tratamientos/${item.tratamiento.idTratamiento}');
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: clinicaColor, width: 6)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.tratamiento.nombreTratamiento,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: ShapeDecoration(
                      color: clinicaColor.withValues(alpha: 0.1),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      item.nombreClinica,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: clinicaColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.nombrePaciente,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  if (item.tratamiento.estado == 'concluido')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: const ShapeDecoration(
                        color: Colors.green,
                        shape: StadiumBorder(),
                      ),
                      child: const Text(
                        'Completado',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Text(
                      nextSession != null
                          ? 'Próxima: ${dateFormat.format(nextSession)}'
                          : 'Sin sesiones programadas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight:
                            nextSession != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                        color:
                            nextSession != null
                                ? null
                                : Theme.of(context).disabledColor,
                      ),
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
