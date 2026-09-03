import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_selection_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';
import 'package:project_mmh/features/notas/presentation/widgets/nota_item_editor.dart';

class ListaMaterialesDetailScreen extends ConsumerStatefulWidget {
  const ListaMaterialesDetailScreen({super.key, required this.listaId});

  final int listaId;

  @override
  ConsumerState<ListaMaterialesDetailScreen> createState() =>
      _ListaMaterialesDetailScreenState();
}

class _ListaMaterialesDetailScreenState
    extends ConsumerState<ListaMaterialesDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<NotaItem>? _items;
  Clinica? _clinica;
  bool _isSaving = false;

  Clinica? _findClinica(List<Clinica> clinicas, int? id) {
    if (id == null) return null;
    for (final c in clinicas) {
      if (c.idClinica == id) return c;
    }
    return null;
  }

  Future<void> _pickClinica(List<Clinica> clinicas, Clinica? current) async {
    final selected = await showAppSelectionSheet<Clinica>(
      context,
      title: 'Clínica',
      options: clinicas,
      labelOf: (c) => c.nombreClinica,
      selected: current,
    );
    if (selected != null) setState(() => _clinica = selected);
  }

  Future<void> _save() async {
    final nota = ref.read(notaByIdProvider(widget.listaId)).asData?.value;
    if (nota == null) return;
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final v = _formKey.currentState!.value;
      await ref.read(notasProvider.notifier).updateNota(
        nota.copyWith(
          contenido: v['contenido'] as String,
          idClinica: _clinica?.idClinica ?? nota.idClinica,
          items: _items ?? nota.items,
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $message')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final cotizaciones = ref.read(
      cotizacionesDeListaProvider(widget.listaId),
    );
    final message = cotizaciones.isEmpty
        ? 'Esta acción no se puede deshacer.'
        : 'Esta acción no se puede deshacer y también eliminará sus '
              '${cotizaciones.length} cotización(es).';

    final confirmed = await showAppConfirm(
      context,
      title: 'Eliminar lista de materiales',
      message: message,
      destructive: true,
      confirmLabel: 'Eliminar',
    );
    if (!confirmed) return;
    try {
      await ref.read(notasProvider.notifier).deleteNota(widget.listaId);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final errMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $errMessage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listaAsync = ref.watch(notaByIdProvider(widget.listaId));

    return listaAsync.when(
      data: (lista) {
        if (lista == null) {
          return const AppScaffold(
            title: 'Lista de materiales',
            body: Center(child: Text('Lista no encontrada.')),
          );
        }
        // Ver Global Constraints: siembra una sola vez, para no perder
        // items si el usuario guarda sin tocar el editor.
        _items ??= List.of(lista.items);
        final cotizaciones = ref.watch(
          cotizacionesDeListaProvider(widget.listaId),
        );
        final periodId = ref.watch(lastViewedPeriodIdProvider);
        final clinicasAsync = periodId == null
            ? const AsyncValue<List<Clinica>>.data([])
            : ref.watch(clinicasByPeriodoProvider(periodId));

        return AppScaffold(
          title: lista.contenido ?? 'Lista de materiales',
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
            AppButton.text(
              label: 'Guardar',
              loading: _isSaving,
              onPressed: _save,
            ),
          ],
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField.singleLine(
                        name: 'contenido',
                        label: 'Nombre de la lista *',
                        initialValue: lista.contenido,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      clinicasAsync.when(
                        data: (clinicas) {
                          final current =
                              _clinica ??
                              _findClinica(clinicas, lista.idClinica);
                          return AppButton.secondary(
                            label:
                                current?.nombreClinica ??
                                'Asociar clínica (opcional)',
                            onPressed: clinicas.isEmpty
                                ? null
                                : () => _pickClinica(clinicas, current),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (e, s) => const SizedBox.shrink(),
                      ),
                      const AppSectionHeader('Ítems'),
                      NotaItemEditor(
                        initialItems: lista.items,
                        onChanged: (items) => _items = items,
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
                              '/notas/materiales/${widget.listaId}/cotizacion-nueva',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: cotizaciones.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final c = cotizaciones[index];
                      return SizedBox(
                        width: 220,
                        child: AppCard(
                          onTap: () => context.push(
                            '/notas/materiales/${widget.listaId}/cotizacion/${c.idNota}',
                          ),
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
                                      .map(
                                        (i) => Text(
                                          '${i.nombre} x${i.cantidad}'
                                          '${i.precioUnitario != null ? ' — \$${i.precioUnitario}' : ''}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      )
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
          onRetry: () => ref.invalidate(notaByIdProvider(widget.listaId)),
        ),
      ),
    );
  }
}
