import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';
import 'package:project_mmh/features/notas/presentation/widgets/cotizacion_item_checklist.dart';

class CotizacionCreateScreen extends ConsumerStatefulWidget {
  const CotizacionCreateScreen({super.key, required this.listaId});

  final int listaId;

  @override
  ConsumerState<CotizacionCreateScreen> createState() =>
      _CotizacionCreateScreenState();
}

class _CotizacionCreateScreenState
    extends ConsumerState<CotizacionCreateScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<NotaItem>? _items;
  bool _isSaving = false;

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final v = _formKey.currentState!.value;

    setState(() => _isSaving = true);
    try {
      await ref.read(notasProvider.notifier).addNota(
        Nota(
          tipo: NotaTipo.cotizacion,
          fecha: DateTime.now().toIso8601String(),
          idNotaRelacionada: widget.listaId,
          proveedor: v['proveedor'] as String,
          items: _items ?? [],
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
    final listaAsync = ref.watch(notaByIdProvider(widget.listaId));

    return listaAsync.when(
      data: (lista) {
        if (lista == null) {
          return const AppScaffold(
            title: 'Nueva Cotización',
            body: Center(child: Text('Lista no encontrada.')),
          );
        }
        // Siembra los ítems desde la lista de materiales una sola vez (ver
        // Global Constraints: evita guardar una lista vacía si el usuario no
        // toca ningún precio).
        _items ??= lista.items
            .map((i) => i.copyWith(precioUnitario: null))
            .toList();

        return AppScaffold(
          title: 'Nueva Cotización',
          actions: [
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
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const AppSectionHeader('Ítems'),
                  CotizacionItemChecklist(
                    initialItems: _items!,
                    onChanged: (items) => _items = items,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Nueva Cotización',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => AppScaffold(
        title: 'Nueva Cotización',
        body: AppErrorView(
          message: 'No se pudo cargar la lista de materiales.',
          onRetry: () => ref.invalidate(notaByIdProvider(widget.listaId)),
        ),
      ),
    );
  }
}
