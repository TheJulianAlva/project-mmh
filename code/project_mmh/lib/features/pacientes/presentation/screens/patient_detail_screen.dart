import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_mmh/core/services/image_service.dart';

class PatientDetailScreen extends ConsumerWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Paciente'),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.9),
            trailing: patientsAsync.when(
              data: (patientsList) {
                final patient =
                    patientsList
                        .where((p) => p.idExpediente == patientId)
                        .firstOrNull;
                if (patient == null) return null;
                return TextButton(
                  onPressed: () {
                    context.push(
                      '/pacientes/${patient.idExpediente}/edit',
                      extra: patient,
                    );
                  },
                  child: const Text(
                    'Editar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                );
              },
              loading: () => null,
              error: (_, __) => null,
            ),
            previousPageTitle: 'Atrás',
          ),
          SliverToBoxAdapter(
            child: patientsAsync.when(
              data: (patientsList) {
                final patient =
                    patientsList
                        .where((p) => p.idExpediente == patientId)
                        .firstOrNull;
                if (patient == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Paciente no encontrado'),
                    ),
                  );
                }
                return _buildPatientContent(context, ref, patient);
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientContent(
    BuildContext context,
    WidgetRef ref,
    dynamic patient,
  ) {
    return Padding(
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                          content: Text('Expediente copiado al portapapeles'),
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
          OutlinedButton.icon(
            onPressed: () {
              context.push('/patient-odontograma/${patient.idExpediente}');
            },
            icon: const Icon(Icons.grid_view),
            label: const Text('Ver Odontograma'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: const StadiumBorder(),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildImagesSection(context, ref, patient),
        ],
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
              icon: const Icon(Icons.add_a_photo, size: 18),
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
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(path), fit: BoxFit.cover),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: const EdgeInsets.all(8),
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.file(File(path)),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                ),
                          );
                        },
                      ),
                    ),
                  ],
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
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder:
          (ctx) => CupertinoActionSheet(
            title: const Text('Agregar fotografía'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(ctx, ImageSource.camera),
                child: const Text('Cámara'),
              ),
              CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
                child: const Text('Galería'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).disabledColor,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onLongPress:
                  enableCopy
                      ? () {
                        Clipboard.setData(ClipboardData(text: value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copiado al portapapeles'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      : null,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
