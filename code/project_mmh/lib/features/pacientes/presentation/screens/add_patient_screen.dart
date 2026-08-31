import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/services/image_service.dart';
import 'package:project_mmh/core/constants/app_constants.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  const AddPatientScreen({super.key});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ImageService _imageService = ImageService();

  // Locally held images before saving
  final List<XFile> _selectedImages = [];
  bool _isSaving = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _imageService.pickImage(source);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      final formData = _formKey.currentState!.value;
      final String idExpediente = formData['id_expediente'];

      // 1. Save images to app storage
      final List<String> savedImagePaths = [];
      try {
        for (var img in _selectedImages) {
          final path = await _imageService.saveImage(img, idExpediente);
          savedImagePaths.add(path);
        }

        // 2. Create Patient object
        final newPatient = Patient(
          idExpediente: idExpediente,
          nombre: formData['nombre'],
          primerApellido: formData['primer_apellido'],
          segundoApellido: formData['segundo_apellido'],
          edad: int.parse(formData['edad']), // Ensure numeric input
          sexo: formData['sexo'],
          telefono: formData['telefono'],
          padecimientoRelevante: formData['padecimiento_relevante'],
          informacionAdicional: formData['informacion_adicional'],
          imagenesPaths: savedImagePaths,
        );

        // 3. Save to DB provider
        await ref.read(patientsProvider.notifier).addPatient(newPatient);

        if (mounted) {
          context.pop(); // Go back to list
        }
      } catch (e) {
        // Rollback: eliminar del disco las imágenes ya guardadas.
        for (final path in savedImagePaths) {
          await _imageService.deleteImage(path);
        }
        if (mounted) {
          final message = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al guardar: $message')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch patients so we have the latest list for validation
    final patientsAsync = ref.watch(patientsProvider);
    final existingPatients = patientsAsync.asData?.value ?? [];

    return AppScaffold(
      title: 'Nuevo Paciente',
      actions: [
        AppButton.primary(
          label: 'Guardar',
          loading: _isSaving,
          onPressed: _savePatient,
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader('Datos Generales'),
              AppTextField.singleLine(
                name: 'id_expediente',
                label: 'No. Expediente *',
                maxLength: kMaxIdExpediente,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Requerido';
                  }
                  if (existingPatients.any((p) => p.idExpediente == val)) {
                    return 'El ID ya existe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField.singleLine(
                name: 'nombre',
                label: 'Nombre(s) *',
                maxLength: kMaxNombrePaciente,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextField.singleLine(
                      name: 'primer_apellido',
                      label: 'Primer Apellido *',
                      maxLength: kMaxNombrePaciente,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField.singleLine(
                      name: 'segundo_apellido',
                      label: 'Segundo Apellido',
                      maxLength: kMaxNombrePaciente,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextField.number(
                      name: 'edad',
                      label: 'Edad *',
                      validator: FormBuilderValidators.compose([
                        (val) {
                          if (val == null || val.isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                        FormBuilderValidators.integer(
                          errorText: 'Debe ser un número entero',
                        ),
                        FormBuilderValidators.min(
                          kEdadMinPaciente,
                          errorText: 'Edad no válida',
                        ),
                        FormBuilderValidators.max(
                          kEdadMaxPaciente,
                          errorText: 'Edad no válida',
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FormBuilderDropdown<String>(
                      name: 'sexo',
                      decoration: const InputDecoration(labelText: 'Sexo *'),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                      items:
                          const ['Masculino', 'Femenino', 'Otro']
                              .map(
                                (gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField.phone(
                name: 'telefono',
                label: 'Teléfono',
                maxLength: 10,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.match(
                    RegExp(r'^\d*$'),
                    errorText: 'Solo números permitidos',
                  ),
                  FormBuilderValidators.maxLength(
                    10,
                    errorText: 'Máximo 10 dígitos',
                  ),
                ]),
              ),
              const AppSectionHeader('Información Médica'),
              AppTextField.singleLine(
                name: 'padecimiento_relevante',
                label: 'Padecimiento (Breve)',
                maxLength: 30,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField.multiline(
                name: 'informacion_adicional',
                label: 'Información Detallada',
                maxLines: 5,
                minLines: 3,
              ),
              const AppSectionHeader('Fotografías'),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Cámara',
                      icon: Icons.camera_alt,
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Galería',
                      icon: Icons.photo_library,
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                              image: DecorationImage(
                                image: FileImage(
                                  File(_selectedImages[index].path),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.error.withValues(alpha: 0.8),
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).colorScheme.onError,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
