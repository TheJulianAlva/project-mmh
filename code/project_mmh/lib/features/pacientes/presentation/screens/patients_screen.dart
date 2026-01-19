import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar paciente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: patientsAsync.when(
              data: (patients) {
                final filteredPatients =
                    patients.where((patient) {
                      final fullName =
                          '${patient.nombre} ${patient.primerApellido} ${patient.segundoApellido ?? ''}'
                              .toLowerCase();
                      return fullName.contains(_searchQuery) ||
                          patient.idExpediente.toLowerCase().contains(
                            _searchQuery,
                          );
                    }).toList();

                if (filteredPatients.isEmpty) {
                  return const Center(
                    child: Text('No hay pacientes que coincidan.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            patient.imagenesPaths.isNotEmpty
                                ? FileImage(File(patient.imagenesPaths.first))
                                : null,
                        child:
                            patient.imagenesPaths.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                      ),
                      title: Text(
                        '${patient.nombre} ${patient.primerApellido} ${patient.segundoApellido ?? ''}',
                      ),
                      subtitle: Text('Exp: ${patient.idExpediente}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [const Icon(Icons.chevron_right)],
                      ),
                      onTap: () {
                        context.push('/pacientes/${patient.idExpediente}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/pacientes/nuevo');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
