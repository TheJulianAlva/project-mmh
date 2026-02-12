import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/session_action_dialog.dart';
import 'package:table_calendar/table_calendar.dart' hide isSameDay;
import 'package:table_calendar/table_calendar.dart' as tc show isSameDay;
import 'package:project_mmh/core/presentation/widgets/custom_bottom_sheet.dart';
import 'package:intl/intl.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  final String? initialAction;
  const AgendaScreen({super.key, this.initialAction});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    if (widget.initialAction == 'new') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openAppointmentForm();
      });
    }
  }

  // Handle widget updates (if navigating while already built)
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
              'No se pueden crear tratamientos sin clínicas registradas. Por favor, registre una clínica primero en Configuración.',
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

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final sessionsAsync = ref.watch(allSesionesProvider);
    final sessionsToday = ref.watch(sessionsOnSelectedDateProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Agenda'),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.9),
            trailing: TextButton(
              onPressed: _openAppointmentForm,
              child: const Text(
                'Añadir',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: sessionsAsync.when(
              data:
                  (allSessions) => TableCalendar(
                    locale: 'es_ES',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: selectedDate,
                    calendarFormat: _calendarFormat,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selectedDayPredicate: (day) {
                      return tc.isSameDay(selectedDate, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      ref.read(selectedDateProvider.notifier).state =
                          selectedDay;
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
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      weekendTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          const SliverToBoxAdapter(
            child: Column(
              children: [Divider(height: 1), SizedBox(height: 8.0)],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final sesion = sessionsToday[index];
              return _buildSessionCard(context, sesion, ref);
            }, childCount: sessionsToday.length),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, sesion, WidgetRef ref) {
    final startTime = DateTime.parse(sesion.fechaInicio);
    final endTime = DateTime.parse(sesion.fechaFin);
    final duration = endTime.difference(startTime);
    final durationStr = "${duration.inHours}h ${duration.inMinutes % 60}m";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: FutureBuilder(
          future: ref.read(
            tratamientoByIdProvider(sesion.idTratamiento).future,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                snapshot.data?.nombreTratamiento ?? 'Tratamiento',
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            }
            return const Text('Cargando...');
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)} ($durationStr)',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: ShapeDecoration(
                color: _getStatusColor(
                  sesion.estadoAsistencia,
                ).withValues(alpha: 0.1),
                shape: const StadiumBorder(),
              ),
              child: Text(
                (sesion.estadoAsistencia ?? 'Programada').toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(sesion.estadoAsistencia),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          showCustomBottomSheet(
            context: context,
            child: SessionActionSheet(sesion: sesion),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'concluido':
        return Theme.of(context).colorScheme.secondary; // Teal
      case 'cancelo':
        return Theme.of(context).colorScheme.error;
      case 'falto':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary; // Default/Programada
    }
  }
}
