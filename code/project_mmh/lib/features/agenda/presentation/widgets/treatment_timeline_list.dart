import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/sesion_rich_model.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/session_action_dialog.dart';
import 'package:project_mmh/core/presentation/widgets/custom_bottom_sheet.dart';
import 'package:project_mmh/features/core/presentation/widgets/app_entity_card.dart';
import 'package:project_mmh/core/utils/formatters.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Date grouping for treatment timeline
// ──────────────────────────────────────────────────────────────────────────────

class DateGroup {
  final DateTime date;
  final List<SesionRichModel> sessions;

  DateGroup({required this.date, required this.sessions});

  String get label {
    // Diferencia en días de calendario (robusto a fin de mes / año).
    final today = DateUtils.dateOnly(DateTime.now());
    final thisDay = DateUtils.dateOnly(date);
    final diffDays = thisDay.difference(today).inDays;

    if (diffDays == 0) return 'Hoy';
    if (diffDays == 1) return 'Mañana';
    if (diffDays == -1) return 'Ayer';

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
  final VoidCallback? onRefresh;

  const TreatmentTimelineList({
    super.key,
    required this.sessions,
    this.onRefresh,
  });

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
                    onRefresh: widget.onRefresh,
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
                      onRefresh: widget.onRefresh,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              group.label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
  final VoidCallback? onRefresh;

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
    this.onRefresh,
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
                            : BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: isDark ? 0.10 : 0.15,
                              ),
                            ),
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
                onRefresh: onRefresh,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNodeColor() {
    return switch (session.sesion.estadoAsistencia) {
      EstadoAsistencia.asistio => colorScheme.secondary,
      EstadoAsistencia.falto => colorScheme.error,
      EstadoAsistencia.programada || null => colorScheme.primary,
    };
  }
}

class _TimelineSessionCard extends StatelessWidget {
  final SesionRichModel session;
  final ColorScheme colorScheme;
  final bool isDark;
  final VoidCallback? onRefresh;

  const _TimelineSessionCard({
    required this.session,
    required this.colorScheme,
    required this.isDark,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime.parse(session.sesion.fechaInicio);
    final endTime = DateTime.parse(session.sesion.fechaFin);
    final duration = endTime.difference(startTime);
    final durationStr = formatDuration(duration);

    return AppEntityCard(
      accentColor: _getNodeColor(),
      onTap: () async {
        await showCustomBottomSheet(
          context: context,
          child: SessionActionSheet(sesion: session.sesion),
        );
        onRefresh?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sesión de ${session.nombreTratamiento}',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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
          const SizedBox(height: 12),
          _buildStatusBadge(context, session.sesion.estadoAsistencia),
        ],
      ),
    );
  }

  Color _getNodeColor() {
    return switch (session.sesion.estadoAsistencia) {
      EstadoAsistencia.asistio => colorScheme.secondary,
      EstadoAsistencia.falto => colorScheme.error,
      EstadoAsistencia.programada || null => colorScheme.primary,
    };
  }

  Widget _buildStatusBadge(BuildContext context, EstadoAsistencia? status) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color color;
    final String label;
    final IconData icon;

    switch (status) {
      case EstadoAsistencia.asistio:
        color = colorScheme.secondary;
        label = 'ASISTIÓ';
        icon = CupertinoIcons.checkmark_alt;
      case EstadoAsistencia.falto:
        color = colorScheme.error;
        label = 'NO ASISTIÓ';
        icon = CupertinoIcons.person_badge_minus;
      case EstadoAsistencia.programada:
      case null:
        color = colorScheme.primary;
        label = 'PROGRAMADA';
        icon = CupertinoIcons.circle_fill;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
