import 'package:flutter/material.dart';

import '../data/student_store.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class WeeklyReportPage extends StatelessWidget {
  const WeeklyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudentStore.instance;
    final completion = store.tasks.isEmpty
        ? 0.0
        : store.completedTasks / store.tasks.length;
    return AppShell(
      index: 0,
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const PageHeader(
              title: 'Weekly report',
              subtitle: 'A simple reflection on your current routine.',
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: completion, minHeight: 10),
                      const SizedBox(height: 8),
                      Text(
                        '${(completion * 100).round()}% of your tasks are complete.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ReportTile(
              icon: Icons.local_fire_department_outlined,
              title: 'Study streak',
              value: '${store.studyStreak} days',
            ),
            _ReportTile(
              icon: Icons.task_alt,
              title: 'Tasks completed',
              value: '${store.completedTasks}',
            ),
            _ReportTile(
              icon: Icons.calendar_month_outlined,
              title: 'Classes planned',
              value: '${store.schedule.length}',
            ),
            _ReportTile(
              icon: Icons.wallet_outlined,
              title: 'Total spending',
              value: 'USD ${store.totalExpenses.toStringAsFixed(2)}',
            ),
            _ReportTile(
              icon: Icons.event_outlined,
              title: 'Campus events',
              value: '${store.events.length}',
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    child: ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
