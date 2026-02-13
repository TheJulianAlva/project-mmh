import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/core/presentation/widgets/custom_bottom_sheet.dart';

enum CupertinoDatePickerType { date, time, dateTime }

class CupertinoDatePickerField extends FormBuilderField<DateTime> {
  final CupertinoDatePickerType pickerType;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateFormat? format;
  final InputDecoration decoration;

  CupertinoDatePickerField({
    super.key,
    required super.name,
    super.validator,
    super.initialValue,
    required this.decoration,
    super.onChanged,
    super.valueTransformer,
    super.enabled,
    super.onSaved,
    super.autovalidateMode,
    super.onReset,
    super.focusNode,
    this.pickerType = CupertinoDatePickerType.dateTime,
    this.firstDate,
    this.lastDate,
    this.format,
  }) : super(
         builder: (FormFieldState<DateTime> field) {
           final state = field as _CupertinoDatePickerFieldState;
           final theme = Theme.of(state.context);

           String displayText = '';
           if (field.value != null) {
             final dateFormat =
                 format ??
                 (pickerType == CupertinoDatePickerType.time
                     ? DateFormat.jm('es_ES')
                     : (pickerType == CupertinoDatePickerType.date
                         ? DateFormat.yMMMMd('es_ES')
                         : DateFormat.yMMMMd('es_ES').add_jm()));
             displayText = dateFormat.format(field.value!);
           }

           return InputDecorator(
             decoration: decoration.copyWith(
               errorText: field.errorText,
               suffixIcon:
                   field.value != null
                       ? IconButton(
                         icon: const Icon(Icons.clear),
                         onPressed: () => field.didChange(null),
                       )
                       : const Icon(Icons.calendar_today),
             ),
             child: InkWell(
               onTap: state.enabled ? () => state._showDatePicker() : null,
               child: Text(
                 displayText.isEmpty ? 'Seleccionar...' : displayText,
                 style:
                     displayText.isEmpty
                         ? theme.textTheme.bodyMedium?.copyWith(
                           color: theme.hintColor,
                         )
                         : theme.textTheme.bodyMedium,
               ),
             ),
           );
         },
       );

  @override
  FormBuilderFieldState<CupertinoDatePickerField, DateTime> createState() =>
      _CupertinoDatePickerFieldState();
}

class _CupertinoDatePickerFieldState
    extends FormBuilderFieldState<CupertinoDatePickerField, DateTime> {
  void _showDatePicker() {
    final mode =
        widget.pickerType == CupertinoDatePickerType.time
            ? CupertinoDatePickerMode.time
            : (widget.pickerType == CupertinoDatePickerType.date
                ? CupertinoDatePickerMode.date
                : CupertinoDatePickerMode.dateAndTime);

    final initialDate = value ?? DateTime.now();
    final minimumDate = widget.firstDate;
    final maximumDate = widget.lastDate;

    showCustomBottomSheet(
      context: context,
      height: 300,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                child: const Text('Listo'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: mode,
              initialDateTime: initialDate,
              minimumDate: minimumDate,
              maximumDate: maximumDate,
              use24hFormat: false,
              onDateTimeChanged: (val) {
                didChange(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
