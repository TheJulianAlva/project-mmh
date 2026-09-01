import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/clinic_palette.dart';

class ColorPickerField extends StatelessWidget {
  final String name;
  final String? initialValue;
  final String? label;

  const ColorPickerField({
    super.key,
    required this.name,
    this.initialValue,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<String>(
      name: name,
      initialValue: initialValue ?? ClinicPalette.toHex(ClinicPalette.fallback),
      builder: (FormFieldState<String> field) {
        final currentColor = ClinicPalette.parse(field.value);

        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: field.errorText,
          ),
          child: GestureDetector(
            onTap: () async {
              final pickedColor = await showAppSheet<Color>(
                context,
                title: 'Color de la clínica',
                builder: (_) => _ColorGrid(selected: currentColor),
              );

              if (pickedColor != null) {
                field.didChange(ClinicPalette.toHex(pickedColor));
              }
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).dividerColor),
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

class _ColorGrid extends StatelessWidget {
  const _ColorGrid({required this.selected});

  final Color selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children:
            ClinicPalette.colors.map((color) {
              final isSelected = color.toARGB32() == selected.toARGB32();
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(color),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadii.smAll,
                    border:
                        isSelected
                            ? Border.all(color: scheme.onSurface, width: 3)
                            : null,
                  ),
                  child:
                      isSelected
                          ? Icon(Icons.check, color: scheme.onPrimary, size: 20)
                          : null,
                ),
              );
            }).toList(),
      ),
    );
  }
}
