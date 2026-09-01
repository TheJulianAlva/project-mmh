import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class PrepacienteCreateScreen extends ConsumerStatefulWidget {
  const PrepacienteCreateScreen({super.key});

  @override
  ConsumerState<PrepacienteCreateScreen> createState() =>
      _PrepacienteCreateScreenState();
}

class _PrepacienteCreateScreenState
    extends ConsumerState<PrepacienteCreateScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final v = _formKey.currentState!.value;

    setState(() => _isSaving = true);
    try {
      await ref.read(notasProvider.notifier).addNota(
        Nota(
          tipo: NotaTipo.prepaciente,
          fecha: DateTime.now().toIso8601String(),
          nombreContacto: v['nombre_contacto'] as String,
          telefono: (v['telefono'] as String?)?.isEmpty ?? true
              ? null
              : v['telefono'] as String,
          tratamientoProbable: (v['tratamiento_probable'] as String?)?.isEmpty ?? true
              ? null
              : v['tratamiento_probable'] as String,
          contenido: (v['contenido'] as String?)?.isEmpty ?? true
              ? null
              : v['contenido'] as String,
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $message')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Nuevo Prepaciente',
      actions: [
        AppButton.text(label: 'Guardar', loading: _isSaving, onPressed: _save),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField.singleLine(
                name: 'nombre_contacto',
                label: 'Nombre *',
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField.phone(name: 'telefono', label: 'Teléfono', maxLength: 10),
              const SizedBox(height: AppSpacing.sm),
              AppTextField.singleLine(
                name: 'tratamiento_probable',
                label: 'Tratamiento probable',
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField.multiline(
                name: 'contenido',
                label: 'Observaciones',
                maxLines: 5,
                minLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
