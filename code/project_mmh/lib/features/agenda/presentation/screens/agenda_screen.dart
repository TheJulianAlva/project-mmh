import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/timeline_session_list.dart';
import 'package:table_calendar/table_calendar.dart' hide isSameDay;
import 'package:table_calendar/table_calendar.dart' as tc show isSameDay;
import 'package:intl/intl.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/features/core/presentation/widgets/app_filter_chip.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  final String? initialAction;
  const AgendaScreen({super.key, this.initialAction});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialAction == 'new') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openAppointmentForm();
      });
    }
  }

  @override
  void didUpdateWidget(AgendaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAction == 'new' && oldWidget.initialAction != 'new') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openAppointmentForm();
      });
    }
  }

  void _openAppointmentForm() {
    final clinicasState = ref.read(clinicasProvider);

    clinicasState.when(
      data: (clinicas) {
        if (clinicas.isEmpty) {
          _showNoClinicsDialog();
        } else {
          context.push('/treatment-create');
        }
      },
      loading: () => context.push('/treatment-create'),
      error: (_, __) => context.push('/treatment-create'),
    );
  }

  void _showNoClinicsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sin Clínicas'),
            content: const Text(
              'No se pueden crear tratamientos sin clínicas registradas. '
              'Por favor, registre una clínica primero en Configuración.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _toggleCalendarFormat() {
    setState(() {
      _calendarFormat =
          _calendarFormat == CalendarFormat.month
              ? CalendarFormat.week
              : CalendarFormat.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    // Mantener la página del calendario sincronizada si la fecha seleccionada
    // cambia desde fuera (p. ej. al abrir la agenda desde una notificación).
    ref.listen(selectedDateProvider, (_, next) {
      if (!tc.isSameDay(_focusedDay, next)) {
        setState(() => _focusedDay = next);
      }
    });
    final sessionsAsync = ref.watch(allSesionesProvider);
    final enrichedToday = ref.watch(enrichedSessionsOnSelectedDateProvider);
    final statusFilter = ref.watch(statusFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Agenda',
      showBack: false,
      actions: [
        AppButton.text(label: 'Añadir', onPressed: _openAppointmentForm),
      ],
      slivers: [
        // ── Collapsible Calendar ──
        SliverToBoxAdapter(
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              // Swipe up → collapse to week, swipe down → expand to month
              if (details.primaryVelocity! < -100 &&
                  _calendarFormat == CalendarFormat.month) {
                _toggleCalendarFormat();
              } else if (details.primaryVelocity! > 100 &&
                  _calendarFormat == CalendarFormat.week) {
                _toggleCalendarFormat();
              }
            },
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: sessionsAsync.when(
                data:
                    (allSessions) => Column(
                      children: [
                        TableCalendar(
                          locale: 'es_ES',
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          onPageChanged: (focusedDay) {
                            // No usar setState aquí (recomendación de
                            // table_calendar): solo persistir la página.
                            _focusedDay = focusedDay;
                          },
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Mes',
                            CalendarFormat.week: 'Semana',
                          },
                          headerStyle: HeaderStyle(
                            formatButtonVisible: true,
                            formatButtonShowsNext: false,
                            formatButtonDecoration: BoxDecoration(
                              border: Border.all(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            formatButtonTextStyle: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            titleCentered: true,
                            titleTextStyle:
                                Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600) ??
                                const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                            leftChevronIcon: Icon(
                              CupertinoIcons.chevron_left,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            rightChevronIcon: Icon(
                              CupertinoIcons.chevron_right,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary.withValues(alpha: 0.7),
                            ),
                            weekendStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          selectedDayPredicate:
                              (day) => tc.isSameDay(selectedDate, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            ref.read(selectedDateProvider.notifier).state =
                                selectedDay;
                            setState(() => _focusedDay = focusedDay);
                          },
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          eventLoader: (day) {
                            return allSessions
                                .where(
                                  (s) => tc.isSameDay(
                                    DateTime.parse(s.fechaInicio),
                                    day,
                                  ),
                                )
                                .toList();
                          },
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            todayDecoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            markerSize: 5,
                            markersMaxCount: 3,
                            defaultTextStyle: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                            weekendTextStyle: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                        // Swipe handle indicator
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 2),
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => AppErrorView(
                      message: 'No se pudo cargar la agenda.',
                      onRetry: () {
                        ref.invalidate(allSesionesProvider);
                        ref.invalidate(enrichedSesionesProvider);
                      },
                    ),
              ),
            ),
          ),
        ),

        // ── Day Header ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildDayHeader(
            context,
            colorScheme,
            selectedDate,
            enrichedToday.length,
          ),
        ),

        // ── Status Filter Chips ──
        SliverToBoxAdapter(child: _buildFilterChips(colorScheme, statusFilter)),

        // ── Timeline or Empty State ──
        if (enrichedToday.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(context, colorScheme, statusFilter),
          )
        else
          SliverToBoxAdapter(
            child: TimelineSessionList(sessions: enrichedToday),
          ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Day Header
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildDayHeader(
    BuildContext context,
    ColorScheme colorScheme,
    DateTime date,
    int count,
  ) {
    final dayName = DateFormat.EEEE('es_ES').format(date);
    final capitalizedDay = dayName[0].toUpperCase() + dayName.substring(1);
    final dateStr = DateFormat("d 'de' MMMM", 'es_ES').format(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$capitalizedDay, $dateStr',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count ${count == 1 ? 'cita' : 'citas'}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Status Filter Chips
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildFilterChips(
    ColorScheme colorScheme,
    EstadoAsistencia? activeFilter,
  ) {
    final filters = <_FilterOption>[
      _FilterOption(
        label: 'Todas',
        value: null,
        icon: CupertinoIcons.list_bullet,
      ),
      _FilterOption(
        label: 'Pendientes',
        value: EstadoAsistencia.programada,
        icon: CupertinoIcons.circle_fill,
      ),
      _FilterOption(
        label: 'Asistió',
        value: EstadoAsistencia.asistio,
        icon: CupertinoIcons.checkmark_alt,
      ),
      _FilterOption(
        label: 'No asistió',
        value: EstadoAsistencia.falto,
        icon: CupertinoIcons.person_badge_minus,
      ),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = activeFilter == filter.value;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppFilterChip(
              label: filter.label,
              icon: filter.icon,
              isActive: isActive,
              onTap: () {
                ref.read(statusFilterProvider.notifier).state = filter.value;
              },
            ),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Empty State
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    EstadoAsistencia? statusFilter,
  ) {
    final isFiltered = statusFilter != null;

    return AppEmptyState(
      icon:
          isFiltered
              ? CupertinoIcons.search
              : CupertinoIcons.calendar_badge_minus,
      title:
          isFiltered
              ? 'No hay citas con este filtro'
              : 'No hay citas programadas',
      action:
          isFiltered
              ? AppButton.text(
                label: 'Mostrar todas',
                icon: CupertinoIcons.arrow_counterclockwise,
                onPressed: () {
                  ref.read(statusFilterProvider.notifier).state = null;
                },
              )
              : AppButton.text(
                label: 'Agendar cita',
                icon: CupertinoIcons.add,
                onPressed: _openAppointmentForm,
              ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Filter Option model
// ────────────────────────────────────────────────────────────────────────────
class _FilterOption {
  final String label;
  final EstadoAsistencia? value;
  final IconData icon;

  const _FilterOption({
    required this.label,
    required this.value,
    required this.icon,
  });
}
