import 'package:get/get.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/local_notification_service.dart';

const _storageVersion = 2;
const _backupVersion = 2;

enum TaskPriority { low, medium, high }
enum TaskRepeat { none, daily, weekly, monthly }

enum AttendanceStatus { present, absent, late, excused }

class AttendanceRecord {
  AttendanceRecord({
    required this.course,
    required this.date,
    required this.status,
    this.note = '',
  });

  final String course;
  final DateTime date;
  final AttendanceStatus status;
  final String note;

  Map<String, Object> toJson() => {
    'course': course,
    'date': date.toIso8601String(),
    'status': status.name,
    'note': note,
  };

  static AttendanceRecord fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        course: json['course'] as String,
        date: DateTime.parse(json['date'] as String),
        status: AttendanceStatus.values.firstWhere(
          (value) => value.name == json['status'],
          orElse: () => AttendanceStatus.present,
        ),
        note: json['note'] as String? ?? '',
      );
}

class StudentTask {
  StudentTask({
    required this.title,
    required this.dueDate,
    this.isExam = false,
    this.done = false,
    this.priority = TaskPriority.medium,
    this.repeat = TaskRepeat.none,
    this.category = 'General',
    this.notes = '',
  });
  final String title;
  final DateTime dueDate;
  final bool isExam;
  bool done;
  TaskPriority priority;
  TaskRepeat repeat;
  final String category;
  final String notes;

  bool get isOverdue => !done && dueDate.isBefore(DateTime.now());

  Map<String, Object> toJson() => {
    'title': title,
    'dueDate': dueDate.toIso8601String(),
    'isExam': isExam,
    'done': done,
    'priority': priority.name,
    'repeat': repeat.name,
    'category': category,
    'notes': notes,
  };

  static StudentTask fromJson(Map<String, dynamic> json) => StudentTask(
    title: json['title'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String),
    isExam: json['isExam'] as bool? ?? false,
    done: json['done'] as bool? ?? false,
    priority: TaskPriority.values.firstWhere(
      (value) => value.name == json['priority'],
      orElse: () => TaskPriority.medium,
    ),
    repeat: TaskRepeat.values.firstWhere(
      (value) => value.name == json['repeat'],
      orElse: () => TaskRepeat.none,
    ),
    category: json['category'] as String? ?? 'General',
    notes: json['notes'] as String? ?? '',
  );
}

class StudentExpense {
  StudentExpense(
    this.title,
    this.amount,
    this.date, {
    this.category = 'Other',
    this.paymentMethod = 'Cash',
    this.notes = '',
  });
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String paymentMethod;
  final String notes;

  Map<String, Object> toJson() => {
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'paymentMethod': paymentMethod,
    'notes': notes,
  };

  static StudentExpense fromJson(Map<String, dynamic> json) => StudentExpense(
    json['title'] as String,
    (json['amount'] as num).toDouble(),
    DateTime.parse(json['date'] as String),
    category: json['category'] as String? ?? 'Other',
    paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
    notes: json['notes'] as String? ?? '',
  );
}

class ClassSchedule {
  ClassSchedule({
    required this.subject,
    required this.time,
    required this.room,
    this.day = 'Monday',
    this.endTime = '',
    this.instructor = '',
    this.notes = '',
  });
  final String subject;
  final String time;
  final String room;
  final String day;
  final String endTime;
  final String instructor;
  final String notes;

  Map<String, String> toJson() => {
    'subject': subject,
    'time': time,
    'room': room,
    'day': day,
    'endTime': endTime,
    'instructor': instructor,
    'notes': notes,
  };

  static ClassSchedule fromJson(Map<String, dynamic> json) => ClassSchedule(
    subject: json['subject'] as String,
    time: json['time'] as String,
    room: json['room'] as String,
    day: json['day'] as String? ?? 'Monday',
    endTime: json['endTime'] as String? ?? '',
    instructor: json['instructor'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
  );
}

class CampusEvent {
  CampusEvent({
    required this.title,
    required this.date,
    required this.place,
    required this.club,
    this.description = '',
  });
  final String title;
  final String date;
  final String place;
  final String club;
  final String description;

  Map<String, String> toJson() => {
    'title': title,
    'date': date,
    'place': place,
    'club': club,
    'description': description,
  };

  static CampusEvent fromJson(Map<String, dynamic> json) => CampusEvent(
    title: json['title'] as String,
    date: json['date'] as String,
    place: json['place'] as String,
    club: json['club'] as String,
    description: json['description'] as String? ?? '',
  );
}

class CourseGrade {
  CourseGrade({required this.course, required this.credits, required this.grade});

  final String course;
  final double credits;
  final String grade;

  double get points => const {
    'A': 4,
    'B': 3,
    'C': 2,
    'D': 1,
    'F': 0,
  }[grade]!.toDouble();

  Map<String, Object> toJson() => {
    'course': course,
    'credits': credits,
    'grade': grade,
  };

  static CourseGrade fromJson(Map<String, dynamic> json) => CourseGrade(
    course: json['course'] as String,
    credits: (json['credits'] as num).toDouble(),
    grade: _normalizeGrade(json['grade'] as String?),
  );
}

class StudentStore extends GetxController {
  StudentStore._();
  static final instance = StudentStore._();

  bool _initialized = false;
  String? _storageError;
  String? get storageError => _storageError;

  Future<void> initialize() async {
    if (_initialized) return;
    final preferences = await SharedPreferences.getInstance();
    final savedVersion = preferences.getInt('storageVersion');
    if (savedVersion == null || savedVersion < _storageVersion) {
      await preferences.setInt('storageVersion', _storageVersion);
    }
    final savedCompletionDays = preferences.getStringList('completionDays');
    if (savedCompletionDays != null) completedDays.addAll(savedCompletionDays);
    tasks
      ..clear()
      ..addAll(_loadList(preferences, 'tasks', StudentTask.fromJson));
    expenses
      ..clear()
      ..addAll(_loadList(preferences, 'expenses', StudentExpense.fromJson));
    schedule
      ..clear()
      ..addAll(_loadList(preferences, 'schedule', ClassSchedule.fromJson));
    events
      ..clear()
      ..addAll(_loadList(preferences, 'events', CampusEvent.fromJson));
    attendance
      ..clear()
      ..addAll(
        _loadList(preferences, 'attendance', AttendanceRecord.fromJson),
      );
    grades
      ..clear()
      ..addAll(_loadList(preferences, 'grades', CourseGrade.fromJson));
    _initialized = true;
    update();
  }

  final tasks = <StudentTask>[];
  final expenses = <StudentExpense>[];
  final schedule = <ClassSchedule>[];
  final events = <CampusEvent>[];
  final attendance = <AttendanceRecord>[];
  final grades = <CourseGrade>[];
  final completedDays = <String>{};

  int get completedTasks => tasks.where((task) => task.done).length;
  double get totalExpenses =>
      expenses.fold<double>(0, (total, item) => total + item.amount);
  double get attendanceRate {
    if (attendance.isEmpty) return 0;
    final attended = attendance
        .where(
          (item) =>
              item.status == AttendanceStatus.present ||
              item.status == AttendanceStatus.late,
        )
        .length;
    return attended / attendance.length;
  }
  double get gpa {
    final credits = grades.fold<double>(0, (total, item) => total + item.credits);
    if (credits == 0) return 0;
    return grades.fold<double>(0, (total, item) => total + item.points * item.credits) /
        credits;
  }

  int get studyStreak {
    var streak = 0;
    var date = DateTime.now();
    while (completedDays.contains(_dayKey(date))) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }

  void addTask(
    String title,
    DateTime date,
    bool exam, {
    TaskPriority priority = TaskPriority.medium,
    TaskRepeat repeat = TaskRepeat.none,
    String category = 'General',
    String notes = '',
  }) {
    if (title.trim().isEmpty) return;
    tasks.add(
      StudentTask(
        title: title.trim(),
        dueDate: date,
        isExam: exam,
        priority: priority,
        repeat: repeat,
        category: category,
        notes: notes.trim(),
      ),
    );
    _save();
    _syncTaskReminders();
    update();
  }

  void deleteTask(StudentTask task) {
    tasks.remove(task);
    _save();
    _syncTaskReminders();
    update();
  }

  void updateTask(StudentTask original, StudentTask updated) {
    final index = tasks.indexOf(original);
    if (index < 0) return;
    tasks[index] = updated;
    _save();
    _syncTaskReminders();
    update();
  }

  void restoreTask(StudentTask task) {
    tasks.add(task);
    _save();
    _syncTaskReminders();
    update();
  }

  void addClass(
    String subject,
    String time,
    String room, {
    String day = 'Monday',
    String endTime = '',
    String instructor = '',
    String notes = '',
  }) {
    if ([subject, time, room].any((value) => value.trim().isEmpty)) return;
    schedule.add(
      ClassSchedule(
        subject: subject.trim(),
        time: time.trim(),
        room: room.trim(),
        day: day,
        endTime: endTime,
        instructor: instructor.trim(),
        notes: notes.trim(),
      ),
    );
    _save();
    update();
  }

  void deleteClass(ClassSchedule item) {
    schedule.remove(item);
    _save();
    update();
  }

  void updateClass(ClassSchedule original, ClassSchedule updated) {
    final index = schedule.indexOf(original);
    if (index < 0) return;
    schedule[index] = updated;
    _save();
    update();
  }

  void addEvent(
    String title,
    String date,
    String place,
    String club, {
    String description = '',
  }) {
    if ([title, date, place, club].any((value) => value.trim().isEmpty)) return;
    events.add(
      CampusEvent(
        title: title.trim(),
        date: date.trim(),
        place: place.trim(),
        club: club.trim(),
        description: description.trim(),
      ),
    );
    _save();
    update();
  }

  void deleteEvent(CampusEvent event) {
    events.remove(event);
    _save();
    update();
  }

  void addAttendance(
    String course,
    DateTime date,
    AttendanceStatus status, {
    String note = '',
  }) {
    if (course.trim().isEmpty) return;
    attendance.insert(
      0,
      AttendanceRecord(
        course: course.trim(),
        date: date,
        status: status,
        note: note.trim(),
      ),
    );
    _save();
    update();
  }

  void deleteAttendance(AttendanceRecord record) {
    attendance.remove(record);
    _save();
    update();
  }

  void updateEvent(CampusEvent original, CampusEvent updated) {
    final index = events.indexOf(original);
    if (index < 0) return;
    events[index] = updated;
    _save();
    update();
  }

  void restoreEvent(CampusEvent event) {
    events.add(event);
    _save();
    update();
  }

  Future<void> clearData() async {
    final preferences = await SharedPreferences.getInstance();
    tasks.clear();
    expenses.clear();
    schedule.clear();
    events.clear();
    attendance.clear();
    grades.clear();
    completedDays.clear();
    for (final key in [
      'tasks',
      'expenses',
      'schedule',
      'events',
      'attendance',
      'grades',
      'completionDays',
    ]) {
      await preferences.remove(key);
    }
    _syncTaskReminders();
    update();
  }

  String exportBackup() => jsonEncode({
    'version': _backupVersion,
    'exportedAt': DateTime.now().toIso8601String(),
    'tasks': tasks.map((task) => task.toJson()).toList(),
    'expenses': expenses.map((expense) => expense.toJson()).toList(),
    'schedule': schedule.map((item) => item.toJson()).toList(),
    'events': events.map((event) => event.toJson()).toList(),
    'attendance': attendance.map((item) => item.toJson()).toList(),
    'grades': grades.map((grade) => grade.toJson()).toList(),
    'completionDays': completedDays.toList(),
  });

  Future<void> importBackup(String source) async {
    if (source.length > 5 * 1024 * 1024) {
      throw const FormatException('Backup is too large. Maximum size is 5 MB.');
    }

    final decoded = jsonDecode(source);
    final version = decoded is Map<String, dynamic> ? decoded['version'] : null;
    if (decoded is! Map<String, dynamic> ||
        version is! int ||
        version < 1 ||
        version > _backupVersion) {
      throw const FormatException('Unsupported backup format.');
    }

    final importedTasks = _decodeList(
      decoded['tasks'],
      (item) => StudentTask.fromJson(item),
    );
    final importedExpenses = _decodeList(
      decoded['expenses'],
      (item) => StudentExpense.fromJson(item),
    );
    final importedSchedule = _decodeList(
      decoded['schedule'],
      (item) => ClassSchedule.fromJson(item),
    );
    final importedEvents = _decodeList(
      decoded['events'],
      (item) => CampusEvent.fromJson(item),
    );
    final importedAttendance = _decodeList(
      decoded['attendance'] ?? [],
      (item) => AttendanceRecord.fromJson(item),
    );
    final importedGrades = _decodeList(
      decoded['grades'] ?? [],
      (item) => CourseGrade.fromJson(item),
    );

    tasks
      ..clear()
      ..addAll(importedTasks);
    expenses
      ..clear()
      ..addAll(importedExpenses);
    schedule
      ..clear()
      ..addAll(importedSchedule);
    events
      ..clear()
      ..addAll(importedEvents);
    attendance
      ..clear()
      ..addAll(importedAttendance);
    grades
      ..clear()
      ..addAll(importedGrades);
    completedDays
      ..clear()
      ..addAll(
        (decoded['completionDays'] as List<dynamic>? ?? []).cast<String>(),
      );
    await _save();
    _syncTaskReminders();
    update();
  }

  void toggleTask(StudentTask task, bool value) {
    final wasDone = task.done;
    task.done = value;
    if (value && !wasDone) {
      completedDays.add(_dayKey(DateTime.now()));
      if (task.repeat != TaskRepeat.none) {
        tasks.add(_nextRecurringTask(task));
      }
    }
    _save();
    _syncTaskReminders();
    update();
  }

  void _syncTaskReminders() {
    LocalNotificationService.instance.syncTasks(tasks);
  }

  void addExpense(
    String title,
    double amount, {
    String category = 'Other',
    String paymentMethod = 'Cash',
    String notes = '',
  }) {
    if (title.trim().isEmpty || amount <= 0) return;
    expenses.insert(
      0,
      StudentExpense(
        title.trim(),
        amount,
        DateTime.now(),
        category: category,
        paymentMethod: paymentMethod,
        notes: notes.trim(),
      ),
    );
    _save();
    update();
  }

  void updateExpense(StudentExpense original, StudentExpense updated) {
    final index = expenses.indexOf(original);
    if (index < 0) return;
    expenses[index] = updated;
    _save();
    update();
  }

  void deleteExpense(StudentExpense expense) {
    expenses.remove(expense);
    _save();
    update();
  }

  void restoreExpense(StudentExpense expense) {
    expenses.add(expense);
    _save();
    update();
  }

  void addGrade(String course, double credits, String grade) {
    final normalizedGrade = _normalizeGrade(grade);
    if (course.trim().isEmpty ||
        credits <= 0 ||
        normalizedGrade != grade.trim().toUpperCase()) {
      return;
    }
    grades.add(
      CourseGrade(
        course: course.trim(),
        credits: credits,
        grade: normalizedGrade,
      ),
    );
    _save();
    update();
  }

  void deleteGrade(CourseGrade grade) {
    grades.remove(grade);
    _save();
    update();
  }

  Future<void> _save() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        'tasks',
        jsonEncode(tasks.map((task) => task.toJson()).toList()),
      );
      await preferences.setString(
        'expenses',
        jsonEncode(expenses.map((expense) => expense.toJson()).toList()),
      );
      await preferences.setString(
        'schedule',
        jsonEncode(schedule.map((item) => item.toJson()).toList()),
      );
      await preferences.setString(
        'events',
        jsonEncode(events.map((event) => event.toJson()).toList()),
      );
      await preferences.setString(
        'attendance',
        jsonEncode(attendance.map((item) => item.toJson()).toList()),
      );
      await preferences.setString(
        'grades',
        jsonEncode(grades.map((grade) => grade.toJson()).toList()),
      );
      await preferences.setStringList('completionDays', completedDays.toList());
      _storageError = null;
    } catch (_) {
      _storageError = 'Your latest change could not be saved locally.';
      update();
    }
  }
}

List<T> _loadList<T>(
  SharedPreferences preferences,
  String key,
  T Function(Map<String, dynamic>) decoder,
) {
  final raw = preferences.getString(key);
  if (raw == null) return [];

  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Expected a list.');
    final validRecords = <T>[];
    var skippedRecord = false;
    for (final item in decoded) {
      try {
        if (item is! Map) throw const FormatException('Invalid record.');
        validRecords.add(decoder(Map<String, dynamic>.from(item)));
      } catch (_) {
        skippedRecord = true;
      }
    }
    if (skippedRecord) {
      StudentStore.instance._storageError ??=
          'Some saved items were damaged and were skipped safely.';
    }
    return validRecords;
  } catch (_) {
    StudentStore.instance._storageError ??=
        'Some saved data could not be read. New data was kept safe.';
    return [];
  }
}

List<T> _decodeList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) decoder,
) {
  if (value is! List || value.length > 10000) {
    throw const FormatException('Invalid or oversized backup records.');
  }
  return value.map((item) {
    if (item is! Map) throw const FormatException('Invalid backup record.');
    return decoder(Map<String, dynamic>.from(item));
  }).toList();
}

String _dayKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

StudentTask _nextRecurringTask(StudentTask task) {
  var nextDate = switch (task.repeat) {
    TaskRepeat.daily => task.dueDate.add(const Duration(days: 1)),
    TaskRepeat.weekly => task.dueDate.add(const Duration(days: 7)),
    TaskRepeat.monthly => _addMonth(task.dueDate),
    TaskRepeat.none => task.dueDate,
  };
  while (!nextDate.isAfter(DateTime.now())) {
    nextDate = switch (task.repeat) {
      TaskRepeat.daily => nextDate.add(const Duration(days: 1)),
      TaskRepeat.weekly => nextDate.add(const Duration(days: 7)),
      TaskRepeat.monthly => _addMonth(nextDate),
      TaskRepeat.none => nextDate,
    };
  }
  return StudentTask(
    title: task.title,
    dueDate: nextDate,
    isExam: task.isExam,
    priority: task.priority,
    repeat: task.repeat,
    category: task.category,
    notes: task.notes,
  );
}

DateTime _addMonth(DateTime date) {
  final targetMonth = date.month + 1;
  final lastDay = DateTime(date.year, targetMonth + 1, 0).day;
  return DateTime(
    date.year,
    targetMonth,
    date.day > lastDay ? lastDay : date.day,
    date.hour,
    date.minute,
  );
}

String _normalizeGrade(String? value) {
  final normalized = value?.trim().toUpperCase();
  return const {'A', 'B', 'C', 'D', 'F'}.contains(normalized) ? normalized! : 'F';
}
