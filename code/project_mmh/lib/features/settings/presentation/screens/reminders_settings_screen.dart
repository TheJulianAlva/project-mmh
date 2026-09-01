import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/core/presentation/widgets/app_date_time_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_list_tile.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_switch.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/settings/presentation/providers/reminder_settings_provider.dart';
import 'package:project_mmh/core/utils/formatters.dart';

class RemindersSettingsScreen extends ConsumerStatefulWidget {
  const RemindersSettingsScreen({super.key});

  @override
  ConsumerState<RemindersSettingsScreen> createState() =>
      _RemindersSettingsScreenState();
}

class _RemindersSettingsScreenState
    extends ConsumerState<RemindersSettingsScreen> {
  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _showTimePicker() async {
    final settings = ref.read(reminderSettingsProvider);
    final initial = DateTime(2026, 1, 1, settings.hour, settings.minute);

    final picked = await AppDateTimeSheet.pick(
      context,
      initial: initial,
      mode: CupertinoDatePickerMode.time,
    );

    if (picked != null) {
      await ref
          .read(reminderSettingsProvider.notifier)
          .setTime(picked.hour, picked.minute);
    }

    // Reprogramar al cerrar el selector (cubre aceptar y cancelar).
    if (mounted) {
      await ref.read(reminderSettingsProvider.notifier).refreshNotifications();
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(reminderSettingsProvider);
    final notifier = ref.read(reminderSettingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      title: 'Recordatorios',
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(colorScheme, textTheme, isDark),
                const SizedBox(height: AppSpacing.xl),

                // ── Master Switch ──
                AppSettingsGroup(
                  children: [
                    _buildSwitchTile(
                      icon: CupertinoIcons.bell_fill,
                      iconColor: colorScheme.primary,
                      title: 'Activar recordatorios',
                      subtitle: 'Recibe notificaciones diarias de tu agenda',
                      value: settings.enabled,
                      onChanged: (v) async {
                        final ok = await notifier.setEnabled(v);
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Activa las notificaciones para Klinik en los '
                                'ajustes del sistema.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Time Picker Section ──
                AppSettingsGroup(
                  header: 'Horario',
                  children: [_buildTimeTile(colorScheme, textTheme, settings)],
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Scope Selection ──
                AppSettingsGroup(
                  header: 'Contenido del resumen',
                  children: [
                    _buildCheckTile(
                      icon: CupertinoIcons.calendar_today,
                      iconColor: colorScheme.primary,
                      title: 'Eventos de hoy',
                      subtitle: 'Siempre incluido en el resumen',
                      value: true,
                      enabled: settings.enabled,
                    ),
                    _buildCheckTile(
                      icon: CupertinoIcons.arrow_right_circle,
                      iconColor: colorScheme.secondary,
                      title: 'Eventos de mañana',
                      subtitle: 'Anticipa tus citas del siguiente día',
                      value: settings.summaryTomorrow,
                      enabled: settings.enabled,
                      onChanged: (v) => notifier.setSummaryTomorrow(v),
                    ),
                    _buildCheckTile(
                      icon: CupertinoIcons.arrow_2_squarepath,
                      iconColor: colorScheme.tertiary,
                      title: 'Eventos en 2 días',
                      subtitle: 'Planifica con anticipación',
                      value: settings.summaryDayAfter,
                      enabled: settings.enabled,
                      onChanged: (v) => notifier.setSummaryDayAfter(v),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Preview Card ──
                _buildPreviewCard(colorScheme, textTheme, isDark, settings),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Widget Builders ─────────────────────────────────────────────────────

  Widget _buildHeaderCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.08),
            colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.lgAll,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: AppOpacity.subtle),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(
                alpha: isDark ? 0.25 : 0.12,
              ),
              borderRadius: AppRadii.mdAll,
            ),
            child: Icon(
              CupertinoIcons.bell_circle_fill,
              size: 28,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recordatorios Diarios',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Configura notificaciones para no olvidar tus citas y tratamientos.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: AppOpacity.strong,
                    ),
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

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: AppOpacity.subtle),
              borderRadius: AppRadii.smAll,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: AppOpacity.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildTimeTile(
    ColorScheme colorScheme,
    TextTheme textTheme,
    ReminderSettings settings,
  ) {
    return InkWell(
      onTap: settings.enabled ? _showTimePicker : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(
                  alpha: AppOpacity.subtle,
                ),
                borderRadius: AppRadii.smAll,
              ),
              child: Icon(
                CupertinoIcons.clock_fill,
                size: 20,
                color:
                    settings.enabled
                        ? colorScheme.secondary
                        : colorScheme.onSurface.withValues(
                          alpha: AppOpacity.muted,
                        ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hora de notificación',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color:
                          settings.enabled
                              ? null
                              : colorScheme.onSurface.withValues(
                                alpha: AppOpacity.muted,
                              ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Se enviará a la hora seleccionada',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(
                        alpha:
                            settings.enabled
                                ? AppOpacity.muted
                                : AppOpacity.subtle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color:
                    settings.enabled
                        ? colorScheme.primary.withValues(
                          alpha: AppOpacity.subtle,
                        )
                        : colorScheme.onSurface.withValues(
                          alpha: AppOpacity.hairline,
                        ),
                borderRadius: AppRadii.smAll,
              ),
              child: Text(
                formatTimeOfDay(settings.timeOfDay),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      settings.enabled
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(
                            alpha: AppOpacity.muted,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    ValueChanged<bool>? onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: (enabled && onChanged != null) ? () => onChanged(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (enabled ? iconColor : colorScheme.onSurface).withValues(
                  alpha: enabled ? AppOpacity.subtle : AppOpacity.hairline,
                ),
                borderRadius: AppRadii.smAll,
              ),
              child: Icon(
                icon,
                size: 18,
                color:
                    enabled
                        ? iconColor
                        : colorScheme.onSurface.withValues(
                          alpha: AppOpacity.muted,
                        ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color:
                          enabled
                              ? null
                              : colorScheme.onSurface.withValues(
                                alpha: AppOpacity.muted,
                              ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(
                        alpha: enabled ? AppOpacity.muted : AppOpacity.subtle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (onChanged != null)
              Transform.scale(
                scale: 0.8,
                child: AppSwitch(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                ),
              )
            else if (value)
              // Ámbito fijo (siempre incluido): no es un interruptor.
              Icon(
                CupertinoIcons.checkmark_alt_circle_fill,
                size: 20,
                color: (enabled ? iconColor : colorScheme.onSurface).withValues(
                  alpha: enabled ? 1 : AppOpacity.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDark,
    ReminderSettings settings,
  ) {
    if (!settings.enabled) return const SizedBox.shrink();

    final activeScopes = <String>[];
    if (settings.summaryToday) activeScopes.add('hoy');
    if (settings.summaryTomorrow) activeScopes.add('mañana');
    if (settings.summaryDayAfter) activeScopes.add('pasado mañana');

    final scopeText =
        activeScopes.isEmpty
            ? 'Selecciona al menos un tipo de resumen.'
            : 'Recibirás un resumen de tus eventos de ${activeScopes.join(', ')} a las ${formatTimeOfDay(settings.timeOfDay)}.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: AppRadii.mdAll,
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: AppOpacity.subtle),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.lightbulb_fill,
            size: 20,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vista previa',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  scopeText,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: AppOpacity.strong,
                    ),
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
}
