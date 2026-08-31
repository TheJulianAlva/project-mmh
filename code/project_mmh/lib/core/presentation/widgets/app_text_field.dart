import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

enum _Kind { singleLine, multiline, number, phone }

/// Envuelve `FormBuilderTextField` con la decoración del tema. Variantes:
/// una línea, multilínea, numérica y teléfono. Acepta `maxLength` para
/// mantener los topes de caracteres del formulario.
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
    this.minLines,
    this.maxLength,
  });

  factory AppTextField.singleLine({
    required String name,
    required String label,
    String? initialValue,
    String? Function(String?)? validator,
    String? hintText,
    int? maxLength,
  }) => AppTextField._(
    _Kind.singleLine,
    name: name,
    label: label,
    initialValue: initialValue,
    validator: validator,
    hintText: hintText,
    maxLength: maxLength,
  );

  factory AppTextField.multiline({
    required String name,
    required String label,
    String? initialValue,
    String? Function(String?)? validator,
    String? hintText,
    int maxLines = 4,
    int? minLines,
    int? maxLength,
  }) => AppTextField._(
    _Kind.multiline,
    name: name,
    label: label,
    initialValue: initialValue,
    validator: validator,
    hintText: hintText,
    maxLines: maxLines,
    minLines: minLines,
    maxLength: maxLength,
  );

  factory AppTextField.number({
    required String name,
    required String label,
    String? initialValue,
    String? Function(String?)? validator,
    String? hintText,
    int? maxLength,
  }) => AppTextField._(
    _Kind.number,
    name: name,
    label: label,
    initialValue: initialValue,
    validator: validator,
    hintText: hintText,
    maxLength: maxLength,
  );

  factory AppTextField.phone({
    required String name,
    required String label,
    String? initialValue,
    String? Function(String?)? validator,
    String? hintText,
    int? maxLength,
  }) => AppTextField._(
    _Kind.phone,
    name: name,
    label: label,
    initialValue: initialValue,
    validator: validator,
    hintText: hintText,
    maxLength: maxLength,
  );

  final _Kind _kind;
  final String name;
  final String label;
  final String? initialValue;
  final String? Function(String?)? validator;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      validator: validator,
      maxLines: _kind == _Kind.multiline ? (maxLines ?? 4) : 1,
      minLines: _kind == _Kind.multiline ? minLines : null,
      maxLength: maxLength,
      keyboardType: switch (_kind) {
        _Kind.number => TextInputType.number,
        _Kind.phone => TextInputType.phone,
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
