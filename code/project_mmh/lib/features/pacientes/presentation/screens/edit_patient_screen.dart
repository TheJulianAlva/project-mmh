import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/constants/app_constants.dart';
import 'package:project_mmh/core/services/image_service.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

/// Carga el paciente por id (funciona con deep link / restauración, sin
/// depender de `state.extra`).
class EditPatientScreen extends ConsumerWidget {
  final String patientId;
  const EditPatientScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientByIdProvider(patientId));
    return patientAsync.when(
      data: (patient) {
        if (patient == null) {
          return const AppScaffold(
            title: 'Editar Paciente',
            body: AppErrorView(message: 'Paciente no encontrado.'),
          );
        }
        return _EditPatientForm(patient: patient);
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) => AppScaffold(
            title: 'Editar Paciente',
            body: AppErrorView(
              message: 'No se pudo cargar el paciente.',
              onRetry: () => ref.invalidate(patientByIdProvider(patientId)),
            ),
          ),
    );
  }
}

class _EditPatientForm extends ConsumerStatefulWidget {
  final Patient patient;
  const _EditPatientForm({required this.patient});

  @override
  ConsumerState<_EditPatientForm> createState() => _EditPatientFormState();
}

class _EditPatientFormState extends ConsumerState<_EditPatientForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  // List of images to keep (initially all existing).
  // We remove from here if user deletes.
  late List<String> _currentImagePaths;
  final List<String> _removedImagePaths = [];
  final ImageService _imageService = ImageService();
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
        final newId = formData['id_expediente'] as String;
        final oldId = widget.patient.idExpediente;
        final isIdChanged = newId != oldId;

        final updatedPatient = widget.patient.copyWith(
          idExpediente: newId,
          nombre: formData['nombre'],
          primerApellido: formData['primer_apellido'],
          segundoApellido: formData['segundo_apellido'],
          edad: int.parse(formData['edad']),
          sexo: formData['sexo'],
          telefono: formData['telefono'],
          padecimientoRelevante: formData['padecimiento_relevante'],
          informacionAdicional: formData['informacion_adicional'],
          imagenesPaths: _currentImagePaths,
        );

        // Borrar los archivos de las imágenes quitadas ANTES de actualizar:
        // en un cambio de id la carpeta se renombra y las rutas viejas dejan
        // de resolver.
        await _deleteRemovedImageFiles();

        if (isIdChanged) {
          await ref
              .read(patientsProvider.notifier)
              .updatePatientId(oldId, updatedPatient);

          if (mounted) {
            context.go('/pacientes/$newId');
          }
        } else {
          await ref
              .read(patientsProvider.notifier)
              .updatePatient(updatedPatient);

          if (mounted) {
            context.pop(); // Go back
          }
        }
      } catch (e) {
        if (mounted) {
          // Extract message if it's an Exception to show cleaner text
          final message = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $message')));
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

  Future<void> _deletePatient() async {
    final confirmed = await showAppConfirm(
      context,
      title: '¿Eliminar Paciente?',
      message:
          'Esta acción eliminará al paciente de la lista. '
          'Si tiene tratamientos, estos se conservarán en el historial pero el paciente no será visible. '
          'Si fue un error de registro (sin tratamientos), se borrará permanentemente.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );

    if (confirmed) {
      setState(() => _isSaving = true);
      try {
        await ref
            .read(patientsProvider.notifier)
            .deletePatient(widget.patient.idExpediente);
        if (mounted) {
          // Pop twice: 1. Edit Screen, 2. Detail Screen -> Back to List
          // Or just pop to list.
          // Since we are in Edit Screen, we pushed from Detail Screen.
          // So we need to go back to Patients List.
          context.go('/pacientes');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
          setState(() => _isSaving = false);
        }
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      // Se marca para borrado en disco; se confirma al guardar.
      _removedImagePaths.add(_currentImagePaths.removeAt(index));
    });
  }

  Future<void> _deleteRemovedImageFiles() async {
    for (final path in _removedImagePaths) {
      await _imageService.deleteImage(path);
    }
    _removedImagePaths.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Editar Paciente',
      actions: [
        AppButton.primary(
          label: 'Hecho',
          loading: _isSaving,
          onPressed: _savePatient,
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
            'padecimiento_relevante': widget.patient.padecimientoRelevante,
            'informacion_adicional': widget.patient.informacionAdicional,
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader('Datos Generales'),
              AppTextField.singleLine(
                name: 'id_expediente',
                label: 'No. Expediente (Ten cuidado al editar)',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Requerido';
                  }

                  final patientsList = ref.read(patientsProvider).value;
                  if (patientsList != null) {
                    final exists = patientsList.any(
                      (p) => p.idExpediente == val,
                    );
                    if (exists && val != widget.patient.idExpediente) {
                      return 'El expediente ya existe';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField.singleLine(
                name: 'nombre',
                label: 'Nombre(s) *',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField.singleLine(
                      name: 'primer_apellido',
                      label: 'Primer Apellido *',
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
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
                          errorText: 'Número entero',
                        ),
                        FormBuilderValidators.min(kEdadMinPaciente),
                        FormBuilderValidators.max(kEdadMaxPaciente),
                      ]),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        const options = ['Masculino', 'Femenino', 'Otro'];
                        final initialSexo = widget.patient.sexo;
                        final validInitial =
                            options.contains(initialSexo) ? initialSexo : null;

                        return FormBuilderDropdown<String>(
                          name: 'sexo',
                          initialValue: validInitial,
                          decoration: const InputDecoration(
                            labelText: 'Sexo *',
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
              const SizedBox(height: AppSpacing.md),
              AppTextField.number(name: 'telefono', label: 'Teléfono'),
              const AppSectionHeader('Información Médica'),
              AppTextField.singleLine(
                name: 'padecimiento_relevante',
                label: 'Padecimiento (Breve)',
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField.multiline(
                name: 'informacion_adicional',
                label: 'Información Detallada',
                maxLines: 5,
              ),
              if (_currentImagePaths.isNotEmpty) ...[
                const AppSectionHeader('Gestionar Imágenes'),
                Text(
                  'Toca el botón X para eliminar una imagen.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            ImageService.resolveFile(path),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const ColoredBox(
                                  color: Colors.black12,
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).colorScheme.onError,
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
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: AppButton.destructive(
                  label: 'Eliminar Paciente',
                  icon: Icons.delete_forever,
                  onPressed: _isSaving ? null : _deletePatient,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
