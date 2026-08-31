import 'package:flutter/material.dart';

/// Vista de error reutilizable: icono + mensaje amable + acción de reintento
/// opcional. Reemplaza los `Text('Error: $e')` crudos repartidos por la app.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    this.message,
    this.onRetry,
    this.compact = false,
  });

  /// Mensaje a mostrar. Si es null se usa un texto genérico.
  final String? message;

  /// Si se provee, se muestra un botón "Reintentar".
  final VoidCallback? onRetry;

  /// Versión reducida (para filas dentro de listas o tarjetas).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = message ?? 'Ocurrió un error al cargar la información.';

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: compact ? 28 : 40,
          color: theme.colorScheme.error,
        ),
        SizedBox(height: compact ? 6 : 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
              ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        if (onRetry != null) ...[
          SizedBox(height: compact ? 6 : 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
          ),
        ],
      ],
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 24),
        child: content,
      ),
    );
  }
}
