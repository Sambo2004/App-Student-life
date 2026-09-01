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

  Future<void> _editClass(BuildContext context, ClassSchedule item) async {
    final subject = TextEditingController(text: item.subject);
    final room = TextEditingController(text: item.room);
    var selectedTime = _parseTime(item.time);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subject,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: room,
                decoration: const InputDecoration(labelText: 'Room'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (subject.text.trim().isEmpty || room.text.trim().isEmpty) {
                  return;
                }
                StudentStore.instance.updateClass(
                  item,
                  ClassSchedule(
                    subject: subject.text.trim(),
                    time: _formatTime(selectedTime),
                    room: room.text.trim(),
                    day: item.day,
                    endTime: item.endTime,
                    instructor: item.instructor,
                    notes: item.notes,
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
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
                    trailing: Wrap(
                      children: [
                        IconButton(
                          tooltip: 'Edit class',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editClass(context, item),
                        ),
                        IconButton(
                          tooltip: 'Delete class',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              StudentStore.instance.deleteClass(item),
                        ),
                      ],
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

TimeOfDay _parseTime(String value) {
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    caseSensitive: false,
  ).firstMatch(value.trim());
  if (match == null) return const TimeOfDay(hour: 9, minute: 0);
  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final isPm = match.group(3)!.toUpperCase() == 'PM';
  if (hour == 12) hour = 0;
  if (isPm) hour += 12;
  return TimeOfDay(hour: hour, minute: minute);
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
