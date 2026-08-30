import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';

/// Selector fecha/hora único (24 h, es_ES) presentado con `showAppSheet`.
/// Devuelve el `DateTime` elegido, o null si se cancela.
/// Uso: `final d = await AppDateTimeSheet.pick(context, initial: x);`.
/// Depende de: showAppSheet, AppButton, CupertinoDatePicker.
abstract final class AppDateTimeSheet {
  static Future<DateTime?> pick(
    BuildContext context, {
    DateTime? initial,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
  }) {
    var value = initial ?? DateTime.now();
    return showAppSheet<DateTime>(
      context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton.text(
                    label: 'Cancelar',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                  AppButton.text(
                    label: 'Aceptar',
                    onPressed: () => Navigator.of(ctx).pop(value),
                  ),
                ],
              ),
              SizedBox(
                height: 216,
                child: CupertinoDatePicker(
                  mode: mode,
                  use24hFormat: true,
                  initialDateTime: value,
                  onDateTimeChanged: (d) => value = d,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
    );
  }
}
