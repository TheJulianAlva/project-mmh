import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';

/// Checklist de captura de precios de cotización: cada renglón trae el
/// nombre/cantidad del ítem (heredado de la lista de materiales al sembrar
/// la cotización, o de la propia cotización al editarla) y un campo de
/// precio en línea. El teclado encadena "siguiente" al precio del renglón
/// que sigue, para capturar precios sin volver a tocar la pantalla entre
/// uno y otro. Nombre/cantidad/unidad se corrigen aparte (ícono de lápiz),
/// sin abrir el precio.
class CotizacionItemChecklist extends StatefulWidget {
  const CotizacionItemChecklist({
    super.key,
    this.initialItems = const [],
    required this.onChanged,
  });

  final List<NotaItem> initialItems;
  final ValueChanged<List<NotaItem>> onChanged;

  @override
  State<CotizacionItemChecklist> createState() =>
      _CotizacionItemChecklistState();
}

class _CotizacionItemChecklistState extends State<CotizacionItemChecklist> {
  late final List<NotaItem> _items = List.of(widget.initialItems);
  late final List<TextEditingController> _priceControllers = _items
      .map(
        (i) =>
            TextEditingController(text: i.precioUnitario?.toString() ?? ''),
      )
      .toList();
  late final List<FocusNode> _priceFocusNodes = List.generate(
    _items.length,
    (_) => FocusNode(),
  );

  void _notify() => widget.onChanged(List.of(_items));

  @override
  void dispose() {
    for (final c in _priceControllers) {
      c.dispose();
    }
    for (final f in _priceFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onPriceChanged(int index, String value) {
    setState(() {
      _items[index] = _items[index].copyWith(
        precioUnitario: value.isEmpty ? null : double.tryParse(value),
      );
    });
    _notify();
  }

  void _focusNext(int index) {
    if (index < _items.length - 1) {
      FocusScope.of(context).requestFocus(_priceFocusNodes[index + 1]);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _editDetails({NotaItem? existing, int? index}) async {
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
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField.decimal(
                        name: 'cantidad',
                        label: 'Cantidad *',
                        initialValue: existing?.cantidad.toString(),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerido' : null,
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
                          precioUnitario: existing?.precioUnitario,
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

    if (result == null || !mounted) return;
    setState(() {
      if (index != null) {
        _items[index] = result;
      } else {
        _items.add(result);
        _priceControllers.add(TextEditingController());
        _priceFocusNodes.add(FocusNode());
      }
    });
    _notify();
  }

  void _removeAt(int index) {
    setState(() {
      _items.removeAt(index);
      _priceControllers.removeAt(index).dispose();
      _priceFocusNodes.removeAt(index).dispose();
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nombre,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${item.cantidad}'
                          '${item.unidad != null ? ' ${item.unidad}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: scheme.onSurface.withValues(
                                  alpha: AppOpacity.muted,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _priceControllers[i],
                      focusNode: _priceFocusNodes[i],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      textInputAction: i == _items.length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      decoration: const InputDecoration(
                        prefixText: '\$',
                        isDense: true,
                        hintText: '0.00',
                      ),
                      onChanged: (value) => _onPriceChanged(i, value),
                      onSubmitted: (_) => _focusNext(i),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editDetails(existing: item, index: i),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _removeAt(i),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: AppSpacing.sm),
        AppButton.secondary(
          label: 'Agregar ítem',
          icon: Icons.add,
          onPressed: () => _editDetails(),
        ),
      ],
    );
  }
}
