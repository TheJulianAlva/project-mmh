import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Encabezado único de pantalla: `SliverAppBar.large` con título grande en
/// Outfit y fondo translúcido, más un hairline inferior. El botón atrás se
/// resuelve solo (`Navigator.maybePop`) cuando hay ruta previa. Acepta
/// `body` (se envuelve en un sliver) o `slivers` directamente.
/// Depende de: AppText, AppOpacity, ColorScheme.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.actions,
    this.body,
    this.slivers,
    this.showBack = true,
    this.floatingActionButton,
  }) : assert(
         body != null || slivers != null,
         'AppScaffold necesita body o slivers',
       );

  final String title;
  final List<Widget>? actions;
  final Widget? body;
  final List<Widget>? slivers;
  final bool showBack;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: showBack,
            backgroundColor: scheme.surface.withValues(alpha: 0.9),
            surfaceTintColor: Colors.transparent,
            title: Text(
              title,
              style: AppText.screenTitle.copyWith(color: scheme.onSurface),
            ),
            actions: actions,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: scheme.onSurface.withValues(alpha: AppOpacity.hairline),
              ),
            ),
          ),
          if (slivers != null) ...slivers! else SliverToBoxAdapter(child: body),
        ],
      ),
    );
  }
}
