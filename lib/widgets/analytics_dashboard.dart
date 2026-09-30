import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/student_store.dart';
import 'depth_card.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key, required this.store});

  final StudentStore store;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100
        ? 3
        : width >= 700
        ? 2
        : 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General data analysis',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'A clear view of your student routine.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 1 ? 1.55 : 1.25,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _AnalyticsCard(
                title: 'Task completion',
                icon: Icons.task_alt,
                child: _CompletionChart(store: store),
              ),
              _AnalyticsCard(
                title: 'Weekly workload',
                icon: Icons.bar_chart_rounded,
                child: _WorkloadChart(store: store),
              ),
              _AnalyticsCard(
                title: 'Priority balance',
                icon: Icons.flag_outlined,
                child: _PriorityChart(store: store),
              ),
              _AnalyticsCard(
                title: 'Spending categories',
                icon: Icons.pie_chart_outline,
                child: _SpendingChart(store: store),
              ),
              _AnalyticsCard(
                title: 'Weekly schedule',
                icon: Icons.calendar_month_outlined,
                child: _ScheduleChart(store: store),
              ),
              _AnalyticsCard(
                title: 'Activity snapshot',
                icon: Icons.insights_outlined,
                child: _Snapshot(store: store),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => DepthCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(child: child),
      ],
    ),
  );
}

class _CompletionChart extends StatelessWidget {
  const _CompletionChart({required this.store});

  final StudentStore store;

  @override
  Widget build(BuildContext context) {
    final total = store.tasks.length;
    final ratio = total == 0 ? 0.0 : store.completedTasks / total;
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: CustomPaint(
            painter: _RingPainter(
              progress: ratio,
              color: Theme.of(context).colorScheme.primary,
              trackColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Center(
              child: Text(
                '${(ratio * 100).round()}%',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            total == 0
                ? 'Add tasks to see your progress.'
                : '${store.completedTasks} of $total tasks completed.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _WorkloadChart extends StatelessWidget {
  const _WorkloadChart({required this.store});

  final StudentStore store;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final values = List.generate(7, (index) {
      final date = DateTime(today.year, today.month, today.day + index);
      return store.tasks.where((task) {
        return task.dueDate.year == date.year &&
            task.dueDate.month == date.month &&
            task.dueDate.day == date.day;
      }).length;
    });
    final labels = List.generate(7, (index) {
      final date = DateTime(today.year, today.month, today.day + index);
      return index == 0 ? 'Today' : _weekday(date.weekday);
    });
    return _BarChart(values: values, labels: labels);
  }
}

class _PriorityChart extends StatelessWidget {
  const _PriorityChart({required this.store});

  final StudentStore store;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _BarChart(
      values: [
        store.tasks.where((task) => task.priority == TaskPriority.high).length,
        store.tasks.where((task) => task.priority == TaskPriority.medium).length,
        store.tasks.where((task) => task.priority == TaskPriority.low).length,
      ],
      labels: const ['High', 'Medium', 'Low'],
      colors: [scheme.error, scheme.tertiary, scheme.secondary],
    );
  }
}

class _SpendingChart extends StatelessWidget {
  const _SpendingChart({required this.store});

  final StudentStore store;

  @override
  Widget build(BuildContext context) {
    final chartColors = _chartColors(context);
    final totals = <String, double>{};
    for (final expense in store.expenses) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final visible = entries.take(4).toList();
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: CustomPaint(
            painter: _DonutPainter(
              values: visible.map((entry) => entry.value).toList(),
              colors: chartColors,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: visible.isEmpty
              ? const Text('Add expenses to see category trends.')
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < visible.length; index++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            _Dot(color: chartColors[index % chartColors.length]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                visible[index].key,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(visible[index].value.toStringAsFixed(0)),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ScheduleChart extends StatelessWidget {
  const _ScheduleChart({required this.store});

  final StudentStore store;

  @override
  Widget build(BuildContext context) {
    final values = List.generate(
      7,
      (index) =>
          store.schedule.where((item) => _dayIndex(item.day) == index).length,
    );
    return _BarChart(
      values: values,
      labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      colors: [Theme.of(context).colorScheme.tertiary],
    );
  }
}

class _Snapshot extends StatelessWidget {
  const _Snapshot({required this.store});

  final StudentStore store;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _SnapshotRow(
        icon: Icons.event_outlined,
        label: 'Campus events',
        value: '${store.events.length}',
      ),
      _SnapshotRow(
        icon: Icons.calendar_today_outlined,
        label: 'Classes planned',
        value: '${store.schedule.length}',
      ),
      _SnapshotRow(
        icon: Icons.warning_amber_rounded,
        label: 'Overdue tasks',
        value: '${store.tasks.where((task) => task.isOverdue).length}',
      ),
    ],
  );
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.values, required this.labels, this.colors});

  final List<int> values;
  final List<String> labels;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(1, math.max);
    final palette = colors ?? [Theme.of(context).colorScheme.primary];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var index = 0; index < values.length; index++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${values[index]}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: values[index] / maxValue,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: palette[index % palette.length],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    labels[index],
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    final value = base..color = color;
    canvas.drawCircle(center, radius, base..color = trackColor);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      value,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    if (total == 0) return;
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 5;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    var start = -math.pi / 2;
    for (var index = 0; index < values.length; index++) {
      final sweep = math.pi * 2 * values[index] / total;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint..color = colors[index % colors.length],
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

List<Color> _chartColors(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return [scheme.primary, scheme.secondary, scheme.tertiary, scheme.error];
}

int _dayIndex(String day) => const [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
].indexOf(day.toLowerCase());

String _weekday(int weekday) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
