import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/features/agenda/domain/sesion_rich_model.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/session_action_dialog.dart';
import 'package:project_mmh/core/presentation/widgets/custom_bottom_sheet.dart';
import 'package:project_mmh/features/core/presentation/widgets/app_entity_card.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Date grouping for treatment timeline
// ──────────────────────────────────────────────────────────────────────────────

class DateGroup {
  final DateTime date;
  final List<SesionRichModel> sessions;

  DateGroup({required this.date, required this.sessions});

  String get label {
    // Format: "Lunes, 12 Feb 2024"
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isTomorrow =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1;

    if (isToday) return 'Hoy';
    if (isTomorrow) return 'Mañana';

    final str = DateFormat("EEEE d 'de' MMMM", 'es_ES').format(date);
    return str[0].toUpperCase() + str.substring(1);
  }
}

List<DateGroup> groupByDate(List<SesionRichModel> sessions) {
  final Map<String, List<SesionRichModel>> map = {};
  final Map<String, DateTime> dateMap = {};

  // Sort sessions by date descending (newest first) for Treatment History
  sessions.sort((a, b) => b.sesion.fechaInicio.compareTo(a.sesion.fechaInicio));

  for (final s in sessions) {
    final date = DateTime.parse(s.sesion.fechaInicio);
    final key = DateFormat('yyyy-MM-dd').format(date); // Distinct by day

    if (!map.containsKey(key)) {
      map[key] = [];
      dateMap[key] = date;
    }
    map[key]!.add(s);
  }

  return map.keys
      .map((key) => DateGroup(date: dateMap[key]!, sessions: map[key]!))
      .toList();
}

// ──────────────────────────────────────────────────────────────────────────────
// Treatment Timeline List
// ──────────────────────────────────────────────────────────────────────────────

class TreatmentTimelineList extends StatefulWidget {
  final List<SesionRichModel> sessions;

  const TreatmentTimelineList({super.key, required this.sessions});

  @override
  State<TreatmentTimelineList> createState() => _TreatmentTimelineListState();
}

class _TreatmentTimelineListState extends State<TreatmentTimelineList>
    with TickerProviderStateMixin {
  static const double _timelineLeftPadding = 56.0;
  static const double _lineXCenter = 36.0;
  static const double _nodeRadius = 6.0;

  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didUpdateWidget(TreatmentTimelineList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessions.length != widget.sessions.length ||
        (widget.sessions.isNotEmpty &&
            oldWidget.sessions.isNotEmpty &&
            oldWidget.sessions.first.sesion.idSesion !=
                widget.sessions.first.sesion.idSesion)) {
      _disposeAnimations();
      _initAnimations();
    }
  }

  void _initAnimations() {
    final count = widget.sessions.length;
    _controllers = List.generate(
      count,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _fadeAnimations =
        _controllers.map((c) {
          return CurvedAnimation(parent: c, curve: Curves.easeOut);
        }).toList();

    _slideAnimations =
        _controllers.map((c) {
          return Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
        }).toList();

    // Stagger the animations
    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: 60 * i), () {
        if (mounted && i < _controllers.length) {
          _controllers[i].forward();
        }
      });
    }
  }

  void _disposeAnimations() {
    for (final c in _controllers) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = groupByDate(widget.sessions);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int sessionIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int gi = 0; gi < groups.length; gi++) ...[
          // ── Date Header ──
          _DateHeader(group: groups[gi]),

          // ── Timeline Cards ──
          for (int si = 0; si < groups[gi].sessions.length; si++)
            Builder(
              builder: (context) {
                final idx = sessionIndex++;
                if (idx >= _fadeAnimations.length) {
                  return _TimelineRow(
                    session: groups[gi].sessions[si],
                    isFirst:
                        false, // In treatment detail, we want continuous line style usually, or per group
                    isLast:
                        si == groups[gi].sessions.length - 1 &&
                        gi == groups.length - 1,
                    colorScheme: colorScheme,
                    isDark: isDark,
                    lineXCenter: _lineXCenter,
                    leftPadding: _timelineLeftPadding,
                    nodeRadius: _nodeRadius,
                    showDate: false, // Date is in header
                  );
                }
                return FadeTransition(
                  opacity: _fadeAnimations[idx],
                  child: SlideTransition(
                    position: _slideAnimations[idx],
                    child: _TimelineRow(
                      session: groups[gi].sessions[si],
                      isFirst: false,
                      isLast:
                          si == groups[gi].sessions.length - 1 &&
                          gi == groups.length - 1,
                      colorScheme: colorScheme,
                      isDark: isDark,
                      lineXCenter: _lineXCenter,
                      leftPadding: _timelineLeftPadding,
                      nodeRadius: _nodeRadius,
                      showDate: false,
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateGroup group;

  const _DateHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPast = group.date.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isPast
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              group.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color:
                    isPast
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final SesionRichModel session;
  final bool isFirst;
  final bool isLast;
  final ColorScheme colorScheme;
  final bool isDark;
  final double lineXCenter;
  final double leftPadding;
  final double nodeRadius;
  final bool showDate;

  const _TimelineRow({
    required this.session,
    required this.isFirst,
    required this.isLast,
    required this.colorScheme,
    required this.isDark,
    required this.lineXCenter,
    required this.leftPadding,
    required this.nodeRadius,
    required this.showDate,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime.parse(session.sesion.fechaInicio);
    final timeStr = DateFormat('HH:mm').format(startTime);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left column: time + line ──
          SizedBox(
            width: leftPadding,
            child: Stack(
              children: [
                // Vertical line
                Positioned(
                  left: lineXCenter - 0.5,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 1.5,
                    color:
                        isLast
                            ? Colors.transparent
                            : colorScheme.primary.withValues(
                              alpha: isDark ? 0.10 : 0.15,
                            ),
                    // Gradient?
                    decoration:
                        isLast
                            ? BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colorScheme.primary.withValues(alpha: 0.15),
                                  colorScheme.primary.withValues(alpha: 0.0),
                                ],
                              ),
                            )
                            : null,
                  ),
                ),
                // Time label
                Positioned(
                  left: 4,
                  top: 14,
                  child: Text(
                    timeStr,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                // Node dot
                Positioned(
                  left: lineXCenter - nodeRadius,
                  top: 18,
                  child: Container(
                    width: nodeRadius * 2,
                    height: nodeRadius * 2,
                    decoration: BoxDecoration(
                      color: _getNodeColor(),
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _getNodeColor().withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Card ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TimelineSessionCard(
                session: session,
                colorScheme: colorScheme,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNodeColor() {
    switch (session.sesion.estadoAsistencia) {
      case 'asistio':
        return Colors.green;
      case 'falto':
        return Colors.redAccent;
      case 'programada':
      default:
        return colorScheme.primary;
    }
  }
}

class _TimelineSessionCard extends StatelessWidget {
  final SesionRichModel session;
  final ColorScheme colorScheme;
  final bool isDark;

  const _TimelineSessionCard({
    required this.session,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime.parse(session.sesion.fechaInicio);
    final endTime = DateTime.parse(session.sesion.fechaFin);
    final duration = endTime.difference(startTime);
    final durationStr = "${duration.inHours}h ${duration.inMinutes % 60}m";

    return AppEntityCard(
      accentColor: _getNodeColor(),
      onTap: () {
        showCustomBottomSheet(
          context: context,
          child: SessionActionSheet(sesion: session.sesion),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sesión de ${session.nombreTratamiento}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              _buildStatusPill(context, session.sesion.estadoAsistencia),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                CupertinoIcons.clock,
                size: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 4),
              Text(
                '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)} · $durationStr',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getNodeColor() {
    switch (session.sesion.estadoAsistencia) {
      case 'asistio':
        return Colors.green;
      case 'falto':
        return Colors.redAccent;
      default:
        return colorScheme.primary;
    }
  }

  Widget _buildStatusPill(BuildContext context, String? status) {
    Color color;
    String text;
    if (status == 'asistio') {
      color = Colors.green;
      text = 'Asistió';
    } else if (status == 'falto') {
      color = Colors.redAccent;
      text = 'Faltó';
    } else {
      color = colorScheme.primary;
      text = 'Programada';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
