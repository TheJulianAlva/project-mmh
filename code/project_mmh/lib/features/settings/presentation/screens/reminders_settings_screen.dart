import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI-only prototype for the Reminders settings screen.
/// All state is local (no persistence yet). Phase 2 will wire up real logic.
class RemindersSettingsScreen extends ConsumerStatefulWidget {
  const RemindersSettingsScreen({super.key});

  @override
  ConsumerState<RemindersSettingsScreen> createState() =>
      _RemindersSettingsScreenState();
}

class _RemindersSettingsScreenState
    extends ConsumerState<RemindersSettingsScreen> {
  bool _remindersEnabled = false;
  bool _summaryToday = true;
  bool _summaryTomorrow = false;
  bool _summaryDayAfter = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void _showTimePicker() {
    // Start with a DateTime that matches _reminderTime
    DateTime initial = DateTime(
      2026,
      1,
      1,
      _reminderTime.hour,
      _reminderTime.minute,
    );

    showCupertinoModalPopup(
      context: context,
      builder:
          (ctx) => Container(
            height: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Header bar with Done button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      Text(
                        'Hora del recordatorio',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Listo',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Cupertino Time Picker
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: initial,
                    use24hFormat: false,
                    onDateTimeChanged: (DateTime dt) {
                      setState(() {
                        _reminderTime = TimeOfDay(
                          hour: dt.hour,
                          minute: dt.minute,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Recordatorios'),
            backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
            previousPageTitle: 'Configuración',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header icon + description ──
                  _buildHeaderCard(colorScheme, textTheme, isDark),

                  const SizedBox(height: 24),

                  // ── Master Switch ──
                  _buildSection(
                    colorScheme: colorScheme,
                    isDark: isDark,
                    children: [
                      _buildSwitchTile(
                        icon: CupertinoIcons.bell_fill,
                        iconColor: colorScheme.primary,
                        title: 'Activar recordatorios',
                        subtitle: 'Recibe notificaciones diarias de tu agenda',
                        value: _remindersEnabled,
                        onChanged: (v) => setState(() => _remindersEnabled = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Time Picker Section ──
                  _buildSectionLabel('HORARIO', textTheme, colorScheme),
                  const SizedBox(height: 8),
                  _buildSection(
                    colorScheme: colorScheme,
                    isDark: isDark,
                    children: [_buildTimeTile(colorScheme, textTheme)],
                  ),

                  const SizedBox(height: 20),

                  // ── Scope Selection ──
                  _buildSectionLabel(
                    'CONTENIDO DEL RESUMEN',
                    textTheme,
                    colorScheme,
                  ),
                  const SizedBox(height: 8),
                  _buildSection(
                    colorScheme: colorScheme,
                    isDark: isDark,
                    children: [
                      _buildCheckTile(
                        icon: CupertinoIcons.calendar_today,
                        iconColor: colorScheme.primary,
                        title: 'Eventos de hoy',
                        subtitle: 'Resumen del día actual',
                        value: _summaryToday,
                        onChanged: (v) => setState(() => _summaryToday = v),
                      ),
                      _buildDivider(),
                      _buildCheckTile(
                        icon: CupertinoIcons.arrow_right_circle,
                        iconColor: colorScheme.secondary,
                        title: 'Eventos de mañana',
                        subtitle: 'Anticipa tus citas del siguiente día',
                        value: _summaryTomorrow,
                        onChanged: (v) => setState(() => _summaryTomorrow = v),
                      ),
                      _buildDivider(),
                      _buildCheckTile(
                        icon: CupertinoIcons.arrow_2_squarepath,
                        iconColor: const Color(0xFF7C4DFF),
                        title: 'Eventos en 2 días',
                        subtitle: 'Planifica con anticipación',
                        value: _summaryDayAfter,
                        onChanged: (v) => setState(() => _summaryDayAfter = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Preview Card ──
                  _buildPreviewCard(colorScheme, textTheme, isDark),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget Builders ─────────────────────────────────────────────────────

  Widget _buildHeaderCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.08),
            colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(
                alpha: isDark ? 0.25 : 0.12,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.bell_circle_fill,
              size: 28,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
                Text(
                  'Configura notificaciones para no olvidar tus citas y tratamientos.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
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

  Widget _buildSectionLabel(
    String label,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.45),
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSection({
    required ColorScheme colorScheme,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: isDark ? 0.08 : 0.06),
        ),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Column(children: children),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
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
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(ColorScheme colorScheme, TextTheme textTheme) {
    return InkWell(
      onTap: _remindersEnabled ? _showTimePicker : null,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                CupertinoIcons.clock_fill,
                size: 20,
                color:
                    _remindersEnabled
                        ? colorScheme.secondary
                        : colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hora de notificación',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color:
                          _remindersEnabled
                              ? null
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Se enviará a la hora seleccionada',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(
                        alpha: _remindersEnabled ? 0.55 : 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color:
                    _remindersEnabled
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _formatTime(_reminderTime),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      _remindersEnabled
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.35),
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
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = _remindersEnabled;

    return InkWell(
      onTap: isEnabled ? () => onChanged(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isEnabled ? iconColor : colorScheme.onSurface)
                    .withValues(alpha: isEnabled ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color:
                    isEnabled
                        ? iconColor
                        : colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color:
                          isEnabled
                              ? null
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(
                        alpha: isEnabled ? 0.55 : 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Cupertino-style checkbox using CupertinoSwitch (smaller)
            Transform.scale(
              scale: 0.8,
              child: CupertinoSwitch(
                value: value,
                activeTrackColor: iconColor,
                onChanged: isEnabled ? onChanged : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 58,
      endIndent: 16,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
    );
  }

  Widget _buildPreviewCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDark,
  ) {
    if (!_remindersEnabled) return const SizedBox.shrink();

    final activeScopes = <String>[];
    if (_summaryToday) activeScopes.add('hoy');
    if (_summaryTomorrow) activeScopes.add('mañana');
    if (_summaryDayAfter) activeScopes.add('pasado mañana');

    final scopeText =
        activeScopes.isEmpty
            ? 'Selecciona al menos un tipo de resumen.'
            : 'Recibirás un resumen de tus eventos de ${activeScopes.join(', ')} a las ${_formatTime(_reminderTime)}.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.15),
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
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  scopeText,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
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
