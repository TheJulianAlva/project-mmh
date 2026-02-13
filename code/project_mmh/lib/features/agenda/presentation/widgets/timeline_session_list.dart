import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_mmh/features/agenda/domain/sesion_rich_model.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/session_action_dialog.dart';
import 'package:project_mmh/core/presentation/widgets/custom_bottom_sheet.dart';
import 'package:intl/intl.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Period grouping for timeline sections
// ──────────────────────────────────────────────────────────────────────────────

enum TimePeriod { manana, tarde, noche }

class PeriodGroup {
  final TimePeriod period;
  final List<SesionRichModel> sessions;

  PeriodGroup({required this.period, required this.sessions});

  String get label {
    switch (period) {
      case TimePeriod.manana:
        return 'Mañana';
      case TimePeriod.tarde:
        return 'Tarde';
      case TimePeriod.noche:
        return 'Noche';
    }
  }

  IconData get icon {
    switch (period) {
      case TimePeriod.manana:
        return CupertinoIcons.sun_max_fill;
      case TimePeriod.tarde:
        return CupertinoIcons.sun_haze_fill;
      case TimePeriod.noche:
        return CupertinoIcons.moon_fill;
    }
  }
}

/// Groups sessions by time period: Mañana (<12h), Tarde (12-18h), Noche (>=18h)
List<PeriodGroup> groupByPeriod(List<SesionRichModel> sessions) {
  final Map<TimePeriod, List<SesionRichModel>> map = {};

  for (final s in sessions) {
    final hour = DateTime.parse(s.sesion.fechaInicio).hour;
    final TimePeriod period;
    if (hour < 12) {
      period = TimePeriod.manana;
    } else if (hour < 18) {
      period = TimePeriod.tarde;
    } else {
      period = TimePeriod.noche;
    }
    map.putIfAbsent(period, () => []).add(s);
  }

  return [TimePeriod.manana, TimePeriod.tarde, TimePeriod.noche]
      .where((p) => map.containsKey(p))
      .map((p) => PeriodGroup(period: p, sessions: map[p]!))
      .toList();
}

// ──────────────────────────────────────────────────────────────────────────────
// Timeline Session List — main widget with staggered entry animations
// ──────────────────────────────────────────────────────────────────────────────

class TimelineSessionList extends StatefulWidget {
  final List<SesionRichModel> sessions;

  const TimelineSessionList({super.key, required this.sessions});

  @override
  State<TimelineSessionList> createState() => _TimelineSessionListState();
}

class _TimelineSessionListState extends State<TimelineSessionList>
    with TickerProviderStateMixin {
  static const double _timelineLeftPadding = 56.0;
  static const double _lineXCenter = 36.0;
  static const double _nodeRadius = 5.0;

  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didUpdateWidget(TimelineSessionList oldWidget) {
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
    final groups = groupByPeriod(widget.sessions);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Flatten to get session index for animation mapping
    int sessionIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int gi = 0; gi < groups.length; gi++) ...[
          // ── Period Header ──
          _PeriodHeader(group: groups[gi]),
          // ── Timeline Cards ──
          for (int si = 0; si < groups[gi].sessions.length; si++)
            Builder(
              builder: (context) {
                final idx = sessionIndex++;
                if (idx >= _fadeAnimations.length) {
                  // Safety fallback: no animation
                  return _TimelineRow(
                    session: groups[gi].sessions[si],
                    isFirst: gi == 0 && si == 0,
                    isLast:
                        gi == groups.length - 1 &&
                        si == groups[gi].sessions.length - 1,
                    colorScheme: colorScheme,
                    isDark: isDark,
                    lineXCenter: _lineXCenter,
                    leftPadding: _timelineLeftPadding,
                    nodeRadius: _nodeRadius,
                  );
                }
                return FadeTransition(
                  opacity: _fadeAnimations[idx],
                  child: SlideTransition(
                    position: _slideAnimations[idx],
                    child: _TimelineRow(
                      session: groups[gi].sessions[si],
                      isFirst: gi == 0 && si == 0,
                      isLast:
                          gi == groups.length - 1 &&
                          si == groups[gi].sessions.length - 1,
                      colorScheme: colorScheme,
                      isDark: isDark,
                      lineXCenter: _lineXCenter,
                      leftPadding: _timelineLeftPadding,
                      nodeRadius: _nodeRadius,
                    ),
                  ),
                );
              },
            ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Period Header (Mañana, Tarde, Noche)
// ──────────────────────────────────────────────────────────────────────────────

class _PeriodHeader extends StatelessWidget {
  final PeriodGroup group;

  const _PeriodHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Icon(
            group.icon,
            size: 16,
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            group.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: colorScheme.primary.withValues(alpha: 0.12),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Timeline Row — time label, node, vertical line, card
// ──────────────────────────────────────────────────────────────────────────────

class _TimelineRow extends StatelessWidget {
  final SesionRichModel session;
  final bool isFirst;
  final bool isLast;
  final ColorScheme colorScheme;
  final bool isDark;
  final double lineXCenter;
  final double leftPadding;
  final double nodeRadius;

  const _TimelineRow({
    required this.session,
    required this.isFirst,
    required this.isLast,
    required this.colorScheme,
    required this.isDark,
    required this.lineXCenter,
    required this.leftPadding,
    required this.nodeRadius,
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
                  top: isFirst ? 20 : 0,
                  bottom: isLast ? 20 : 0,
                  child: Container(
                    width: 1.5,
                    color: colorScheme.primary.withValues(
                      alpha: isDark ? 0.10 : 0.18,
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
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                // Node dot
                Positioned(
                  left: lineXCenter - nodeRadius,
                  top: 18,
                  child: _AnimatedNode(
                    color: _getNodeColor(),
                    radius: nodeRadius,
                    borderColor: colorScheme.surface,
                  ),
                ),
              ],
            ),
          ),
          // ── Card ──
          Expanded(
            child: _TimelineSessionCard(
              session: session,
              colorScheme: colorScheme,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNodeColor() {
    switch (session.sesion.estadoAsistencia) {
      case 'asistio':
        return colorScheme.secondary;
      case 'falto':
        return Colors.orange;
      default:
        return colorScheme.primary;
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Animated Node — subtle scale-in pulse on appear
// ──────────────────────────────────────────────────────────────────────────────

class _AnimatedNode extends StatefulWidget {
  final Color color;
  final double radius;
  final Color borderColor;

  const _AnimatedNode({
    required this.color,
    required this.radius,
    required this.borderColor,
  });

  @override
  State<_AnimatedNode> createState() => _AnimatedNodeState();
}

class _AnimatedNodeState extends State<_AnimatedNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          border: Border.all(color: widget.borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Timeline Session Card (compact, with accent bar)
// ──────────────────────────────────────────────────────────────────────────────

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
    final clinicColor = _parseColor(session.colorClinica);

    return GestureDetector(
      onTap: () {
        showCustomBottomSheet(
          context: context,
          child: SessionActionSheet(sesion: session.sesion),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 5, 16, 5),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent bar
                Container(width: 4, color: clinicColor),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Treatment name
                        Text(
                          session.nombreTratamiento,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        // Time + duration
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              size: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.45,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${DateFormat('HH:mm').format(startTime)} – ${DateFormat('HH:mm').format(endTime)}  ·  $durationStr',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.55,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        // Patient + clinic
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.person,
                              size: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.45,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${session.nombrePaciente}  ·  ${session.nombreClinica}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.55,
                                  ),
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Status badge
                        _buildStatusBadge(
                          context,
                          session.sesion.estadoAsistencia,
                        ),
                      ],
                    ),
                  ),
                ),
                // Chevron
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    CupertinoIcons.chevron_right,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    final colorScheme = Theme.of(context).colorScheme;

    late Color color;
    late String label;
    late IconData icon;

    switch (status) {
      case 'asistio':
        color = colorScheme.secondary;
        label = 'ASISTIÓ';
        icon = CupertinoIcons.checkmark_alt;
        break;
      case 'falto':
        color = Colors.orange;
        label = 'NO ASISTIÓ';
        icon = CupertinoIcons.person_badge_minus;
        break;
      default:
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

  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('Color(')) {
        String value = colorStr.split('(')[1].split(')')[0];
        return Color(int.parse(value));
      } else {
        String cleanHex = colorStr
            .replaceAll('#', '')
            .replaceAll('0x', '')
            .replaceAll('0X', '');
        if (cleanHex.length == 6) {
          return Color(int.parse(cleanHex, radix: 16) + 0xFF000000);
        } else if (cleanHex.length == 8) {
          return Color(int.parse(cleanHex, radix: 16));
        } else {
          return Color(int.parse(cleanHex, radix: 16) + 0xFF000000);
        }
      }
    } catch (_) {
      return colorScheme.secondary;
    }
  }
}
