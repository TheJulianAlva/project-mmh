import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/core/presentation/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showAboutDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: CupertinoTheme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey4.resolveFrom(context),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      children: [
                        const SizedBox(height: 10),
                        // Icon
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.activeBlue
                                  .resolveFrom(context)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.info,
                              size: 40,
                              color: CupertinoColors.activeBlue.resolveFrom(
                                context,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Descargo de Responsabilidad Médica',
                          textAlign: TextAlign.center,
                          style: CupertinoTheme.of(
                            context,
                          ).textTheme.navTitleTextStyle.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 24),

                        // Disclaimer Text
                        _buildInfoSection(
                          context,
                          'Herramienta Educativa',
                          'Este módulo es una herramienta auxiliar y educativa. No sustituye el juicio clínico profesional.',
                          CupertinoIcons.book_fill,
                        ),
                        _buildInfoSection(
                          context,
                          'Responsabilidad',
                          'Las sugerencias son algorítmicas. La supervisión docente es la autoridad final.',
                          CupertinoIcons
                              .person_crop_circle_fill_badge_checkmark,
                        ),
                        _buildInfoSection(
                          context,
                          'Limitaciones',
                          'El resultado depende totalmente de la exactitud de los datos ingresados.',
                          CupertinoIcons.exclamationmark_triangle_fill,
                        ),

                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6
                                .resolveFrom(context)
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: CupertinoColors.systemGrey4.resolveFrom(
                                context,
                              ),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            'Al continuar, usted confirma que comprende estas limitaciones y asume la responsabilidad total de sus decisiones clínicas.',
                            textAlign: TextAlign.center,
                            style: CupertinoTheme.of(
                              context,
                            ).textTheme.textStyle.copyWith(
                              fontSize: 13,
                              color: CupertinoColors.secondaryLabel.resolveFrom(
                                context,
                              ),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        Text(
                          'Klinik',
                          textAlign: TextAlign.center,
                          style: CupertinoTheme.of(
                            context,
                          ).textTheme.textStyle.copyWith(
                            color: CupertinoColors.tertiaryLabel.resolveFrom(
                              context,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        child: const Text('Entendido'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: CupertinoTheme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CupertinoTheme.of(context).textTheme.textStyle
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: CupertinoTheme.of(
                    context,
                  ).textTheme.textStyle.copyWith(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Configuración'),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.9),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SwitchListTile(
                title: const Text('Modo Oscuro'),
                secondary: const Icon(Icons.dark_mode),
                value: themeMode == ThemeMode.dark,
                onChanged: (val) {
                  ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.school, size: 28),
                title: const Text('Gestión Académica'),
                subtitle: const Text('Administrar clínicas y metas'),
                trailing: const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 16,
                  color: CupertinoColors.systemGrey3,
                ),
                onTap: () {
                  context.go('/settings/clinicas-metas');
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(CupertinoIcons.info_circle_fill, size: 28),
                title: const Text('Acerca de'),
                subtitle: const Text('Aviso legal e información'),
                trailing: const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 16,
                  color: CupertinoColors.systemGrey3,
                ),
                onTap: () => _showAboutDialog(context),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
