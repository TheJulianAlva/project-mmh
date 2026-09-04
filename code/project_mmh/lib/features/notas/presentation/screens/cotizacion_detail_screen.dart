import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';
import 'package:project_mmh/features/notas/presentation/widgets/cotizacion_item_checklist.dart';

class CotizacionDetailScreen extends ConsumerStatefulWidget {
  const CotizacionDetailScreen({super.key, required this.cotizacionId});

  final int cotizacionId;

  @override
  ConsumerState<CotizacionDetailScreen> createState() =>
      _CotizacionDetailScreenState();
}

class _CotizacionDetailScreenState
    extends ConsumerState<CotizacionDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<NotaItem>? _items;
  bool _isSaving = false;

  Future<void> _save() async {
    final nota = ref
        .read(notaByIdProvider(widget.cotizacionId))
        .asData
        ?.value;
    if (nota == null) return;
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final v = _formKey.currentState!.value;
      await ref.read(notasProvider.notifier).updateNota(
        nota.copyWith(
          proveedor: v['proveedor'] as String,
          items: _items ?? nota.items,
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
      title: 'Eliminar cotización',
      message: 'Esta acción no se puede deshacer.',
      destructive: true,
      confirmLabel: 'Eliminar',
    );
    if (!confirmed) return;
    try {
      await ref.read(notasProvider.notifier).deleteNota(widget.cotizacionId);
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
    final notaAsync = ref.watch(notaByIdProvider(widget.cotizacionId));

    return notaAsync.when(
      data: (nota) {
        if (nota == null) {
          return const AppScaffold(
            title: 'Cotización',
            body: Center(child: Text('Cotización no encontrada.')),
          );
        }
        // Ver Global Constraints: siembra una sola vez desde los datos ya
        // guardados, para no perder ítems si el usuario no toca ninguno.
        _items ??= List.of(nota.items);

        return AppScaffold(
          title: nota.proveedor ?? 'Cotización',
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
                    name: 'proveedor',
                    label: 'Proveedor *',
                    initialValue: nota.proveedor,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const AppSectionHeader('Ítems'),
                  CotizacionItemChecklist(
                    initialItems: nota.items,
                    onChanged: (items) => _items = items,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Cotización',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => AppScaffold(
        title: 'Cotización',
        body: AppErrorView(
          message: 'No se pudo cargar la cotización.',
          onRetry: () =>
              ref.invalidate(notaByIdProvider(widget.cotizacionId)),
        ),
      ),
    );
  }
}
