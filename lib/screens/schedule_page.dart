import 'package:flutter/material.dart';

import '../data/student_store.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  Future<void> _addClass(BuildContext context) async {
    final subject = TextEditingController();
    final room = TextEditingController();
    final instructor = TextEditingController();
    final notes = TextEditingController();
    var selectedDay = 'Monday';
    var selectedTime = const TimeOfDay(hour: 9, minute: 0);
    var selectedEndTime = const TimeOfDay(hour: 10, minute: 0);
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add class'),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          actionsOverflowDirection: VerticalDirection.down,
          actionsOverflowButtonSpacing: 8,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items: _weekdays
                      .map(
                        (day) => DropdownMenuItem(value: day, child: Text(day)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedDay = value);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: const Text('Start time'),
                  subtitle: Text(_formatTime(selectedTime)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() => selectedTime = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: const Text('End time'),
                  subtitle: Text(_formatTime(selectedEndTime)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedEndTime,
                    );
                    if (picked != null) {
                      setDialogState(() => selectedEndTime = picked);
                    }
                  },
                ),
                TextField(
                  controller: room,
                  decoration: const InputDecoration(labelText: 'Room'),
                ),
                TextField(
                  controller: instructor,
                  decoration: const InputDecoration(
                    labelText: 'Instructor (optional)',
                  ),
                ),
                TextField(
                  controller: notes,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if ([
                  subject.text,
                  room.text,
                ].any((value) => value.trim().isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Complete all class fields.')),
                  );
                  return;
                }
                StudentStore.instance.addClass(
                  subject.text,
                  _formatTime(selectedTime),
                  room.text,
                  day: selectedDay,
                  endTime: _formatTime(selectedEndTime),
                  instructor: instructor.text,
                  notes: notes.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppShell(
    index: 1,
    child: AnimatedBuilder(
      animation: StudentStore.instance,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addClass(context),
          icon: const Icon(Icons.add),
          label: const Text('Class'),
        ),
        body: ListView(
          children: [
            const PageHeader(
              title: 'Class timetable',
              subtitle: 'Your weekly class plan.',
            ),
            if (StudentStore.instance.schedule.isEmpty)
              const ListTile(title: Text('No classes added yet.'))
            else
              ...StudentStore.instance.schedule.map(
                (item) => Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.school)),
                    title: Text(item.subject),
                    subtitle: Text(
                      '${item.day} - ${item.time}${item.endTime.isEmpty ? '' : ' - ${item.endTime}'}\n'
                      '${item.room}${item.instructor.isEmpty ? '' : ' - ${item.instructor}'}'
                      '${item.notes.isEmpty ? '' : '\n${item.notes}'}',
                    ),
                    isThreeLine: item.notes.isNotEmpty,
                    trailing: IconButton(
                      tooltip: 'Delete class',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => StudentStore.instance.deleteClass(item),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
