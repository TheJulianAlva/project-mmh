import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

enum _Kind { singleLine, multiline, number }

/// Envuelve `FormBuilderTextField` con la decoración del tema. Tres
/// variantes: una línea, multilínea y numérica.
/// Uso: `AppTextField.singleLine(name: 'nombre', label: 'Nombre')`.
/// Depende de: flutter_form_builder, inputDecorationTheme.
class AppTextField extends StatelessWidget {
  const AppTextField._(
    this._kind, {
    required this.name,
    required this.label,
    this.initialValue,
    this.validator,
    this.hintText,
    this.maxLines,
  });

  factory AppTextField.singleLine({
    required String name,
    required String label,
    String? initialValue,
    String? Function(String?)? validator,
    String? hintText,
  }) => AppTextField._(
    _Kind.singleLine,
    name: name,
    label: label,
    initialValue: initialValue,
    validator: validator,
    hintText: hintText,
  );

  factory AppTextField.multiline({
    required String name,
    required String label,
    String? initialValue,
    String? Function(String?)? validator,
    String? hintText,
    int maxLines = 4,
  }) => AppTextField._(
    _Kind.multiline,
    name: name,
    label: label,
    initialValue: initialValue,
    validator: validator,
    hintText: hintText,
    maxLines: maxLines,
  );

  factory AppTextField.number({
    required String name,
    required String label,
    String? initialValue,
    String? Function(String?)? validator,
    String? hintText,
  }) => AppTextField._(
    _Kind.number,
    name: name,
    label: label,
    initialValue: initialValue,
    validator: validator,
    hintText: hintText,
  );

  final _Kind _kind;
  final String name;
  final String label;
  final String? initialValue;
  final String? Function(String?)? validator;
  final String? hintText;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      validator: validator,
      maxLines: _kind == _Kind.multiline ? (maxLines ?? 4) : 1,
      keyboardType: switch (_kind) {
        _Kind.number => TextInputType.number,
        _Kind.multiline => TextInputType.multiline,
        _Kind.singleLine => TextInputType.text,
      },
      inputFormatters:
          _kind == _Kind.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }
}
