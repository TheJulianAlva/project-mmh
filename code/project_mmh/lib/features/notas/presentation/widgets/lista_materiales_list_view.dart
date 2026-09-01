import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_entity_card.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
import 'package:project_mmh/features/core/presentation/widgets/app_filter_chip.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class ListaMaterialesListView extends ConsumerStatefulWidget {
  const ListaMaterialesListView({super.key});

  @override
  ConsumerState<ListaMaterialesListView> createState() =>
      _ListaMaterialesListViewState();
}

class _ListaMaterialesListViewState
    extends ConsumerState<ListaMaterialesListView> {
  int? _clinicaFiltro;

  @override
  Widget build(BuildContext context) {
    final listas = ref.watch(notasPorTipoProvider(NotaTipo.listaMateriales));
    final periodId = ref.watch(lastViewedPeriodIdProvider);
    final clinicasAsync = periodId == null
        ? null
        : ref.watch(clinicasByPeriodoProvider(periodId));

    final filtradas = _clinicaFiltro == null
        ? listas
        : listas.where((n) => n.idClinica == _clinicaFiltro).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (clinicasAsync != null)
          clinicasAsync.when(
            data: (clinicas) => clinicas.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: AppFilterChip(
                            label: 'Todas',
                            icon: Icons.apps,
                            isActive: _clinicaFiltro == null,
                            onTap: () => setState(() => _clinicaFiltro = null),
                          ),
                        ),
                        ...clinicas.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: AppFilterChip(
                              label: c.nombreClinica,
                              icon: Icons.local_hospital,
                              isActive: _clinicaFiltro == c.idClinica,
                              onTap: () =>
                                  setState(() => _clinicaFiltro = c.idClinica),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: filtradas.isEmpty
              ? const AppEmptyState(
                  icon: Icons.list_alt_outlined,
                  title: 'No hay listas de materiales.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: filtradas.length,
                  itemBuilder: (context, index) {
                    final lista = filtradas[index];
                    final cotizaciones =
                        ref.watch(cotizacionesDeListaProvider(lista.idNota!));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppEntityCard(
                        title: lista.contenido ?? '(Sin nombre)',
                        onTap: () =>
                            context.push('/notas/materiales/${lista.idNota}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(
                                'd MMM y, HH:mm',
                                'es_ES',
                              ).format(DateTime.parse(lista.fecha)),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme
                                        .onSurface
                                        .withValues(alpha: AppOpacity.muted),
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${cotizaciones.length} cotización(es)',
                            ),
                          ],
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
