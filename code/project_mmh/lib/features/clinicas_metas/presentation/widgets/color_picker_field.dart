import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ColorPickerField extends StatelessWidget {
  final String name;
  final String? initialValue;
  final InputDecoration decoration;

  const ColorPickerField({
    super.key,
    required this.name,
    this.initialValue,
    this.decoration = const InputDecoration(),
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<String>(
      name: name,
      initialValue: initialValue ?? '#2196F3',
      builder: (FormFieldState<String> field) {
        Color currentColor = _hexToColor(field.value);

        return InputDecorator(
          decoration: decoration.copyWith(
            errorText: field.errorText,
            suffixIcon: GestureDetector(
              onTap: () async {
                final pickedColor = await showDialog<Color>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Seleccionar Color'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: currentColor,
                            onColorChanged: (color) {
                              Navigator.of(context).pop(color);
                            },
                          ),
                        ),
                      ),
                );

                if (pickedColor != null) {
                  field.didChange(_colorToHex(pickedColor));
                }
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
                width: 24,
                height: 24,
              ),
            ),
          ),
          child: Text(field.value ?? ''),
        );
      },
    );
  }

  Color _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (_) {
      return Colors.blue;
    }
  }

  String _colorToHex(Color color) {
    // Use .r, .g, .b (doubles 0.0-1.0) as color.value is deprecated
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }
}
