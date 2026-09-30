import 'package:flutter/material.dart';

import '../data/student_store.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  Future<void> _addRecord(BuildContext context) async {
    final course = TextEditingController();
    final note = TextEditingController();
    var date = DateTime.now();
    var status = AttendanceStatus.present;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.tr('Add attendance')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: course,
                  decoration: InputDecoration(
                    labelText: context.tr('Course'),
                  ),
                ),
                DropdownButtonFormField<AttendanceStatus>(
                  initialValue: status,
                  decoration: InputDecoration(
                    labelText: context.tr('Status'),
                  ),
                  items: AttendanceStatus.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(_statusLabel(context, item)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => status = value);
                  },
                ),
                TextField(
                  controller: note,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: context.tr('Note (optional)'),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('Date')),
                  trailing: Text(_dateText(date)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setState(() => date = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr('Cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (course.text.trim().isEmpty) return;
                StudentStore.instance.addAttendance(
                  course.text,
                  date,
                  status,
                  note: note.text,
                );
                Navigator.pop(dialogContext);
              },
              child: Text(context.tr('Save')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppShell(
    index: 5,
    child: AnimatedBuilder(
      animation: StudentStore.instance,
      builder: (context, _) {
        final store = StudentStore.instance;
        final records = [...store.attendance]
          ..sort((a, b) => b.date.compareTo(a.date));
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addRecord(context),
            icon: const Icon(Icons.add),
            label: Text(context.tr('Attendance')),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const PageHeader(
                title: 'Attendance',
                subtitle: 'Keep track of every class and stay on target.',
                showBackButton: true,
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  leading: Icon(
                    Icons.fact_check_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(context.tr('Attendance rate')),
                  subtitle: Text(
                    '${store.attendance.length} ${context.tr('records')}',
                  ),
                  trailing: Text(
                    '${(store.attendanceRate * 100).round()}%',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (records.isEmpty)
                ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(context.tr('No attendance records yet')),
                  subtitle: Text(context.tr('Add your first class record.')),
                )
              else
                ...records.map(
                  (record) => Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _statusColor(context, record.status)
                            .withValues(alpha: 0.14),
                        child: Icon(
                          _statusIcon(record.status),
                          color: _statusColor(context, record.status),
                        ),
                      ),
                      title: Text(record.course),
                      subtitle: Text(
                        '${_dateText(record.date)} · ${_statusLabel(context, record.status)}${record.note.isEmpty ? '' : ' · ${record.note}'}',
                      ),
                      trailing: IconButton(
                        tooltip: context.tr('Delete'),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => store.deleteAttendance(record),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

String _dateText(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _statusLabel(BuildContext context, AttendanceStatus status) =>
    context.tr(status.name[0].toUpperCase() + status.name.substring(1));

IconData _statusIcon(AttendanceStatus status) => switch (status) {
  AttendanceStatus.present => Icons.check_circle_outline,
  AttendanceStatus.absent => Icons.cancel_outlined,
  AttendanceStatus.late => Icons.schedule_outlined,
  AttendanceStatus.excused => Icons.assignment_turned_in_outlined,
};

Color _statusColor(BuildContext context, AttendanceStatus status) =>
    switch (status) {
      AttendanceStatus.present => Colors.green,
      AttendanceStatus.absent => Theme.of(context).colorScheme.error,
      AttendanceStatus.late => Colors.orange,
      AttendanceStatus.excused => Theme.of(context).colorScheme.primary,
    };
