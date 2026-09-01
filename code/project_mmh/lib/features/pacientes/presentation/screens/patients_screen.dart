import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_entity_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_search_field.dart';
import 'package:project_mmh/core/services/image_service.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsProvider);

    return AppScaffold(
      title: 'Pacientes',
      showBack: false,
      actions: [
        AppButton.text(
          label: 'Añadir',
          onPressed: () => context.push('/patient-create'),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: AppSearchField(
              hintText: 'Buscar paciente',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
        patientsAsync.when(
          data: (patients) {
            final filteredPatients =
                patients.where((patient) {
                  final fullName = patient.nombreCompleto.toLowerCase();
                  return fullName.contains(_searchQuery) ||
                      patient.idExpediente.toLowerCase().contains(_searchQuery);
                }).toList();

            if (filteredPatients.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.people_outline,
                  title: 'No hay pacientes que coincidan.',
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final patient = filteredPatients[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: AppEntityCard(
                    title: patient.nombreCompleto,
                    leading: CircleAvatar(
                      backgroundImage:
                          patient.imagenesPaths.isNotEmpty
                              ? FileImage(
                                ImageService.resolveFile(
                                  patient.imagenesPaths.first,
                                ),
                              )
                              : null,
                      onBackgroundImageError:
                          patient.imagenesPaths.isNotEmpty ? (_, __) {} : null,
                      child:
                          patient.imagenesPaths.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                    ),
                    onTap: () {
                      context.push('/pacientes/${patient.idExpediente}');
                    },
                    child: Text(
                      'Exp: ${patient.idExpediente}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: AppOpacity.muted),
                      ),
                    ),
                  ),
                );
              }, childCount: filteredPatients.length),
            );
          },
          loading:
              () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
          error:
              (err, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorView(
                  message: 'No se pudo cargar la lista de pacientes.',
                  onRetry: () => ref.invalidate(patientsProvider),
                ),
              ),
        ),
      ],
    );
  }
}
