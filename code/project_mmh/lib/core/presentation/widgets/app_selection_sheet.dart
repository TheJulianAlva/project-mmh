import 'package:flutter/material.dart';
import 'package:project_mmh/core/presentation/widgets/app_list_tile.dart';
import 'package:project_mmh/core/presentation/widgets/app_search_field.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Hoja modal de selección única: lista de opciones tocables sobre
/// `showAppSheet`, con marca en la opción activa y búsqueda opcional.
/// Devuelve la opción elegida, o null si se cierra sin elegir.
/// Depende de: showAppSheet, AppListTile, AppSearchField.
Future<T?> showAppSelectionSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  String? Function(T)? sublabelOf,
  T? selected,
  bool searchable = false,
  String searchHint = 'Buscar',
}) {
  return showAppSheet<T>(
    context,
    title: title,
    builder: (ctx) {
      var query = '';
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered =
              query.trim().isEmpty
                  ? options
                  : options.where((o) {
                    final q = query.toLowerCase();
                    return labelOf(o).toLowerCase().contains(q) ||
                        (sublabelOf?.call(o)?.toLowerCase().contains(q) ??
                            false);
                  }).toList();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (searchable)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: AppSearchField(
                    hintText: searchHint,
                    debounce: const Duration(milliseconds: 200),
                    onChanged: (v) => setModalState(() => query = v),
                  ),
                ),
              Flexible(
                child:
                    filtered.isEmpty
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Text(
                              'Sin coincidencias',
                              style: AppText.body.copyWith(
                                color: Theme.of(ctx).colorScheme.onSurface
                                    .withValues(alpha: AppOpacity.muted),
                              ),
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final o = filtered[i];
                            return AppListTile(
                              title: labelOf(o),
                              subtitle: sublabelOf?.call(o),
                              trailing:
                                  o == selected
                                      ? const Icon(Icons.check)
                                      : null,
                              onTap: () => Navigator.of(ctx).pop(o),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      );
    },
  );
}
