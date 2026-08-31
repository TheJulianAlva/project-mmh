import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_date_time_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/utils/formatters.dart';

class WeeklySchedulePicker extends StatefulWidget {
  final String name;
  final String? initialValue;
  final String? label;

  const WeeklySchedulePicker({
    super.key,
    required this.name,
    this.initialValue,
    this.label,
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
          decoration: InputDecoration(
            labelText: widget.label,
            errorText: field.errorText,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_schedule.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text('No hay horarios seleccionados'),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
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
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                icon: Icons.access_time,
                label: 'Agregar Horario',
                onPressed: () => _showAddScheduleSheet(context, field),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddScheduleSheet(
    BuildContext context,
    FormFieldState<String> field,
  ) async {
    String selectedDay = _days[0];
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);

    await showAppSheet<void>(
      context,
      title: 'Agregar Horario',
      builder:
          (sheetContext) => StatefulBuilder(
            builder: (context, setStateSheet) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Día'),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: List.generate(_days.length, (index) {
                        final day = _days[index];
                        return ChoiceChip(
                          label: Text(_fullDayNames[index]),
                          selected: selectedDay == day,
                          onSelected:
                              (_) => setStateSheet(() => selectedDay = day),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Inicio'),
                      trailing: Text(formatTimeOfDay(startTime)),
                      onTap: () async {
                        final picked = await _pickTime(context, startTime);
                        if (picked != null) {
                          setStateSheet(() => startTime = picked);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fin'),
                      trailing: Text(formatTimeOfDay(endTime)),
                      onTap: () async {
                        final picked = await _pickTime(context, endTime);
                        if (picked != null) {
                          setStateSheet(() => endTime = picked);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton.text(
                          label: 'Cancelar',
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton.primary(
                          label: 'Agregar',
                          onPressed: () {
                            final start = formatTimeOfDay(startTime);
                            final end = formatTimeOfDay(endTime);
                            setState(() {
                              _schedule[selectedDay] = '$start-$end';
                              field.didChange(_formatSchedule());
                            });
                            Navigator.pop(sheetContext);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay initial) async {
    final now = DateTime.now();
    final picked = await AppDateTimeSheet.pick(
      context,
      initial: DateTime(
        now.year,
        now.month,
        now.day,
        initial.hour,
        initial.minute,
      ),
      mode: CupertinoDatePickerMode.time,
    );
    if (picked == null) return null;
    return TimeOfDay(hour: picked.hour, minute: picked.minute);
  }

  String _formatSchedule() {
    // Sort days based on standard week order
    final sortedKeys =
        _schedule.keys.toList()
          ..sort((a, b) => _days.indexOf(a).compareTo(_days.indexOf(b)));

    return sortedKeys.map((day) => '$day: ${_schedule[day]}').join(', ');
  }
}
