import 'package:flutter/material.dart';

import '../data/student_store.dart';

class RoutineChart extends StatelessWidget {
  const RoutineChart({super.key, required this.tasks});

  final List<StudentTask> tasks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final days = List.generate(7, (index) {
      final date = DateTime(today.year, today.month, today.day + index);
      final dayTasks = tasks.where((task) {
        final due = task.dueDate;
        return due.year == date.year &&
            due.month == date.month &&
            due.day == date.day;
      }).toList();
      return _DayWorkload(
        label: index == 0 ? 'Today' : _weekday(date.weekday),
        planned: dayTasks.length,
        open: dayTasks.where((task) => !task.done).length,
        isToday: index == 0,
      );
    });
    final maxTasks = days.fold<int>(
      1,
      (max, day) => day.planned > max ? day.planned : max,
    );

    return Column(
      children: days
          .map(
            (day) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Text(
                      day.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: day.isToday ? FontWeight.bold : null,
                        color: day.isToday ? scheme.primary : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Container(
                            height: 14,
                            color: scheme.primary.withValues(alpha: 0.14),
                          ),
                          FractionallySizedBox(
                            widthFactor: day.planned / maxTasks,
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: day.isToday
                                    ? scheme.primary
                                    : scheme.primary.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 54,
                    child: Text(
                      day.planned == 0 ? 'Free' : '${day.open} open',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayWorkload {
  const _DayWorkload({
    required this.label,
    required this.planned,
    required this.open,
    required this.isToday,
  });

  final String label;
  final int planned;
  final int open;
  final bool isToday;
}

String _weekday(int weekday) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
