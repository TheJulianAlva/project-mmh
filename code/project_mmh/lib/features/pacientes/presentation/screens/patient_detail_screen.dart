import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_mmh/core/services/image_service.dart';
import 'package:project_mmh/core/services/whatsapp_launcher.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';

class PatientDetailScreen extends ConsumerWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientByIdProvider(patientId));

    return AppScaffold(
      title: 'Paciente',
      actions: patientAsync.maybeWhen(
        data: (patient) {
          if (patient == null) return null;
          return [
            AppButton.text(
              label: 'Editar',
              onPressed:
                  () => context.push('/pacientes/${patient.idExpediente}/edit'),
            ),
          ];
        },
        orElse: () => null,
      ),
      body: patientAsync.when(
        data: (patient) {
          if (patient == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Text('Paciente no encontrado'),
              ),
            );
          }
          return _buildPatientContent(context, ref, patient);
        },
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: CircularProgressIndicator(),
              ),
            ),
        error:
            (e, s) => AppErrorView(
              message: 'No se pudo cargar el paciente.',
              onRetry: () => ref.invalidate(patientByIdProvider(patientId)),
            ),
      ),
    );
  }

  Widget _buildPatientContent(
    BuildContext context,
    WidgetRef ref,
    Patient patient,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Profile
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
                  patient.imagenesPaths.isNotEmpty
                      ? FileImage(
                        ImageService.resolveFile(patient.imagenesPaths.first),
                      )
                      : null,
              child:
                  patient.imagenesPaths.isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              patient.nombreCompleto,
              style: textTheme.headlineSmall?.copyWith(
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
                  style: textTheme.bodyMedium?.copyWith(
                    color: textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.lg),

          // Info Cards
          const AppSectionHeader('Información Personal'),
          AppCard(
            tint: scheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          ),

          const AppSectionHeader('Información Médica'),
          AppCard(
            tint: scheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          ),
          const SizedBox(height: AppSpacing.lg),

          // Actions
          AppButton.secondary(
            label: 'Ver Odontograma',
            icon: Icons.grid_view,
            onPressed: () {
              context.push('/patient-odontograma/${patient.idExpediente}');
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          if (patient.telefono != null) ...[
            AppButton.primary(
              label: 'Contactar por WhatsApp',
              icon: Icons.chat,
              onPressed: () async {
                try {
                  await launchWhatsApp(patient.telefono!);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No se pudo abrir WhatsApp.'),
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _buildImagesSection(context, ref, patient),
        ],
      ),
    );
  }

  Widget _buildImagesSection(
    BuildContext context,
    WidgetRef ref,
    Patient patient,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: AppSectionHeader('Fotografías')),
            AppButton.text(
              label: 'Agregar',
              icon: Icons.add_a_photo,
              onPressed: () => _addQuickPhoto(context, ref, patient),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
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
                    Image.file(
                      ImageService.resolveFile(path),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => ColoredBox(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                    ),
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
                                        child: Image.file(
                                          ImageService.resolveFile(path),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          // design-system-ignore: contraste sobre visor de foto a pantalla completa con fondo transparente
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
    Patient patient,
  ) async {
    final imageService = ImageService();

    // Show sheet to choose source
    final source = await showAppSheet<ImageSource>(
      context,
      title: 'Agregar fotografía',
      builder:
          (ctx) => Column(
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
          final message = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo guardar la imagen: $message')),
          );
        }
      }
    }
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
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).disabledColor,
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
                style: textTheme.bodyMedium?.copyWith(
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
