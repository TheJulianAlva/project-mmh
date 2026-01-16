import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class WeeklySchedulePicker extends StatefulWidget {
  final String name;
  final String? initialValue;
  final InputDecoration decoration;

  const WeeklySchedulePicker({
    super.key,
    required this.name,
    this.initialValue,
    this.decoration = const InputDecoration(),
  });

  @override
  State<WeeklySchedulePicker> createState() => _WeeklySchedulePickerState();
}

class _WeeklySchedulePickerState extends State<WeeklySchedulePicker> {
  // Map to store selected days and their time ranges.
  // Key: Day name (e.g., 'Lun'), Value: TimeRange string (e.g., '08:00-10:00')
  final Map<String, String> _schedule = {};

  final List<String> _days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  final List<String> _fullDayNames = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    _parseInitialValue();
  }

  void _parseInitialValue() {
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      // Expected format: "Lun: 08:00-10:00, Mar: 09:00-11:00"
      final parts = widget.initialValue!.split(', ');
      for (final part in parts) {
        final dayTime = part.split(': ');
        if (dayTime.length == 2) {
          _schedule[dayTime[0]] = dayTime[1];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<String>(
      name: widget.name,
      initialValue: widget.initialValue,
      builder: (FormFieldState<String> field) {
        return InputDecorator(
          decoration: widget.decoration.copyWith(errorText: field.errorText),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_schedule.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('No hay horarios seleccionados'),
                )
              else
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children:
                      _schedule.entries.map((entry) {
                        return Chip(
                          label: Text('${entry.key}: ${entry.value}'),
                          onDeleted: () {
                            setState(() {
                              _schedule.remove(entry.key);
                              field.didChange(_formatSchedule());
                            });
                          },
                        );
                      }).toList(),
                ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.access_time),
                label: const Text('Agregar Horario'),
                onPressed: () => _showAddScheduleDialog(context, field),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddScheduleDialog(
    BuildContext context,
    FormFieldState<String> field,
  ) async {
    String selectedDay = _days[0];
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: const Text('Agregar Horario'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedDay,
                      decoration: const InputDecoration(labelText: 'Día'),
                      items: List.generate(_days.length, (index) {
                        return DropdownMenuItem(
                          value: _days[index],
                          child: Text(_fullDayNames[index]),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => selectedDay = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: startTime,
                              );
                              if (time != null) {
                                setStateDialog(() => startTime = time);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Inicio',
                              ),
                              child: Text(startTime.format(context)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: endTime,
                              );
                              if (time != null) {
                                setStateDialog(() => endTime = time);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fin',
                              ),
                              child: Text(endTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final start = _formatTime(startTime);
                      final end = _formatTime(endTime);

                      setState(() {
                        _schedule[selectedDay] = '$start-$end';
                        field.didChange(_formatSchedule());
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Agregar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  String _formatTime(TimeOfDay time) {
    // Force 24h format for consistency "HH:mm"
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatSchedule() {
    // Sort days based on standard week order
    final sortedKeys =
        _schedule.keys.toList()
          ..sort((a, b) => _days.indexOf(a).compareTo(_days.indexOf(b)));

    return sortedKeys.map((day) => '$day: ${_schedule[day]}').join(', ');
  }
}
