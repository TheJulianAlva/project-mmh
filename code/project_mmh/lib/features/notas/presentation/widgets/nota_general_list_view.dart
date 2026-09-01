import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_entity_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_search_field.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class NotaGeneralListView extends ConsumerStatefulWidget {
  const NotaGeneralListView({super.key});

  @override
  ConsumerState<NotaGeneralListView> createState() =>
      _NotaGeneralListViewState();
}

class _NotaGeneralListViewState extends ConsumerState<NotaGeneralListView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final notas = ref.watch(notasPorTipoProvider(NotaTipo.general));
    final filtradas = notas.where((n) {
      return _query.isEmpty ||
          (n.contenido ?? '').toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: AppSearchField(
            hintText: 'Buscar en notas',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: filtradas.isEmpty
              ? const AppEmptyState(
                  icon: Icons.note_alt_outlined,
                  title: 'No hay notas que coincidan.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: filtradas.length,
                  itemBuilder: (context, index) {
                    final nota = filtradas[index];
                    final extracto = (nota.contenido ?? '').trim();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppEntityCard(
                        title: extracto.isEmpty ? '(Sin contenido)' : extracto,
                        onTap: () => context.push('/notas/${nota.idNota}'),
                        child: Text(
                          DateFormat('d MMM y, HH:mm', 'es_ES')
                              .format(DateTime.parse(nota.fecha)),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: AppOpacity.muted),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
