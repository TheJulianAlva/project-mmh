import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_list_tile.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_switch.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';
import 'package:project_mmh/features/core/presentation/providers/package_info_provider.dart';
import 'package:project_mmh/features/core/presentation/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showAboutDialog(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showAppSheet(
      context,
      title: 'Descargo de Responsabilidad Médica',
      builder:
          (context) => ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(
                        alpha: AppOpacity.subtle,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.info,
                      size: 40,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildInfoSection(
                  context,
                  'Herramienta Educativa',
                  'Este módulo es una herramienta auxiliar y educativa. No sustituye el juicio clínico profesional.',
                ),
                _buildInfoSection(
                  context,
                  'Responsabilidad',
                  'Las sugerencias son algorítmicas. La supervisión docente es la autoridad final.',
                ),
                _buildInfoSection(
                  context,
                  'Limitaciones',
                  'El resultado depende totalmente de la exactitud de los datos ingresados.',
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Text(
                    'Al continuar, usted confirma que comprende estas limitaciones y asume la responsabilidad total de sus decisiones clínicas.',
                    textAlign: TextAlign.center,
                    style: AppText.caption.copyWith(
                      color: scheme.onSurface.withValues(
                        alpha: AppOpacity.muted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Consumer(
                  builder: (context, ref, child) {
                    final packageInfo = ref.watch(packageInfoProvider);
                    final version = packageInfo.when(
                      data: (info) => 'v${info.version}',
                      loading: () => '',
                      error: (_, __) => '',
                    );
                    return Column(
                      children: [
                        Text(
                          'Klinik',
                          textAlign: TextAlign.center,
                          style: AppText.sectionLabel.copyWith(
                            color: scheme.onSurface.withValues(
                              alpha: AppOpacity.muted,
                            ),
                          ),
                        ),
                        if (version.isNotEmpty)
                          Text(
                            version,
                            textAlign: TextAlign.center,
                            style: AppText.caption.copyWith(
                              color: scheme.onSurface.withValues(
                                alpha: AppOpacity.muted,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton.primary(
                  label: 'Entendido',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String content) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title,
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.xs,
            ),
          ),
          Text(
            content,
            style: AppText.body.copyWith(
              color: scheme.onSurface.withValues(alpha: AppOpacity.strong),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final scheme = Theme.of(context).colorScheme;
    final chevron = Icon(
      CupertinoIcons.chevron_forward,
      size: 16,
      color: scheme.onSurface.withValues(alpha: AppOpacity.muted),
    );

    return AppScaffold(
      title: 'Ajustes',
      showBack: false,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSettingsGroup(
                  header: 'Apariencia',
                  children: [
                    AppListTile(
                      icon: Icons.dark_mode,
                      title: 'Modo Oscuro',
                      trailing: AppSwitch(
                        value: themeMode == ThemeMode.dark,
                        onChanged: (val) {
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(
                                val ? ThemeMode.dark : ThemeMode.light,
                              );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                AppSettingsGroup(
                  header: 'General',
                  children: [
                    AppListTile(
                      icon: CupertinoIcons.bell_fill,
                      title: 'Recordatorios de Agenda',
                      subtitle: 'Notificaciones diarias de tus citas',
                      trailing: chevron,
                      onTap: () => context.go('/settings/recordatorios'),
                    ),
                    AppListTile(
                      icon: Icons.school,
                      title: 'Gestión Académica',
                      subtitle: 'Administrar clínicas y metas',
                      trailing: chevron,
                      onTap: () => context.go('/settings/clinicas-metas'),
                    ),
                    AppListTile(
                      icon: CupertinoIcons.info_circle_fill,
                      title: 'Acerca de',
                      subtitle: 'Aviso legal e información',
                      trailing: chevron,
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
