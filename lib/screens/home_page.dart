import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../data/student_store.dart';
import '../routes/app_routes.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';
import '../widgets/routine_chart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
    index: 0,
    child: AnimatedBuilder(
      animation: StudentStore.instance,
      builder: (context, _) {
        final store = StudentStore.instance;
        return AnimatedBuilder(
          animation: AppSettings.instance,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PageHeader(
                        title:
                            'Good morning, ${AppSettings.instance.displayName}',
                        subtitle: 'Here is your day at a glance.',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage:
                            AppSettings.instance.profileImage == null
                            ? null
                            : MemoryImage(AppSettings.instance.profileImage!),
                        child: AppSettings.instance.profileImage == null
                            ? const Icon(Icons.person, size: 28)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.task_alt,
                        label: 'Tasks done',
                        value: '${store.completedTasks}/${store.tasks.length}',
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.wallet,
                        label: 'Spent',
                        value: 'USD ${store.totalExpenses.toStringAsFixed(2)}',
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Weekly momentum',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text('${store.completedTasks} completed'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: store.tasks.isEmpty
                              ? 0
                              : store.completedTasks / store.tasks.length,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Routine forecast',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${store.tasks.where((task) => task.isOverdue).length} overdue',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your task load for the next seven days',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _LegendDot(label: 'Planned', muted: true),
                            SizedBox(width: 12),
                            _LegendDot(label: 'Open'),
                          ],
                        ),
                        RoutineChart(tasks: store.tasks),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Upcoming tasks'),
              if (store.tasks.isEmpty)
                const ListTile(title: Text('You are all caught up.'))
              else
                ...store.tasks
                    .take(3)
                    .map(
                      (task) => ListTile(
                        leading: Icon(
                          task.isExam
                              ? Icons.school
                              : Icons.assignment_outlined,
                        ),
                        title: Text(task.title),
                        subtitle: Text(
                          '${task.isExam ? 'Exam' : 'Assignment'} - Due ${_dateText(task.dueDate)}',
                        ),
                        trailing: task.done
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.tasks),
                  child: const Text('View all tasks'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    color: color,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary
              .withValues(alpha: muted ? 0.3 : 1),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

String _dateText(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
