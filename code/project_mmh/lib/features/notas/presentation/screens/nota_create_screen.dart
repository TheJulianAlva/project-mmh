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

class NotaCreateScreen extends ConsumerStatefulWidget {
  const NotaCreateScreen({super.key});

  @override
  ConsumerState<NotaCreateScreen> createState() => _NotaCreateScreenState();
}

class _NotaCreateScreenState extends ConsumerState<NotaCreateScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  Future<void> _save() async {
    _formKey.currentState?.save();
    final contenido = _formKey.currentState?.value['contenido'] as String?;

    setState(() => _isSaving = true);
    try {
      await ref.read(notasProvider.notifier).addNota(
        Nota(
          tipo: NotaTipo.general,
          contenido: contenido,
          fecha: DateTime.now().toIso8601String(),
        ),
      );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Nueva Nota',
      actions: [
        AppButton.text(label: 'Guardar', loading: _isSaving, onPressed: _save),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FormBuilder(
          key: _formKey,
          child: AppTextField.multiline(
            name: 'contenido',
            label: 'Escribe tu nota',
            maxLines: 12,
            minLines: 6,
          ),
        ),
      ),
    );
  }
}
