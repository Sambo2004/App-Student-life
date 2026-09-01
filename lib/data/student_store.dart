import 'package:get/get.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum TaskPriority { low, medium, high }

class StudentTask {
  StudentTask({
    required this.title,
    required this.dueDate,
    this.isExam = false,
    this.done = false,
    this.priority = TaskPriority.medium,
    this.category = 'General',
    this.notes = '',
  });
  final String title;
  final DateTime dueDate;
  final bool isExam;
  bool done;
  TaskPriority priority;
  final String category;
  final String notes;

  bool get isOverdue => !done && dueDate.isBefore(DateTime.now());

  Map<String, Object> toJson() => {
    'title': title,
    'dueDate': dueDate.toIso8601String(),
    'isExam': isExam,
    'done': done,
    'priority': priority.name,
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

class StudentStore extends GetxController {
  StudentStore._();
  static final instance = StudentStore._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final preferences = await SharedPreferences.getInstance();
    final savedTasks = preferences.getString('tasks');
    final savedExpenses = preferences.getString('expenses');
    final savedSchedule = preferences.getString('schedule');
    final savedEvents = preferences.getString('events');
    final savedCompletionDays = preferences.getStringList('completionDays');
    if (savedCompletionDays != null) completedDays.addAll(savedCompletionDays);
    if (savedTasks != null) {
      tasks
        ..clear()
        ..addAll(
          (jsonDecode(savedTasks) as List).map(
            (item) => StudentTask.fromJson(item as Map<String, dynamic>),
          ),
        );
    }
    if (savedExpenses != null) {
      expenses
        ..clear()
        ..addAll(
          (jsonDecode(savedExpenses) as List).map(
            (item) => StudentExpense.fromJson(item as Map<String, dynamic>),
          ),
        );
    }
    if (savedSchedule != null) {
      schedule
        ..clear()
        ..addAll(
          (jsonDecode(savedSchedule) as List).map(
            (item) => ClassSchedule.fromJson(item as Map<String, dynamic>),
          ),
        );
    }
    if (savedEvents != null) {
      events
        ..clear()
        ..addAll(
          (jsonDecode(savedEvents) as List).map(
            (item) => CampusEvent.fromJson(item as Map<String, dynamic>),
          ),
        );
    }
    _initialized = true;
    update();
  }

  final tasks = <StudentTask>[];
  final expenses = <StudentExpense>[];
  final schedule = <ClassSchedule>[];
  final events = <CampusEvent>[];
  final completedDays = <String>{};

  int get completedTasks => tasks.where((task) => task.done).length;
  double get totalExpenses =>
      expenses.fold<double>(0, (total, item) => total + item.amount);

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
        category: category,
        notes: notes.trim(),
      ),
    );
    _save();
    update();
  }

  void deleteTask(StudentTask task) {
    tasks.remove(task);
    _save();
    update();
  }

  void updateTask(StudentTask original, StudentTask updated) {
    final index = tasks.indexOf(original);
    if (index < 0) return;
    tasks[index] = updated;
    _save();
    update();
  }

  void restoreTask(StudentTask task) {
    tasks.add(task);
    _save();
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
    completedDays.clear();
    for (final key in ['tasks', 'expenses', 'schedule', 'events']) {
      await preferences.remove(key);
    }
    update();
  }

  String exportBackup() => jsonEncode({
    'version': 1,
    'exportedAt': DateTime.now().toIso8601String(),
    'tasks': tasks.map((task) => task.toJson()).toList(),
    'expenses': expenses.map((expense) => expense.toJson()).toList(),
    'schedule': schedule.map((item) => item.toJson()).toList(),
    'events': events.map((event) => event.toJson()).toList(),
    'completionDays': completedDays.toList(),
  });

  Future<void> importBackup(String source) async {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic> || decoded['version'] != 1) {
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
    completedDays
      ..clear()
      ..addAll(
        (decoded['completionDays'] as List<dynamic>? ?? []).cast<String>(),
      );
    await _save();
    update();
  }

  void toggleTask(StudentTask task, bool value) {
    task.done = value;
    if (value) {
      completedDays.add(_dayKey(DateTime.now()));
    }
    _save();
    update();
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

  Future<void> _save() async {
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
    await preferences.setStringList('completionDays', completedDays.toList());
  }
}

List<T> _decodeList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) decoder,
) {
  if (value is! List) throw const FormatException('Invalid backup records.');
  return value.map((item) {
    if (item is! Map) throw const FormatException('Invalid backup record.');
    return decoder(Map<String, dynamic>.from(item));
  }).toList();
}

String _dayKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
