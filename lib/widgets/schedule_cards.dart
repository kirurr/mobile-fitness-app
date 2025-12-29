import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/planned_exercise_program/model.dart';

class ScheduleEntry {
  final PlannedExerciseProgram planned;
  final DateTime date;
  final ExerciseProgram? program;

  const ScheduleEntry({
    required this.planned,
    required this.date,
    required this.program,
  });
}

class ScheduleCardsList extends StatelessWidget {
  final List<ScheduleEntry> entries;
  final ValueChanged<ScheduleEntry>? onTap;
  final ValueChanged<ScheduleEntry>? onLongPress;
  final Widget Function(BuildContext, ScheduleEntry)? footerBuilder;

  const ScheduleCardsList({
    super.key,
    required this.entries,
    this.onTap,
    this.onLongPress,
    this.footerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _ScheduleCard(
          entry: item,
          showConnector: index < entries.length - 1,
          onTap: onTap,
          onLongPress: onLongPress,
          footerBuilder: footerBuilder,
        );
      }).toList(),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleEntry entry;
  final bool showConnector;
  final ValueChanged<ScheduleEntry>? onTap;
  final ValueChanged<ScheduleEntry>? onLongPress;
  final Widget Function(BuildContext, ScheduleEntry)? footerBuilder;

  const _ScheduleCard({
    required this.entry,
    required this.showConnector,
    this.onTap,
    this.onLongPress,
    this.footerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorPrimary = Theme.of(context).colorScheme.primary;
    final programName =
        entry.planned.program.value?.name ??
        entry.program?.name ??
        'Program';
    final badgeText = _formatScheduleBadge(entry.date);
    final badgeIsToday = _isSameDay(entry.date, DateTime.now());
    final startTime = _formatTime(entry.date);
    final durationText = _formatProgramDuration(entry.program);
    final exerciseCount = entry.program?.programExercises.length ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeIsToday
                          ? colorPrimary.withOpacity(0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                      border: badgeIsToday
                          ? Border.all(color: colorPrimary)
                          : null,
                    ),
                    child: Text(
                      badgeIsToday ? 'Today' : badgeText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: badgeIsToday ? colorPrimary : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (showConnector) ...[
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: onTap == null ? null : () => onTap!(entry),
                onLongPress:
                    onLongPress == null ? null : () => onLongPress!(entry),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  programName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  startTime,
                                  style: TextStyle(
                                    color: colorPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.white60,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      durationText,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.fitness_center,
                                      size: 16,
                                      color: Colors.white60,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$exerciseCount exercises',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                      if (footerBuilder != null) ...[
                        const SizedBox(height: 12),
                        footerBuilder!(context, entry),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatProgramDuration(ExerciseProgram? program) {
    if (program == null) return '0 m';
    final exercises = program.programExercises.toList();
    int totalSeconds = 0;
    for (final item in exercises) {
      final sets = item.sets;
      final duration = item.duration ?? 0;
      final rest = item.restDuration;
      totalSeconds += duration * sets;
      if (rest > 0 && sets > 1) {
        totalSeconds += rest * (sets - 1);
      }
    }

    final totalMinutes = (totalSeconds / 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours <= 0) return '${minutes} m';
    if (minutes == 0) return '${hours} h';
    return '${hours} h ${minutes} m';
  }

  String _formatScheduleBadge(DateTime date) {
    if (_isSameDay(date, DateTime.now())) {
      return 'Today';
    }
    return _formatDate(date);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatTime(DateTime dateTime) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dateTime.hour)}:${two(dateTime.minute)}';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }
}
