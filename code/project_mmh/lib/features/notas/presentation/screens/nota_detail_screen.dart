import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class NotaDetailScreen extends ConsumerStatefulWidget {
  const NotaDetailScreen({super.key, required this.notaId});

  final int notaId;

  @override
  ConsumerState<NotaDetailScreen> createState() => _NotaDetailScreenState();
}

class _NotaDetailScreenState extends ConsumerState<NotaDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  Future<void> _save() async {
    final nota = ref.read(notaByIdProvider(widget.notaId)).asData?.value;
    if (nota == null) return;

    setState(() => _isSaving = true);
    try {
      final contenido = _formKey.currentState?.value['contenido'] as String?;
      await ref
          .read(notasProvider.notifier)
          .updateNota(nota.copyWith(contenido: contenido));
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showAppConfirm(
      context,
      title: 'Eliminar nota',
      message: 'Esta acción no se puede deshacer.',
      destructive: true,
      confirmLabel: 'Eliminar',
    );
    if (!confirmed) return;
    await ref.read(notasProvider.notifier).deleteNota(widget.notaId);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final notaAsync = ref.watch(notaByIdProvider(widget.notaId));

    return notaAsync.when(
      data: (nota) {
        if (nota == null) {
          return const AppScaffold(
            title: 'Nota',
            body: Center(child: Text('Nota no encontrada.')),
          );
        }
        return AppScaffold(
          title: 'Nota',
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
            AppButton.text(
              label: 'Guardar',
              loading: _isSaving,
              onPressed: _save,
            ),
          ],
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: FormBuilder(
              key: _formKey,
              child: AppTextField.multiline(
                name: 'contenido',
                label: 'Contenido',
                initialValue: nota.contenido,
                maxLines: 12,
                minLines: 6,
              ),
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Nota',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => AppScaffold(
        title: 'Nota',
        body: AppErrorView(
          message: 'No se pudo cargar la nota.',
          onRetry: () => ref.invalidate(notaByIdProvider(widget.notaId)),
        ),
      ),
    );
  }
}
