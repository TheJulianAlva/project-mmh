import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento_rich_model.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/agenda/presentation/screens/treatment_detail_screen.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';

import 'package:project_mmh/features/agenda/presentation/widgets/appointment_form.dart';

class TreatmentsScreen extends ConsumerStatefulWidget {
  final String? initialPatientId;
  const TreatmentsScreen({super.key, this.initialPatientId});

  @override
  ConsumerState<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends ConsumerState<TreatmentsScreen> {
  int? selectedClinicaId;
  String? selectedPatientId;
  int? selectedPeriodId; // Local filter, defaults to persistent

  @override
  void initState() {
    super.initState();
    if (widget.initialPatientId != null) {
      selectedPatientId = widget.initialPatientId;
    }
    // Initialize period from persistent state
    selectedPeriodId = ref.read(lastViewedPeriodIdProvider);
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
        appBar: AppBar(
          title: const Text('Tratamientos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(allTratamientosRichProvider),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Pendientes'), Tab(text: 'Concluidos')],
          ),
        ),
        body: Column(
          children: [
            _buildFilters(context, clinicasAsync, patientsAsync),
            Expanded(
              child: tratamientosAsync.when(
                data: (tratamientos) {
                  // Filter by clinic/patient
                  var filtered = tratamientos;
                  if (selectedClinicaId != null) {
                    filtered =
                        filtered
                            .where(
                              (t) =>
                                  t.tratamiento.idClinica == selectedClinicaId,
                            )
                            .toList();
                  }
                  if (selectedPatientId != null) {
                    filtered =
                        filtered
                            .where(
                              (t) =>
                                  t.tratamiento.idExpediente ==
                                  selectedPatientId,
                            )
                            .toList();
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppointmentForm(initialDate: DateTime.now()),
              ),
            );
          },
          child: const Icon(Icons.add),
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
            const Text(
              'Filtrar por: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            // Period Filter
            FilterChip(
              label: Text(
                selectedPeriodId == null
                    ? 'Todos los Periodos'
                    : 'Periodo Actual', // Simplification: we could fetch period name if needed
              ),
              selected: selectedPeriodId != null,
              onSelected: (selected) {
                // Toggle: if selected and was already selected (logic handled by chip usually),
                // here we just want to allow clearing it.
                // But wait, the requirement says "default to last viewed".
                // Let's allow user to clear it to see EVERYTHING.
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
                        _showClinicSelectionDialog(context, clinicas);
                      } else {
                        setState(() => selectedClinicaId = null);
                      }
                    },
                  ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(width: 8),
            // Patient Filter
            patientsAsync.when(
              data:
                  (patients) => FilterChip(
                    label: Text(
                      selectedPatientId == null
                          ? 'Paciente'
                          : (patients
                                  .where(
                                    (p) => p.idExpediente == selectedPatientId,
                                  )
                                  .firstOrNull
                                  ?.nombre ??
                              'Desconocido'),
                    ),
                    selected: selectedPatientId != null,
                    onSelected: (selected) {
                      if (selected) {
                        _showPatientSelectionDialog(context, patients);
                      } else {
                        setState(() => selectedPatientId = null);
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

  void _showClinicSelectionDialog(
    BuildContext context,
    List<Clinica> clinicas,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => SimpleDialog(
            title: const Text('Seleccionar Clínica'),
            children:
                clinicas
                    .map(
                      (c) => SimpleDialogOption(
                        child: Text(c.nombreClinica),
                        onPressed: () {
                          setState(() => selectedClinicaId = c.idClinica);
                          Navigator.pop(ctx);
                        },
                      ),
                    )
                    .toList(),
          ),
    );
  }

  void _showPatientSelectionDialog(
    BuildContext context,
    List<Patient> patients,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Seleccionar Paciente'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final p = patients[index];
                  return ListTile(
                    title: Text('${p.nombre} ${p.primerApellido}'),
                    subtitle: Text(p.idExpediente),
                    onTap: () {
                      setState(() => selectedPatientId = p.idExpediente);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ),
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
      clinicaColor = Colors.blue;
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => TreatmentDetailScreen(
                    tratamientoId: item.tratamiento.idTratamiento!,
                  ),
            ),
          );
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.tratamiento.nombreTratamiento,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: clinicaColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.nombreClinica,
                      style: TextStyle(
                        fontSize: 12,
                        color: clinicaColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.nombrePaciente,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  if (item.tratamiento.estado == 'concluido')
                    const Text(
                      'Completado',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  else
                    Text(
                      nextSession != null
                          ? 'Próxima: ${dateFormat.format(nextSession)}'
                          : 'Sin sesiones programadas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            nextSession != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                        color:
                            nextSession != null ? Colors.black87 : Colors.grey,
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
