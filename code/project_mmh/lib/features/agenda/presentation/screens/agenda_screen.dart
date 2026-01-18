import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/appointment_form.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/session_action_dialog.dart';
import 'package:table_calendar/table_calendar.dart' hide isSameDay;
import 'package:table_calendar/table_calendar.dart' as tc show isSameDay;
import 'package:intl/intl.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final sessionsAsync = ref.watch(allSesionesProvider);
    final sessionsToday = ref.watch(sessionsOnSelectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda y Citas'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.today, color: Theme.of(context).primaryColor),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime.now();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          sessionsAsync.when(
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
                    ref.read(selectedDateProvider.notifier).state = selectedDay;
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  eventLoader: (day) {
                    return allSessions
                        .where(
                          (s) =>
                              tc.isSameDay(DateTime.parse(s.fechaInicio), day),
                        )
                        .toList();
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: sessionsToday.length,
              itemBuilder: (context, index) {
                final sesion = sessionsToday[index];
                return _buildSessionCard(context, sesion, ref);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AppointmentForm(initialDate: selectedDate),
            ),
          );
        },
        child: const Icon(Icons.add),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
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
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)} ($durationStr)',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  sesion.estadoAsistencia,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
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
          showDialog(
            context: context,
            builder: (_) => SessionActionDialog(sesion: sesion),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'concluido':
        return Colors.green;
      case 'cancelo':
        return Colors.red;
      case 'falto':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
