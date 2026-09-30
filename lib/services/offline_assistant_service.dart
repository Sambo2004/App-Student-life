import '../data/student_store.dart';

/// A private, deterministic assistant that works entirely from local data.
/// It is intentionally not a cloud LLM and never sends student data online.
class OfflineAssistantReply {
  const OfflineAssistantReply(this.message, {this.actionLabel, this.route});
  final String message;
  final String? actionLabel;
  final String? route;
}

class OfflineAssistantService {
  const OfflineAssistantService();

  OfflineAssistantReply reply(String question, StudentStore store) {
    final query = _normalize(question);
    if (query.isEmpty || _matches(query, ['hello', 'hi', 'hey'])) {
      return const OfflineAssistantReply(
        'Hi! I am your private offline assistant. Ask me about your schedule, tasks, spending, GPA, or study plan.',
      );
    }
    if (_matches(query, ['help', 'what can you do', 'menu'])) {
      return const OfflineAssistantReply(
        'I can check today\'s schedule, open or overdue tasks, spending, GPA, attendance, study streak, and build a simple study plan.',
      );
    }
    if (_matches(query, ['today', 'schedule', 'class', 'classes'])) return _todaySchedule(store);
    if (_matches(query, ['overdue', 'late'])) return _overdueTasks(store);
    if (_matches(query, ['task', 'tasks', 'assignment', 'assignments', 'exam', 'deadline'])) return _tasks(store);
    if (_matches(query, ['expense', 'expenses', 'spend', 'spent', 'budget'])) return _expenses(store);
    if (_matches(query, ['gpa', 'grade', 'grades'])) return _grades(store);
    if (_matches(query, ['attendance', 'absence', 'present'])) return _attendance(store);
    if (_matches(query, ['streak', 'habit', 'progress'])) return _streak(store);
    if (_matches(query, ['plan', 'study plan', 'focus', 'prioritize'])) return _studyPlan(store);
    return const OfflineAssistantReply(
      'I did not find that yet. Try "What do I have today?", "Show my open tasks", "How is my GPA?", or "Make a study plan".',
    );
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[!?.,;:/()]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  bool _matches(String query, List<String> words) => words.any(query.contains);

  OfflineAssistantReply _todaySchedule(StudentStore store) {
    final day = _weekdayName(DateTime.now().weekday);
    final classes = store.schedule.where((item) => item.day.toLowerCase() == day.toLowerCase()).toList();
    if (classes.isEmpty) {
      return const OfflineAssistantReply('You have no classes saved for today.', actionLabel: 'Open schedule', route: '/schedule');
    }
    final details = classes.map((item) => '${item.time} ${item.subject}${item.room.isEmpty ? '' : ' - ${item.room}'}').join('\n');
    return OfflineAssistantReply('Your classes today:\n$details', actionLabel: 'Open schedule', route: '/schedule');
  }

  OfflineAssistantReply _tasks(StudentStore store) {
    final tasks = store.tasks.where((task) => !task.done).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (tasks.isEmpty) return const OfflineAssistantReply('Nice work! You have no open tasks right now.', actionLabel: 'Open tasks', route: '/tasks');
    final visible = tasks.take(5).map((task) => '- ${task.title} - ${_shortDate(task.dueDate)}').join('\n');
    final remaining = tasks.length > 5 ? '\n${tasks.length - 5} more in your task list.' : '';
    return OfflineAssistantReply('Your next open tasks:\n$visible$remaining', actionLabel: 'Open tasks', route: '/tasks');
  }

  OfflineAssistantReply _overdueTasks(StudentStore store) {
    final tasks = store.tasks.where((task) => task.isOverdue).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (tasks.isEmpty) return const OfflineAssistantReply('You have no overdue tasks. Keep the momentum!');
    final names = tasks.take(5).map((task) => '- ${task.title} - ${_shortDate(task.dueDate)}').join('\n');
    return OfflineAssistantReply('${tasks.length} overdue task(s):\n$names', actionLabel: 'Open tasks', route: '/tasks');
  }

  OfflineAssistantReply _expenses(StudentStore store) {
    final recent = store.expenses.toList()..sort((a, b) => b.date.compareTo(a.date));
    final details = recent.take(3).map((item) => '- ${item.title}: ${item.amount.toStringAsFixed(2)}').join('\n');
    final total = store.totalExpenses.toStringAsFixed(2);
    return OfflineAssistantReply('Your recorded spending total is $total.\n${details.isEmpty ? 'No expenses have been added yet.' : 'Recent entries:\n$details'}', actionLabel: 'Open expenses', route: '/expenses');
  }

  OfflineAssistantReply _grades(StudentStore store) => OfflineAssistantReply(
        store.grades.isEmpty ? 'No grades yet. Add courses and results to calculate your GPA.' : 'Your current GPA is ${store.gpa.toStringAsFixed(2)} across ${store.grades.length} course(s).',
        actionLabel: 'Open grades', route: '/grades');

  OfflineAssistantReply _attendance(StudentStore store) => OfflineAssistantReply(
        store.attendance.isEmpty ? 'No attendance records yet.' : 'Your attendance rate is ${(store.attendanceRate * 100).toStringAsFixed(0)}% across ${store.attendance.length} record(s).',
        actionLabel: 'Open attendance', route: '/attendance');

  OfflineAssistantReply _streak(StudentStore store) => OfflineAssistantReply(
        'Your current study streak is ${store.studyStreak} day(s), with ${store.completedTasks} completed task(s).',
        actionLabel: 'Open study streak', route: '/study-streak');

  OfflineAssistantReply _studyPlan(StudentStore store) {
    final tasks = store.tasks.where((task) => !task.done).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final top = tasks.take(3).toList();
    if (top.isEmpty) return const OfflineAssistantReply('Today\'s plan: review your schedule, then set one new study goal.');
    final plan = top.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value.title} (${_shortDate(entry.value.dueDate)})').join('\n');
    return OfflineAssistantReply('Your priority study plan:\n$plan\n\nStart with item 1 and use the focus timer for one distraction-free session.', actionLabel: 'Start focus timer', route: '/pomodoro');
  }

  String _weekdayName(int weekday) => const <int, String>{1: 'Monday', 2: 'Tuesday', 3: 'Wednesday', 4: 'Thursday', 5: 'Friday', 6: 'Saturday', 7: 'Sunday'}[weekday]!;
  String _shortDate(DateTime date) => '${date.day}/${date.month}';
}
