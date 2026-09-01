import 'package:flutter/material.dart';

import '../data/student_store.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _filter = 'Open';

  Future<void> _confirmDelete(StudentTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Remove "${task.title}" from your task list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    StudentStore.instance.deleteTask(task);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => StudentStore.instance.restoreTask(task),
        ),
      ),
    );
  }

  Future<void> _addTask(BuildContext context) async {
    final title = TextEditingController();
    final category = TextEditingController();
    final notes = TextEditingController();
    var dueDate = DateTime.now().add(const Duration(days: 1));
    var isExam = false;
    var priority = TaskPriority.medium;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add assignment or exam'),
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
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: category,
                  decoration: const InputDecoration(
                    labelText: 'Course or category (optional)',
                  ),
                ),
                TextField(
                  controller: notes,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('This is an exam'),
                  value: isExam,
                  onChanged: (value) => setDialogState(() => isExam = value),
                ),
                DropdownButtonFormField<TaskPriority>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: TaskPriority.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(_priorityLabel(value)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => priority = value);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due date'),
                  subtitle: Text(dateText(dueDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setDialogState(() => dueDate = picked);
                    }
                  },
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
                if (title.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add a task title first.')),
                  );
                  return;
                }
                StudentStore.instance.addTask(
                  title.text,
                  dueDate,
                  isExam,
                  priority: priority,
                  category: category.text,
                  notes: notes.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTask(BuildContext context, StudentTask task) async {
    final title = TextEditingController(text: task.title);
    var dueDate = task.dueDate;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due date'),
                  subtitle: Text(dateText(dueDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setDialogState(() => dueDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty) return;
                StudentStore.instance.updateTask(
                  task,
                  StudentTask(
                    title: title.text.trim(),
                    dueDate: dueDate,
                    isExam: task.isExam,
                    done: task.done,
                    priority: task.priority,
                    category: task.category,
                    notes: task.notes,
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
    index: 2,
    child: AnimatedBuilder(
      animation: StudentStore.instance,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addTask(context),
          icon: const Icon(Icons.add),
          label: const Text('Task'),
        ),
        body: ListView(
          children: [
            const PageHeader(
              title: 'Assignments & exams',
              subtitle: 'Never miss a deadline.',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Open', label: Text('Open')),
                  ButtonSegment(value: 'Done', label: Text('Done')),
                  ButtonSegment(value: 'All', label: Text('All')),
                ],
                selected: {_filter},
                onSelectionChanged: (value) =>
                    setState(() => _filter = value.first),
              ),
            ),
            const SizedBox(height: 12),
            ...StudentStore.instance.tasks
                .where((task) {
                  if (_filter == 'Open') return !task.done;
                  if (_filter == 'Done') return task.done;
                  return true;
                })
                .map(
                  (task) => Dismissible(
                    key: ValueKey(task),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      color: Theme.of(context).colorScheme.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => StudentStore.instance.deleteTask(task),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              value: task.done,
                              onChanged: (value) => StudentStore.instance
                                  .toggleTask(task, value ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.done
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                '${task.isExam ? 'Exam' : 'Assignment'} - ${task.category} - ${_priorityLabel(task.priority)} - Due ${dateText(task.dueDate)}${task.notes.isEmpty ? '' : '\n${task.notes}'}',
                                style: TextStyle(
                                  color: task.isOverdue
                                      ? Theme.of(context).colorScheme.error
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit task',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editTask(context, task),
                          ),
                          IconButton(
                            tooltip: 'Delete task',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmDelete(task),
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

String _priorityLabel(TaskPriority priority) =>
    '${priority.name[0].toUpperCase()}${priority.name.substring(1)}';

String dateText(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
