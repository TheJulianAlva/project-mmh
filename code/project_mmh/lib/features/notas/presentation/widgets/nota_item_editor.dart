import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_list_tile.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';

/// Editor de la lista de ítems de una nota `lista_materiales` o `cotizacion`.
/// Mantiene el estado en memoria; el llamador decide cuándo persistir.
class NotaItemEditor extends StatefulWidget {
  const NotaItemEditor({
    super.key,
    this.initialItems = const [],
    this.showPrecio = false,
    required this.onChanged,
  });

  final List<NotaItem> initialItems;
  final bool showPrecio;
  final ValueChanged<List<NotaItem>> onChanged;

  @override
  State<NotaItemEditor> createState() => _NotaItemEditorState();
}

class _NotaItemEditorState extends State<NotaItemEditor> {
  late List<NotaItem> _items = List.of(widget.initialItems);

  void _notify() => widget.onChanged(_items);

  Future<void> _openEditor({NotaItem? existing, int? index}) async {
    final formKey = GlobalKey<FormBuilderState>();
    final result = await showAppSheet<NotaItem>(
      context,
      title: existing == null ? 'Nuevo ítem' : 'Editar ítem',
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField.singleLine(
                  name: 'nombre',
                  label: 'Nombre *',
                  initialValue: existing?.nombre,
                  validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField.number(
                        name: 'cantidad',
                        label: 'Cantidad *',
                        initialValue: existing?.cantidad.toString(),
                        validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField.singleLine(
                        name: 'unidad',
                        label: 'Unidad',
                        initialValue: existing?.unidad,
                      ),
                    ),
                  ],
                ),
                if (widget.showPrecio) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField.number(
                    name: 'precio_unitario',
                    label: 'Precio unitario',
                    initialValue: existing?.precioUnitario?.toString(),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton.primary(
                  label: 'Guardar',
                  onPressed: () {
                    if (formKey.currentState?.saveAndValidate() ?? false) {
                      final v = formKey.currentState!.value;
                      Navigator.of(ctx).pop(
                        NotaItem(
                          nombre: v['nombre'] as String,
                          cantidad: num.parse(v['cantidad'] as String),
                          unidad: (v['unidad'] as String?)?.isEmpty ?? true
                              ? null
                              : v['unidad'] as String,
                          precioUnitario: (v['precio_unitario'] as String?)
                                  ?.isNotEmpty ==
                              true
                              ? double.tryParse(v['precio_unitario'] as String)
                              : null,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;
    setState(() {
      if (index != null) {
        _items[index] = result;
      } else {
        _items.add(result);
      }
    });
    _notify();
  }

  void _removeAt(int index) {
    setState(() => _items.removeAt(index));
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_items.isEmpty)
          const AppEmptyState(
            icon: Icons.checklist_rtl,
            title: 'Sin ítems todavía',
          )
        else
          ..._items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final subtitleParts = [
              '${item.cantidad}${item.unidad != null ? ' ${item.unidad}' : ''}',
              if (widget.showPrecio && item.precioUnitario != null)
                '\$${item.precioUnitario}',
            ];
            return AppListTile(
              title: item.nombre,
              subtitle: subtitleParts.join(' · '),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeAt(i),
              ),
              onTap: () => _openEditor(existing: item, index: i),
            );
          }),
        const SizedBox(height: AppSpacing.sm),
        AppButton.secondary(
          label: 'Agregar ítem',
          icon: Icons.add,
          onPressed: () => _openEditor(),
        ),
      ],
    );
  }
}
