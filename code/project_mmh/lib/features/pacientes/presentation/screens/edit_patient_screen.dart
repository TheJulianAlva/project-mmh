import 'dart:io';

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
      appBar: AppBar(
        title: const Text('Editar Paciente'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _savePatient,
          ),
        ],
      ),
      body:
          _isSaving
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                      const Text(
                        'Datos Generales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // ID Expediente is Read Only usually for consistency,
                      // or we can allow edit if it's not the PK in DB (it looks like it is).
                      // Repository uses it for update `where: id_expediente = ?`.
                      // So we CANNOT edit ID Expediente here effectively unless we handle primary key change (delete + insert).
                      // Better to leave it read-only or disabled.
                      FormBuilderTextField(
                        name: 'id_expediente',
                        decoration: const InputDecoration(
                          labelText: 'No. Expediente (No editable)',
                        ),
                        readOnly: true,
                        enabled: false,
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        name: 'nombre',
                        decoration: const InputDecoration(
                          labelText: 'Nombre(s) *',
                        ),
                        maxLength: 20,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Requerido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'primer_apellido',
                              decoration: const InputDecoration(
                                labelText: 'Primer Apellido *',
                              ),
                              maxLength: 20,
                              validator: (val) {
                                if (val == null || val.isEmpty)
                                  return 'Requerido';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'segundo_apellido',
                              decoration: const InputDecoration(
                                labelText: 'Segundo Apellido',
                              ),
                              maxLength: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'edad',
                              decoration: const InputDecoration(
                                labelText: 'Edad *',
                              ),
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: FormBuilderDropdown<String>(
                              name: 'sexo',
                              decoration: const InputDecoration(
                                labelText: 'Sexo *',
                              ),
                              items:
                                  ['Masculino', 'Femenino', 'Otro']
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
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        name: 'telefono',
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                        ),
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Información Médica',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        name: 'padecimiento_relevante',
                        decoration: const InputDecoration(
                          labelText: 'Padecimiento Relevante (Breve)',
                        ),
                        maxLength: 30,
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        name: 'informacion_adicional',
                        decoration: const InputDecoration(
                          labelText: 'Información Adicional (Detallada)',
                        ),
                        maxLines: 5,
                        minLines: 3,
                      ),

                      const SizedBox(height: 20),
                      if (_currentImagePaths.isNotEmpty) ...[
                        const Text(
                          'Gestionar Imágenes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca el botón X para eliminar una imagen.',
                          style: TextStyle(
                            color: Theme.of(context).disabledColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(File(path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 5,
                                  top: 5,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
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
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}
