import '../student_store.dart';

/// Data boundary for task operations.
///
/// This adapter intentionally delegates to the existing store during the
/// migration. A database-backed implementation can replace it later without
/// requiring the Tasks page to know how data is persisted.
class TaskRepository {
  TaskRepository._(this._store);

  static final instance = TaskRepository._(StudentStore.instance);

  final StudentStore _store;

  List<StudentTask> get tasks => _store.tasks;

  void addTask(
    String title,
    DateTime date,
    bool exam, {
    TaskPriority priority = TaskPriority.medium,
    String category = 'General',
    String notes = '',
  }) => _store.addTask(
    title,
    date,
    exam,
    priority: priority,
    category: category,
    notes: notes,
  );

  void deleteTask(StudentTask task) => _store.deleteTask(task);

  void updateTask(StudentTask original, StudentTask updated) =>
      _store.updateTask(original, updated);

  void restoreTask(StudentTask task) => _store.restoreTask(task);

  void toggleTask(StudentTask task, bool value) => _store.toggleTask(task, value);
}
