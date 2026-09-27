import 'dart:convert';

import 'package:share_plus/share_plus.dart';

import '../data/student_store.dart';

class CalendarExportService {
  const CalendarExportService._();

  static Future<void> shareCalendar(StudentStore store) async {
    final bytes = utf8.encode(_buildIcs(store));
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
          bytes,
          name: 'student-life-calendar.ics',
          mimeType: 'text/calendar',
          ),
        ],
        fileNameOverrides: const ['student-life-calendar.ics'],
      ),
    );
  }

  static String _buildIcs(StudentStore store) {
    final events = <String>[];
    for (final task in store.tasks) {
      events.add(_event(
        uid: 'task-${task.title}-${task.dueDate.toIso8601String()}',
        title: '${task.isExam ? 'Exam' : 'Task'}: ${task.title}',
        date: task.dueDate,
        description: task.notes,
      ));
    }
    for (final event in store.events) {
      final date = DateTime.tryParse(event.date);
      if (date == null) continue;
      events.add(_event(
        uid: 'event-${event.title}-${event.date}',
        title: event.title,
        date: date,
        location: event.place,
        description: event.description,
      ));
    }
    return 'BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Student Life Hub//EN\r\n${events.join()}END:VCALENDAR\r\n';
  }

  static String _event({
    required String uid,
    required String title,
    required DateTime date,
    String location = '',
    String description = '',
  }) {
    final start = _formatDate(date);
    return 'BEGIN:VEVENT\r\nUID:${_escape(uid)}\r\nDTSTAMP:$start\r\nDTSTART;VALUE=DATE:$start\r\nSUMMARY:${_escape(title)}\r\nLOCATION:${_escape(location)}\r\nDESCRIPTION:${_escape(description)}\r\nEND:VEVENT\r\n';
  }

  static String _formatDate(DateTime date) =>
      '${date.toUtc().year.toString().padLeft(4, '0')}${date.toUtc().month.toString().padLeft(2, '0')}${date.toUtc().day.toString().padLeft(2, '0')}';

  static String _escape(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll('\n', r'\n');
}
