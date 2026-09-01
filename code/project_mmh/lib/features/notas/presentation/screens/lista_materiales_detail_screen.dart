import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class ListaMaterialesDetailScreen extends ConsumerWidget {
  const ListaMaterialesDetailScreen({super.key, required this.listaId});

  final int listaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaAsync = ref.watch(notaByIdProvider(listaId));

    return listaAsync.when(
      data: (lista) {
        if (lista == null) {
          return const AppScaffold(
            title: 'Lista de materiales',
            body: Center(child: Text('Lista no encontrada.')),
          );
        }
        final cotizaciones = ref.watch(cotizacionesDeListaProvider(listaId));

        return AppScaffold(
          title: lista.contenido ?? 'Lista de materiales',
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader('Ítems'),
                    if (lista.items.isEmpty)
                      const AppEmptyState(
                        icon: Icons.checklist_rtl,
                        title: 'Sin ítems.',
                      )
                    else
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: lista.items
                              .map((i) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.xs,
                                    ),
                                    child: Text(
                                      '${i.nombre} — ${i.cantidad}${i.unidad != null ? ' ${i.unidad}' : ''}',
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppSectionHeader('Cotizaciones'),
                        AppButton.text(
                          label: 'Agregar cotización',
                          icon: Icons.add,
                          onPressed: () => context.push(
                            '/notas/materiales/$listaId/cotizacion-nueva',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (cotizaciones.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: AppEmptyState(
                    icon: Icons.request_quote_outlined,
                    title: 'Aún no hay cotizaciones.',
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: cotizaciones.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final c = cotizaciones[index];
                      return SizedBox(
                        width: 220,
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.proveedor ?? '(Sin proveedor)',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Expanded(
                                child: ListView(
                                  children: c.items
                                      .map((i) => Text(
                                            '${i.nombre} x${i.cantidad}${i.precioUnitario != null ? ' — \$${i.precioUnitario}' : ''}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ))
                                      .toList(),
                                ),
                              ),
                              const Divider(),
                              Text(
                                'Total: \$${c.totalCotizacion.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        );
      },
      loading: () => const AppScaffold(
        title: 'Lista de materiales',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => AppScaffold(
        title: 'Lista de materiales',
        body: AppErrorView(
          message: 'No se pudo cargar la lista.',
          onRetry: () => ref.invalidate(notaByIdProvider(listaId)),
        ),
      ),
    );
  }
}
