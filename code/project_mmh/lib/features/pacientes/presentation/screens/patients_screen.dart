import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Pacientes'),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.9),
            trailing: TextButton(
              onPressed: () => context.push('/patient-create'),
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
                  hintText: 'Buscar paciente',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
          patientsAsync.when(
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
                return const SliverFillRemaining(
                  child: Center(child: Text('No hay pacientes que coincidan.')),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
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
                }, childCount: filteredPatients.length),
              );
            },
            loading:
                () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (err, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error: $err')),
                ),
          ),
        ],
      ),
    );
  }
}
