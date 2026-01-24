import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Icono / Indicador Visual
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: result.color.withValues(alpha: 0.2),
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
              const SizedBox(height: 32),

              // Título del Diagnóstico
              Text(
                'Diagnóstico Final',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.outline,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),

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
                  const SizedBox(width: 8),
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    tooltip: 'Copiar diagnóstico',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Descripción
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      result.description,
                      textAlign:
                          TextAlign
                              .left, // Left align within the card looks better for reading
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Recomendación de Tratamiento
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tratamiento Recomendado',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                readOnly: true, // Por ahora read-only
                controller: TextEditingController(
                  text:
                      result.treatmentRecommendation ??
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.',
                ),
                maxLines: 4,
                decoration: InputDecoration(
                  fillColor: theme.colorScheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Botones de Acción
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Nuevo Diagnóstico',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Volver al Inicio',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
