import 'dart:io';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_mmh/core/services/image_service.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/edit_patient_screen.dart';

class PatientDetailScreen extends ConsumerWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Paciente'),
        actions: [
          patientsAsync.when(
            data: (patients) {
              final patient =
                  patients
                      .where((p) => p.idExpediente == patientId)
                      .firstOrNull;
              if (patient == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPatientScreen(patient: patient),
                    ),
                  );
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Expediente: ${patient.idExpediente}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: Icon(
                            Icons.copy,
                            color: Theme.of(context).disabledColor,
                          ),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: patient.idExpediente),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Expediente copiado al portapapeles',
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
                      enableCopy: true,
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
                const SizedBox(height: 24),
                _buildImagesSection(context, ref, patient),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildImagesSection(
    BuildContext context,
    WidgetRef ref,
    dynamic patient,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fotografías',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _addQuickPhoto(context, ref, patient),
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (patient.imagenesPaths.isEmpty)
          Text(
            'No hay imágenes registradas.',
            style: TextStyle(color: Theme.of(context).disabledColor),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: patient.imagenesPaths.length,
            itemBuilder: (context, index) {
              final path = patient.imagenesPaths[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  image: DecorationImage(
                    image: FileImage(File(path)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(child: Image.file(File(path))),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Future<void> _addQuickPhoto(
    BuildContext context,
    WidgetRef ref,
    dynamic patient,
  ) async {
    final imageService = ImageService();

    // Show dialog to choose source
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Cámara'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galería'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
          ),
    );

    if (source == null) return;

    final XFile? image = await imageService.pickImage(source);
    if (image != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Guardando imagen...')));
      try {
        final path = await imageService.saveImage(image, patient.idExpediente);
        final currentPaths = List<String>.from(patient.imagenesPaths);
        currentPaths.add(path);

        final updatedPatient = patient.copyWith(imagenesPaths: currentPaths);
        await ref.read(patientsProvider.notifier).updatePatient(updatedPatient);

        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen agregada correctamente')),
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
                color: Theme.of(context).colorScheme.primary,
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
  final bool enableCopy;

  const _InfoRow({
    required this.label,
    required this.value,
    this.enableCopy = false,
  });

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
          if (enableCopy)
            SizedBox(
              height: 24,
              width: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 16,
                icon: Icon(Icons.copy, color: Theme.of(context).disabledColor),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"$label" copiado al portapapeles'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
