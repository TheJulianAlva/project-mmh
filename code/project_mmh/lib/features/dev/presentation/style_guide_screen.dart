import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_entity_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_date_time_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_list_tile.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_search_field.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_status_badge.dart';
import 'package:project_mmh/core/presentation/widgets/app_switch.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_semantic_colors.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';

/// Catálogo visual de tokens y componentes `App*`. Solo accesible en
/// `kDebugMode` vía deep link `/dev/style-guide`. Es la prueba de
/// regresión de la fase D3.
class StyleGuideScreen extends StatelessWidget {
  const StyleGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;

    return AppScaffold(
      title: 'Style Guide',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList.list(
            children: [
              const AppSectionHeader('Color'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _Swatch('primary', scheme.primary),
                  _Swatch('secondary', scheme.secondary),
                  _Swatch('surface', scheme.surface),
                  _Swatch('error', scheme.error),
                  _Swatch('success', semantic.success),
                  _Swatch('warning', semantic.warning),
                  _Swatch('info', semantic.info),
                ],
              ),

              const AppSectionHeader('Tipografía'),
              for (final (name, style) in const [
                ('screenTitle', AppText.screenTitle),
                ('cardTitle', AppText.cardTitle),
                ('body', AppText.body),
                ('sectionLabel', AppText.sectionLabel),
                ('metric', AppText.metric),
                ('caption', AppText.caption),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Text('$name — El veloz murciélago', style: style),
                ),

              const AppSectionHeader('Espaciado'),
              for (final (name, v) in const [
                ('xs', AppSpacing.xs),
                ('sm', AppSpacing.sm),
                ('md', AppSpacing.md),
                ('lg', AppSpacing.lg),
                ('xl', AppSpacing.xl),
                ('xxl', AppSpacing.xxl),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(name, style: AppText.caption),
                      ),
                      Container(width: v, height: 12, color: scheme.primary),
                    ],
                  ),
                ),

              const AppSectionHeader('Radios'),
              Wrap(
                spacing: AppSpacing.md,
                children: [
                  for (final r in const [AppRadii.sm, AppRadii.md, AppRadii.lg])
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(r),
                      ),
                    ),
                ],
              ),

              const AppSectionHeader('Botones'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppButton.primary(label: 'Primary', onPressed: () {}),
                  AppButton.secondary(label: 'Secondary', onPressed: () {}),
                  AppButton.text(label: 'Text', onPressed: () {}),
                  AppButton.destructive(label: 'Destructive', onPressed: () {}),
                  AppButton.primary(
                    label: 'Loading',
                    loading: true,
                    onPressed: () {},
                  ),
                  AppButton.primary(label: 'Disabled', onPressed: null),
                ],
              ),

              const AppSectionHeader('Tarjetas'),
              const AppCard(child: Text('AppCard normal')),
              const AppCard(
                accentColor: Color(0xFF00C7BE),
                child: Text('AppCard con barra de acento'),
              ),
              const SizedBox(height: AppSpacing.sm),
              const AppCard(
                tint: Color(0xFFD81B60),
                child: Text('AppCard tint (panel)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppEntityCard(
                title: 'AppEntityCard',
                onTap: () {},
                child: const Text('fila de entidad tocable'),
              ),

              const AppSectionHeader('Campos'),
              const AppSearchField(),
              const SizedBox(height: AppSpacing.sm),
              FormBuilder(
                child: AppTextField.singleLine(name: 'demo', label: 'Nombre'),
              ),

              const AppSectionHeader('Listas'),
              AppSettingsGroup(
                header: 'General',
                children: [
                  const AppListTile(
                    icon: Icons.palette_outlined,
                    title: 'Tema',
                    subtitle: 'Sistema',
                  ),
                  AppListTile(
                    icon: Icons.notifications_outlined,
                    title: 'Recordatorios',
                    trailing: AppSwitch(value: true, onChanged: (_) {}),
                  ),
                ],
              ),

              const AppSectionHeader('Estados'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final e in EstadoAsistencia.values)
                    AppStatusBadge.asistencia(e),
                  for (final e in EstadoTratamiento.values)
                    AppStatusBadge.tratamiento(e),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const SizedBox(
                height: 180,
                child: AppEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'Sin resultados',
                  message: 'Prueba con otro filtro',
                ),
              ),

              const AppSectionHeader('Hojas y diálogos'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppButton.secondary(
                    label: 'showAppSheet',
                    onPressed:
                        () => showAppSheet<void>(
                          context,
                          title: 'Opciones',
                          builder:
                              (_) => const Padding(
                                padding: EdgeInsets.all(AppSpacing.lg),
                                child: Text('Contenido de la hoja'),
                              ),
                        ),
                  ),
                  AppButton.secondary(
                    label: 'showAppConfirm',
                    onPressed:
                        () => showAppConfirm(
                          context,
                          title: '¿Eliminar?',
                          message: 'No se puede deshacer',
                          destructive: true,
                        ),
                  ),
                  AppButton.secondary(
                    label: 'AppDateTimeSheet',
                    onPressed: () => AppDateTimeSheet.pick(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 48,
          decoration: BoxDecoration(color: color, borderRadius: AppRadii.smAll),
        ),
        const SizedBox(height: 2),
        Text(name, style: AppText.caption),
      ],
    );
  }
}
