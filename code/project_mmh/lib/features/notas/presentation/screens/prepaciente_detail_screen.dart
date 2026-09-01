import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/services/whatsapp_launcher.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class PrepacienteDetailScreen extends ConsumerWidget {
  const PrepacienteDetailScreen({super.key, required this.notaId});

  final int notaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notaAsync = ref.watch(notaByIdProvider(notaId));

    return notaAsync.when(
      data: (nota) {
        if (nota == null) {
          return const AppScaffold(
            title: 'Prepaciente',
            body: Center(child: Text('Prepaciente no encontrado.')),
          );
        }
        return AppScaffold(
          title: nota.nombreContacto ?? 'Prepaciente',
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (nota.telefono != null)
                        Text('Teléfono: ${nota.telefono}'),
                      if (nota.tratamientoProbable != null)
                        Text(
                          'Tratamiento probable: ${nota.tratamientoProbable}',
                        ),
                      if (nota.contenido != null &&
                          nota.contenido!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(nota.contenido!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (nota.telefono != null)
                  AppButton.primary(
                    label: 'Contactar por WhatsApp',
                    icon: Icons.chat,
                    onPressed: () => launchWhatsApp(nota.telefono!),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Prepaciente',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => AppScaffold(
        title: 'Prepaciente',
        body: AppErrorView(
          message: 'No se pudo cargar el prepaciente.',
          onRetry: () => ref.invalidate(notaByIdProvider(notaId)),
        ),
      ),
    );
  }
}
