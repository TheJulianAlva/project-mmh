import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/diagnosis/domain/models/node.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final DiagnosisResultNode result;
  final VoidCallback onRestart;

  const DiagnosisResultScreen({
    super.key,
    required this.result,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (result.title.trim().isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: AppEmptyState(
            icon: Icons.medical_services_outlined,
            title: 'Sin diagnóstico',
            message: 'No se obtuvo un resultado para las respuestas dadas.',
            action: AppButton.primary(
              label: 'Nuevo Diagnóstico',
              onPressed: onRestart,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              // Icono / Indicador Visual
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: result.color.withValues(alpha: AppOpacity.subtle),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.medical_services_rounded,
                    size: 48,
                    color: result.color,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Título del Diagnóstico
              Text(
                'Diagnóstico Final',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.outline,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      result.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: result.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result.title));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Diagnóstico copiado'),
                          backgroundColor: theme.colorScheme.secondary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.copy_rounded,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: AppOpacity.muted,
                      ),
                    ),
                    tooltip: 'Copiar diagnóstico',
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Descripción
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  result.description,
                  // Left align within the card looks better for reading
                  textAlign: TextAlign.left,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Recomendación de Tratamiento
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tratamiento Recomendado',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: SelectableText(
                    result.treatmentRecommendation?.trim().isNotEmpty == true
                        ? result.treatmentRecommendation!
                        : 'Sin recomendación de tratamiento para este diagnóstico.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Botones de Acción
              SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  label: 'Nuevo Diagnóstico',
                  onPressed: onRestart,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton.text(
                label: 'Volver al Inicio',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
