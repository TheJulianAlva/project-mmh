import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

class PatientDetailScreen extends ConsumerWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Paciente')),
      body: patientsAsync.when(
        data: (patients) {
          final patient =
              patients.where((p) => p.idExpediente == patientId).firstOrNull;

          if (patient == null) {
            return const Center(child: Text('Paciente no encontrado'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Profile
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        patient.imagenesPaths.isNotEmpty
                            ? FileImage(File(patient.imagenesPaths.first))
                            : null,
                    child:
                        patient.imagenesPaths.isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${patient.nombre} ${patient.primerApellido} ${patient.segundoApellido ?? ''}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Text(
                    'Expediente: ${patient.idExpediente}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Info Cards
                _InfoCard(
                  title: 'Información Personal',
                  children: [
                    _InfoRow(label: 'Edad', value: '${patient.edad} años'),
                    _InfoRow(label: 'Sexo', value: patient.sexo),
                    _InfoRow(
                      label: 'Teléfono',
                      value: patient.telefono ?? 'No registrado',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _InfoCard(
                  title: 'Información Médica',
                  children: [
                    _InfoRow(
                      label: 'Padecimiento',
                      value: patient.padecimientoRelevante ?? 'Ninguno',
                    ),
                    _InfoRow(
                      label: 'Info Adicional',
                      value: patient.informacionAdicional ?? 'N/A',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      '/pacientes/${patient.idExpediente}/odontograma',
                    );
                  },
                  icon: const Icon(Icons.grid_view),
                  label: const Text('Ver Odontograma'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to treatments with query param
                    context.go(
                      '/tratamientos?patientId=${patient.idExpediente}',
                    );
                  },
                  icon: const Icon(Icons.medical_services_outlined),
                  label: const Text('Ver Tratamientos'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
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

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
