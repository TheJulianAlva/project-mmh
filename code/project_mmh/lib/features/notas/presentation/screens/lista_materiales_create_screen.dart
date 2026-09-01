import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_selection_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';
import 'package:project_mmh/features/notas/presentation/widgets/nota_item_editor.dart';

class ListaMaterialesCreateScreen extends ConsumerStatefulWidget {
  const ListaMaterialesCreateScreen({super.key});

  @override
  ConsumerState<ListaMaterialesCreateScreen> createState() =>
      _ListaMaterialesCreateScreenState();
}

class _ListaMaterialesCreateScreenState
    extends ConsumerState<ListaMaterialesCreateScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<NotaItem> _items = [];
  Clinica? _clinica;
  bool _isSaving = false;

  Future<void> _pickClinica(List<Clinica> clinicas) async {
    final selected = await showAppSelectionSheet<Clinica>(
      context,
      title: 'Clínica',
      options: clinicas,
      labelOf: (c) => c.nombreClinica,
      selected: _clinica,
    );
    if (selected != null) setState(() => _clinica = selected);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final v = _formKey.currentState!.value;

    setState(() => _isSaving = true);
    try {
      await ref.read(notasProvider.notifier).addNota(
        Nota(
          tipo: NotaTipo.listaMateriales,
          fecha: DateTime.now().toIso8601String(),
          contenido: v['contenido'] as String,
          idClinica: _clinica?.idClinica,
          items: _items,
        ),
      );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final periodId = ref.watch(lastViewedPeriodIdProvider);
    final clinicasAsync = periodId == null
        ? const AsyncValue<List<Clinica>>.data([])
        : ref.watch(clinicasByPeriodoProvider(periodId));

    return AppScaffold(
      title: 'Nueva Lista de Materiales',
      actions: [
        AppButton.text(label: 'Guardar', loading: _isSaving, onPressed: _save),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField.singleLine(
                name: 'contenido',
                label: 'Nombre de la lista *',
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              clinicasAsync.when(
                data: (clinicas) => AppButton.secondary(
                  label: _clinica?.nombreClinica ?? 'Asociar clínica (opcional)',
                  onPressed: clinicas.isEmpty ? null : () => _pickClinica(clinicas),
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),
              const AppSectionHeader('Ítems'),
              NotaItemEditor(onChanged: (items) => _items = items),
            ],
          ),
        ),
      ),
    );
  }
}
