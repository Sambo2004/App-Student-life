import 'package:flutter/material.dart';

import '../data/student_store.dart';
import '../l10n/app_localizations.dart';
import '../services/calendar_export_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) => AppShell(
    index: 0,
    child: AnimatedBuilder(
      animation: StudentStore.instance,
      builder: (context, _) {
        final store = StudentStore.instance;
        final tasks = store.tasks.where(
          (task) => _sameDay(task.dueDate, _selectedDate),
        );
        final classes = store.schedule.where(
          (item) =>
              item.day.toLowerCase() ==
              _weekday(_selectedDate.weekday).toLowerCase(),
        );
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const PageHeader(
              title: 'Weekly planner',
              subtitle: 'See classes and deadlines together.',
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await CalendarExportService.shareCalendar(store);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('Could not export the calendar.')),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download_outlined),
                label: Text(context.tr('Export calendar')),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                _dateLabel(_selectedDate),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (tasks.isEmpty && classes.isEmpty)
              ListTile(title: Text(context.tr('Nothing planned for this day.'))),
            ...classes.map(
              (item) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.school_outlined)),
                title: Text(item.subject),
                subtitle: Text('${item.time} - ${item.room}'),
              ),
            ),
            ...tasks.map(
              (task) => ListTile(
                leading: Icon(task.isExam ? Icons.school : Icons.task_alt),
                title: Text(task.title),
                subtitle: Text(
                  context.tr(task.done ? 'Completed' : 'Open task'),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

String _dateLabel(DateTime date) =>
    '${_weekday(date.weekday)}, ${date.day}/${date.month}/${date.year}';

String _weekday(int weekday) => const [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][weekday - 1];
