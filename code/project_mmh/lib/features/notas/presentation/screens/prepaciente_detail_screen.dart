import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/services/whatsapp_launcher.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class PrepacienteDetailScreen extends ConsumerStatefulWidget {
  const PrepacienteDetailScreen({super.key, required this.notaId});

  final int notaId;

  @override
  ConsumerState<PrepacienteDetailScreen> createState() =>
      _PrepacienteDetailScreenState();
}

class _PrepacienteDetailScreenState
    extends ConsumerState<PrepacienteDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  Future<void> _save() async {
    final nota = ref.read(notaByIdProvider(widget.notaId)).asData?.value;
    if (nota == null) return;
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final v = _formKey.currentState!.value;
      await ref.read(notasProvider.notifier).updateNota(
        nota.copyWith(
          nombreContacto: v['nombre_contacto'] as String,
          telefono: (v['telefono'] as String?)?.isEmpty ?? true
              ? null
              : v['telefono'] as String,
          tratamientoProbable:
              (v['tratamiento_probable'] as String?)?.isEmpty ?? true
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

  Future<void> _delete() async {
    final confirmed = await showAppConfirm(
      context,
      title: 'Eliminar prepaciente',
      message: 'Esta acción no se puede deshacer.',
      destructive: true,
      confirmLabel: 'Eliminar',
    );
    if (!confirmed) return;
    try {
      await ref.read(notasProvider.notifier).deleteNota(widget.notaId);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $message')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notaAsync = ref.watch(notaByIdProvider(widget.notaId));

    return notaAsync.when(
      data: (nota) {
        if (nota == null) {
          return const AppScaffold(
            title: 'Prepaciente',
            body: Center(child: Text('Prepaciente no encontrado.')),
          );
        }
        return AppScaffold(
          title: 'Prepaciente',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField.singleLine(
                    name: 'nombre_contacto',
                    label: 'Nombre *',
                    initialValue: nota.nombreContacto,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField.phone(
                    name: 'telefono',
                    label: 'Teléfono',
                    initialValue: nota.telefono,
                    maxLength: 10,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField.singleLine(
                    name: 'tratamiento_probable',
                    label: 'Tratamiento probable',
                    initialValue: nota.tratamientoProbable,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField.multiline(
                    name: 'contenido',
                    label: 'Observaciones',
                    initialValue: nota.contenido,
                    maxLines: 5,
                    minLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (nota.telefono != null)
                    AppButton.primary(
                      label: 'Contactar por WhatsApp',
                      icon: Icons.chat,
                      onPressed: () async {
                        try {
                          await launchWhatsApp(nota.telefono!);
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
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Prepaciente',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => AppScaffold(
        title: 'Prepaciente',
        body: AppErrorView(
          message: 'No se pudo cargar el prepaciente.',
          onRetry: () => ref.invalidate(notaByIdProvider(widget.notaId)),
        ),
      ),
    );
  }
}
