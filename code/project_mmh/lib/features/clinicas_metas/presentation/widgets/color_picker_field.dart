import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/theme/clinic_palette.dart';

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
      initialValue: initialValue ?? '#007AFF',
      builder: (FormFieldState<String> field) {
        final currentColor = ClinicPalette.parse(field.value);

        return InputDecorator(
          decoration: decoration.copyWith(errorText: field.errorText),
          child: GestureDetector(
            onTap: () async {
              final pickedColor = await showDialog<Color>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Seleccionar Color'),
                      content: SingleChildScrollView(
                        child: BlockPicker(
                          pickerColor: currentColor,
                          availableColors: ClinicPalette.colors,
                          onColorChanged: (color) {
                            Navigator.of(context).pop(color);
                          },
                        ),
                      ),
                    ),
              );

              if (pickedColor != null) {
                field.didChange(ClinicPalette.toHex(pickedColor));
              }
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
