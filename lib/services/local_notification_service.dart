import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/student_store.dart';

/// Schedules task reminders on the device without requiring an account or
/// network connection. Unsupported platforms simply continue without alerts.
class LocalNotificationService {
  LocalNotificationService._();

  static final instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> initialize() async {
    if (_ready || kIsWeb) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Phnom_Penh'));
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('student_life_icon'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      windows: WindowsInitializationSettings(
        appName: 'Student Life Hub',
        appUserModelId: 'com.example.student_life',
        guid: '5b07f7d8-2c9d-4e56-b4f5-9d1d740b2b37',
      ),
    );

    try {
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
      final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
      await android?.requestNotificationsPermission();
      _ready = true;
    } catch (_) {
      // Notifications must never prevent the offline app from starting.
    }
  }

  Future<void> syncTasks(Iterable<StudentTask> tasks) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      for (final task in tasks.where((task) => !task.done)) {
        final reminder = tz.TZDateTime(
          tz.local,
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
          8,
        );
        if (!reminder.isAfter(tz.TZDateTime.now(tz.local))) continue;
        await _plugin.zonedSchedule(
          id: _notificationId(task),
          title: task.isExam ? 'Exam reminder' : 'Assignment reminder',
          body: task.title,
          scheduledDate: reminder,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'student_life_tasks',
              'Task reminders',
              channelDescription: 'Upcoming assignment and exam reminders',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
            macOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'task:${task.title}',
        );
      }
    } catch (_) {
      // A platform may reject scheduling; local task storage remains safe.
    }
  }

  void _onNotificationResponse(NotificationResponse response) {}

  int _notificationId(StudentTask task) {
    var result = 17;
    for (final codeUnit
        in '${task.title}|${task.dueDate.toIso8601String()}'.codeUnits) {
      result = (result * 31 + codeUnit) & 0x7fffffff;
    }
    return result == 0 ? 1 : result;
  }
}
