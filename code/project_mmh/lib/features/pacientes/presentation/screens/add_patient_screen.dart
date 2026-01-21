import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_mmh/core/services/image_service.dart';
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

      try {
        final formData = _formKey.currentState!.value;
        final String idExpediente = formData['id_expediente'];

        // 1. Save images to app storage
        List<String> savedImagePaths = [];
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
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Nuevo Paciente'),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.9),
            trailing: TextButton(
              onPressed: _isSaving ? null : _savePatient,
              child: const Text(
                'Guardar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child:
                _isSaving
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Datos Generales'),
                            const SizedBox(height: 12),
                            FormBuilderTextField(
                              name: 'id_expediente',
                              decoration: _getInputDecoration(
                                'No. Expediente *',
                              ),
                              maxLength: 15,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Requerido';
                                }
                                if (existingPatients.any(
                                  (p) => p.idExpediente == val,
                                )) {
                                  return 'El ID ya existe';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            FormBuilderTextField(
                              name: 'nombre',
                              decoration: _getInputDecoration('Nombre(s) *'),
                              maxLength: 20,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Requerido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'primer_apellido',
                                    decoration: _getInputDecoration(
                                      'Primer Apellido *',
                                    ),
                                    maxLength: 20,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Requerido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'segundo_apellido',
                                    decoration: _getInputDecoration(
                                      'Segundo Apellido',
                                    ),
                                    maxLength: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'edad',
                                    decoration: _getInputDecoration('Edad *'),
                                    keyboardType: TextInputType.number,
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
                                        1,
                                        errorText: 'Edad no válida',
                                      ),
                                      FormBuilderValidators.max(
                                        100,
                                        errorText: 'Edad no válida',
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Builder(
                                    builder: (context) {
                                      const options = [
                                        'Masculino',
                                        'Femenino',
                                        'Otro',
                                      ];
                                      return FormBuilderDropdown<String>(
                                        name: 'sexo',
                                        decoration: _getInputDecoration(
                                          'Sexo *',
                                        ),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return 'Requerido';
                                          }
                                          return null;
                                        },
                                        items:
                                            options
                                                .map(
                                                  (gender) => DropdownMenuItem(
                                                    value: gender,
                                                    child: Text(gender),
                                                  ),
                                                )
                                                .toList(),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FormBuilderTextField(
                              name: 'telefono',
                              decoration: _getInputDecoration('Teléfono'),
                              maxLength: 10,
                              keyboardType: TextInputType.phone,
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
                            const SizedBox(height: 24),
                            _buildSectionTitle('Información Médica'),
                            const SizedBox(height: 12),
                            FormBuilderTextField(
                              name: 'padecimiento_relevante',
                              decoration: _getInputDecoration(
                                'Padecimiento (Breve)',
                              ),
                              maxLength: 30,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 12),
                            FormBuilderTextField(
                              name: 'informacion_adicional',
                              decoration: _getInputDecoration(
                                'Información Detallada',
                              ),
                              maxLines: 5,
                              minLines: 3,
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Fotografías'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        () => _pickImage(ImageSource.camera),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                    ),
                                    label: const Text('Cámara'),
                                    style: OutlinedButton.styleFrom(
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        () => _pickImage(ImageSource.gallery),
                                    icon: const Icon(
                                      Icons.photo_library,
                                      size: 18,
                                    ),
                                    label: const Text('Galería'),
                                    style: OutlinedButton.styleFrom(
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
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
                                          margin: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).dividerColor,
                                            ),
                                            image: DecorationImage(
                                              image: FileImage(
                                                File(
                                                  _selectedImages[index].path,
                                                ),
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error
                                                  .withValues(alpha: 0.8),
                                              child: Icon(
                                                Icons.close,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onError,
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
          ),
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }
}
