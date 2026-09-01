import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_entity_card.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class PrepacienteListView extends ConsumerWidget {
  const PrepacienteListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prepacientes = ref.watch(notasPorTipoProvider(NotaTipo.prepaciente));

    if (prepacientes.isEmpty) {
      return const AppEmptyState(
        icon: Icons.person_search_outlined,
        title: 'No hay prepacientes registrados.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: prepacientes.length,
      itemBuilder: (context, index) {
        final p = prepacientes[index];
        final partes = [
          if (p.telefono != null) p.telefono!,
          if (p.tratamientoProbable != null) p.tratamientoProbable!,
        ];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppEntityCard(
            title: p.nombreContacto ?? '(Sin nombre)',
            onTap: () => context.push('/notas/prepacientes/${p.idNota}'),
            child: Text(partes.isEmpty ? 'Sin datos adicionales' : partes.join(' · ')),
          ),
        );
      },
    );
  }
}
