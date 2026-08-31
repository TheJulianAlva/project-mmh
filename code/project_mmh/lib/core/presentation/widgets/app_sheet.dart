import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Único helper de hoja modal: asa (del bottomSheetTheme), safe area,
/// título opcional y padding que respeta el teclado (`viewInsets`).
/// Uso: `await showAppSheet<Foo>(context, builder: (_) => ...)`.
/// Depende de: bottomSheetTheme, AppSpacing, AppText.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    builder: (ctx) {
      final media = MediaQuery.of(ctx);
      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Text(title, style: AppText.cardTitle),
              ),
            Flexible(child: builder(ctx)),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      );
    },
  );
}
