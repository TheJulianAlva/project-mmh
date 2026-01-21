import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

class EditPatientScreen extends ConsumerStatefulWidget {
  final Patient patient;
  const EditPatientScreen({super.key, required this.patient});

  @override
  ConsumerState<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends ConsumerState<EditPatientScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  // List of images to keep (initially all existing).
  // We remove from here if user deletes.
  late List<String> _currentImagePaths;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentImagePaths = List.from(widget.patient.imagenesPaths);
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      try {
        final formData = _formKey.currentState!.value;

        // Note: New images are added via Detail Screen mostly,
        // but if we were to support adding here, we'd need ImageService.
        // For now, we only handle UPDATING TEXT fields and DELETING existing images
        // as per the user plan "functionality to eliminate uploaded images".
        // Adding images is explicitly requested for the Detail Screen.

        final updatedPatient = widget.patient.copyWith(
          nombre: formData['nombre'],
          primerApellido: formData['primer_apellido'],
          segundoApellido: formData['segundo_apellido'],
          edad: int.parse(formData['edad']),
          sexo: formData['sexo'],
          telefono: formData['telefono'],
          padecimientoRelevante: formData['padecimiento_relevante'],
          informacionAdicional: formData['informacion_adicional'],
          imagenesPaths: _currentImagePaths, // Use the modified list
        );

        await ref.read(patientsProvider.notifier).updatePatient(updatedPatient);

        if (mounted) {
          context.pop(); // Go back
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
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

  void _removeImage(int index) {
    setState(() {
      _currentImagePaths.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Editar Paciente'),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.9),
            trailing: TextButton(
              onPressed: _isSaving ? null : _savePatient,
              child: const Text(
                'Hecho',
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
                        initialValue: {
                          'id_expediente': widget.patient.idExpediente,
                          'nombre': widget.patient.nombre,
                          'primer_apellido': widget.patient.primerApellido,
                          'segundo_apellido': widget.patient.segundoApellido,
                          'edad': widget.patient.edad.toString(),
                          'sexo': widget.patient.sexo,
                          'telefono': widget.patient.telefono,
                          'padecimiento_relevante':
                              widget.patient.padecimientoRelevante,
                          'informacion_adicional':
                              widget.patient.informacionAdicional,
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Datos Generales'),
                            const SizedBox(height: 12),
                            FormBuilderTextField(
                              name: 'id_expediente',
                              decoration: _getInputDecoration(
                                'No. Expediente (No editable)',
                              ),
                              readOnly: true,
                              enabled: false,
                            ),
                            const SizedBox(height: 12),
                            FormBuilderTextField(
                              name: 'nombre',
                              decoration: _getInputDecoration('Nombre(s) *'),
                              maxLength: 20,
                              validator: (val) {
                                if (val == null || val.isEmpty)
                                  return 'Requerido';
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
                                      if (val == null || val.isEmpty)
                                        return 'Requerido';
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
                                        if (val == null || val.isEmpty)
                                          return 'Requerido';
                                        return null;
                                      },
                                      FormBuilderValidators.integer(
                                        errorText: 'Número entero',
                                      ),
                                      FormBuilderValidators.min(1),
                                      FormBuilderValidators.max(100),
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
                                      final initialSexo = widget.patient.sexo;
                                      final validInitial =
                                          options.contains(initialSexo)
                                              ? initialSexo
                                              : null;

                                      return FormBuilderDropdown<String>(
                                        name: 'sexo',
                                        initialValue: validInitial,
                                        decoration: _getInputDecoration(
                                          'Sexo *',
                                        ),
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
                            if (_currentImagePaths.isNotEmpty) ...[
                              _buildSectionTitle('Gestionar Imágenes'),
                              const SizedBox(height: 4),
                              Text(
                                'Toca el botón X para eliminar una imagen.',
                                style: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                itemCount: _currentImagePaths.length,
                                itemBuilder: (context, index) {
                                  final path = _currentImagePaths[index];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(
                                          File(path),
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          right: 4,
                                          top: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error
                                                    .withValues(alpha: 0.8),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onError,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
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
